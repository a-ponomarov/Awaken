//
//  AlarmService.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import AlarmKit
import SwiftUI
import WidgetKit

extension AlarmManager: @unchecked @retroactive Sendable { }

struct WakeAlarmMetadata: AlarmMetadata, Codable, Sendable { }

enum AlarmServiceError: Error {

  case cancelFailed

}

extension AlarmServiceError: LocalizedError {

  var errorDescription: String? {
    switch self {
    case .cancelFailed:
      return String(localized: "Couldn't turn off the alarm.", comment: "Error when alarm cancellation fails")
    }
  }

}

@MainActor
@Observable
final class AlarmService {

  private let alarmManager: AlarmManager
  private let logger: Logger

  private var schedulingTask: Task<Void, Never>?

  private(set) var isAlarmActive = false {
    didSet {
      guard oldValue != isAlarmActive else { return }
      WidgetCenter.shared.reloadAllTimelines()
    }
  }

  private(set) var alarmDate: Date? {
    didSet {
      guard oldValue != alarmDate else { return }
      WidgetCenter.shared.reloadAllTimelines()
    }
  }

  init(
    alarmManager: AlarmManager = .shared,
    logger: Logger
  ) {
    self.alarmManager = alarmManager
    self.logger = logger
    refresh()
    observe()
  }

  private func observe() {
    Task { @MainActor in
      for await _ in alarmManager.alarmUpdates {
        refresh()
      }
    }
  }

  func refresh() {
    Task { @MainActor in
      let activeAlarm = (try? alarmManager.alarms)?
        .first(where: { $0.id == AlarmIdentifiers.wake })
      apply(alarm: activeAlarm)
    }
  }

  private func apply(alarm: Alarm?) {
    let exists = alarm != nil
    if exists != isAlarmActive {
      isAlarmActive = exists
    }
    alarmDate = alarm?.schedule?.fixedDate
  }

  func schedule(at date: Date, onFailure: (@Sendable () async -> Void)? = nil) {
    schedulingTask?.cancel()
    let scheduledDate = date.nextOccurrence()
    alarmDate = scheduledDate.roundedToMinute

    schedulingTask = Task {
      guard let authorized = try? await requestAuthorization(), authorized else {
        await onFailure?()
        return
      }

      guard !Task.isCancelled else { return }

      let alertContent = AlarmPresentation.Alert(title: LocalizedStringResource("Alarm"))
      let attributes = AlarmAttributes(
        presentation: AlarmPresentation(alert: alertContent),
        metadata: WakeAlarmMetadata(),
        tintColor: .white
      )

      let configuration = AlarmManager.AlarmConfiguration(
        schedule: Alarm.Schedule.fixed(scheduledDate),
        attributes: attributes
      )

      do {
        _ = try await alarmManager.schedule(
          id: AlarmIdentifiers.wake,
          configuration: configuration
        )
        guard !Task.isCancelled else { return }
        isAlarmActive = true
      } catch {
        await onFailure?()
      }
    }
  }

  func cancel() {
    schedulingTask?.cancel()

    do {
      try alarmManager.cancel(id: AlarmIdentifiers.wake)
      isAlarmActive = false
      alarmDate = nil
    } catch {
      isAlarmActive = false
      alarmDate = nil
      logger.log(.error(AlarmServiceError.cancelFailed.localizedDescription))
    }
  }

  private func requestAuthorization() async throws -> Bool {
    if alarmManager.authorizationState == .notDetermined {
      return try await alarmManager.requestAuthorization() == .authorized
    }
    return alarmManager.authorizationState == .authorized
  }
}

extension Alarm.Schedule {
  var fixedDate: Date? {
    if case .fixed(let date) = self { return date }
    return nil
  }
}
