//
//  CountdownViewModel.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CountdownViewModel {

  private enum Constants {
    static let defaultDuration: TimeInterval = 1 * 60
    static let minimumDuration = TimeInterval(TimeView.minimumDurationMinutes * 60)
    static let maximumDuration = TimeInterval(TimeView.maximumDurationMinutes * 60)
    static let minimumScheduledDuration: TimeInterval = 1
  }

  private let alarmService: CountdownAlarm
  private let persistenceService: CountdownPersistence
  private let historyService: CountdownHistory
  private let runtime: CountdownRuntime
  private let recovery: CountdownRecovery
  private let sessionMachine: CountdownSession
  private let coordinator: CountdownCoordinator
  @ObservationIgnored private var observationTask: Task<Void, Never>?
  @ObservationIgnored private var draftPersistTask: Task<Void, Never>?
  private var hasRestoredRunningTimer = false
  private var isSchedulingAlarm = false
  private var state = CountdownState(
    draft: CountdownDraftState(
      taskName: "",
      duration: Constants.defaultDuration
    ),
    session: CountdownSessionState(
      status: .idle,
      alarmID: nil,
      remainingDuration: Constants.defaultDuration,
      plannedDuration: Constants.defaultDuration,
      startedAt: nil,
      endDate: nil
    )
  )

  var taskName: String {
    get { state.draft.taskName }
    set { updateTaskName(to: newValue) }
  }
  var duration: TimeInterval { state.draft.duration }
  var status: TimeStatus { state.session.status }
  var alarmID: UUID? { state.session.alarmID }
  var remainingDuration: TimeInterval { state.session.remainingDuration }
  var plannedDuration: TimeInterval { state.session.plannedDuration }
  var startedAt: Date? { state.session.startedAt }
  var endDate: Date? { state.session.endDate }
  var showPermissionAlert = false

  private(set) var history: [TimeRecord] = []

  deinit {
    observationTask?.cancel()
    draftPersistTask?.cancel()
  }

  init(
    alarmService: CountdownAlarm,
    persistenceService: CountdownPersistence,
    historyService: CountdownHistory,
    runtime: CountdownRuntime,
    recovery: CountdownRecovery,
    sessionMachine: CountdownSession,
    interactor: CountdownCoordinator
  ) {
    self.alarmService = alarmService
    self.persistenceService = persistenceService
    self.historyService = historyService
    self.runtime = runtime
    self.recovery = recovery
    self.sessionMachine = sessionMachine
    self.coordinator = interactor

    Task { @MainActor [weak self] in
      guard let self else { return }
      await load()
      if status == .running {
        await restoreRunningTimerIfNeeded()
      } else {
        await synchronize(with: alarmService.currentState())
      }
      observe()
    }
  }

  func refresh() {
    Task { @MainActor [weak self] in
      guard let self else { return }
      await synchronize(with: alarmService.currentState())
    }
  }

  func toggle() {
    switch status {
    case .idle:
      start()
    case .running:
      pause()
    case .paused:
      resume()
    }
  }

  func stop() {
    finishCurrentSession(cancelAlarm: true)
  }

  func stopIfMatching(alarmID: UUID) -> Bool {
    guard state.session.alarmID == alarmID else { return false }
    finishCurrentSession(cancelAlarm: false)
    return true
  }

  func reuseTimeRecord(_ timeRecord: TimeRecord) {
    guard status == .idle else { return }
    sessionMachine.reuseTimeRecord(timeRecord, state: &state)
    Task { [weak self] in await self?.persistSession() }
  }

  func deleteTimeRecord(_ timeRecord: TimeRecord) {
    let previousHistory = history
    historyService.delete(timeRecord, from: &history)
    Task { [weak self] in
      do {
        try await self?.historyService.persistDelete(id: timeRecord.id)
      } catch {
        self?.history = previousHistory
      }
    }
  }

  func updateTimeRecord(_ timeRecord: TimeRecord, taskName: String) {
    let previousHistory = history
    historyService.update(timeRecord, taskName: taskName, in: &history)
    Task { [weak self] in
      do {
        try await self?.historyService.persistUpdate(
          id: timeRecord.id,
          taskName: taskName
        )
      } catch {
        self?.history = previousHistory
      }
    }
  }

  func clearTaskName() {
    guard status == .idle else { return }
    sessionMachine.clearTaskName(state: &state)
    Task { [weak self] in await self?.persistSession() }
  }

  func updateTaskName(to taskName: String) {
    guard status == .idle else { return }
    sessionMachine.updateTaskName(to: taskName, state: &state)
    persistDraftDebounced()
  }

  func updateDuration(minutes: Int) {
    sessionMachine.updateDuration(
      minutes: minutes,
      normalizeDuration: normalizedDuration,
      state: &state
    )
    persistDraftDebounced()
  }

  private func start() {
    guard status == .idle, !isSchedulingAlarm else { return }

    if alarmService.currentState() != .idle {
      alarmService.cancelCountdownAlarm()
    }

    state.draft.taskName = state.draft.taskName.trimmingCharacters(
      in: CharacterSet.whitespacesAndNewlines
    )
    schedule(duration: state.draft.duration, restoringSession: false)
  }

  private func pause() {
    do {
      try coordinator.pause(
        alarmService: alarmService,
        runtime: runtime,
        sessionMachine: sessionMachine,
        state: &state,
        minimumScheduledDuration: Constants.minimumScheduledDuration,
        restartClock: startClock
      )
      Task { [weak self] in await self?.persistSession() }
    } catch {
      // Alarm pause failed; action already restarted the clock
    }
  }

  private func resume() {
    do {
      try coordinator.resume(
        alarmService: alarmService,
        sessionMachine: sessionMachine,
        state: &state,
        minimumScheduledDuration: Constants.minimumScheduledDuration
      )
      startClock()
      Task { [weak self] in await self?.persistSession() }
    } catch {
      // Alarm resume failed; state was not mutated
    }
  }

  private func schedule(duration: TimeInterval, restoringSession: Bool) {
    guard
      (!isSchedulingAlarm && status == .idle) || (restoringSession && status == .running)
    else {
      return
    }

    isSchedulingAlarm = true

    Task { @MainActor [weak self] in
      guard let self else { return }

      defer {
        isSchedulingAlarm = false
      }

      switch await coordinator.schedule(
        duration: duration,
        restoringSession: restoringSession,
        alarmService: alarmService,
        sessionMachine: sessionMachine,
        state: state
      ) {
      case .ignored:
        return
      case .synchronize(let alarmState):
        await synchronize(with: alarmState)
      case .scheduled(let updatedState):
        state = updatedState
        startClock()
        await persistSession()
      case .finishSession:
        finishCurrentSession(cancelAlarm: false)
      case .reset(let updatedState, let shouldShowPermissionAlert):
        state = updatedState
        showPermissionAlert = shouldShowPermissionAlert
        await persistSession()
      }
    }
  }

  private func observe() {
    guard observationTask == nil else { return }

    observationTask = Task { @MainActor [weak self] in
      guard let self else { return }

      for await _ in alarmService.updates() {
        await synchronize(with: alarmService.currentState())
      }
    }
  }

  private func restoreRunningTimerIfNeeded() async {
    switch coordinator.restoreRunningTimer(
      recovery: recovery,
      hasRestoredRunningTimer: hasRestoredRunningTimer,
      status: status,
      alarmState: alarmService.currentState(),
      endDate: endDate,
      restoredDuration: restoredCountdownDuration
    ) {
    case .none:
      return
    case .synchronize:
      hasRestoredRunningTimer = true
      await synchronize(with: alarmService.currentState())
    case .finishSession:
      hasRestoredRunningTimer = true
      finishCurrentSession(cancelAlarm: false)
    case .schedule(let duration):
      hasRestoredRunningTimer = true
      schedule(duration: duration, restoringSession: true)
    }
  }

  private func synchronize(with alarmState: CountdownAlarmState) async {
    switch await coordinator.synchronize(
      alarmState: alarmState,
      recovery: recovery,
      alarmService: alarmService,
      persistenceService: persistenceService,
      sessionMachine: sessionMachine,
      state: state,
      isSchedulingAlarm: isSchedulingAlarm,
      minimumScheduledDuration: Constants.minimumScheduledDuration,
      normalizeDuration: normalizedDuration
    ) {
    case .none:
      return
    case .finishSession:
      runtime.stopClock()
      finishCurrentSession(cancelAlarm: false)
    case .updated(let updatedState, let clockDirective):
      state = updatedState
      switch clockDirective {
      case .none:
        break
      case .start:
        startClock()
      case .stop:
        runtime.stopClock()
      }
      Task { [weak self] in await self?.persistSession() }
    }
  }

  private func startClock() {
    runtime.startClock { [weak self] in
      self?.tick()
    }
  }

  private func tick() {
    switch coordinator.tick(
      runtime: runtime,
      alarmService: alarmService,
      sessionMachine: sessionMachine,
      state: state
    ) {
    case .none:
      return
    case .updated(let updatedState, let stopClock):
      state = updatedState
      if stopClock {
        runtime.stopClock()
      }
    case .finishSession:
      finishCurrentSession(cancelAlarm: false)
    }
  }

  private func finishCurrentSession(cancelAlarm: Bool) {
    let appendedRecord = coordinator.stop(
      cancelAlarm: cancelAlarm,
      runtime: runtime,
      alarmService: alarmService,
      historyService: historyService,
      sessionMachine: sessionMachine,
      state: &state,
      history: &history,
      elapsedDuration: elapsedDuration
    )
    Task { [weak self] in
      if let appendedRecord {
        do {
          try await self?.historyService.persistAppend(appendedRecord)
        } catch {
          self?.history.removeAll { $0.id == appendedRecord.id }
        }
      }
      await self?.persistSession()
    }
  }

  private func persistDraftDebounced() {
    draftPersistTask?.cancel()
    draftPersistTask = Task { [weak self] in
      try? await Task.sleep(for: .milliseconds(300))
      guard !Task.isCancelled else { return }
      await self?.persistSession()
    }
  }

  private func persistSession() async {
    await persistenceService.saveSession(state: state)
  }

  private func load() async {
    let snapshot = await persistenceService.loadSession(
      defaultState: CountdownState(
        draft: state.draft,
        session: CountdownSessionState(
          status: .idle,
          alarmID: nil,
          remainingDuration: state.draft.duration,
          plannedDuration: state.draft.duration,
          startedAt: nil,
          endDate: nil
        )
      )
    )

    state = snapshot.state
    state.draft.duration = normalizedDuration(state.draft.duration)
    history = snapshot.history
  }

  private var restoredCountdownDuration: TimeInterval {
    runtime.restoredDuration(
      endDate: endDate,
      remainingDuration: state.session.remainingDuration,
      minimumDuration: Constants.minimumScheduledDuration
    )
  }

  private var elapsedDuration: TimeInterval {
    runtime.elapsedDuration(
      endDate: endDate,
      plannedDuration: state.session.plannedDuration,
      remainingDuration: state.session.remainingDuration
    )
  }

  private func normalizedDuration(minutes: Int) -> TimeInterval {
    normalizedDuration(TimeInterval(minutes * 60))
  }

  private func normalizedDuration(_ duration: TimeInterval) -> TimeInterval {
    min(
      Constants.maximumDuration,
      max(Constants.minimumDuration, duration)
    )
  }

}
