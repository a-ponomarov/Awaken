//
//  PlayButton.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct PlayButton: View {

  let isPlaying: Bool
  @Binding var progress: Double
  let completion: () -> Void

  var body: some View {
    Button(action: completion) {
      ZStack {
        CircleProgressView(progress: $progress)
        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
          .font(AppFont.captionMedium)
          .foregroundStyle(AppColors.primary)
      }
      .frame(height: 36.0)
    }
    .buttonStyle(.plain)
  }

}
