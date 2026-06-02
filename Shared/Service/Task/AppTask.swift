//
//  AppTask.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

@MainActor
final class AppTask {

  var currentTask: Task<Void, Never>? {
    didSet { oldValue?.cancel() }
  }

  func schedule(after delay: Duration, work: @escaping @MainActor () async -> Void) {
    currentTask = Task { @MainActor in
      try? await Task.sleep(for: delay)
      guard !Task.isCancelled else { return }
      await work()
    }
  }

  func schedule(every interval: Duration, work: @escaping @MainActor () async -> Void) {
    currentTask = Task { @MainActor in
      while !Task.isCancelled {
        try? await Task.sleep(for: interval)
        guard !Task.isCancelled else { return }
        await work()
      }
    }
  }

}
