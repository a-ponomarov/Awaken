//
//  AppColors.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

enum AppColors {

  // MARK: - Brand

  static let red = Color(
    cgColor: #colorLiteral(red: 0.9055547118, green: 0.01990455389, blue: 0.003983021714, alpha: 1)
  )
  static let blue = Color(
    cgColor: #colorLiteral(red: 0.0862745098, green: 0.1019607843, blue: 0.1803921569, alpha: 1)
  )
  static let surface = Color(
    cgColor: #colorLiteral(red: 0.1177619174, green: 0.1412237883, blue: 0.2783397436, alpha: 1)
  )
  static let tint = Color(
    cgColor: #colorLiteral(red: 0.2153407335, green: 0.2897263169, blue: 0.6222022176, alpha: 1)
  )

  // MARK: - Text

  static let textPrimary = Color.white
  static let textSecondary = Color.white.opacity(0.55)
  static let textTertiary = Color.white.opacity(0.35)

}
