//
//  RecordButtonModel.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AVFoundation
import Observation

@Observable
@MainActor
final class RecordButtonModel {

  var audioRecorder = AudioRecorder()
  var showPermissionAlert = false
  private let persistence: Persistence

  init(persistence: Persistence) {
    self.persistence = persistence
  }

  var isRecording: Bool {
    audioRecorder.isRecording
  }

  func action() {
    if audioRecorder.isRecording {
      guard let dreamID = audioRecorder.stop() else { return }
      Task { @MainActor in await persistence.saveDream(id: dreamID) }
    } else {
      startRecording()
    }
  }

  private func startRecording() {
    switch AVAudioApplication.shared.recordPermission {
    case .granted:
      audioRecorder.start()
    case .denied:
      showPermissionAlert = true
    case .undetermined:
      AVAudioApplication.requestRecordPermission { granted in
        Task { @MainActor in
          if granted {
            self.audioRecorder.start()
          } else {
            self.showPermissionAlert = true
          }
        }
      }
    @unknown default:
      showPermissionAlert = true
    }
  }

}
