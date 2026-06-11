//
//  AppContainer.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import Observation

private enum AppContainerError: Error {

  case audioStorageUnavailable

}

extension AppContainerError: LocalizedError {

  var errorDescription: String? {
    switch self {
    case .audioStorageUnavailable:
      return String(localized: "Audio storage isn't available right now.", comment: "Error when audio recording storage cannot be set up")
    }
  }

}

@MainActor
final class AppContainer {

  let logger: Logger
  let persistence: Persistence
  let defaults: KeyValueStore
  let store: Store
  let coordinator: Coordinator
  let audioPlayer: AudioPlayer
  let network: Network
  let alarmService: AlarmService
  let timeService: CountdownViewModel

  init() {
    let logger = Logger(modelContainer: .log)
    let persistence = Persistence(modelContainer: .main, logger: logger)

    do {
      try AudioFileManager.ensureSetup()
    } catch {
      logger.log(.error(AppContainerError.audioStorageUnavailable.localizedDescription))
    }

    let defaults: KeyValueStore = UserDefaults.standard

    self.logger = logger
    self.persistence = persistence
    self.defaults = defaults
    self.store = Store(defaults: defaults)
    self.coordinator = Coordinator()
    self.audioPlayer = AudioPlayer()
    self.network = Network()
    self.alarmService = AlarmService(logger: logger)
    let countdownPersistence = CountdownPersistence(persistence: persistence)
    self.timeService = CountdownViewModel(
      alarmService: CountdownAlarm(logger: logger),
      persistenceService: countdownPersistence,
      historyService: CountdownHistory(persistenceService: countdownPersistence),
      runtime: CountdownRuntime(),
      recovery: CountdownRecovery(),
      sessionMachine: CountdownSession(),
      interactor: CountdownCoordinator(logger: logger)
    )

    observeStore()

    Task { [persistence] in
      await persistence.ensureUser()
      await persistence.migrateStandaloneDreamsToNotes()
    }
  }

  func syncRoot() {
    coordinator.updateRoot(entitlementState: store.entitlementState)
  }

  private func observeStore() {
    withObservationTracking {
      syncRoot()
    } onChange: { [weak self] in
      Task { @MainActor [weak self] in
        self?.observeStore()
      }
    }
  }

}
