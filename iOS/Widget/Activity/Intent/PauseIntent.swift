//
//  PauseIntent.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AlarmKit
import AppIntents

nonisolated func resolveCountdownAlarmID(_ alarmID: String) -> UUID? {
  UUID(uuidString: alarmID)
}

struct PauseIntent: LiveActivityIntent {

  static let title: LocalizedStringResource = "Pause"
  static let description = IntentDescription("Pause a countdown")

  @Parameter(title: "alarmID")
  var alarmID: String

  init() {
    alarmID = AlarmIdentifiers.time.uuidString
  }

  init(alarmID: String) {
    self.alarmID = alarmID
  }

  func perform() throws -> some IntentResult {
    guard let alarmID = resolveCountdownAlarmID(alarmID) else {
      return .result()
    }

    try AlarmManager.shared.pause(id: alarmID)
    return .result()
  }

}
