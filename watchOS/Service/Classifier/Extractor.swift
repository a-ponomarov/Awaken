//
//  Extractor.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import Accelerate
import Darwin

/// A heart-rate sample captured at a specific timestamp.
public struct HeartRate: Sendable, Equatable {

  /// The sample timestamp, in seconds.
  let timestamp: Double

  /// The measured heart rate value.
  let value: Double

}

nonisolated
/// A 3-axis acceleration sample captured at a specific timestamp.
public struct Acceleration: Sendable, Equatable {

  /// The sample timestamp, in seconds.
  let timestamp: Double

  /// The acceleration value on the x-axis.
  let x: Double

  /// The acceleration value on the y-axis.
  let y: Double

  /// The acceleration value on the z-axis.
  let z: Double

  var magnitude: Double {
    sqrt(x * x + y * y + z * z)
  }

}

nonisolated
extension Array where Element == Acceleration {

  fileprivate var timestamps: [Double] { map(\.timestamp) }
  fileprivate var xValues: [Double] { map(\.x) }
  fileprivate var yValues: [Double] { map(\.y) }
  fileprivate var zValues: [Double] { map(\.z) }
  fileprivate var magnitudes: [Double] { map(\.magnitude) }

}

extension Array where Element == HeartRate {

  fileprivate var timestamps: [Double] { map(\.timestamp) }
  fileprivate var values: [Double] { map(\.value) }

}

nonisolated
extension Array where Element == Double {

  fileprivate var standardDeviation: Double {
    guard count > 1 else { return 0.0 }

    var mean: Double = 0
    vDSP_meanvD(self, 1, &mean, vDSP_Length(count))

    var centeredValues = [Double](repeating: 0, count: count)
    var negativeMean = -mean
    vDSP_vsaddD(self, 1, &negativeMean, &centeredValues, 1, vDSP_Length(count))

    var squaredValues = [Double](repeating: 0, count: count)
    vDSP_vmulD(centeredValues, 1, centeredValues, 1, &squaredValues, 1, vDSP_Length(count))

    var variance: Double = 0
    vDSP_meanvD(squaredValues, 1, &variance, vDSP_Length(count))
    return sqrt(variance)
  }

  fileprivate var range: Double {
    guard count > 1,
          let minimum = self.min(),
          let maximum = self.max()
    else { return 0.0 }
    return maximum - minimum
  }

  fileprivate var mean: Double {
    guard !isEmpty else { return 0.0 }
    var mean: Double = 0
    vDSP_meanvD(self, 1, &mean, vDSP_Length(count))
    return mean
  }

  fileprivate var absoluteValues: [Double] {
    var result = [Double](repeating: 0, count: count)
    vDSP_vabsD(self, 1, &result, 1, vDSP_Length(count))
    return result
  }

  fileprivate func applyMovingAverageFilter(windowSize: Int) -> [Double] {
    guard count >= windowSize else { return self }

    var filteredSignal = [Double]()
    filteredSignal.reserveCapacity(count)
    var windowSum = 0.0

    for index in 0 ..< windowSize {
      windowSum += self[index]
    }
    filteredSignal.append(windowSum / Double(windowSize))

    for index in windowSize ..< count {
      windowSum = windowSum - self[index - windowSize] + self[index]
      filteredSignal.append(windowSum / Double(windowSize))
    }

    return filteredSignal
  }

}

nonisolated
private protocol Extractor {

  associatedtype SampleType
  var windowSize: Double { get }

}

nonisolated
extension Extractor {

  fileprivate func findTimeWindowIndices(
    in timestamps: [Double],
    around epochTime: Double
  ) -> [Int] {
    let windowStart = epochTime - windowSize
    let windowEnd = epochTime

    return timestamps.enumerated()
      .filter { $1 >= windowStart && $1 <= windowEnd }
      .map(\.0)
  }

  fileprivate func generateUniformTimestamps(
    from startTime: Double,
    to endTime: Double,
    step: Double
  ) -> [Double] {
    Array(stride(from: startTime, through: endTime, by: step))
  }

  fileprivate func linearInterpolation(
    sourcePoints: [Double],
    sourceValues: [Double],
    queryPoints: [Double]
  ) -> [Double] {
    precondition(sourcePoints.count == sourceValues.count)
    guard !sourcePoints.isEmpty else { return [] }

    var currentIndex = 0
    var result = [Double](repeating: 0, count: queryPoints.count)

    for (index, queryPoint) in queryPoints.enumerated() {
      while currentIndex < sourcePoints.count - 2 &&
          sourcePoints[currentIndex + 1] < queryPoint {
        currentIndex += 1
      }

      let leftPoint = sourcePoints[currentIndex]
      let rightPoint = sourcePoints[currentIndex + 1]
      let leftValue = sourceValues[currentIndex]
      let rightValue = sourceValues[currentIndex + 1]
      let interpolationFactor = (queryPoint - leftPoint) / (rightPoint - leftPoint)

      result[index] = leftValue + interpolationFactor * (rightValue - leftValue)
    }
    return result
  }

