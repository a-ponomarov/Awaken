//
//  Persistence+User.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

extension Persistence {

  /// Ensures the app-wide user exists.
  func ensureUser() {
    _ = user
  }

  func fetchFirstUser() -> User? {
    do {
      var descriptor = FetchDescriptor<User>(
        sortBy: [SortDescriptor(\.birthday, order: .forward)]
      )
      descriptor.fetchLimit = 1
      return try modelContext.fetch(descriptor).first
    } catch {
      logger?.log(.error(PersistenceError.fetchFirstUserFailed.localizedDescription))
      return nil
    }
  }

  func fetchUserBirthday() -> Date {
    user.birthday
  }

  func updateUserBirthday(_ birthday: Date) {
    user.birthday = birthday
    save()
  }

  func createUser() -> User {
    let newUser = User()
    modelContext.insert(newUser)
    do {
      try modelContext.save()
    } catch {
      logger?.log(.error(PersistenceError.createUserFailed.localizedDescription))
    }
    return newUser
  }

  @discardableResult
  func createUserAndSelect() -> User {
    createUser()
  }

  /// The app-wide persisted user, creating one if needed.
  var user: User {
    get {
      if let existingUser = fetchFirstUser() {
        return existingUser
      }
      return createUserAndSelect()
    }
  }

}
