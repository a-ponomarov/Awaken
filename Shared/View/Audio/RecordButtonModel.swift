//
//  RecordButtonModel.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AVFoundation
import Observation

@Observable
@MainActor
final class RecordButtonModel {

  private let audioPlayer: AudioPlayer
  private let audioRecorder: AudioRecorder
  var showPermissionAlert = false
  private let saveRecording: (UUID) async -> Void

  init(
    persistence: Persistence,
    audioPlayer: AudioPlayer,
    audioRecorder: AudioRecorder,
    saveRecording: ((Persistence, UUID) async -> Void)? = nil
  ) {
    self.audioPlayer = audioPlayer
    self.audioRecorder = audioRecorder
    self.saveRecording = { id in
      if let saveRecording {
        await saveRecording(persistence, id)
      } else {
        await persistence.saveDream(id: id)
      }
    }
  }

  var isRecording: Bool {
    audioRecorder.isRecording
  }

  func action() {
    if audioRecorder.isRecording {
      stopRecording()
    } else {
      startRecording()
    }
  }

  func stopRecording() {
    guard let dreamID = audioRecorder.stop() else { return }
    Task { @MainActor in await saveRecording(dreamID) }
  }

  private func startRecording() {
    audioRecorder.didStopRecording = { [saveRecording] id in
      Task { @MainActor in
        await saveRecording(id)
      }
    }

    switch AVAudioApplication.shared.recordPermission {
    case .granted:
      beginRecording()
    case .denied:
      showPermissionAlert = true
    case .undetermined:
      AVAudioApplication.requestRecordPermission { granted in
        Task { @MainActor in
          if granted {
            self.beginRecording()
          } else {
            self.showPermissionAlert = true
          }
        }
      }
    @unknown default:
      showPermissionAlert = true
    }
  }

  private func beginRecording() {
    audioPlayer.stop()
    audioRecorder.start()
  }

}
