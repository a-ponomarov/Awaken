//
//  CountdownResumeAction.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

private enum CountdownResumeActionError: Error {

  case resumeFailed

}

extension CountdownResumeActionError: LocalizedError {

  var errorDescription: String? {
    switch self {
    case .resumeFailed:
      return String(localized: "Couldn't resume the timer.", comment: "Error when timer resume fails")
    }
  }

}

@MainActor
final class CountdownResumeAction {

  func execute(
    alarmService: CountdownAlarm,
    sessionMachine: CountdownSession,
    logger: Logger,
    state: inout CountdownState,
    minimumScheduledDuration: TimeInterval
  ) throws {
    guard
      state.session.status == .paused,
      let alarmID = state.session.alarmID
    else {
      return
    }

    let remainingDuration = max(
      minimumScheduledDuration,
      state.session.remainingDuration
    )

    do {
      try alarmService.resume(alarmID: alarmID)
      sessionMachine.resume(
        remainingDuration: remainingDuration,
        state: &state
      )
    } catch {
      logger.log(.error(CountdownResumeActionError.resumeFailed.localizedDescription))
      throw error
    }
  }

}
