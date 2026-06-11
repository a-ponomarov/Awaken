//
//  SubscriptionView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {

  private enum Constants {

    static let productID = "subscription"
    static let termsOfServiceURL: URL = {
      let urlString = "https://www.apple.com/legal/internet-services/" +
        "itunes/dev/stdeula/"
      guard let url = URL(string: urlString) else {
        preconditionFailure("Terms of service URL must be a valid static URL.")
      }
      return url
    }()

    static let privacyPolicyURL: URL = {
      guard let url = AppConstants.privacyPolicyURL else {
        preconditionFailure("Privacy policy URL must be a valid static URL.")
      }
      return url
    }()
    static let wifiIconFontSize = 51.0
    static let networkSpacing = 20.0

  }

  @Environment(Store.self) private var store
  @Environment(Network.self) private var network

  var body: some View {
    Group {
      if network.isConnected {
        subscriptionStoreView
      } else {
        networkStatusView
      }
    }
    .task {
      await store.refreshPurchasedProducts()
    }
  }

  @ViewBuilder
  private var subscriptionStoreView: some View {
    SubscriptionStoreView(productIDs: [Constants.productID])
      .background(.clear)
      .tint(.white)
      .subscriptionStorePolicyDestination(
        url: Constants.termsOfServiceURL,
        for: .termsOfService
      )
      .subscriptionStorePolicyDestination(
        url: Constants.privacyPolicyURL,
        for: .privacyPolicy
      )
      .storeButton(.visible, for: .restorePurchases)
      .onInAppPurchaseCompletion { _, result in
        Task {
          guard case .success(let purchaseResult) = result,
                case .success(let verification) = purchaseResult,
                case .verified(let transaction) = verification
          else {
            return
          }
          store.applyVerifiedTransaction(transaction)
        }
      }
  }

  private var networkStatusView: some View {
    VStack(spacing: Constants.networkSpacing) {
      ZStack {
        Image(systemName: "wifi")
          .font(.system(size: Constants.wifiIconFontSize))
          .foregroundStyle(AppColors.primary)
        Image(systemName: "wifi")
          .font(.system(size: Constants.wifiIconFontSize))
          .foregroundStyle(AppColors.accent)
          .symbolEffect(.variableColor.iterative, options: .repeating, isActive: true)
      }
      Text(String.waitingForNetwork)
        .font(AppFont.subtitle)
        .bold()
        .foregroundStyle(AppColors.primary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

}
