//
//  AudioRecorder.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AVFoundation
import Observation

@Observable
final class AudioRecorder {

  private enum Constants {

    static let sampleRate = 16_000
    static let channelCount = 1
    static let bitRate = 32_000

  }

  var isRecording = false

  private var recorder: AVAudioRecorder?
  private var currentDreamID: UUID?

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
    } catch {
      print("AudioRecorder: failed to start recording – \(error.localizedDescription)")
    }
  }

  func stop() -> UUID? {
    guard let recorder = recorder else { return nil }

    recorder.stop()
    isRecording = false
    try? AVAudioSession.sharedInstance().setActive(false)

    defer {
      self.recorder = nil
    }

    return currentDreamID
  }

}
