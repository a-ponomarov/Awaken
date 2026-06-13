//
//  QueuedTimeEditorView.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/12/2026.
//

import SwiftUI

struct QueuedTimeEditorView: View {

  let initialTitle: String
  let onCancel: () -> Void
  let onSave: (String) -> Void

  @State private var title: String
  @FocusState private var isTitleFocused: Bool

  var body: some View {
    NavigationStack {
      VStack(spacing: AppLayout.spacing * 6) {
        TimeTextField(
          title: String.timeHistoryTaskPlaceholder,
          text: $title,
          autocapitalization: .sentences,
          isEnabled: true,
          focus: $isTitleFocused,
          onSubmit: saveTask,
          onClear: { title = "" }
        )
      }
      .padding(.horizontal, AppLayout.cardPadding)
      .padding(.top, AppLayout.spacing * 4)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(String.cancel, action: onCancel).tint(.white)
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button(String.done, action: saveTask)
            .tint(.white)
            .disabled(!canSaveTask)
        }
      }
    }
    .background(AppColors.background.ignoresSafeArea())
    .onAppear {
      title = initialTitle
      isTitleFocused = true
    }
    .onChange(of: initialTitle) { _, newTitle in
      title = newTitle
    }
  }

  init(
    initialTitle: String = "",
    onCancel: @escaping () -> Void,
    onSave: @escaping (String) -> Void
  ) {
    self.initialTitle = initialTitle
    self.onCancel = onCancel
    self.onSave = onSave
    _title = State(initialValue: initialTitle)
  }

  private var canSaveTask: Bool {
    !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private func saveTask() {
    guard canSaveTask else { return }
    onSave(title)
  }

}
