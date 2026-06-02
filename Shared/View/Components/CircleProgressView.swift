//
//  CircleProgressView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct CircleProgressView: View {

  private enum Constants {

    static let degreesOffset = -90.0
    static let lineWidth = 2.0

  }

  @Binding var progress: Double

  var body: some View {
    ZStack {
      Circle()
        .stroke(.white, lineWidth: Constants.lineWidth)
      Circle()
        .trim(from: 0.0, to: progress)
        .stroke(
          AppColors.red,
          style: StrokeStyle(lineWidth: Constants.lineWidth, lineCap: .round)
        )
        .rotationEffect(.degrees(Constants.degreesOffset))
    }
  }

}
