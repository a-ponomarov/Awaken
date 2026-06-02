//
//  CountdownAlarm.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AlarmKit
import Foundation
import SwiftUI

struct CountdownAlarmScheduleRequest {

  let duration: TimeInterval
  let taskName: String

}

enum CountdownAlarmState: Equatable {

  case idle
  case running(alarmID: UUID)
  case paused(alarmID: UUID)
  case alerting(alarmID: UUID)

}

enum CountdownAlarmError: Error {

  case unauthorized
  case stopFailed
  case loadFailed
  case cancelFailed

}

extension CountdownAlarmError: LocalizedError {

  var errorDescription: String? {
    switch self {
    case .unauthorized:
      return String(localized: "Alarm permission is required.", comment: "Error when AlarmKit access is denied")
    case .stopFailed:
      return String(localized: "Couldn't stop the timer alarm.", comment: "Error when stopping the timer alarm fails")
    case .loadFailed:
      return String(localized: "Couldn't access the timer alarm.", comment: "Error when loading the timer alarm fails")
    case .cancelFailed:
      return String(localized: "Couldn't cancel the timer alarm.", comment: "Error when cancelling the timer alarm fails")
    }
  }

}

@MainActor
final class CountdownAlarm {

  private let alarmManager: AlarmManager
  private let logger: Logger

  init(
    alarmManager: AlarmManager = .shared,
    logger: Logger
  ) {
    self.alarmManager = alarmManager
    self.logger = logger
  }

  func updates() -> AsyncStream<Void> {
    AsyncStream { continuation in
      let task = Task { @MainActor [alarmManager] in
        for await _ in alarmManager.alarmUpdates {
          continuation.yield(())
        }

        continuation.finish()
      }

      continuation.onTermination = { _ in task.cancel() }
    }
  }

  func currentState() -> CountdownAlarmState {
    guard let alarm = activeAlarm() else {
      return .idle
    }

    switch alarm.state {
    case .paused:
      return .paused(alarmID: alarm.id)
    case .countdown, .scheduled:
      return .running(alarmID: alarm.id)
    case .alerting:
      return .alerting(alarmID: alarm.id)
    @unknown default:
      return .idle
    }
  }

  func stopIfActive(alarmID: UUID?) {
    guard
      let alarmID,
      activeAlarm()?.id == alarmID
    else {
      return
    }

    do {
      try alarmManager.stop(id: alarmID)
    } catch {
      logger.log(.error(CountdownAlarmError.stopFailed.localizedDescription))
    }
  }

  private func activeAlarm() -> Alarm? {
    do {
      return try alarmManager.alarms.first { $0.id == AlarmIdentifiers.time }
    } catch {
      logger.log(.error(CountdownAlarmError.loadFailed.localizedDescription))
      return nil
    }
  }

  func pause(alarmID: UUID) throws {
    try alarmManager.pause(id: alarmID)
  }

  func resume(alarmID: UUID) throws {
    try alarmManager.resume(id: alarmID)
  }

  func cancelCountdownAlarm() {
    guard let activeAlarm = activeAlarm() else { return }

    do {
      try alarmManager.cancel(id: activeAlarm.id)
    } catch {
      guard self.activeAlarm() != nil else { return }
      logger.log(.error(CountdownAlarmError.cancelFailed.localizedDescription))
    }
  }

  func scheduleCountdownAlarm(_ request: CountdownAlarmScheduleRequest) async throws -> UUID {
    guard try await requestAuthorization() else {
      throw CountdownAlarmError.unauthorized
    }

    let alarmID = AlarmIdentifiers.time
    let alert = AlarmPresentation.Alert(
      title: LocalizedStringResource(
        stringLiteral: String.timeComplete
      ),
      secondaryButton: nil,
      secondaryButtonBehavior: nil
    )
    let countdown = AlarmPresentation.Countdown(
      title: LocalizedStringResource(
        stringLiteral: request.taskName
      ),
      pauseButton: AlarmButton(
        text: LocalizedStringResource(
          stringLiteral: String.pause
        ),
        textColor: .white,
        systemImageName: "pause.fill"
      )
    )
    let paused = AlarmPresentation.Paused(
      title: LocalizedStringResource(
        stringLiteral: String.timePaused
      ),
      resumeButton: AlarmButton(
        text: LocalizedStringResource(
          stringLiteral: String.resume
        ),
        textColor: .white,
        systemImageName: "play.fill"
      )
    )
    let attributes = AlarmAttributes(
      presentation: AlarmPresentation(
        alert: alert,
        countdown: countdown,
        paused: paused
      ),
      metadata: CountdownLiveActivityMetadata(
        taskName: request.taskName.trimmingCharacters(
          in: .whitespacesAndNewlines
        )
      ),
      tintColor: .white
    )
    let configuration = AlarmManager.AlarmConfiguration.timer(
      duration: request.duration,
      attributes: attributes,
      stopIntent: StopIntent(
        alarmID: alarmID.uuidString
      )
    )

    _ = try await alarmManager.schedule(
      id: alarmID,
      configuration: configuration
    )

    return alarmID
  }

  private func requestAuthorization() async throws -> Bool {
    if alarmManager.authorizationState == .notDetermined {
      return try await alarmManager.requestAuthorization() == .authorized
    }
    return alarmManager.authorizationState == .authorized
  }

}
