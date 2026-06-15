//
//  TimeRecordDetailView.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/12/2026.
//

import SwiftUI

struct TimeRecordDetailView: View {

  private enum Constants {
    static let labelFieldHeight: CGFloat = 56
    static let clearButtonSize: CGFloat = 32
  }

  let timeRecord: TimeRecord
  let note: Note
  let onUpdateLabel: (String) -> Void

  @Environment(\.persistence) private var persistence
  @Environment(AudioPlayer.self) private var audioPlayer
  @Environment(AudioRecorder.self) private var audioRecorder
  @Environment(\.dismiss) private var dismiss
  @State private var labelDraft = ""
  @State private var noteDraft = ""
  @State private var saveTask: Task<Void, Never>?
  @State private var hasLoadedDrafts = false
  @FocusState private var isLabelFocused: Bool

  var body: some View {
    NavigationStack {
      ZStack {
        AppColors.background.ignoresSafeArea()
        GeometryReader { geometry in
          ScrollView {
            VStack(spacing: AppLayout.cardPadding) {
              focusLabelField

              NoteAudioCard(note: note)
              NoteTextEditor(
                text: $noteDraft,
                placeholder: String.focusNotePlaceholder,
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
      .navigationTitle(timeRecord.endedAt?.formatted(date: .abbreviated, time: .shortened) ?? String.timeTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            saveDrafts()
            dismiss()
          } label: {
            Image(systemName: "checkmark")
          }
        }
      }
    }
    .onAppear(perform: loadDraftsIfNeeded)
    .onChange(of: labelDraft) { _, _ in scheduleDraftSave() }
    .onChange(of: noteDraft) { _, _ in scheduleDraftSave() }
    .onDisappear {
      saveTask?.cancel()
      finishRecordingIfNeeded()
      saveDrafts()
      stopPlaybackIfNeeded()
    }
  }

  private var focusLabelField: some View {
    HStack(spacing: 12) {
      TextField(
        "",
        text: $labelDraft,
        prompt: Text(String.timeHistoryTaskPlaceholder).foregroundStyle(AppColors.tertiary)
      )
      .font(AppFont.bodyMedium)
      .foregroundStyle(AppColors.primary)
      .textInputAutocapitalization(.sentences)
      .autocorrectionDisabled()
      .submitLabel(.done)
      .focused($isLabelFocused)
      .onSubmit { isLabelFocused = false }

      if !labelDraft.isEmpty {
        Button {
          labelDraft = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(AppFont.captionMedium)
            .foregroundStyle(AppColors.secondary)
            .frame(width: Constants.clearButtonSize, height: Constants.clearButtonSize)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal, 12)
    .frame(height: Constants.labelFieldHeight)
    .background(AppColors.surface)
    .clipShape(RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous)
        .stroke(isLabelFocused ? AppColors.primary.opacity(0.35) : AppColors.accent, lineWidth: AppLayout.stroke)
    }
  }

  private func editorMinHeight(for size: CGSize) -> CGFloat {
    max(120, size.height - AppLayout.vInset * 2 - 76)
  }

  private func loadDraftsIfNeeded() {
    guard !hasLoadedDrafts else { return }

    labelDraft = timeRecord.taskName
    noteDraft = note.text ?? ""
    hasLoadedDrafts = true
  }

  private func scheduleDraftSave() {
    guard hasLoadedDrafts else { return }

    let label = labelDraft
    let text = noteDraft
    saveTask?.cancel()
    saveTask = Task {
      try? await Task.sleep(for: .seconds(1))
      guard !Task.isCancelled else { return }

      await persistence.updateNote(id: note.id, text: text)
      await MainActor.run {
        onUpdateLabel(label.trimmingCharacters(in: .whitespacesAndNewlines))
      }
    }
  }

  private func saveDrafts() {
    guard hasLoadedDrafts else { return }

    let label = labelDraft.trimmingCharacters(in: .whitespacesAndNewlines)
    let text = noteDraft
    saveTask?.cancel()
    onUpdateLabel(label)
    Task {
      await persistence.updateNote(id: note.id, text: text)
    }
  }

  private func stopPlaybackIfNeeded() {
    if let currentFilename = audioPlayer.url?.lastPathComponent,
       audioFilenames.contains(currentFilename) {
      audioPlayer.stop()
    }
  }

  private func finishRecordingIfNeeded() {
    guard let audioID = audioRecorder.stop() else { return }

    Task {
      await persistence.saveNoteAudio(noteID: note.id, audioID: audioID)
    }
  }

  private var audioFilenames: [String] {
    note.dreams.compactMap(\.audioFilename)
  }

}
