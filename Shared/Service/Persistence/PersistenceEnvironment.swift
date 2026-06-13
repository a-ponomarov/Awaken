//
//  PersistenceEnvironment.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

private struct PersistenceKey: EnvironmentKey {

  static let defaultValue = Persistence(modelContainer: .main)

}

extension EnvironmentValues {

  var persistence: Persistence {
    get { self[PersistenceKey.self] }
    set { self[PersistenceKey.self] = newValue }
  }

}