  fileprivate func resampleToUniformGrid(
    timestamps: [Double],
    values: [Double],
    timeStep: Double
  ) -> ([Double], [Double]) {
    let (uniformTimestamps, valuesArrays) = resampleMultivariateToUniformGrid(
      timestamps: timestamps,
      valuesArrays: [values],
      timeStep: timeStep
    )
    return (uniformTimestamps, valuesArrays.first ?? [])
  }

  fileprivate func resampleMultivariateToUniformGrid(
    timestamps: [Double],
    valuesArrays: [[Double]],
    timeStep: Double
  ) -> ([Double], [[Double]]) {
    guard !timestamps.isEmpty, !valuesArrays.isEmpty else { return ([], []) }
    guard valuesArrays.allSatisfy({ $0.count == timestamps.count }) else { return ([], []) }
    guard let startTime = timestamps.min(),
          let endTime = timestamps.max()
    else { return ([], []) }

    let uniformTimestamps = generateUniformTimestamps(
      from: startTime,
      to: endTime,
      step: timeStep
    )
    guard !uniformTimestamps.isEmpty else { return ([], []) }

    let uniformValuesArrays = valuesArrays.map { values in
      linearInterpolation(
        sourcePoints: timestamps,
        sourceValues: values,
        queryPoints: uniformTimestamps
      )
    }

    return (uniformTimestamps, uniformValuesArrays)
  }

  fileprivate func aggregateInWindows<T, R>(
    _ data: [T],
    windowSize: Int,
    aggregator: ([T]) -> R
  ) -> [R] {
    guard data.count >= windowSize else { return [] }

    let windowCount = data.count / windowSize
    var results = [R]()
    results.reserveCapacity(windowCount)

    for window in 0 ..< windowCount {
      let startIndex = window * windowSize
      let endIndex = min(startIndex + windowSize, data.count)
      let windowData = Array(data[startIndex ..< endIndex])
      results.append(aggregator(windowData))
    }
    return results
  }

  fileprivate func generateEpochTimestamps(
    from timestamps: [Double],
    epochCount: Int
  ) -> [Double] {
    guard epochCount > 0 else { return [] }
    guard let startTime = timestamps.first, let endTime = timestamps.last else { return [] }
    guard epochCount > 1 else { return [startTime] }

    var epochTimestamps = [Double](repeating: 0, count: epochCount)
    let timeStep = (endTime - startTime) / Double(epochCount - 1)
    var currentTime = startTime
    var step = timeStep
    vDSP_vrampD(&currentTime, &step, &epochTimestamps, 1, vDSP_Length(epochCount))

    return epochTimestamps
  }

}

nonisolated
/// Extracts motion-based features from acceleration samples.
public struct AccelerationExtractor: Extractor {

  /// The sample type consumed by this extractor.
  public typealias SampleType = Acceleration

  /// The analysis window size, in seconds.
  public let windowSize: Double
  private let sampleRate: Double
  private let highCutoffFrequency: Double
  private let epochLength: Int
  private let log: (@Sendable (LogEvent) -> Void)?

  private static let binWidth = 5.0 / 128.0
  private static let maxEdge = 5.0
  private static let maxBinValue = 129

  /// Creates an acceleration feature extractor.
  /// - Parameters:
  ///   - windowSize: The analysis window size, in seconds.
  ///   - sampleRate: The expected sample rate, in Hz.
  ///   - highCutoffFrequency: The cutoff used for smoothing calculations, in Hz.
  ///   - epochLength: The epoch length used for aggregation, in seconds.
  init(
    windowSize: Double,
    sampleRate: Double = 50.0,
    highCutoffFrequency: Double = 8.8,
    epochLength: Int = 10,
    log: (@Sendable (LogEvent) -> Void)? = nil
  ) {
    self.windowSize = windowSize
    self.sampleRate = sampleRate
    self.highCutoffFrequency = highCutoffFrequency
    self.epochLength = epochLength
    self.log = log
  }

  /// Extracts acceleration features at the provided epoch timestamps.
  /// - Parameters:
  ///   - samples: Source acceleration samples.
  ///   - epochTimestamps: Epoch timestamps, in seconds, where features are computed.
  /// - Returns: Flattened feature values for all epochs.
  public func extractFeatures(
    from samples: [Acceleration],
    epochTimestamps: [Double]
  ) -> [Double] {
    guard !samples.isEmpty else { return [] }

    let interpolatedSamples = createInterpolatedSamples(from: samples)
    let activityData = calculateActivityCounts(from: interpolatedSamples)
    let activityTimestamps = activityData.map { $0.time }
    let activityCounts = activityData.map { $0.counts }

    var features = [Double]()
    features.reserveCapacity(epochTimestamps.count * 3)

    for epochTime in epochTimestamps {
      let windowIndices = findTimeWindowIndices(in: activityTimestamps, around: epochTime)
      let windowValues = windowIndices.map { activityCounts[$0] }

      let mean = windowValues.mean
      features.append(mean)

      let recent3Count = min(3, windowValues.count)
      let recent3Slice = recent3Count > 0 ? Array(windowValues.suffix(recent3Count)) : []

      let recentMean = recent3Slice.mean
      let recentRange = recent3Slice.range
      features.append(recentMean)
      features.append(recentRange)

      log?(.motion(mean: mean, recent3Mean: recentMean, recent3Range: recentRange))
    }

    return features
  }

