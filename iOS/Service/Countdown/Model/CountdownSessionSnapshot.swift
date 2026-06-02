//
//  CountdownSessionSnapshot.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

struct CountdownSessionSnapshot: Sendable {

  let state: CountdownState
  let history: [TimeRecord]

}
