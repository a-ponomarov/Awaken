//
//  CountdownPauseAction.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

private enum CountdownPauseActionError: Error {

  case pauseFailed

}

extension CountdownPauseActionError: LocalizedError {

  var errorDescription: String? {
    switch self {
    case .pauseFailed:
      return String(localized: "Couldn't pause the timer.", comment: "Error when timer pause fails")
    }
  }

}

@MainActor
final class CountdownPauseAction {

  func execute(
    alarmService: CountdownAlarm,
    runtime: CountdownRuntime,
    sessionMachine: CountdownSession,
    logger: Logger,
    state: inout CountdownState,
    minimumScheduledDuration: TimeInterval,
    restartClock: () -> Void
  ) throws {
    guard
      state.session.status == .running,
      let endDate = state.session.endDate,
      let alarmID = state.session.alarmID
    else {
      return
    }

    let remainingDuration = max(
      minimumScheduledDuration,
      endDate.timeIntervalSinceNow
    )

    do {
      try alarmService.pause(alarmID: alarmID)
      runtime.stopClock()
      sessionMachine.pause(
        remainingDuration: remainingDuration,
        state: &state
      )
    } catch {
      logger.log(.error(CountdownPauseActionError.pauseFailed.localizedDescription))
      restartClock()
      throw error
    }
  }

}
