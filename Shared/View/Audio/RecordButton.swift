//
//  RecordButton.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AVFoundation
import SwiftUI

struct RecordButton: View {

  @Environment(\.persistence) private var persistence

  private let saveRecording: ((Persistence, UUID) async -> Void)?

  init(saveRecording: ((Persistence, UUID) async -> Void)? = nil) {
    self.saveRecording = saveRecording
  }

  var body: some View {
    RecordButtonContent(persistence: persistence, saveRecording: saveRecording)
  }

}

private struct RecordButtonContent: View {

  private enum Constants {

    static let iconFontSize = 36.0
    static let buttonSize = 44.0
    static let topPadding = 33.0

  }

  @State private var model: RecordButtonModel

  init(
    persistence: Persistence,
    saveRecording: ((Persistence, UUID) async -> Void)?
  ) {
    _model = State(initialValue: RecordButtonModel(
      persistence: persistence,
      saveRecording: saveRecording
    ))
  }

  var body: some View {
    ZStack {
      Button {
        model.action()
      } label: {
#if os(iOS)
        HStack(spacing: AppLayout.spacing * 3) {
          recordIcon
          Text(recordTitle)
            .font(AppFont.button)
            .foregroundStyle(AppColors.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
          Spacer(minLength: 0)
        }
        .padding(AppLayout.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous))
        .cardStyle()
#else
        ZStack {
          recordIcon
        }
        .padding(.top, Constants.topPadding)
#endif
      }
      .buttonStyle(.plain)
      .alert(Text(verbatim: ""), isPresented: Binding(
        get: { model.showPermissionAlert },
        set: { model.showPermissionAlert = $0 }
      )) {
#if os(iOS)
        Button(String.settings) {
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
          }
        }
#endif
        Button(String.cancel, role: .cancel) { }
      } message: {
        Text(microphonePermissionMessage)
      }
    }
  }

  private var recordIcon: some View {
    Image(systemName: model.isRecording ? "stop.fill" : "waveform.badge.plus")
      .font(.light(size: Constants.iconFontSize))
      .frame(width: Constants.buttonSize, height: Constants.buttonSize)
      .foregroundStyle(AppColors.primary)
  }

  private var recordTitle: String {
    model.isRecording ? String.stopRecording : String.addAudio
  }

  private var microphonePermissionMessage: String {
#if os(watchOS)
    String.watchMicrophonePermissionMessage
#else
    String.microphonePermissionMessage
#endif
  }

}
