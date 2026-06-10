//
//  DreamRow.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct DreamRow: View {

  let dream: Dream
  let showsDetails: Bool
  let audioPlayer: AudioPlayer
  @Environment(\.persistence) private var persistence

  var body: some View {
    DreamRowContent(
      dream: dream,
      showsDetails: showsDetails,
      audioPlayer: audioPlayer,
      persistence: persistence
    )
  }

}

private struct DreamRowContent: View {

  let dream: Dream
  let showsDetails: Bool
  let audioPlayer: AudioPlayer
  @State private var model: DreamRowModel
  @State private var timerTask: Task<Void, Never>?

  init(
    dream: Dream,
    showsDetails: Bool,
    audioPlayer: AudioPlayer,
    persistence: Persistence
  ) {
    self.dream = dream
    self.showsDetails = showsDetails
    self.audioPlayer = audioPlayer
    _model = State(
      initialValue: DreamRowModel(
        dream: dream,
        audioPlayer: audioPlayer,
        persistence: persistence
      )
    )
  }

  var body: some View {
    ZStack {
      @Bindable var bindableModel = model

      VStack {
        HStack {
          DateLabel(date: dream.createdAt)
          Spacer()
          PlayButton(
            isPlaying: model.isPlaying,
            progress: model.isCurrent ? $bindableModel.progress : .constant(0),
            completion: model.handlePlayButton
          )
        }
        if showsDetails, let samples = dream.waveform {
          WaveformView(
            samples: samples,
            progress: $bindableModel.progress,
            isDragging: $bindableModel.isDragging,
            onSeek: model.handleWaveformSeek
          )
        }
      }
      .padding(AppLayout.cardPadding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .cardStyle(cornerRadius: AppLayout.cardRadius)
    }
    .onAppear {
      timerTask = Task { @MainActor in
        while !Task.isCancelled {
          try? await Task.sleep(for: .milliseconds(50))
          model.syncProgress()
        }
      }
    }
    .onDisappear {
      timerTask?.cancel()
      timerTask = nil
    }
  }

}
