//
//  ProManager.swift
//  Goldweek
//
//  StoreKit 2 Pro 구매 관리
//

import Foundation
import StoreKit
import SwiftUI

@Observable
class ProManager {
    static let shared = ProManager()

    private(set) var products: [Product] = []
    private(set) var purchaseState: PurchaseState = .notPurchased
    private(set) var isLoading = false

    private let productID = "com.Ysoup.LeaveWise.pro"
    private var updateListenerTask: Task<Void, Never>?

    // TestFlight 빌드는 sandbox receipt을 사용
    var isTestFlight: Bool {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }

    // SwiftUI 옵저베이션을 위해 stored property로 보관하고, didSet으로 UserDefaults 동기화.
    // computed property로 두면 @Observable이 추적하지 못해 구매 직후 UI가 갱신되지 않음.
    var isPro: Bool {
        didSet {
            UserDefaults.standard.set(isPro, forKey: "isPro")
        }
    }

    enum PurchaseState {
        case notPurchased
        case purchased
        case pending
        case failed(String)
    }

    private init() {
        let storedIsPro = UserDefaults.standard.bool(forKey: "isPro")
        let isTF = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        self.isPro = storedIsPro || isTF

        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await checkEntitlement() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: [productID])
            logDebug("StoreKit 제품 로드 완료: \(products.count)개", category: .app)
        } catch {
            logError("StoreKit 제품 로드 실패: \(error.localizedDescription)", category: .app)
        }
    }

    // MARK: - Purchase

    func purchase() async throws {
        guard let product = products.first else {
            await loadProducts()
            guard let product = products.first else {
                throw ProPurchaseError.productNotFound
            }
            return try await purchaseProduct(product)
        }
        try await purchaseProduct(product)
    }

    private func purchaseProduct(_ product: Product) async throws {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await MainActor.run {
                self.isPro = true
                self.purchaseState = .purchased
            }
            logInfo("Pro 구매 완료", category: .app)

        case .userCancelled:
            logInfo("사용자가 구매를 취소", category: .app)

        case .pending:
            purchaseState = .pending
            logInfo("구매 대기 중", category: .app)

        @unknown default:
            break
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await checkEntitlement()
            logInfo("구매 복원 완료", category: .app)
        } catch {
            logError("구매 복원 실패: \(error.localizedDescription)", category: .app)
        }
    }

    // MARK: - Check Entitlement

    func checkEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productID {
                    await MainActor.run {
                        self.isPro = true
                        self.purchaseState = .purchased
                    }
                    return
                }
            }
        }

        // No valid entitlement found
        // TestFlight 빌드는 sandbox에서 자동으로 Pro 부여 (init에서 이미 처리)
        await MainActor.run {
            self.isPro = isTestFlight
            self.purchaseState = isTestFlight ? .purchased : .notPurchased
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    if transaction.productID == self.productID {
                        await MainActor.run {
                            self.isPro = true
                            self.purchaseState = .purchased
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Verify Transaction

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw ProPurchaseError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Formatted Price

    var proPrice: String {
        products.first?.displayPrice ?? ""
    }
}

// MARK: - Errors

enum ProPurchaseError: LocalizedError {
    case productNotFound
    case verificationFailed
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "제품을 찾을 수 없습니다."
        case .verificationFailed: return "구매 검증에 실패했습니다."
        case .purchaseFailed: return "구매에 실패했습니다."
        }
    }
}
