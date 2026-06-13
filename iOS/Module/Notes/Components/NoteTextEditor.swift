//
//  NoteTextEditor.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/12/2026.
//

import SwiftUI

private struct NoteTextEditorHeightPreferenceKey: PreferenceKey {

  static var defaultValue: CGFloat = 0

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = max(value, nextValue())
  }

}

struct NoteTextEditor: View {

  @Binding var text: String

  let placeholder: String
  let minHeight: CGFloat

  @State private var editorHeight: CGFloat = 0

  var body: some View {
    ZStack(alignment: .topLeading) {
      sizingText

      if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        Text(placeholder)
          .font(AppFont.input)
          .foregroundStyle(AppColors.tertiary)
          .padding(.top, 8)
          .allowsHitTesting(false)
          .padding(.horizontal, 5)
      }

      TextEditor(text: $text)
        .font(AppFont.input)
        .foregroundStyle(AppColors.primary)
        .tint(AppColors.primary)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .frame(maxWidth: .infinity)
        .frame(height: max(minHeight, editorHeight))
    }
    .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
    .onPreferenceChange(NoteTextEditorHeightPreferenceKey.self) { height in
      editorHeight = height
    }
  }

  private var sizingText: some View {
    Text(text.isEmpty ? " " : text + "\n")
      .font(AppFont.input)
      .foregroundStyle(.clear)
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .padding(.top, 8)
      .background {
        GeometryReader { geometry in
          Color.clear.preference(
            key: NoteTextEditorHeightPreferenceKey.self,
            value: geometry.size.height
          )
        }
      }
      .allowsHitTesting(false)
  }

}
