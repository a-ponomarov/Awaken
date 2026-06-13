//
//  CountdownCoordinator.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

@MainActor
final class CountdownCoordinator {

  private let logger: Logger
  private let pauseAction = CountdownPauseAction()
  private let resumeAction = CountdownResumeAction()
  private let stopAction = CountdownStopAction()
  private let scheduleAction = CountdownScheduleAction()
  private let synchronizeAction = CountdownSynchronizeAction()
  private let tickAction = CountdownTickAction()

  init(logger: Logger) {
    self.logger = logger
  }

  func pause(
    alarmService: CountdownAlarm,
    runtime: CountdownRuntime,
    sessionMachine: CountdownSession,
    state: inout CountdownState,
    minimumScheduledDuration: TimeInterval,
    restartClock: () -> Void
  ) throws {
    try pauseAction.execute(
      alarmService: alarmService,
      runtime: runtime,
      sessionMachine: sessionMachine,
      logger: logger,
      state: &state,
      minimumScheduledDuration: minimumScheduledDuration,
      restartClock: restartClock
    )
  }

  func resume(
    alarmService: CountdownAlarm,
    sessionMachine: CountdownSession,
    state: inout CountdownState,
    minimumScheduledDuration: TimeInterval
  ) throws {
    try resumeAction.execute(
      alarmService: alarmService,
      sessionMachine: sessionMachine,
      logger: logger,
      state: &state,
      minimumScheduledDuration: minimumScheduledDuration
    )
  }

  func stop(
    cancelAlarm: Bool,
    runtime: CountdownRuntime,
    alarmService: CountdownAlarm,
    historyService: CountdownHistory,
    sessionMachine: CountdownSession,
    state: inout CountdownState,
    history: inout [TimeRecord],
    elapsedDuration: TimeInterval
  ) -> TimeRecord? {
    stopAction.execute(
      cancelAlarm: cancelAlarm,
      runtime: runtime,
      alarmService: alarmService,
      historyService: historyService,
      sessionMachine: sessionMachine,
      state: &state,
      history: &history,
      elapsedDuration: elapsedDuration
    )
  }

  func schedule(
    duration: TimeInterval,
    restoringSession: Bool,
    alarmService: CountdownAlarm,
    sessionMachine: CountdownSession,
    state: CountdownState
  ) async -> CountdownScheduleResult {
    await scheduleAction.execute(
      duration: duration,
      restoringSession: restoringSession,
      alarmService: alarmService,
      sessionMachine: sessionMachine,
      state: state
    )
  }

  func synchronize(
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
    await synchronizeAction.execute(
      alarmState: alarmState,
      recovery: recovery,
      alarmService: alarmService,
      persistenceService: persistenceService,
      sessionMachine: sessionMachine,
      state: state,
      isSchedulingAlarm: isSchedulingAlarm,
      minimumScheduledDuration: minimumScheduledDuration,
      normalizeDuration: normalizeDuration
    )
  }

  func restoreRunningTimer(
    recovery: CountdownRecovery,
    hasRestoredRunningTimer: Bool,
    status: TimeStatus,
    alarmState: CountdownAlarmState,
    endDate: Date?,
    restoredDuration: TimeInterval
  ) -> CountdownRestoreAction {
    recovery.restoreAction(
      hasRestoredRunningTimer: hasRestoredRunningTimer,
      status: status,
      alarmState: alarmState,
      endDate: endDate,
      restoredDuration: restoredDuration
    )
  }

  func tick(
    runtime: CountdownRuntime,
    alarmService: CountdownAlarm,
    sessionMachine: CountdownSession,
    state: CountdownState
  ) -> CountdownTickActionResult {
    tickAction.execute(
      runtime: runtime,
      alarmService: alarmService,
      sessionMachine: sessionMachine,
      state: state
    )
  }

}
