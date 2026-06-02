//
//  Session.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import CoreMotion
import Observation
import WatchKit

private enum SessionError: Error {

  case trackingUnavailable
  case endedUnexpectedly

}

extension SessionError: LocalizedError {

  var errorDescription: String? {
    switch self {
    case .trackingUnavailable:
      return String(localized: "Sleep stage prediction is temporarily unavailable.", comment: "Sleep session error: stage classifier is unavailable")
    case .endedUnexpectedly:
      return String(localized: "The sleep session ended earlier than expected.", comment: "Sleep session error: session terminated prematurely")
    }
  }

}

@Observable
final class Session: NSObject {

  private enum Constants {

    static let duration = 30
    static let windowSize: Double = 610
    static let expireWakeLeadTime: TimeInterval = 61

  }

  var isAlarming = false

  var isPlanned: Bool { session != nil }

  private var heartRates: [HeartRate] = []
  private var accelerations: [Acceleration] = []

  private var didStartDate: Date?
  private var isRunning: Bool { didStartDate != nil }

  private let timerTask = AppTask()
  private let predictLoopTask = AppTask()
  private let expireAlarmTask = AppTask()
  private let healthSource: HealthSource
  private let motionSource: MotionSource
  private let classifier: Classifier
  private let persistence: Persistence
  private let logger: Logger

  private var session: WKExtendedRuntimeSession?

  private var cancelContinuation: CheckedContinuation<Void, Never>?

  private var isAvailable = true

  private var startDate: Date? {
    Calendar.current.date(
      byAdding: .minute,
      value: -Constants.duration,
      to: expireDate
    )
  }

  var wakeStage: WakeStageOption = {
    let rawValue = UserDefaults.standard.string(forKey: StorageKey.wakeStageOption)
    return rawValue.flatMap(WakeStageOption.init(rawValue:)) ?? .dream
  }() {
    didSet {
      UserDefaults.standard.set(wakeStage.rawValue, forKey: StorageKey.wakeStageOption)
    }
  }

  var expireDate: Date = {
    let interval = UserDefaults.standard.value(
      forKey: StorageKey.lastSelectedTime
    ) as? TimeInterval
    return interval.map { Date(timeIntervalSince1970: $0) } ?? .now
  }() {
    didSet {
      UserDefaults.standard.set(
        expireDate.timeIntervalSince1970,
        forKey: StorageKey.lastSelectedTime
      )
    }
  }

  // MARK: - Public

  func handle(extendedRuntimeSession: WKExtendedRuntimeSession) {
    extendedRuntimeSession.delegate = self
    session = extendedRuntimeSession
    logger.log(.relaunch)
  }

  func start(at date: Date) async {
    expireDate = date
    adjustExpireDate()
    if isPlanned { await cancel() }
    await start()
  }

  func toggle() async {
    isPlanned ? await cancel() : await start()
  }

  // MARK: - Private

  init(
    healthSource: HealthSource,
    motionSource: MotionSource,
    classifier: Classifier,
    persistence: Persistence,
    logger: Logger
  ) {
    self.healthSource = healthSource
    self.motionSource = motionSource
    self.classifier = classifier
    self.persistence = persistence
    self.logger = logger
    super.init()
    startTimer()
  }

  private func start() async {
    guard isAvailable else { return }
    isAvailable = false
    defer { isAvailable = true }

    adjustExpireDate()

    guard let startDate else { return }

    classifier.train()

    await persistence.createSleep(endDate: expireDate)

    session = WKExtendedRuntimeSession()
    session?.delegate = self
    session?.start(at: startDate)

    logger.log(.planned(startDate))
  }

  private func cancel() async {
    guard isAvailable, session != nil else { return }
    isAvailable = false
    defer { isAvailable = true }
    await withCheckedContinuation { continuation in
      cancelContinuation = continuation
      session?.invalidate()
    }
  }

  private func resetSessionState() async {
    session = nil
    didStartDate = nil
    predictLoopTask.currentTask = nil
    accelerations.removeAll()
    heartRates.removeAll()
    expireAlarmTask.currentTask = nil
    isAlarming = false

    await motionSource.stop()
    healthSource.delegate = nil
    await persistence.finishSession()

    cancelContinuation?.resume()
    cancelContinuation = nil
  }

  private func wake() async {
    isAlarming = true
    session?.notifyUser(hapticType: .start)
    logger.log(.wakeUp)
  }

