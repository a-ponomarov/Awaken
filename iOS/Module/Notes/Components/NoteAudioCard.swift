//
//  NoteAudioCard.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/10/2026.
//

import SwiftUI

struct NoteAudioCard: View {

  let note: Note

  @Environment(\.persistence) private var persistence
  @Environment(AudioPlayer.self) private var audioPlayer
  @Environment(AudioRecorder.self) private var audioRecorder
  @State private var progressByID: [UUID: Double] = [:]
  @State private var draggingID: UUID?
  @State private var timerTask: Task<Void, Never>?

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      RecordButton { persistence, audioID in
        await persistence.saveNoteAudio(noteID: note.id, audioID: audioID)
      }
      .frame(maxWidth: .infinity)
      ForEach(audioRecords, id: \.self) { dream in
        audioRow(for: dream)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .onAppear(perform: startTimer)
    .onDisappear(perform: stopTimer)
  }

  private func audioRow(for dream: Dream) -> some View {
    VStack(spacing: 12) {
      HStack {
        PlayButton(
          isPlaying: isPlaying(dream),
          progress: progressBinding(for: dream),
          completion: { playPause(dream) }
        )
        audioDateLabel(for: dream)
        Spacer()
        Menu {
          Button(role: .destructive) {
            deleteAudio(dream)
          } label: {
            Label(String.deleteAudio, systemImage: "trash")
          }
        } label: {
          Image(systemName: "ellipsis")
            .font(AppFont.captionMedium)
            .foregroundStyle(AppColors.secondary)
            .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String.deleteAudio)
      }

      if let samples = dream.waveform, !samples.isEmpty {
        WaveformView(
          samples: samples,
          progress: progressBinding(for: dream),
          isDragging: draggingBinding(for: dream),
          onSeek: { seek(dream, to: $0) }
        )
      }
    }
    .padding(12)
    .background(AppColors.accent.opacity(0.45))
    .clipShape(RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous))
  }

  private func audioDateLabel(for dream: Dream) -> some View {
    VStack(alignment: .leading) {
      Text(dream.createdAt, style: .date)
        .font(AppFont.subtitle)
        .foregroundStyle(AppColors.primary)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
      Text(dream.createdAt, style: .time)
        .font(AppFont.caption)
        .foregroundStyle(AppColors.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
  }

  private var audioRecords: [Dream] {
    note.dreams
      .sorted { $0.createdAt > $1.createdAt }
      .filter { dream in
        guard let filename = dream.audioFilename else { return false }
        return audioURL(filename: filename) != nil
      }
  }

  private func progressBinding(for dream: Dream) -> Binding<Double> {
    Binding(
      get: { progressByID[dream.id] ?? 0 },
      set: { progressByID[dream.id] = $0 }
    )
  }

  private func draggingBinding(for dream: Dream) -> Binding<Bool> {
    Binding(
      get: { draggingID == dream.id },
      set: { draggingID = $0 ? dream.id : nil }
    )
  }

  private func audioURL(filename: String) -> URL? {
    let url = AudioFileManager.dir.appendingPathComponent(filename)
    return FileManager.default.fileExists(atPath: url.path) ? url : nil
  }

  private func isCurrent(_ dream: Dream) -> Bool {
    guard let filename = dream.audioFilename else { return false }

    return audioPlayer.url?.lastPathComponent == filename
  }

  private func isPlaying(_ dream: Dream) -> Bool {
    isCurrent(dream) && audioPlayer.isPlaying
  }

  private func playPause(_ dream: Dream) {
    if isPlaying(dream) {
      audioPlayer.pause()
      return
    }
    guard !audioRecorder.isRecording else { return }

    guard let filename = dream.audioFilename,
          let url = audioURL(filename: filename)
    else {
      return
    }

    audioPlayer.play(url: url)
    let progress = progressByID[dream.id] ?? 0
    if progress > 0 {
      audioPlayer.seek(to: progress)
    }
  }

  private func seek(_ dream: Dream, to newProgress: Double) {
    guard isCurrent(dream) || !audioRecorder.isRecording else { return }

    if !isCurrent(dream),
       let filename = dream.audioFilename,
       let url = audioURL(filename: filename) {
      audioPlayer.play(url: url)
    }
    audioPlayer.seek(to: newProgress)
  }

  private func deleteAudio(_ dream: Dream) {
    if isCurrent(dream) {
      audioPlayer.stop()
    }

    progressByID[dream.id] = nil
    Task {
      await persistence.deleteNoteAudio(id: dream.id)
    }
  }

  private func startTimer() {
    timerTask = Task { @MainActor in
      while !Task.isCancelled {
        try? await Task.sleep(for: .milliseconds(50))
        syncProgress()
      }
    }
  }

  private func stopTimer() {
    timerTask?.cancel()
    timerTask = nil
  }

  private func syncProgress() {
    guard draggingID == nil,
          let currentFilename = audioPlayer.url?.lastPathComponent,
          let currentDream = audioRecords.first(where: { $0.audioFilename == currentFilename }),
          let currentTime = audioPlayer.currentTime,
          let duration = audioPlayer.duration,
          duration > 0
    else {
      return
    }
    progressByID[currentDream.id] = currentTime / duration
  }

}
