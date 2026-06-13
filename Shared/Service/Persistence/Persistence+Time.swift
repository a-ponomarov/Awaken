//
//  Persistence+Time.swift
//  Time
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
      deleteAudioFiles(for: record.note?.dreams ?? [])
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
    record.note?.title = taskName
    record.note?.updatedAt = .now
    try trySave()
  }

  func ensureTimeRecordNote(id: UUID) throws -> UUID? {
    let descriptor = FetchDescriptor<Time>(
      predicate: #Predicate {
        $0.id == id &&
        $0.isCurrent == false
      }
    )
    guard let record = try modelContext.fetch(descriptor).first else { return nil }

    if let note = record.note {
      return note.id
    }

    let note = Note(title: record.taskName, text: "")
    note.createdAt = record.endedAt ?? record.startedAt ?? .now
    record.note = note
    modelContext.insert(note)
    try trySave()
    return note.id
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

  func fetchTimeFocusQueue() -> [QueuedTimeRecord] {
    let descriptor = FetchDescriptor<QueuedTime>(
      sortBy: [SortDescriptor(\.createdAt, order: .forward)]
    )
    do {
      return try modelContext.fetch(descriptor).map(\.entry)
    } catch {
      logger?.log(
        .error(PersistenceError.fetchTimeFocusQueueFailed.localizedDescription)
      )
      return []
    }
  }

  func appendQueuedTime(_ focusTask: QueuedTimeRecord) throws {
    let model = QueuedTime(
      id: focusTask.id,
      title: focusTask.title,
      createdAt: focusTask.createdAt
    )
    model.user = user
    modelContext.insert(model)
    try trySave()
  }

  func updateQueuedTime(_ focusTask: QueuedTimeRecord) throws {
    let focusTaskID = focusTask.id
    var descriptor = FetchDescriptor<QueuedTime>(
      predicate: #Predicate {
        $0.id == focusTaskID
      }
    )
    descriptor.fetchLimit = 1

    guard let task = try modelContext.fetch(descriptor).first else { return }
    task.title = focusTask.title
    try trySave()
  }

  func deleteQueuedTime(id: UUID) throws {
    let descriptor = FetchDescriptor<QueuedTime>(
      predicate: #Predicate {
        $0.id == id
      }
    )
    for task in try modelContext.fetch(descriptor) {
      modelContext.delete(task)
    }
    try trySave()
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

  private func deleteAudioFiles(for dreams: [Dream]) {
    for dream in dreams {
      guard let audioFilename = dream.audioFilename else { continue }

      let url = AudioFileManager.dir.appendingPathComponent(audioFilename)
      if FileManager.default.fileExists(atPath: url.path) {
        try? FileManager.default.removeItem(at: url)
      }
    }
  }

}
