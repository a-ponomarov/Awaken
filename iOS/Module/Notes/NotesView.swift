//
//  NotesView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 6/10/2026.
//

import SwiftData
import SwiftUI

struct NotesView: View {

  @Environment(\.persistence) private var persistence
  @Environment(Coordinator.self) private var coordinator
  @Environment(AudioPlayer.self) private var audioPlayer
  @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]
  @State private var pendingNoteID: UUID?

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()
      NotesList(
        notes: notes,
        onSelect: coordinator.showNoteDetail,
        onDelete: deleteNote
      )
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(action: createNote) {
          Image(systemName: "plus")
        }
        .accessibilityLabel(String.newNote)
      }
    }
    .onChange(of: notes.map(\.id)) { _, _ in
      openPendingNoteIfNeeded()
    }
  }

  private func createNote() {
    Task {
      guard let noteID = await persistence.createNote(text: "") else { return }

      await MainActor.run {
        pendingNoteID = noteID
        openPendingNoteIfNeeded()
      }
    }
  }

  private func deleteNote(_ note: Note) {
    stopPlaybackIfNeeded(for: note)

    Task {
      await persistence.deleteNote(id: note.id)
    }
  }

  private func openPendingNoteIfNeeded() {
    guard let pendingNoteID,
          let note = notes.first(where: { $0.id == pendingNoteID })
    else {
      return
    }

    self.pendingNoteID = nil
    coordinator.showNoteDetail(note)
  }

  private func stopPlaybackIfNeeded(for note: Note) {
    if let currentFilename = audioPlayer.url?.lastPathComponent,
       audioFilenames(for: note).contains(currentFilename) {
      audioPlayer.stop()
    }
  }

  private func audioFilenames(for note: Note) -> [String] {
    note.dreams.compactMap(\.audioFilename)
  }

}
