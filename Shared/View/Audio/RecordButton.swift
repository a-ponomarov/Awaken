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

  var body: some View {
    RecordButtonContent(persistence: persistence)
  }

}

private struct RecordButtonContent: View {

  private enum Constants {

    static let iconFontSize = 36.0
    static let buttonSize = 44.0
    static let topPadding = 33.0

  }

  @State private var model: RecordButtonModel

  init(persistence: Persistence) {
    _model = State(initialValue: RecordButtonModel(persistence: persistence))
  }

  var body: some View {
    ZStack {
      Button {
        model.action()
      } label: {
        ZStack {
          Image(systemName: model.isRecording ? "stop.fill" : "waveform.badge.plus")
            .font(.light(size: Constants.iconFontSize))
            .frame(width: Constants.buttonSize, height: Constants.buttonSize)
            .foregroundColor(.white)
        }
        .padding(.top, Constants.topPadding)
#if os(iOS)
        .padding(.bottom)
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

  private var microphonePermissionMessage: String {
#if os(watchOS)
    String.watchMicrophonePermissionMessage
#else
    String.microphonePermissionMessage
#endif
  }

}
