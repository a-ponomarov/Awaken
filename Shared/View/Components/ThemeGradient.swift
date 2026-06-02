//
//  ThemeGradient.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct ThemeGradient: View {

  var body: some View {
    LinearGradient(
      gradient: Gradient(colors: [
        AppColors.blue,
        AppColors.blue
      ]),
      startPoint: .bottom,
      endPoint: .top
    )
    .ignoresSafeArea()
  }

}
