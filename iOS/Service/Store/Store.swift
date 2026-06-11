//
//  Store.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import Observation
import StoreKit

@Observable
@MainActor
final class Store {

  enum EntitlementState {

    case active
    case inactive

  }

  private var updatesTask: Task<Void, Never>?
  private let defaults: KeyValueStore

  var entitlementState: EntitlementState
  var isRefreshing = false

  @MainActor
  deinit {
    updatesTask?.cancel()
  }

  init(defaults: KeyValueStore = UserDefaults.standard) {
    self.defaults = defaults
    self.entitlementState = Self.cachedEntitlementState(defaults: defaults)
    Task { @MainActor in await refreshPurchasedProducts() }
    updatesTask = Task { @MainActor in
      for await result in Transaction.updates {
        guard case .verified(let transaction) = result else {
          continue
        }
        await refreshPurchasedProducts()
        await transaction.finish()
      }
    }
  }

  private static func cachedEntitlementState(
    defaults: KeyValueStore
  ) -> EntitlementState {
    guard let expirationDate =
      defaults.object(forKey: StorageKey.subscriptionExpirationDate) as? Date
    else {
      return .inactive
    }
    return expirationDate > Date() ? .active : .inactive
  }

  func applyVerifiedTransaction(_ transaction: Transaction) {
    guard let expirationDate = transaction.expirationDate,
          expirationDate > Date()
    else {
      entitlementState = .inactive
      defaults.removeObject(forKey: StorageKey.subscriptionExpirationDate)
      return
    }
    entitlementState = .active
    defaults.set(expirationDate, forKey: StorageKey.subscriptionExpirationDate)
  }

  func refreshPurchasedProducts() async {
    isRefreshing = true
    defer { isRefreshing = false }

    for await result in Transaction.currentEntitlements {
      guard case .verified(let transaction) = result
      else {
        continue
      }
      applyVerifiedTransaction(transaction)
      guard entitlementState == .active else {
        continue
      }
      return
    }
    entitlementState = .inactive
    defaults.removeObject(forKey: StorageKey.subscriptionExpirationDate)
  }

}
