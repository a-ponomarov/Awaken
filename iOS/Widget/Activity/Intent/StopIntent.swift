//
//  StopIntent.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AppIntents

import AlarmKit

struct StopIntent: LiveActivityIntent {

  static let title: LocalizedStringResource = "Stop"
  static let description = IntentDescription("Stop an alert")
  static let openAppWhenRun = true

  @Parameter(title: "alarmID")
  var alarmID: String

  init() {
    alarmID = AlarmIdentifiers.time.uuidString
  }

  init(alarmID: String) {
    self.alarmID = alarmID
  }

  func perform() async throws -> some IntentResult {
    guard let alarmID = UUID(uuidString: alarmID) else {
      return .result()
    }

    try AlarmManager.shared.stop(id: alarmID)
    return .result()
  }

}
