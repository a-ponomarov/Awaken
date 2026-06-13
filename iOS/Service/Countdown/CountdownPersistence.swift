//
//  CountdownPersistence.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

@MainActor
final class CountdownPersistence {

  private let persistence: Persistence
  private var isPrepared = false

  init(persistence: Persistence) {
    self.persistence = persistence
  }

  private func prepareIfNeeded() async {
    guard !isPrepared else { return }
    await persistence.ensureUser()
    isPrepared = true
  }

  func loadSession(defaultState: CountdownState) async -> CountdownSessionSnapshot {
    await prepareIfNeeded()
    let currentTimeRecord = await persistence.fetchCurrentTimeRecord()
    let timeHistoryRecords = await persistence.fetchTimeRecordsHistory()

    guard let currentTimeRecord else {
      return CountdownSessionSnapshot(
        state: defaultState,
        history: timeHistoryRecords
      )
    }

    return CountdownSessionSnapshot(
      state: CountdownState(
        draft: CountdownDraftState(
          taskName: currentTimeRecord.taskName,
          duration: currentTimeRecord.duration
        ),
        session: CountdownSessionState(
          status: currentTimeRecord.status,
          alarmID: currentTimeRecord.alarmID,
          remainingDuration: currentTimeRecord.remainingDuration,
          plannedDuration: currentTimeRecord.plannedDuration,
          startedAt: currentTimeRecord.startedAt,
          endDate: currentTimeRecord.endDate
        )
      ),
      history: timeHistoryRecords
    )
  }

  func loadCurrentTimeRecord(alarmID: UUID) async -> TimeRecord? {
    await prepareIfNeeded()
    return await persistence.fetchCurrentTimeRecord(alarmID: alarmID)
  }

  func saveSession(state: CountdownState) async {
    await prepareIfNeeded()
    await persistence.saveTimeSession(
      taskName: state.draft.taskName,
      status: state.session.status,
      duration: state.draft.duration,
      alarmID: state.session.alarmID,
      remainingDuration: state.session.remainingDuration,
      plannedDuration: state.session.plannedDuration,
      startedAt: state.session.startedAt,
      endDate: state.session.endDate
    )
  }

  func loadFocusQueue() async -> [QueuedTimeRecord] {
    await prepareIfNeeded()
    return await persistence.fetchTimeFocusQueue()
  }

  func appendFocusTask(_ focusTask: QueuedTimeRecord) async throws {
    await prepareIfNeeded()
    try await persistence.appendQueuedTime(focusTask)
  }

  func updateFocusTask(_ focusTask: QueuedTimeRecord) async throws {
    await prepareIfNeeded()
    try await persistence.updateQueuedTime(focusTask)
  }

  func deleteFocusTask(id: UUID) async throws {
    await prepareIfNeeded()
    try await persistence.deleteQueuedTime(id: id)
  }

  func appendHistoryRecord(_ timeRecord: TimeRecord) async throws {
    await prepareIfNeeded()
    try await persistence.appendTimeRecordToHistory(timeRecord)
  }

  func deleteHistoryRecord(id: UUID) async throws {
    await prepareIfNeeded()
    try await persistence.deleteTimeRecordFromHistory(id: id)
  }

  func updateHistoryRecord(id: UUID, taskName: String) async throws {
    await prepareIfNeeded()
    try await persistence.updateTimeRecordHistoryLabel(id: id, taskName: taskName)
  }

  func ensureHistoryRecordNote(id: UUID) async throws -> UUID? {
    await prepareIfNeeded()
    return try await persistence.ensureTimeRecordNote(id: id)
  }

}
