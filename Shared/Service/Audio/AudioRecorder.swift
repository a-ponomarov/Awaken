//
//  AudioRecorder.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AVFoundation
import Observation

@Observable
@MainActor
final class AudioRecorder {

  private enum Constants {

    static let sampleRate = 16_000
    static let channelCount = 1
    static let bitRate = 32_000

  }

  var isRecording = false
  var didStopRecording: ((UUID) -> Void)?

  private var recorder: AVAudioRecorder?
  private var currentDreamID: UUID?
  private var interruptionObserver: NSObjectProtocol?

  func start() {
    guard !isRecording else { return }

    let dreamID = UUID()
    currentDreamID = dreamID
    let targetURL = AudioFileManager.fileURL(for: dreamID)

    let settings: [String: Any] = [
      AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
      AVSampleRateKey: Constants.sampleRate,
      AVNumberOfChannelsKey: Constants.channelCount,
      AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
      AVEncoderBitRateKey: Constants.bitRate
    ]

    do {
      try AVAudioSession.sharedInstance().setCategory(.record)
      try AVAudioSession.sharedInstance().setActive(true)

      recorder = try AVAudioRecorder(url: targetURL, settings: settings)
      recorder?.record()

      isRecording = true
      observeAudioSessionInterruptions()
    } catch {
      print("AudioRecorder: failed to start recording – \(error.localizedDescription)")
      currentDreamID = nil
    }
  }

  func stop() -> UUID? {
    finishRecording(notify: false)
  }

  private func finishRecording(notify: Bool) -> UUID? {
    guard let recorder = recorder else { return nil }

    recorder.stop()
    isRecording = false
    try? AVAudioSession.sharedInstance().setActive(false)
    removeAudioSessionObservers()

    defer {
      self.recorder = nil
      self.currentDreamID = nil
    }

    guard let currentDreamID else { return nil }
    if notify {
      didStopRecording?(currentDreamID)
    }
    return currentDreamID
  }

  private func observeAudioSessionInterruptions() {
    removeAudioSessionObservers()
    interruptionObserver = NotificationCenter.default.addObserver(
      forName: AVAudioSession.interruptionNotification,
      object: AVAudioSession.sharedInstance(),
      queue: .main
    ) { [weak self] notification in
      guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
            AVAudioSession.InterruptionType(rawValue: typeValue) == .began
      else {
        return
      }

      Task { @MainActor in
        _ = self?.finishRecording(notify: true)
      }
    }
  }

  private func removeAudioSessionObservers() {
    if let interruptionObserver {
      NotificationCenter.default.removeObserver(interruptionObserver)
      self.interruptionObserver = nil
    }
  }

}
