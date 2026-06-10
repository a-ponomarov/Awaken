//
//  DreamRowModel.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class DreamRowModel {

  let dream: Dream

  var progress = 0.0
  var isDragging = false
  var isShowingActions = false

  private let audioPlayer: AudioPlayer
  private let persistence: Persistence

  init(
    dream: Dream,
    audioPlayer: AudioPlayer,
    persistence: Persistence
  ) {
    self.dream = dream
    self.audioPlayer = audioPlayer
    self.persistence = persistence
  }

  var isCurrent: Bool {
    audioPlayer.url?.lastPathComponent.contains(dream.id.uuidString) ?? false
  }

  var isPlaying: Bool {
    isCurrent ? audioPlayer.isPlaying : false
  }

  func syncProgress() {
    guard !isDragging, isCurrent,
          let currentTime = audioPlayer.currentTime,
          let duration = audioPlayer.duration,
          duration > 0
    else {
      return
    }
    progress = currentTime / duration
  }

  func handlePlayButton() {
    if isCurrent && audioPlayer.isPlaying {
      audioPlayer.pause()
    } else {
      audioPlayer.play(dream: dream)
      if progress > 0 {
        audioPlayer.seek(to: progress)
      }
    }
  }

  func handleWaveformSeek(_ newProgress: Double) {
    if !isCurrent {
      audioPlayer.play(dream: dream)
    }
    audioPlayer.seek(to: newProgress)
  }

  func deleteDream(dismiss: @escaping @MainActor () -> Void) {
    if isCurrent {
      audioPlayer.stop()
    }
    Task { @MainActor in
      await persistence.deleteDream(id: dream.id)
      dismiss()
    }
  }

}