  private func createInterpolatedSamples(from samples: [Acceleration]) -> [Acceleration] {
    let (timestamps, values) = resampleMultivariateToUniformGrid(
      timestamps: samples.timestamps,
      valuesArrays: [samples.xValues, samples.yValues, samples.zValues],
      timeStep: 1.0 / sampleRate
    )

    return timestamps.indices.map { index in
      Acceleration(
        timestamp: timestamps[index],
        x: values[0][index],
        y: values[1][index],
        z: values[2][index]
      )
    }
  }

  private func calculateActivityCounts(
    from samples: [Acceleration]
  ) -> [(time: Double, counts: Double)] {
    guard !samples.isEmpty else { return [] }

    let filtered = samples.magnitudes
      .applyMovingAverageFilter(
        windowSize: max(1, Int(sampleRate / (2.0 * highCutoffFrequency)))
      )
      .absoluteValues

    let binned = digitizeSignal(filtered)
    let epochCounts = aggregateToEpochs(binned)

    return zip(
      generateEpochTimestamps(from: samples.timestamps, epochCount: epochCounts.count),
      epochCounts
    ).map { (time: $0, counts: $1) }
  }

  private func digitizeSignal(_ signal: [Double]) -> [Int] {
    signal.map { sample in
      if sample >= Self.maxEdge { Self.maxBinValue }
      else if sample <= 0 { 1 }
      else { Int(sample / Self.binWidth) + 1 }
    }
  }

  private func aggregateToEpochs(_ binnedData: [Int]) -> [Double] {
    guard binnedData.count >= Int(sampleRate) else { return [] }

    let samplesPerSecond = Int(sampleRate)
    let secondMaximums = aggregateInWindows(
      binnedData,
      windowSize: samplesPerSecond
    ) { window in
      window.max() ?? 0
    }

    let epochs = aggregateInWindows(secondMaximums, windowSize: epochLength) { window in
      Double(window.reduce(0, +))
    }

    return epochs
  }

}

nonisolated
/// Extracts heart-rate-based features from heart-rate samples.
public struct HeartRateExtractor: Extractor {

  /// The sample type consumed by this extractor.
  public typealias SampleType = HeartRate

  /// The analysis window size, in seconds.
  public let windowSize: Double
  private static let downsamplingInterval = 60.0
  private let log: (@Sendable (LogEvent) -> Void)?

  /// Creates a heart-rate feature extractor.
  /// - Parameter windowSize: The analysis window size, in seconds.
  init(
    windowSize: Double,
    log: (@Sendable (LogEvent) -> Void)? = nil
  ) {
    self.windowSize = windowSize
    self.log = log
  }

  /// Extracts heart-rate features at the provided epoch timestamps.
  /// - Parameters:
  ///   - samples: Source heart-rate samples.
  ///   - epochTimestamps: Epoch timestamps, in seconds, where features are computed.
  /// - Returns: Flattened feature values for all epochs.
  public func extractFeatures(from samples: [HeartRate], epochTimestamps: [Double]) -> [Double] {
    guard !samples.isEmpty else { return [] }

    return epochTimestamps.flatMap { epochTime in
      let windowStart = epochTime - windowSize
      let windowMid = epochTime - windowSize / 2
      let windowEnd = epochTime

      let leftPoint = findNearestPoint(to: windowStart, in: samples)
      let midPoint = findNearestPoint(to: windowMid, in: samples)
      let rightPoint = findNearestPoint(to: windowEnd, in: samples)

      let values = [leftPoint.value, midPoint.value, rightPoint.value]

      let sd = values.standardDeviation
      let range = values.range
      let mean = values.mean
      let last = rightPoint.value

      log?(.cardio(standardDeviation: sd, range: range, mean: mean, last: last))

      return [sd, range, mean, last]
    }
  }

  private func findNearestPoint(to targetTime: Double, in samples: [HeartRate]) -> HeartRate {
    guard !samples.isEmpty else {
      return HeartRate(timestamp: targetTime, value: 0.0)
    }

    var nearestSample = samples[0]
    var minDistance = abs(samples[0].timestamp - targetTime)

    for sample in samples {
      let distance = abs(sample.timestamp - targetTime)
      if distance < minDistance {
        minDistance = distance
        nearestSample = sample
      }
    }

    return nearestSample
  }

}
