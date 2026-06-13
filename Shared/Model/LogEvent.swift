//
//  LogEvent.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

nonisolated
enum LogEvent: Codable, Equatable {

  case planned(Date)
  case started
  case relaunch
  case wakeUp
  case end(code: String)
  case prediction(stage: String, probability: Double)

  case motion(mean: Double, recent3Mean: Double, recent3Range: Double)
  case cardio(standardDeviation: Double, range: Double, mean: Double, last: Double)
  case selectedHealthKitSleepStages([String])
  case matchedStoredFeaturesToHealthKitStageLabels
  case personalizationSample(stage: String, features: [Double])
  case personalized
  case error(String)

  var icon: String {
    switch self {
    case .planned:
      return "hourglass.tophalf.filled"
    case .end:
      return "hourglass.bottomhalf.filled"
    case .started:
      return "gamecontroller.fill"
    case .relaunch:
      return "gearshape.circle.fill"
    case .wakeUp:
      return "alarm.waves.left.and.right.fill"
    case .prediction:
      return "gear.circle.fill"
    case .motion:
      return "move.3d"
    case .cardio:
      return "heart.badge.bolt.fill"
    case .selectedHealthKitSleepStages:
      return "list.bullet.circle.fill"
    case .matchedStoredFeaturesToHealthKitStageLabels:
      return "point.3.connected.trianglepath.dotted"
    case .personalizationSample:
      return "brain.filled.head.profile"
    case .personalized:
      return "brain.fill"
    case .error:
      return "exclamationmark.triangle.fill"
    }
  }

  var text: String {
    switch self {
    case .planned(let date):
      return "alarm planned at \(date.formatted(date: .numeric, time: .standard))"
    case .started:
      return "alarm started"
    case .end:
      return "alarm ended"
    case .relaunch:
      return "relaunch"
    case .wakeUp:
      return "alarm"
    case .prediction(let stage, _):
      return "\(stage) stage"
    case .motion(let mean, let recent3Mean, let recent3Range):
      return String(
        format: "motion: [%.2f %.2f %.2f]",
        mean,
        recent3Mean,
        recent3Range
      )
    case .cardio(let standardDeviation, let range, let mean, let last):
      return String(
        format: "cardio: [%.2f %.2f %.2f %.2f]",
        range,
        mean,
        last,
        standardDeviation
      )
    case .selectedHealthKitSleepStages(let stages):
      return "selected HealthKit sleep stages: \(stages.joined(separator: ", "))"
    case .matchedStoredFeaturesToHealthKitStageLabels:
      return "matched stored features to HealthKit stage labels"
    case .personalizationSample(let stage, let features):
      let values = features.map { String(format: "%.0f", $0) }.joined(separator: " ")
      let displayStage = stage.prefix(1).uppercased() + stage.dropFirst().lowercased()
      return "\(displayStage) • [\(values)]"
    case .personalized:
      return "model personalization completed"
    case .error(let message):
      return message
    }
  }

}
