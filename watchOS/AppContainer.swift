//
//  AppContainer.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

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
  let coordinator = Coordinator()
  let audioPlayer = AudioPlayer()
  let network = Network()
  let healthSource = HealthSource()
  let motionSource = MotionSource()
  lazy var classifier = Classifier(
    persistence: persistence,
    healthSource: healthSource,
    logger: logger
  )
  lazy var session = Session(
    healthSource: healthSource,
    motionSource: motionSource,
    classifier: classifier,
    persistence: persistence,
    logger: logger
  )

  init() {
    let logger = Logger(modelContainer: .log)
    let persistence = Persistence(modelContainer: .main, logger: logger)

    do {
      try AudioFileManager.ensureSetup()
    } catch {
      logger.log(.error(AppContainerError.audioStorageUnavailable.localizedDescription))
    }

    self.logger = logger
    self.persistence = persistence

    Task { [persistence] in
      await persistence.ensureUser()
    }
  }

}
