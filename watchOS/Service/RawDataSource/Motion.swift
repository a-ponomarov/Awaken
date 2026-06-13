//
//  Motion.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import CoreMotion

actor MotionSource {

  nonisolated protocol Delegate: Sendable {

    func motionDidUpdate(_ motions: [Motion])

  }

  private var delegate: Delegate?

  private var manager: CMMotionManager?
  private var queue: OperationQueue?

  private static let sampleRate: Double = 50.0
  private let interval: TimeInterval = 1.0 / MotionSource.sampleRate
  private let bufferLimit = Int(MotionSource.sampleRate)

  private var buffer: [Motion] = []

  func stop() {
    guard let manager else { return }
    manager.stopAccelerometerUpdates()
    self.manager = nil
    queue = nil
    buffer.removeAll()
    delegate = nil
  }

  func start(delegate: Delegate) {
    stop()
    self.delegate = delegate
    startUpdates()
  }

  private func startUpdates() {
    let manager = CMMotionManager()
    guard manager.isAccelerometerAvailable else { return }

    buffer.reserveCapacity(bufferLimit)

    let queue = OperationQueue()
    self.queue = queue

    manager.accelerometerUpdateInterval = interval
    manager.startAccelerometerUpdates(to: queue) { [weak self] data, _ in
      guard let data else { return }
      self?.handleUpdate(Motion(acceleration: data.acceleration))
    }
    self.manager = manager
  }

  nonisolated private func handleUpdate(_ data: Motion) {
    Task { [unowned self] in await process(data) }
  }

  private func process(_ data: Motion) {
    buffer.append(data)
    guard buffer.count >= bufferLimit else { return }
    flush()
  }

  private func flush() {
    guard !buffer.isEmpty else { return }
    delegate?.motionDidUpdate(buffer)
    buffer.removeAll(keepingCapacity: true)
  }

}

struct Motion: Equatable {

  let date = Date()
  let acceleration: CMAcceleration

  static func == (lhs: Motion, rhs: Motion) -> Bool {
    lhs.date == rhs.date
  }

}
