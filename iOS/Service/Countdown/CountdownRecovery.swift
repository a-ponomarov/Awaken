//
//  CountdownRecovery.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

enum CountdownRestoreAction {

  case none
  case synchronize
  case finishSession
  case schedule(TimeInterval)

}

struct CountdownRecoveredContext {

  let state: CountdownState

}

@MainActor
final class CountdownRecovery {

  func restoreAction(
    hasRestoredRunningTimer: Bool,
    status: TimeStatus,
    alarmState: CountdownAlarmState,
    endDate: Date?,
    restoredDuration: TimeInterval
  ) -> CountdownRestoreAction {
    guard !hasRestoredRunningTimer, status == .running else {
      return .none
    }

    if alarmState != .idle {
      return .synchronize
    }

    if let endDate, endDate <= .now {
      return .finishSession
    }

    return .schedule(restoredDuration)
  }

  func shouldReuseCurrentContext(
    alarmID: UUID,
    currentAlarmID: UUID?,
    status: TimeStatus
  ) -> Bool {
    currentAlarmID == alarmID && status != .idle
  }

  func makeRecoveredContext(
    from timeRecord: TimeRecord,
    alarmID: UUID,
    minimumScheduledDuration: TimeInterval,
    normalizeDuration: (TimeInterval) -> TimeInterval
  ) -> CountdownRecoveredContext {
    CountdownRecoveredContext(
      state: CountdownState(
        draft: CountdownDraftState(
          taskName: timeRecord.taskName,
          duration: normalizeDuration(timeRecord.duration)
        ),
        session: CountdownSessionState(
          status: timeRecord.status,
          alarmID: alarmID,
          remainingDuration: max(
            minimumScheduledDuration,
            timeRecord.remainingDuration
          ),
          plannedDuration: max(
            minimumScheduledDuration,
            timeRecord.plannedDuration
          ),
          startedAt: timeRecord.startedAt,
          endDate: timeRecord.endDate
        )
      )
    )
  }

}
