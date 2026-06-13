//
//  DreamRow.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct DreamRow: View {

  let dream: Dream
  let showsDetails: Bool
  let audioPlayer: AudioPlayer
  @Environment(AudioRecorder.self) private var audioRecorder
  @Environment(\.persistence) private var persistence

  var body: some View {
    DreamRowContent(
      dream: dream,
      showsDetails: showsDetails,
      audioPlayer: audioPlayer,
      audioRecorder: audioRecorder,
      persistence: persistence
    )
  }

}

private struct DreamRowContent: View {

  let dream: Dream
  let showsDetails: Bool
  let audioPlayer: AudioPlayer
  let audioRecorder: AudioRecorder
  @State private var model: DreamRowModel
  @State private var timerTask: Task<Void, Never>?

  init(
    dream: Dream,
    showsDetails: Bool,
    audioPlayer: AudioPlayer,
    audioRecorder: AudioRecorder,
    persistence: Persistence
  ) {
    self.dream = dream
    self.showsDetails = showsDetails
    self.audioPlayer = audioPlayer
    self.audioRecorder = audioRecorder
    _model = State(
      initialValue: DreamRowModel(
        dream: dream,
        audioPlayer: audioPlayer,
        audioRecorder: audioRecorder,
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
            progress: $bindableModel.progress,
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
