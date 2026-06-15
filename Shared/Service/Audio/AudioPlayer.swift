//
//  AudioPlayer.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AVFoundation
import Observation

@MainActor
@Observable
final class AudioPlayer: NSObject {

  var isPlaying = false
  var duration: TimeInterval?

  var url: URL? {
    audioPlayer?.url
  }

  var currentTime: TimeInterval? {
    audioPlayer?.currentTime
  }

  private var audioPlayer: AVAudioPlayer?

  override init() {
    super.init()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleAudioSessionInterruptionNotification),
      name: AVAudioSession.interruptionNotification,
      object: AVAudioSession.sharedInstance()
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func play(url: URL) {
    stop()
    do {
      try activateAudioSession()
      try setupPlayer(url: url)
    } catch {
      print("AudioPlayer: failed to play \(url.lastPathComponent) – \(error.localizedDescription)")
    }
  }

  func play(dream: Dream) {
    stop()
    let url = dream.audioFilename
      .flatMap { AudioFileManager.dir.appendingPathComponent($0) }
      ?? AudioFileManager.fileURL(for: dream.id)
    guard FileManager.default.fileExists(atPath: url.path) else { return }
    do {
      try activateAudioSession()
      try setupPlayer(url: url)
    } catch {
      print("AudioPlayer: failed to play dream – \(error.localizedDescription)")
    }
  }

  func seek(to progress: Double) {
    guard let player = audioPlayer, player.duration > 0 else { return }
    player.currentTime = progress * player.duration
  }

  func pause() {
    audioPlayer?.pause()
    setupPlayingState()
  }

  func stop() {
    audioPlayer?.stop()
    audioPlayer = nil
    duration = nil
    setupPlayingState()
  }

  private func setupPlayingState() {
    isPlaying = audioPlayer?.isPlaying ?? false
  }

  @objc
  nonisolated private func handleAudioSessionInterruptionNotification(_ notification: Notification) {
    let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt

    Task { @MainActor in
      handleAudioSessionInterruption(typeValue: typeValue)
    }
  }

  private func handleAudioSessionInterruption(typeValue: UInt?) {
    guard let typeValue,
          let type = AVAudioSession.InterruptionType(rawValue: typeValue)
    else {
      return
    }

    switch type {
    case .began:
      audioPlayer?.pause()
      isPlaying = false
    case .ended:
      setupPlayingState()
    @unknown default:
      setupPlayingState()
    }
  }

  private func activateAudioSession() throws {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(
      .playback,
      mode: .default,
      policy: .longFormAudio,
      options: []
    )
    try session.setActive(true)
  }

  private func setupPlayer(url: URL) throws {
    let audioPlayer = try AVAudioPlayer(contentsOf: url)
    self.audioPlayer = audioPlayer
    audioPlayer.delegate = self

    duration = audioPlayer.duration
    audioPlayer.play()

    setupPlayingState()
  }

}

// MARK: - AVAudioPlayerDelegate

extension AudioPlayer: AVAudioPlayerDelegate {

  nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    Task { @MainActor in
      setupPlayingState()
    }
  }

}
