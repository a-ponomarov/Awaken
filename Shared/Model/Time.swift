//
//  Time.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

enum TimeStatus: String, Codable, Sendable {

  case idle
  case running
  case paused

}

struct TimeRecord: Identifiable, Hashable, Sendable {

  let id: UUID
  let taskName: String
  let status: TimeStatus
  let duration: TimeInterval
  let alarmID: UUID?
  let remainingDuration: TimeInterval
  let plannedDuration: TimeInterval
  let startedAt: Date?
  let endDate: Date?
  let endedAt: Date?

}

extension TimeRecord {

  nonisolated static func elapsedDuration(
    endDate: Date?,
    plannedDuration: TimeInterval,
    remainingDuration: TimeInterval
  ) -> TimeInterval {
    if let endDate {
      let remaining = max(0, endDate.timeIntervalSinceNow)
      return min(plannedDuration, max(0, plannedDuration - remaining))
    }
    return min(plannedDuration, max(0, plannedDuration - remainingDuration))
  }

}

@Model
final class Time {

  var id = UUID()
  var taskName: String = ""
  var statusRaw: String = TimeStatus.idle.rawValue
  var duration: TimeInterval = 0
  var isCurrent: Bool = true
  var alarmID: UUID?
  var remainingDuration: TimeInterval = 0
  var plannedDuration: TimeInterval = 0
  var startedAt: Date?
  var endDate: Date?
  var endedAt: Date?
  
  @Relationship var user: User?

  var timeRecord: TimeRecord {
    TimeRecord(
      id: id,
      taskName: taskName,
      status: TimeStatus(rawValue: statusRaw) ?? .idle,
      duration: duration,
      alarmID: alarmID,
      remainingDuration: remainingDuration,
      plannedDuration: plannedDuration,
      startedAt: startedAt,
      endDate: endDate,
      endedAt: endedAt
    )
  }

  init(
    id: UUID = UUID(),
    taskName: String = "",
    statusRaw: String = TimeStatus.idle.rawValue,
    duration: TimeInterval = 0,
    isCurrent: Bool = true,
    alarmID: UUID? = nil,
    remainingDuration: TimeInterval = 0,
    plannedDuration: TimeInterval = 0,
    startedAt: Date? = nil,
    endDate: Date? = nil,
    endedAt: Date? = nil
  ) {
    self.id = id
    self.taskName = taskName
    self.statusRaw = statusRaw
    self.duration = duration
    self.isCurrent = isCurrent
    self.alarmID = alarmID
    self.remainingDuration = remainingDuration
    self.plannedDuration = plannedDuration
    self.startedAt = startedAt
    self.endDate = endDate
    self.endedAt = endedAt
  }

}
