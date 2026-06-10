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
  private let saveRecording: (UUID) async -> Void

  init(
    persistence: Persistence,
    saveRecording: ((Persistence, UUID) async -> Void)? = nil
  ) {
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
      guard let dreamID = audioRecorder.stop() else { return }
      Task { @MainActor in await saveRecording(dreamID) }
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
