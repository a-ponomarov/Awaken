//
//  ResumeIntent.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AppIntents

import AlarmKit

struct ResumeIntent: LiveActivityIntent {

  static let title: LocalizedStringResource = "Resume"
  static let description = IntentDescription("Resume a countdown")

  @Parameter(title: "alarmID")
  var alarmID: String

  init() {
    alarmID = AlarmIdentifiers.time.uuidString
  }

  init(alarmID: String) {
    self.alarmID = alarmID
  }

  func perform() throws -> some IntentResult {
    guard let alarmID = UUID(uuidString: alarmID) else {
      return .result()
    }

    try AlarmManager.shared.resume(id: alarmID)
    return .result()
  }

}
