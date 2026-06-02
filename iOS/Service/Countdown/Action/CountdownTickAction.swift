//
//  CountdownTickAction.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

enum CountdownTickActionResult {

  case none
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
    switch runtime.tickResult(
      status: state.session.status,
      endDate: state.session.endDate,
      alarmState: alarmService.currentState()
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
