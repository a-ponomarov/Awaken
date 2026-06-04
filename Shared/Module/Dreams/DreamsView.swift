//
//  DreamsView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftData
import SwiftUI

struct DreamsView: View {

  @Environment(AudioPlayer.self) private var audioPlayer
  @Environment(\.persistence) private var persistence
  #if os(iOS)
  @Environment(Coordinator.self) private var coordinator
  #elseif os(watchOS)
  @Environment(Coordinator.self) private var coordinator
  #endif

  var body: some View {
    DreamsViewContent(
      audioPlayer: audioPlayer,
      persistence: persistence,
      coordinator: coordinator
    )
  }

}

private struct DreamsViewContent: View {

  @Query(sort: \Dream.createdAt, order: .reverse) private var dreams: [Dream]

  let audioPlayer: AudioPlayer
  let persistence: Persistence
  let coordinator: Coordinator

  init(
    audioPlayer: AudioPlayer,
    persistence: Persistence,
    coordinator: Coordinator
  ) {
    self.audioPlayer = audioPlayer
    self.persistence = persistence
    self.coordinator = coordinator
  }

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()
      DreamsList(
        dreams: dreams,
        onSelect: handleDreamSelection,
        onDelete: deleteDream
      )
    }
    #if os(watchOS)
    .ignoresSafeArea(edges: .top)
    #endif
  }

  private func handleDreamSelection(_ dream: Dream) {
    coordinator.showDreamDetail(dream)
  }

  private func deleteDream(_ dream: Dream) {
    if audioPlayer.url?.lastPathComponent.contains(dream.id.uuidString) == true {
      audioPlayer.stop()
    }

    Task {
      await persistence.deleteDream(id: dream.id)
    }
  }

}
