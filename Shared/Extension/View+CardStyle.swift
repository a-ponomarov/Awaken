//
//  View+CardStyle.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/10/2026.
//

import SwiftUI

extension View {

  func cardStyle(
    cornerRadius: CGFloat = AppLayout.cardRadius
  ) -> some View {
    self
      .background(AppColors.surface)
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .stroke(AppColors.accent, lineWidth: AppLayout.stroke)
      }
  }

}
