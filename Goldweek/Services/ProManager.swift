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
    /// 상품 로드 실패 여부 — Paywall에서 재시도 UI 노출에 사용
    private(set) var productLoadFailed = false

    /// App Store Connect·기존 사용자 영수증과의 계약 — 변경 금지.
    /// GoldweekSpec(LeeoKit 계약)도 이 값을 참조한다.
    static let proProductID = "com.Ysoup.LeaveWise.pro"
    private let productID = ProManager.proProductID
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
        // DEBUG에서는 UserDefaults에 isPro가 명시적으로 set 되어 있으면 StoreKit 검증을 skip
        // (시뮬레이터에서 Pro 화면 테스트하기 위함)
        #if DEBUG
        if !storedIsPro {
            Task { await checkEntitlement() }
        }
        #else
        Task { await checkEntitlement() }
        #endif
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        isLoading = true
        productLoadFailed = false
        defer { isLoading = false }

        do {
            products = try await Product.products(for: [productID])
            logDebug("StoreKit 제품 로드 완료: \(products.count)개", category: .app)
        } catch {
            productLoadFailed = true
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

    enum RestoreResult {
        case restored
        case nothingToRestore
        case failed(String)
    }

    /// 구매 복원 후 결과를 반환한다 — 호출부는 이 결과로 사용자에게 피드백을 보여줄 것
    @discardableResult
    func restorePurchases() async -> RestoreResult {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await checkEntitlement()
            logInfo("구매 복원 완료", category: .app)
            return isPro ? .restored : .nothingToRestore
        } catch {
            logError("구매 복원 실패: \(error.localizedDescription)", category: .app)
            return .failed(error.localizedDescription)
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
        // DEBUG 빌드는 UserDefaults에 저장된 값 존중 (시뮬레이터 테스트용)
        await MainActor.run {
            #if DEBUG
            let storedIsPro = UserDefaults.standard.bool(forKey: "isPro")
            self.isPro = storedIsPro || isTestFlight
            #else
            self.isPro = isTestFlight
            #endif
            self.purchaseState = self.isPro ? .purchased : .notPurchased
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
        switch LanguageManager.shared.currentLanguage {
        case .korean:
            switch self {
            case .productNotFound: return "제품을 찾을 수 없습니다."
            case .verificationFailed: return "구매 검증에 실패했습니다."
            case .purchaseFailed: return "구매에 실패했습니다."
            }
        case .english:
            switch self {
            case .productNotFound: return "Product not found."
            case .verificationFailed: return "Purchase verification failed."
            case .purchaseFailed: return "Purchase failed."
            }
        case .japanese:
            switch self {
            case .productNotFound: return "製品が見つかりません。"
            case .verificationFailed: return "購入の検証に失敗しました。"
            case .purchaseFailed: return "購入に失敗しました。"
            }
        case .chinese:
            switch self {
            case .productNotFound: return "找不到产品。"
            case .verificationFailed: return "购买验证失败。"
            case .purchaseFailed: return "购买失败。"
            }
        }
    }
}
