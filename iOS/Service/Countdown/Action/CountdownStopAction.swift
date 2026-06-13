//
//  CountdownStopAction.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

@MainActor
final class CountdownStopAction {

  func execute(
    cancelAlarm: Bool,
    runtime: CountdownRuntime,
    alarmService: CountdownAlarm,
    historyService: CountdownHistory,
    sessionMachine: CountdownSession,
    state: inout CountdownState,
    history: inout [TimeRecord],
    elapsedDuration: TimeInterval
  ) -> TimeRecord? {
    runtime.stopClock()

    if cancelAlarm {
      alarmService.cancelCountdownAlarm()
    }

    var appendedRecord: TimeRecord?

    if let startedAt = state.session.startedAt, elapsedDuration > 0 {
      appendedRecord = historyService.appendCompletedRecord(
        taskName: state.draft.taskName,
        startedAt: startedAt,
        endedAt: .now,
        duration: elapsedDuration,
        to: &history
      )
    }

    sessionMachine.reset(
      defaultDuration: state.draft.duration,
      state: &state
    )

    return appendedRecord
  }

}
