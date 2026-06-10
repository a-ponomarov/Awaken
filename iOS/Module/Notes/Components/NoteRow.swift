//
//  NoteRow.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 6/10/2026.
//

import SwiftUI

struct NoteRow: View {

  let note: Note

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 6) {
        Text(previewText)
          .font(AppFont.bodyMedium)
          .foregroundStyle(previewColor)
          .lineLimit(3)
          .fixedSize(horizontal: false, vertical: true)

        Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
          .font(AppFont.caption)
          .foregroundStyle(AppColors.secondary)
      }

      Spacer(minLength: AppLayout.spacing * 3)

      if audioCount > 0 {
        HStack(spacing: 4) {
          Image(systemName: "waveform")
          if audioCount > 1 {
            Text("\(audioCount)")
          }
        }
        .font(AppFont.caption)
        .foregroundStyle(AppColors.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(AppLayout.cardPadding)
    .cardStyle()
  }

  private var previewText: String {
    let trimmedText = (note.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmedText.isEmpty {
      return trimmedText
    }
    if audioCount > 0 {
      return audioCount == 1 ? "Audio note" : "Audio notes"
    }
    return "Empty note"
  }

  private var audioCount: Int {
    note.dreams.count
  }

  private var previewColor: Color {
    let hasText = !(note.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    return hasText ? AppColors.primary : AppColors.tertiary
  }

}
