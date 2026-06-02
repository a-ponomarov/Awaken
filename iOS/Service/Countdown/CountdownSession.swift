//
//  CountdownSession.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

@MainActor
final class CountdownSession {

  func reuseTimeRecord(
    _ timeRecord: TimeRecord,
    state: inout CountdownState
  ) {
    state.draft.taskName = timeRecord.taskName
  }

  func clearTaskName(state: inout CountdownState) {
    state.draft.taskName = ""
  }

  func updateTaskName(
    to taskName: String,
    state: inout CountdownState
  ) {
    state.draft.taskName = taskName
  }

  func updateDuration(
    minutes: Int,
    normalizeDuration: (Int) -> TimeInterval,
    state: inout CountdownState
  ) {
    state.draft.duration = normalizeDuration(minutes)
    if state.session.status == .idle {
      state.session.remainingDuration = state.draft.duration
      state.session.plannedDuration = state.draft.duration
    }
  }

  func pause(
    remainingDuration: TimeInterval,
    state: inout CountdownState
  ) {
    state.session.remainingDuration = remainingDuration
    state.session.endDate = nil
    state.session.status = .paused
  }

  func resume(
    remainingDuration: TimeInterval,
    state: inout CountdownState
  ) {
    state.session.status = .running
    state.session.remainingDuration = remainingDuration
    state.session.endDate = .now.addingTimeInterval(remainingDuration)
  }

  func scheduled(
    alarmID: UUID,
    duration: TimeInterval,
    startedAt: Date,
    state: inout CountdownState
  ) {
    state.session.status = .running
    state.session.alarmID = alarmID
    state.session.startedAt = startedAt
    state.session.plannedDuration = max(duration, state.session.plannedDuration)
    state.session.endDate = .now.addingTimeInterval(duration)
    state.session.remainingDuration = duration
  }

  func restore(
    context: CountdownRecoveredContext,
    state: inout CountdownState
  ) {
    state = context.state
  }

  func applyRunningState(
    alarmID: UUID,
    minimumScheduledDuration: TimeInterval,
    state: inout CountdownState
  ) {
    state.session.alarmID = alarmID
    state.session.startedAt = state.session.startedAt ?? .now
    state.session.status = .running

    if state.session.endDate == nil {
      state.session.endDate = .now.addingTimeInterval(
        max(minimumScheduledDuration, state.session.remainingDuration)
      )
    }

    if let endDate = state.session.endDate, endDate > .now {
      state.session.remainingDuration = max(0, endDate.timeIntervalSinceNow)
    } else {
      state.session.remainingDuration = 0
    }
  }

  func applyPausedState(
    alarmID: UUID,
    minimumScheduledDuration: TimeInterval,
    state: inout CountdownState
  ) {
    state.session.alarmID = alarmID
    state.session.startedAt = state.session.startedAt ?? .now
    state.session.status = .paused
    state.session.remainingDuration = max(
      minimumScheduledDuration,
      state.session.remainingDuration
    )
    state.session.endDate = nil
  }

  func applyAlertingState(
    alarmID: UUID,
    state: inout CountdownState
  ) {
    state.session.alarmID = alarmID
    state.session.startedAt = state.session.startedAt ?? .now
    state.session.status = .running
    state.session.remainingDuration = 0
    state.session.endDate = nil
  }

  func updateRemainingDuration(
    _ remainingDuration: TimeInterval,
    state: inout CountdownState
  ) {
    state.session.remainingDuration = remainingDuration
  }

  func reset(
    defaultDuration: TimeInterval,
    state: inout CountdownState
  ) {
    state.session = CountdownSessionState(
      status: .idle,
      alarmID: nil,
      remainingDuration: defaultDuration,
      plannedDuration: defaultDuration,
      startedAt: nil,
      endDate: nil
    )
  }

}
