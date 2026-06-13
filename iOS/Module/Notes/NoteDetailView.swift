//
//  NoteDetailView.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/10/2026.
//

import SwiftUI

struct NoteDetailView: View {

  let note: Note

  @Environment(\.persistence) private var persistence
  @Environment(AudioPlayer.self) private var audioPlayer
  @Environment(\.dismiss) private var dismiss
  @State private var draftText = ""
  @State private var saveTask: Task<Void, Never>?
  @State private var isShowingActions = false
  @State private var isDeleting = false
  @State private var hasLoadedDraft = false

  var body: some View {
    NavigationStack {
      ZStack {
        AppColors.background.ignoresSafeArea()
        GeometryReader { geometry in
          ScrollView {
            VStack(spacing: AppLayout.cardPadding) {
              NoteAudioCard(note: note)
              NoteTextEditor(
                text: $draftText,
                placeholder: String.notePlaceholder,
                minHeight: editorMinHeight(for: geometry.size)
              )
            }
            .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .top)
            .padding(.horizontal, AppLayout.cardPadding)
            .padding(.vertical, AppLayout.vInset)
          }
          .scrollDismissesKeyboard(.interactively)
        }
      }
      .navigationTitle(note.createdAt.formatted(date: .abbreviated, time: .shortened))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "checkmark")
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            isShowingActions = true
          } label: {
            Image(systemName: "ellipsis")
          }
        }
      }
      .alert(Text(verbatim: ""), isPresented: $isShowingActions) {
        Button(String.delete, role: .destructive) {
          deleteNote()
        }
        Button(String.cancel, role: .cancel) {}
      }
    }
    .onAppear(perform: loadDraftIfNeeded)
    .onChange(of: draftText) { _, _ in
      scheduleDraftSave()
    }
    .onDisappear {
      saveTask?.cancel()
      guard !isDeleting else { return }
      saveDraft()
    }
  }

  private func editorMinHeight(for size: CGSize) -> CGFloat {
    max(120, size.height - AppLayout.vInset * 2)
  }

  private func loadDraftIfNeeded() {
    guard !hasLoadedDraft else { return }

    draftText = note.text ?? ""
    hasLoadedDraft = true
  }

  private func scheduleDraftSave() {
    guard hasLoadedDraft else { return }

    let text = draftText
    saveTask?.cancel()
    saveTask = Task {
      try? await Task.sleep(for: .seconds(1))
      guard !Task.isCancelled else { return }

      await persistence.updateNote(id: note.id, text: text)
    }
  }

  private func saveDraft() {
    let text = draftText
    saveTask?.cancel()
    Task {
      await persistence.updateNote(id: note.id, text: text)
    }
  }

  private func deleteNote() {
    isDeleting = true
    saveTask?.cancel()
    stopPlaybackIfNeeded()

    Task {
      await persistence.deleteNote(id: note.id)
      await MainActor.run {
        dismiss()
      }
    }
  }

  private func stopPlaybackIfNeeded() {
    if let currentFilename = audioPlayer.url?.lastPathComponent,
       audioFilenames.contains(currentFilename) {
      audioPlayer.stop()
    }
  }

  private var audioFilenames: [String] {
    note.dreams.compactMap(\.audioFilename)
  }

}
