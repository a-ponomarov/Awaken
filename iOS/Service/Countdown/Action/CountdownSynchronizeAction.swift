//
//  CountdownSynchronizeAction.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

enum CountdownClockDirective {

  case none
  case start
  case stop

}

enum CountdownSynchronizeResult {

  case none
  case finishSession
  case updated(CountdownState, CountdownClockDirective)

}

@MainActor
final class CountdownSynchronizeAction {

  func execute(
    alarmState: CountdownAlarmState,
    recovery: CountdownRecovery,
    alarmService: CountdownAlarm,
    persistenceService: CountdownPersistence,
    sessionMachine: CountdownSession,
    state: CountdownState,
    isSchedulingAlarm: Bool,
    minimumScheduledDuration: TimeInterval,
    normalizeDuration: (TimeInterval) -> TimeInterval
  ) async -> CountdownSynchronizeResult {
    if isSchedulingAlarm {
      return .none
    }

    switch alarmState {
    case .idle:
      return state.session.status == .idle ? .none : .finishSession
    case .running(let alarmID):
      guard let restoredState = await restoredStateIfNeeded(
        alarmID: alarmID,
        recovery: recovery,
        alarmService: alarmService,
        persistenceService: persistenceService,
        state: state,
        minimumScheduledDuration: minimumScheduledDuration,
        normalizeDuration: normalizeDuration
      ) else {
        return .none
      }

      var updatedState = restoredState
      sessionMachine.applyRunningState(
        alarmID: alarmID,
        minimumScheduledDuration: minimumScheduledDuration,
        state: &updatedState
      )

      let clockDirective: CountdownClockDirective = updatedState.session.endDate == nil
        ? .stop
        : updatedState.session.remainingDuration == 0 ? .stop : .start
      return .updated(updatedState, clockDirective)
    case .paused(let alarmID, let remainingDuration):
      guard let restoredState = await restoredStateIfNeeded(
        alarmID: alarmID,
        recovery: recovery,
        alarmService: alarmService,
        persistenceService: persistenceService,
        state: state,
        minimumScheduledDuration: minimumScheduledDuration,
        normalizeDuration: normalizeDuration
      ) else {
        return .none
      }

      var updatedState = restoredState
      sessionMachine.applyPausedState(
        alarmID: alarmID,
        remainingDuration: remainingDuration,
        state: &updatedState
      )
      return .updated(updatedState, .stop)
    case .alerting(let alarmID):
      guard let restoredState = await restoredStateIfNeeded(
        alarmID: alarmID,
        recovery: recovery,
        alarmService: alarmService,
        persistenceService: persistenceService,
        state: state,
        minimumScheduledDuration: minimumScheduledDuration,
        normalizeDuration: normalizeDuration
      ) else {
        return .none
      }

      var updatedState = restoredState
      sessionMachine.applyAlertingState(
        alarmID: alarmID,
        state: &updatedState
      )
      return .updated(updatedState, .stop)
    }
  }

  private func restoredStateIfNeeded(
    alarmID: UUID,
    recovery: CountdownRecovery,
    alarmService: CountdownAlarm,
    persistenceService: CountdownPersistence,
    state: CountdownState,
    minimumScheduledDuration: TimeInterval,
    normalizeDuration: (TimeInterval) -> TimeInterval
  ) async -> CountdownState? {
    if recovery.shouldReuseCurrentContext(
      alarmID: alarmID,
      currentAlarmID: state.session.alarmID,
      status: state.session.status
    ) {
      return state
    }

    guard let timeRecord = await persistenceService.loadCurrentTimeRecord(alarmID: alarmID) else {
      alarmService.cancelCountdownAlarm()
      return nil
    }

    return recovery.makeRecoveredContext(
      from: timeRecord,
      alarmID: alarmID,
      minimumScheduledDuration: minimumScheduledDuration,
      normalizeDuration: normalizeDuration
    ).state
  }

}
