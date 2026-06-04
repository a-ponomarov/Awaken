//
//  AppColors.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

enum AppColors {

  static let background = Color(
    cgColor: #colorLiteral(red: 0.107200928, green: 0.1084394231, blue: 0.1110956445, alpha: 1)
  )
  static let surface = Color(
    cgColor: #colorLiteral(red: 0.1227148101, green: 0.124573119, blue: 0.1297583282, alpha: 1)
  )
  static let accent = Color(
    cgColor: #colorLiteral(red: 0.2198110521, green: 0.2227534056, blue: 0.2305957675, alpha: 1)
  )

  static let primary = Color.white
  static let secondary = primary.opacity(0.55)
  static let tertiary = primary.opacity(0.35)

}
