//
//  Classifier.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

@preconcurrency import CoreML

/// Manages sleep-stage model loading, training, and prediction.
actor Classifier {

  private var personalized: MLModel?
  private var trainingTask: Task<Void, Never>?
  private let persistence: Persistence
  private let healthSource: HealthSource
  private let logger: Logger

  private let directory: URL = {
    let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    return urls[0]
  }()

  private var initialURL: URL {
    get throws {
      guard
        let url = Bundle.main.url(
          forResource: "SleepStageClassifier",
          withExtension: ".mlmodelc"
        )
      else {
        throw PersonalizationError.modelLoadFailed
      }
      return url
    }
  }

  private var personalizedURL: URL {
    directory.appendingPathComponent("PersonalizedSleepStageClassifier.mlmodelc")
  }

  private var tempPersonalizedURL: URL {
    directory.appendingPathComponent("TempPersonalizedSleepStageClassifier.mlmodelc")
  }

  /// Creates a classifier and attempts to load any personalized model.
  init(
    persistence: Persistence,
    healthSource: HealthSource,
    logger: Logger
  ) {
    self.persistence = persistence
    self.healthSource = healthSource
    self.logger = logger
    Task { await loadPersonalized() }
  }

  func model() throws -> MLModel {
    if let personalized {
      return personalized
    } else {
      return try initial()
    }
  }

  private func initial() throws -> MLModel {
    let configuration = MLModelConfiguration()
    return try MLModel(contentsOf: initialURL, configuration: configuration)
  }

  private func loadPersonalized() {
    guard FileManager.default.fileExists(atPath: personalizedURL.path) else { return }
    do {
      personalized = try MLModel(contentsOf: personalizedURL)
    } catch {
      logger.log(.error(PersonalizationError.modelLoadFailed.localizedDescription))
    }
  }

    /// Discards the personalized model and falls back to the bundled model.
  func resetToInitial() {
    personalized = nil
    try? FileManager.default.removeItem(at: personalizedURL)
  }

  nonisolated
  /// Starts background training for finished sleep sessions not yet used for personalization.
  func train() {
    Task { await startTrainingIfNeeded() }
  }

  private func startTrainingIfNeeded() {
    guard trainingTask == nil else { return }
    trainingTask = Task(priority: .background) { [weak self] in
      await self?.runTraining()
    }
  }

  private func runTraining() async {
    defer { trainingTask = nil }

    let ids = await persistence.finishedSleepIDsNotUsedForPersonalization()
    for id in ids {
      do {
        try await train(for: id)
      } catch let error as PersonalizationError {
        logger.log(.error(error.localizedDescription))
      } catch {
        logger.log(.error(PersonalizationError.modelUpdateFailed.localizedDescription))
      }
    }
  }

  private func train(for sleepID: Date) async throws {
    let snapshots = await persistence
      .snapshots(forSleepID: sleepID)

    guard !snapshots.isEmpty else {
      await persistence.deleteSleep(id: sleepID)
      return
    }

    guard let startDate = snapshots.map(\.timestamp).min(),
          let endDate = snapshots.map(\.timestamp).max()
    else { throw PersonalizationError.insufficientData }

    let stages = try await healthSource.fetchSleepStages(from: startDate, to: endDate)
    guard !stages.isEmpty else {
      await persistence.markSleepSkippedForPersonalization(id: sleepID)
      return
    }
    let selectedStages = Array(Set(stages.map(\.stage.rawValue))).sorted()
    if !selectedStages.isEmpty {
      logger.log(.selectedHealthKitSleepStages(selectedStages))
    }

    let expectedFeatureCount = 7
    let features = snapshots.compactMap { snapshot -> StageFeatures? in
      guard let match = stages.first(where: { $0.contains(snapshot.timestamp) }) else {
        return nil
      }
      guard !snapshot.features.isEmpty,
            snapshot.features.count == expectedFeatureCount,
            snapshot.features.allSatisfy({ $0.isFinite })
      else { return nil }
      return StageFeatures(stage: match.stage, features: snapshot.features)
    }

    guard !features.isEmpty else {
      await persistence.markSleepSkippedForPersonalization(id: sleepID)
      return
    }
    logger.log(.matchedStoredFeaturesToHealthKitStageLabels)
    let byStage = Dictionary(grouping: features, by: \.stage)
    for stage in Stage.allCases {
      if let sample = byStage[stage]?.first {
        logger.log(.personalizationSample(stage: stage.rawValue, features: sample.features))
      }
    }
    try await train(with: features)
    loadPersonalized()
    logger.log(.personalized)
    await persistence.markSleepUsedForPersonalization(id: sleepID)
  }

  private func train(with features: [StageFeatures]) async throws {
    let trainingData = try MLArrayBatchProvider.from(features: features)
    guard trainingData.count > 0 else { throw PersonalizationError.insufficientData }

    let currentModelURL = personalized != nil ? personalizedURL : try initialURL
    let personalizedURL = personalizedURL
    let tempPersonalizedURL = tempPersonalizedURL

    try await withCheckedThrowingContinuation {
      (continuation: CheckedContinuation<Void, Error>) in
      do {
        let updateTask = try MLUpdateTask(
          forModelAt: currentModelURL,
          trainingData: trainingData
        ) { updateContext in
          if let error = updateContext.task.error {
            continuation.resume(throwing: error)
            return
          }

          do {
            try FileManager.default.createDirectory(
              at: tempPersonalizedURL.deletingLastPathComponent(),
              withIntermediateDirectories: true,
              attributes: nil
            )

            try updateContext.model.write(to: tempPersonalizedURL)

            _ = try FileManager.default.replaceItem(
              at: personalizedURL,
              withItemAt: tempPersonalizedURL,
              backupItemName: nil,
              options: [],
              resultingItemURL: nil
            )
            continuation.resume()
          } catch {
            continuation.resume(throwing: PersonalizationError.modelUpdateFailed)
          }
        }
        updateTask.resume()
      } catch {
        continuation.resume(throwing: PersonalizationError.modelUpdateFailed)
      }
    }
  }

  /// Predicts a sleep stage and its confidence from extracted feature values.
  /// - Parameter features: The feature vector to classify.
  /// - Returns: The predicted stage identifier and its probability.
  func predict(features: [Double]) async throws -> (stage: String, probability: Double) {
    let prediction = try await model().prediction(
      from: MLDictionaryFeatureProvider(
        dictionary: ["features": MLMultiArray.from(features: features)]
      )
    )
    let stage = prediction.featureValue(for: "stage")?.stringValue ?? ""
    let probabilities = prediction.featureValue(
      for: "stageProbs"
    )?.dictionaryValue as? [String: Double] ?? [:]
    let probability = probabilities[stage] ?? 0

    return (stage, probability)
  }

}

