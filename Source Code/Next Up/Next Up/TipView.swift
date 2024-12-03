//
//  TipView.swift
//  Next Up
//
//  Created by Mark Howard on 03/12/2024.
//

import SwiftUI
import StoreKit

struct TipView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("If You Like This App And Want To Support Me And My Work, Please Consider A Tip!")
                    .padding()
                ForEach(TipJars.allCases) { tip in
                    ProductView(id: tip.id) {
                        Image(tip.imageName)
                            .resizable()
                            .scaledToFit()
                    }
                    .onInAppPurchaseStart { product in
                        print("User Has Started Buying \(product.id)")
                    }
                    .onInAppPurchaseCompletion { product, result in
                        switch result {
                        case .success(let purchaseResult):
                            switch purchaseResult {
                            case .success(let verificationResult):
                                switch verificationResult {
                                case .verified(let transaction):
                                    print("Purchase Verified")
                                    await transaction.finish()
                                case .unverified(let transaction, let verificationError):
                                    print("Purchase Unverified \(verificationError), \(transaction)")
                                }
                            case .pending:
                                print("Purchase Pending")
                            case .userCancelled:
                                print("Purchase Cancelled")
                            @unknown default:
                                print("Unknown Break")
                                break
                            }
                        case .failure(let error):
                            print("Purchase Failure \(error)")
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

enum TipJars: Identifiable, CaseIterable {
    case small
    case medium
    case large

    var id: String {
        switch self {
        case .small:
            return "next_up_small_tip"
        case .medium:
            return "next_up_medium_tip"
        case .large:
            return "next_up_large_tip"
        }
    }

    var imageName: String {
        switch self {
        case .small:
            return "smalltip"
        case .medium:
            return "mediumtip"
        case .large:
            return "largetip"
        }
    }
}

#Preview {
    TipView()
}
