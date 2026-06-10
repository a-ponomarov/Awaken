//
//  Persistence+Note.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 6/10/2026.
//

import Foundation
import SwiftData

extension Persistence {

  /// Creates a note and returns its identifier when persistence succeeds.
  func createNote(text: String? = nil) -> UUID? {
    let note = Note(text: text)
    let id = note.id
    modelContext.insert(note)
    save()
    return id
  }

  /// Updates the text for a note with the given identifier.
  func updateNote(id: UUID, text: String) {
    guard let note = fetchNote(id: id) else { return }

    note.text = text
    note.updatedAt = .now
    save()
  }

  /// Deletes a note and all audio files attached to its dream records.
  func deleteNote(id: UUID) {
    guard let note = fetchNote(id: id) else { return }

    deleteAudioFiles(for: note.dreams)
    modelContext.delete(note)
    save()
  }

  /// Adds a recorded audio file to the note with the given identifier.
  func saveNoteAudio(noteID: UUID, audioID: UUID) {
    guard let note = fetchNote(id: noteID) else { return }

    let filename = "\(audioID.uuidString).m4a"
    let dream = Dream(audioFilename: filename)
    dream.id = audioID
    dream.note = note
    dream.waveform = WaveformCalculator.extract(
      from: AudioFileManager.fileURL(for: audioID)
    )

    modelContext.insert(dream)
    note.dreams.append(dream)
    note.updatedAt = .now
    save()
  }

  /// Deletes one audio record and its backing file.
  func deleteNoteAudio(id: UUID) {
    guard let dream = fetchDream(id: id) else { return }

    deleteAudioFile(for: dream)
    dream.note?.updatedAt = .now
    modelContext.delete(dream)
    save()
  }

  /// Migrates existing standalone dream records into one-note-per-record notes.
  func migrateStandaloneDreamsToNotes() {
    do {
      let descriptor = FetchDescriptor<Dream>(
        predicate: #Predicate {
          $0.note == nil
        }
      )
      let dreams = try modelContext.fetch(descriptor)
      guard !dreams.isEmpty else { return }

      for dream in dreams {
        let note = Note()
        note.createdAt = dream.createdAt
        note.dreams = [dream]
        dream.note = note
        modelContext.insert(note)
      }

      save()
    } catch {
      logger?.log(.error(PersistenceError.migrateDreamsToNotesFailed.localizedDescription))
    }
  }

  private func fetchNote(id: UUID) -> Note? {
    do {
      var descriptor = FetchDescriptor<Note>(
        predicate: #Predicate {
          $0.id == id
        }
      )
      descriptor.fetchLimit = 1
      return try modelContext.fetch(descriptor).first
    } catch {
      logger?.log(.error(PersistenceError.fetchNoteFailed.localizedDescription))
      return nil
    }
  }

  private func fetchDream(id: UUID) -> Dream? {
    do {
      var descriptor = FetchDescriptor<Dream>(
        predicate: #Predicate {
          $0.id == id
        }
      )
      descriptor.fetchLimit = 1
      return try modelContext.fetch(descriptor).first
    } catch {
      logger?.log(.error(PersistenceError.fetchDreamFailed.localizedDescription))
      return nil
    }
  }

  private func deleteAudioFiles(for dreams: [Dream]) {
    for dream in dreams {
      deleteAudioFile(for: dream)
    }
  }

  private func deleteAudioFile(for dream: Dream) {
    guard let audioFilename = dream.audioFilename else { return }

    let url = AudioFileManager.dir.appendingPathComponent(audioFilename)
    if FileManager.default.fileExists(atPath: url.path) {
      try? FileManager.default.removeItem(at: url)
    }
  }

}