nonisolated
extension MLArrayBatchProvider {

  fileprivate static func from(features: [StageFeatures]) throws -> MLArrayBatchProvider {
    let providers = try features.compactMap { sample -> MLFeatureProvider? in
      let featureArray = try MLMultiArray.from(features: sample.features)
      let dictionary = ["features": featureArray, "stage": sample.stage.rawValue] as [String: Any]
      return try? MLDictionaryFeatureProvider(dictionary: dictionary)
    }
    return MLArrayBatchProvider(array: providers)
  }

}

nonisolated
extension MLMultiArray {

  fileprivate static func from(features: [Double]) throws -> MLMultiArray {
    let shape = [NSNumber(value: features.count)]
    let multiArray = try MLMultiArray(shape: shape, dataType: .double)
    for (index, feature) in features.enumerated() {
      multiArray[index] = NSNumber(value: feature.isFinite ? feature : 0.0)
    }
    return multiArray
  }

}

/// Errors that can occur while loading or personalizing the sleep-stage model.
enum PersonalizationError: Error {

  case insufficientData
  case modelUpdateFailed
  case modelLoadFailed

}

extension PersonalizationError: LocalizedError {

  var errorDescription: String? {
    switch self {
    case .insufficientData:
      return String(localized: "There isn't enough sleep data to personalize the sleep stage model.", comment: "Classifier error: not enough training data")
    case .modelUpdateFailed:
      return String(localized: "The sleep stage model couldn't be personalized.", comment: "Classifier error: personalization (training) failed")
    case .modelLoadFailed:
      return String(localized: "The personalized sleep stage model isn't available right now.", comment: "Classifier error: personalized model can't be loaded")
    }
  }

}

/// A labeled feature vector used for model personalization.
struct StageFeatures {

  let stage: Stage
  let features: [Double]

}
