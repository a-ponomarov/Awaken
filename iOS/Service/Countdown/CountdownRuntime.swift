//
//  CountdownRuntime.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

enum CountdownTickResult {

  case idle
  case updateRemaining(TimeInterval)
  case finishedWhileAlarmActive
  case finishedWhileAlarmIdle

}

@MainActor
final class CountdownRuntime {

  private let timerTask = AppTask()

  func startClock(onTick: @escaping @MainActor () -> Void) {
    timerTask.schedule(every: .seconds(1)) {
      onTick()
    }
  }

  func stopClock() {
    timerTask.currentTask = nil
  }

  func tickResult(
    status: TimeStatus,
    endDate: Date?,
    alarmState: CountdownAlarmState
  ) -> CountdownTickResult {
    guard status == .running, let endDate else {
      return .idle
    }

    if endDate <= .now {
      switch alarmState {
      case .running, .paused, .alerting:
        return .finishedWhileAlarmActive
      case .idle:
        return .finishedWhileAlarmIdle
      }
    }

    return .updateRemaining(max(0, endDate.timeIntervalSinceNow))
  }

  func restoredDuration(
    endDate: Date?,
    remainingDuration: TimeInterval,
    minimumDuration: TimeInterval
  ) -> TimeInterval {
    if let endDate {
      return max(
        minimumDuration,
        endDate.timeIntervalSinceNow
      )
    }

    return max(
      minimumDuration,
      remainingDuration
    )
  }

  func elapsedDuration(
    endDate: Date?,
    plannedDuration: TimeInterval,
    remainingDuration: TimeInterval
  ) -> TimeInterval {
    TimeRecord.elapsedDuration(
      endDate: endDate,
      plannedDuration: plannedDuration,
      remainingDuration: remainingDuration
    )
  }

}
