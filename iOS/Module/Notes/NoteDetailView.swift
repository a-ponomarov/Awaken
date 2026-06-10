//
//  NoteDetailView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 6/10/2026.
//

import SwiftUI

private struct NoteEditorHeightPreferenceKey: PreferenceKey {

  static var defaultValue: CGFloat = 0

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = max(value, nextValue())
  }

}

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
  @State private var editorHeight: CGFloat = 0

  var body: some View {
    NavigationStack {
      ZStack {
        AppColors.background.ignoresSafeArea()
        GeometryReader { geometry in
          ScrollView {
            VStack(spacing: AppLayout.cardPadding) {
              NoteAudioCard(note: note)
              noteEditor(minHeight: editorMinHeight(for: geometry.size))
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

  private func noteEditor(minHeight: CGFloat) -> some View {
    ZStack(alignment: .topLeading) {
      editorSizingText

      if draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        Text(String.notePlaceholder)
          .font(AppFont.input)
          .foregroundStyle(AppColors.tertiary)
          .padding(.top, 8)
          .allowsHitTesting(false)
          .padding(.horizontal, 5)
      }

      TextEditor(text: $draftText)
        .font(AppFont.input)
        .foregroundStyle(AppColors.primary)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .frame(maxWidth: .infinity)
        .frame(height: max(minHeight, editorHeight))
    }
    .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
    .onPreferenceChange(NoteEditorHeightPreferenceKey.self) { height in
      editorHeight = height
    }
  }

  private var editorSizingText: some View {
    Text(draftText.isEmpty ? " " : draftText + "\n")
      .font(AppFont.input)
      .foregroundStyle(.clear)
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .padding(.top, 8)
      .background {
        GeometryReader { geometry in
          Color.clear.preference(
            key: NoteEditorHeightPreferenceKey.self,
            value: geometry.size.height
          )
        }
      }
      .allowsHitTesting(false)
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
