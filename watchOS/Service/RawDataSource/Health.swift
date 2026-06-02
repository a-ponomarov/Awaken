//
//  Health.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import HealthKit

@Observable
/// Manages HealthKit authorization and heart-rate/sleep data access on Apple Watch.
final class HealthSource {

  /// Receives heart-rate updates from the active HealthKit query.
  protocol Delegate: AnyObject {

    /// Called when a new heart-rate sample is received.
    /// - Parameters:
    ///   - bpm: The heart rate in beats per minute.
    ///   - date: The sample timestamp.
    func heartRateDidUpdate(bpm: Double, date: Date)

  }

  weak var delegate: Delegate?

  private(set) var lastHeartRate: Double?

  private let store = HKHealthStore()

  private var anchor: HKQueryAnchor?
  private var query: HKAnchoredObjectQuery?

  private let sleepType: HKCategoryType = {
    guard let type = HKObjectType.categoryType(
      forIdentifier: .sleepAnalysis
    ) else {
      preconditionFailure("Sleep analysis type is unavailable")
    }
    return type
  }()

  private let heartRateType: HKQuantityType = {
    guard let type = HKObjectType.quantityType(
      forIdentifier: .heartRate
    ) else {
      preconditionFailure("Heart rate type is unavailable")
    }
    return type
  }()

  /// Requests HealthKit read authorization for heart-rate and sleep data.
  func requestAuthorization() async {
    do {
      guard HKHealthStore.isHealthDataAvailable() else { return }
      let types: Set<HKSampleType> = [heartRateType, sleepType]
      try await store.requestAuthorization(toShare: [], read: types)
    } catch {
      print(error.localizedDescription)
    }
  }

  /// Returns whether the current HealthKit read authorization status is determined.
  func isAuthorizationDetermined() async -> Bool {
    let types: Set<HKSampleType> = [heartRateType, sleepType]
    do {
      let status = try await store.statusForAuthorizationRequest(toShare: [], read: types)
      return status == .unnecessary
    } catch {
      return false
    }
  }

  /// Starts heart-rate observation and assigns the provided delegate.
  /// - Parameter delegate: The receiver of heart-rate updates.
  func start(delegate: Delegate) {
    self.delegate = delegate
    start()
  }

  /// Starts heart-rate observation using the current delegate.
  func start() {
    if let query { store.stop(query) }
    query = nil
    anchor = nil
    queryRate()
  }

  private func queryRate() {
    let date = Date().addingTimeInterval(-61)
    let predicate = HKQuery.predicateForSamples(
      withStart: date,
      end: nil,
      options: .init()
    )
    let query = HKAnchoredObjectQuery(
      type: heartRateType,
      predicate: predicate,
      anchor: anchor,
      limit: HKObjectQueryNoLimit
    ) { [unowned self] _, samples, _, newAnchor, _ in
      Task { [unowned self] in await process(newAnchor: newAnchor, samples: samples) }
    }
    query.updateHandler = { [unowned self] _, samples, _, newAnchor, _ in
      Task { [unowned self] in await process(newAnchor: newAnchor, samples: samples) }
    }
    self.query = query
    store.execute(query)
  }

  /// Loads sleep stages overlapping the provided date range.
  /// - Parameters:
  ///   - startDate: The start of the query interval.
  ///   - endDate: The end of the query interval.
  /// - Returns: Sleep stage ranges returned by HealthKit.
  func fetchSleepStages(from startDate: Date, to endDate: Date) async throws -> [RangeStage] {
    let predicate = HKQuery.predicateForSamples(
      withStart: startDate,
      end: endDate,
      options: []
    )

    let predicates = [
      HKSamplePredicate.sample(
        type: HKCategoryType(.sleepAnalysis),
        predicate: predicate
      )
    ]

    let query = HKSampleQueryDescriptor(predicates: predicates, sortDescriptors: [])
    let samples = try await query.result(for: store) as? [HKCategorySample]

    let stages = samples?.compactMap { sample in
      Stage(sleepAnalysisRaw: sample.value).map { stage in
        RangeStage(
          startDate: sample.startDate,
          endDate: sample.endDate,
          stage: stage
        )
      }
    }

    return stages ?? []
  }

  private func process(newAnchor: HKQueryAnchor?, samples: [HKSample]?) {
    anchor = newAnchor
    samples?
      .compactMap { $0 as? HKQuantitySample }
      .forEach {
        let bpm = $0.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
        lastHeartRate = bpm
        delegate?.heartRateDidUpdate(bpm: bpm, date: $0.startDate)
      }
  }

}
