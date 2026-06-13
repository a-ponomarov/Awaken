//
//  CountdownTickAction.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

enum CountdownTickActionResult {

  case none
  case synchronizedPaused(CountdownState)
  case updated(CountdownState, stopClock: Bool)
  case finishSession

}

@MainActor
final class CountdownTickAction {

  func execute(
    runtime: CountdownRuntime,
    alarmService: CountdownAlarm,
    sessionMachine: CountdownSession,
    state: CountdownState
  ) -> CountdownTickActionResult {
    let alarmState = alarmService.currentState()

    if case .paused(let alarmID, let remainingDuration) = alarmState, state.session.status != .idle {
      var updatedState = state
      sessionMachine.applyPausedState(
        alarmID: alarmID,
        remainingDuration: remainingDuration,
        state: &updatedState
      )
      return .synchronizedPaused(updatedState)
    }

    switch runtime.tickResult(
      status: state.session.status,
      endDate: state.session.endDate,
      alarmState: alarmState
    ) {
    case .idle:
      return .none
    case .updateRemaining(let remainingDuration):
      var updatedState = state
      sessionMachine.updateRemainingDuration(
        remainingDuration,
        state: &updatedState
      )
      return .updated(updatedState, stopClock: false)
    case .finishedWhileAlarmActive:
      var updatedState = state
      sessionMachine.updateRemainingDuration(0, state: &updatedState)
      return .updated(updatedState, stopClock: true)
    case .finishedWhileAlarmIdle:
      return .finishSession
    }
  }

}