  private func adjustExpireDate() {
    expireDate = expireDate.nextOccurrence(threshold: Constants.duration)
  }

  private func startTimer() {
    guard timerTask.currentTask == nil else { return }
    timerTask.schedule(every: .seconds(1)) { [unowned self] in
      guard !isPlanned else { return }
      adjustExpireDate()
    }
  }

  private func intervalSinceStartDate(from date: Date = .now) -> TimeInterval? {
    guard let didStartDate else { return nil }
    return date.timeIntervalSince(didStartDate)
  }

  private func startLoop() {
    predictLoopTask.schedule(every: .seconds(Constants.duration)) { [unowned self] in
      await predict()
    }
  }

  private func predict() async {
    guard let time = intervalSinceStartDate(),
          time >= Constants.windowSize
    else { return }

    let window = time - Constants.windowSize

    accelerations = accelerations.filter { $0.timestamp >= window }
    heartRates = heartRates.filter { $0.timestamp >= window }

    guard !accelerations.isEmpty, !heartRates.isEmpty else { return }

    let accelerationFeatures = AccelerationExtractor(
      windowSize: Constants.windowSize,
      log: { self.logger.log($0) }
    )
    .extractFeatures(from: accelerations, epochTimestamps: [time])
    let heartRateFeatures = HeartRateExtractor(
      windowSize: Constants.windowSize,
      log: { self.logger.log($0) }
    )
    .extractFeatures(from: heartRates, epochTimestamps: [time])
    let features = accelerationFeatures + heartRateFeatures

    do {
      let (stage, probability) = try await classifier.predict(
        features: features
      )
      await persistence.addSnapshot(stage: stage, features: features)
      logger.log(.prediction(stage: stage, probability: probability))
      guard let stage = Stage(rawValue: stage),
            wakeStage.matches(stage)
      else { return }
      await wake()
    } catch {
      logger.log(.error(SessionError.trackingUnavailable.localizedDescription))
    }
  }

}

extension Session: WKExtendedRuntimeSessionDelegate {

  nonisolated
  func extendedRuntimeSessionWillExpire(_ session: WKExtendedRuntimeSession) { }

  nonisolated
  func extendedRuntimeSessionDidStart(_ session: WKExtendedRuntimeSession) {
    Task { await didStart() }
  }

  private func didStart() async {
    guard let sleep = await persistence.latestSleepID(),
          let scheduledDate = sleep.scheduledDate
    else { return }

    expireDate = scheduledDate

    let delay = expireDate.timeIntervalSince(.now) - Constants.expireWakeLeadTime
    expireAlarmTask.schedule(after: .seconds(max(0, delay))) { [unowned self] in
      await wake()
    }

    guard !isRunning else { return }
    didStartDate = .now

    await motionSource.start(delegate: self)
    healthSource.start(delegate: self)
    startLoop()

    logger.log(.started)
  }

  nonisolated
  func extendedRuntimeSession(
    _ session: WKExtendedRuntimeSession,
    didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
    error: Error?
  ) {
    Task { await didInvalidate(reason: reason, error: error) }
  }

  private func didInvalidate(
    reason: WKExtendedRuntimeSessionInvalidationReason,
    error: Error?
  ) async {
    if error != nil { logger.log(.error(SessionError.endedUnexpectedly.localizedDescription)) }
    logger.log(.end(code: reason.rawValue.description))
    await resetSessionState()
  }

}

extension Session: MotionSource.Delegate {

  nonisolated func motionDidUpdate(_ motions: [Motion]) {
    Task { for motion in motions { await addMotion(motion) } }
  }

  func addMotion(_ motion: Motion) {
    guard isRunning,
          let timestamp = intervalSinceStartDate(from: motion.date)
    else { return }
    let acceleration = motion.acceleration
    accelerations.append(
      .init(
        timestamp: timestamp,
        x: acceleration.x,
        y: acceleration.y,
        z: acceleration.z
      )
    )
  }

}

extension Session: HealthSource.Delegate {

  nonisolated func heartRateDidUpdate(bpm: Double, date: Date) {
    Task { await addHeartRate(bpm, date: date) }
  }

  func addHeartRate(_ bpm: Double, date: Date) {
    guard isRunning,
          let timestamp = intervalSinceStartDate(from: date)
    else { return }
    heartRates.append(HeartRate(timestamp: timestamp, value: bpm))
  }

}
