//
//  Persistence+Time.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

extension Persistence {

  func fetchCurrentTimeRecord() -> TimeRecord? {
    var descriptor = FetchDescriptor<Time>(
      predicate: #Predicate {
        $0.isCurrent == true
      }
    )
    descriptor.fetchLimit = 1
    do {
      return try modelContext.fetch(descriptor).first?.timeRecord
    } catch {
      logger?.log(
        .error(PersistenceError.fetchTimeSessionFailed.localizedDescription)
      )
      return nil
    }
  }

  func fetchCurrentTimeRecord(alarmID: UUID) -> TimeRecord? {
    var descriptor = FetchDescriptor<Time>(
      predicate: #Predicate { time in
        time.isCurrent == true &&
        time.alarmID == alarmID
      }
    )
    descriptor.fetchLimit = 1
    do {
      return try modelContext.fetch(descriptor).first?.timeRecord
    } catch {
      logger?.log(
        .error(PersistenceError.fetchTimeSessionByAlarmIDFailed.localizedDescription)
      )
      return nil
    }
  }

  func fetchTimeRecordsHistory() -> [TimeRecord] {
    let descriptor = FetchDescriptor<Time>(
      predicate: #Predicate {
        $0.isCurrent == false
      },
      sortBy: [SortDescriptor(\.endedAt, order: .reverse)]
    )
    do {
      return try modelContext.fetch(descriptor).compactMap {
        guard $0.startedAt != nil, $0.endedAt != nil else { return nil }
        return $0.timeRecord
      }
    } catch {
      logger?.log(
        .error(PersistenceError.fetchTimeHistoryFailed.localizedDescription)
      )
      return []
    }
  }

  func appendTimeRecordToHistory(_ timeRecord: TimeRecord) throws {
    let record = Time(
      id: timeRecord.id,
      taskName: timeRecord.taskName,
      statusRaw: timeRecord.status.rawValue,
      duration: timeRecord.duration,
      isCurrent: false,
      remainingDuration: timeRecord.duration,
      plannedDuration: timeRecord.duration,
      startedAt: timeRecord.startedAt,
      endDate: timeRecord.endDate,
      endedAt: timeRecord.endedAt
    )
    record.user = user
    modelContext.insert(record)
    try trySave()
  }

  func deleteTimeRecordFromHistory(id: UUID) throws {
    let descriptor = FetchDescriptor<Time>(
      predicate: #Predicate {
        $0.id == id &&
        $0.isCurrent == false
      }
    )
    for record in try modelContext.fetch(descriptor) {
      modelContext.delete(record)
    }
    try trySave()
  }

  func updateTimeRecordHistoryLabel(id: UUID, taskName: String) throws {
    let descriptor = FetchDescriptor<Time>(
      predicate: #Predicate {
        $0.id == id &&
        $0.isCurrent == false
      }
    )
    guard let record = try modelContext.fetch(descriptor).first else { return }
    record.taskName = taskName
    try trySave()
  }

  func saveTimeSession(
    taskName: String,
    status: TimeStatus,
    duration: TimeInterval,
    alarmID: UUID?,
    remainingDuration: TimeInterval,
    plannedDuration: TimeInterval,
    startedAt: Date?,
    endDate: Date?
  ) {
    let record = fetchCurrentTimeModel() ?? Time()
    record.taskName = taskName
    record.statusRaw = status.rawValue
    record.duration = duration
    record.isCurrent = true
    record.alarmID = alarmID
    record.remainingDuration = remainingDuration
    record.plannedDuration = plannedDuration
    record.startedAt = startedAt
    record.endDate = endDate
    record.endedAt = nil
    record.user = user

    if record.modelContext == nil {
      modelContext.insert(record)
    }

    save()
  }

  // MARK: - Private Helpers

  private func fetchCurrentTimeModel() -> Time? {
    var descriptor = FetchDescriptor<Time>(
      predicate: #Predicate {
        $0.isCurrent == true
      }
    )
    descriptor.fetchLimit = 1
    return try? modelContext.fetch(descriptor).first
  }

  private func elapsedDuration(for time: Time) -> TimeInterval {
    TimeRecord.elapsedDuration(
      endDate: time.endDate,
      plannedDuration: time.plannedDuration,
      remainingDuration: time.remainingDuration
    )
  }

}
