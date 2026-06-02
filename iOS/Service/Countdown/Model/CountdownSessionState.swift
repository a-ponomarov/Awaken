//
//  CountdownSessionState.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

struct CountdownSessionState: Sendable {

  var status: TimeStatus
  var alarmID: UUID?
  var remainingDuration: TimeInterval
  var plannedDuration: TimeInterval
  var startedAt: Date?
  var endDate: Date?

}
