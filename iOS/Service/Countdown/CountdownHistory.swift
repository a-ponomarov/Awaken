//
//  CountdownHistory.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

@MainActor
final class CountdownHistory {

  private let persistenceService: CountdownPersistence

  init(persistenceService: CountdownPersistence) {
    self.persistenceService = persistenceService
  }

  // MARK: - Sync mutations

  func delete(_ timeRecord: TimeRecord, from history: inout [TimeRecord]) {
    history.removeAll { $0.id == timeRecord.id }
  }

  func update(
    _ timeRecord: TimeRecord,
    taskName: String,
    in history: inout [TimeRecord]
  ) {
    let trimmedTaskName = taskName.trimmingCharacters(in: .whitespacesAndNewlines)

    if let index = history.firstIndex(where: { $0.id == timeRecord.id }) {
      history[index] = TimeRecord(
        id: timeRecord.id,
        taskName: trimmedTaskName,
        status: timeRecord.status,
        duration: timeRecord.duration,
        alarmID: timeRecord.alarmID,
        remainingDuration: timeRecord.remainingDuration,
        plannedDuration: timeRecord.plannedDuration,
        startedAt: timeRecord.startedAt,
        endDate: timeRecord.endDate,
        endedAt: timeRecord.endedAt,
        noteID: timeRecord.noteID
      )
    }
  }

  @discardableResult
  func appendCompletedRecord(
    taskName: String,
    startedAt: Date,
    endedAt: Date,
    duration: TimeInterval,
    to history: inout [TimeRecord]
  ) -> TimeRecord {
    let timeRecord = TimeRecord(
      id: UUID(),
      taskName: taskName,
      status: .idle,
      duration: duration,
      alarmID: nil,
      remainingDuration: duration,
      plannedDuration: duration,
      startedAt: startedAt,
      endDate: nil,
      endedAt: endedAt,
      noteID: nil
    )
    history.insert(timeRecord, at: 0)
    return timeRecord
  }

  // MARK: - Async persistence

  func persistDelete(id: UUID) async throws {
    try await persistenceService.deleteHistoryRecord(id: id)
  }

  func persistUpdate(id: UUID, taskName: String) async throws {
    try await persistenceService.updateHistoryRecord(
      id: id,
      taskName: taskName.trimmingCharacters(in: .whitespacesAndNewlines)
    )
  }

  func persistAppend(_ timeRecord: TimeRecord) async throws {
    try await persistenceService.appendHistoryRecord(timeRecord)
  }

}
