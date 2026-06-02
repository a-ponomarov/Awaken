//
//  CountdownScheduleAction.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

enum CountdownScheduleResult {

  case ignored
  case synchronize(CountdownAlarmState)
  case scheduled(CountdownState)
  case finishSession
  case reset(CountdownState, showPermissionAlert: Bool)

}

@MainActor
final class CountdownScheduleAction {

  func execute(
    duration: TimeInterval,
    restoringSession: Bool,
    alarmService: CountdownAlarm,
    sessionMachine: CountdownSession,
    state: CountdownState
  ) async -> CountdownScheduleResult {
    guard
      state.session.status == .idle || (restoringSession && state.session.status == .running)
    else {
      return .ignored
    }

    let alarmState = alarmService.currentState()
    if alarmState != .idle {
      return .synchronize(alarmState)
    }

    do {
      let alarmID = try await alarmService.scheduleCountdownAlarm(
        CountdownAlarmScheduleRequest(
          duration: duration,
          taskName: state.draft.taskName
        )
      )

      var updatedState = state
      sessionMachine.scheduled(
        alarmID: alarmID,
        duration: duration,
        startedAt: updatedState.session.startedAt ?? .now,
        state: &updatedState
      )
      return .scheduled(updatedState)
    } catch CountdownAlarmError.unauthorized {
      return failureResult(
        restoringSession: restoringSession,
        sessionMachine: sessionMachine,
        state: state
      )
    } catch {
      return failureResult(
        restoringSession: restoringSession,
        sessionMachine: sessionMachine,
        state: state
      )
    }
  }

  private func failureResult(
    restoringSession: Bool,
    sessionMachine: CountdownSession,
    state: CountdownState
  ) -> CountdownScheduleResult {
    if restoringSession {
      return .finishSession
    }

    var resetState = state
    sessionMachine.reset(
      defaultDuration: state.draft.duration,
      state: &resetState
    )
    return .reset(resetState, showPermissionAlert: true)
  }

}
