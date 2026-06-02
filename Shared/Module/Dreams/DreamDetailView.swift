//
//  DreamDetailView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct DreamDetailView: View {

  let dream: Dream
  @Environment(AudioPlayer.self) private var audioPlayer
  @Environment(\.persistence) private var persistence
  @Environment(\.dismiss) private var dismiss
  @State private var isShowingActions = false

  var body: some View {
    NavigationStack {
      ZStack {
        ThemeGradient()
        DreamRow(dream: dream, showsDetails: true, audioPlayer: audioPlayer)
          .padding(.horizontal, AppLayout.cardPadding)
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
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
        Button("Delete", role: .destructive) {
          deleteDream()
        }
        Button("Cancel", role: .cancel) {}
      }
    }
  }

  private func deleteDream() {
    if audioPlayer.url?.lastPathComponent.contains(dream.id.uuidString) == true {
      audioPlayer.stop()
    }

    Task {
      await persistence.deleteDream(id: dream.id)
      dismiss()
    }
  }

}
