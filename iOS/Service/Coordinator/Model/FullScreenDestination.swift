//
//  FullScreenDestination.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

enum FullScreenDestination: Identifiable, Hashable {

  case noteDetail(Note)

  var id: FullScreenDestination {
    self
  }

}
