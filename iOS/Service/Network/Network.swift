//
//  Network.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Network
import Observation

@MainActor
@Observable
final class Network {

  private let monitor = NWPathMonitor()

  private(set) var isConnected = false

  init() {
    monitor.pathUpdateHandler = { [weak self] path in
      Task { @MainActor in
        self?.isConnected = path.status == .satisfied
      }
    }
    monitor.start(queue: DispatchQueue.global(qos: .background))
  }

  deinit {
    monitor.cancel()
  }

}
