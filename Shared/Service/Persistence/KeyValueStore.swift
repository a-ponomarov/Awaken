//
//  KeyValueStore.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

/// Abstracts key-value persistence so consumers are not coupled to UserDefaults.
protocol KeyValueStore {

  func object(forKey defaultName: String) -> Any?
  func set(_ value: Any?, forKey defaultName: String)
  func removeObject(forKey defaultName: String)
  func data(forKey defaultName: String) -> Data?

}

extension UserDefaults: KeyValueStore {}
