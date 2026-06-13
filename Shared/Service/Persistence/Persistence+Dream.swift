//
//  Persistence+Dream.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

extension Persistence {

  /// Persists a dream record and extracts waveform data for its audio file.
  func saveDream(id: UUID, sleep: Sleep?) {
    let filename = "\(id.uuidString).m4a"
    let dream = Dream(audioFilename: filename, sleep: sleep)
    dream.user = user
    dream.waveform = WaveformCalculator.extract(
      from: AudioFileManager.fileURL(for: id)
    )
    dream.id = id
    modelContext.insert(dream)
    save()
  }

  func saveDream(id: UUID) {
    saveDream(id: id, sleep: nil)
  }

  /// Deletes all dream records with the given identifier and removes related
  /// audio files.
  func deleteDream(id: UUID) {
    do {
      let descriptor = FetchDescriptor<Dream>(
        predicate: #Predicate {
          $0.id == id
        }
      )
      let dreams = try modelContext.fetch(descriptor)
      for dream in dreams {
        if let audioFilename = dream.audioFilename {
          let url = AudioFileManager.dir.appendingPathComponent(audioFilename)
          if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
          }
        }
        modelContext.delete(dream)
      }
      save()
    } catch {
      logger?.log(
        .error(PersistenceError.deleteDreamFailed.localizedDescription)
      )
    }
  }

}
