//
//  ProManager.swift
//  Goldweek
//
//  StoreKit 2 Pro 구매 관리
//

import Foundation
import StoreKit
import SwiftUI

/// 유료 트림. 위 트림은 아래 트림 기능을 모두 포함한다 — 무엇을 왜 어느 트림에 두는지는 docs/MONETIZATION.md.
/// - 플러스: 최적 플래너·추천 무제한·다른 해 추천·캘린더 앱으로 보내기 (`isPro`로 본다)
/// - 프로: + 보너스 연차·캘린더 자동 감지·종류별 한도·학교 달력 (`hasProTier`·`has(_:)`)
/// - 패밀리: 프로를 App Store 가족 공유로 6명까지
enum ProTier: Int, Comparable, CaseIterable {
    case free, plus, pro, family

    static func < (a: ProTier, b: ProTier) -> Bool { a.rawValue < b.rawValue }
}

/// 프로 트림 기능 중 **2.4.0에서 새로 유료가 된 것** — 그 전에 설치한 사람에게는 계속 무료다.
/// 원래부터 유료였던 기능은 여기 넣지 않고 `isPro`·`hasProTier`로 본다.
enum ProFeature: String, CaseIterable {
    /// 학교 달력 가져오기 (사진·PDF·붙여 넣은 글에서 방학·시험 기간 읽기)
    case schoolCalendarImport
    /// 직접 만든 휴가 종류의 연간 한도·남은 양 넘겨 쓰기
    case leaveKindAllowance
}

@Observable
class ProManager {
    static let shared = ProManager()

    private(set) var products: [Product] = []
    private(set) var purchaseState: PurchaseState = .notPurchased
    private(set) var isLoading = false
    /// 상품 로드 실패 여부 — Paywall에서 재시도 UI 노출에 사용
    private(set) var productLoadFailed = false
    /// 지금 Pro를 열어 주는 상품. TestFlight·DEBUG로 열린 Pro면 nil.
    private(set) var activePlan: ActivePlan?
    /// 2.4.0 전에 설치한 사람 — `ProFeature`를 계속 무료로 쓴다. 한 번 true면 내려가지 않는다.
    private(set) var isLegacyUser: Bool

    /// App Store Connect·기존 사용자 영수증과의 계약 — 변경 금지.
    /// GoldweekSpec(LeeoKit 계약)도 이 값을 참조한다.
    /// 평생 상품(비소모성). 2.4.0 전에는 이것 하나만 팔았다.
    static let proProductID = "com.Ysoup.LeaveWise.pro"
    /// 연간 자동 갱신 구독들 — App Store Connect 구독 그룹 "Goldweek" (레벨: 패밀리 1, 프로 2, 플러스 3).
    /// 프로 연간
    static let yearlyProductID = "com.Ysoup.LeaveWise.pro.yearly"
    /// 플러스 연간 (`plus.yearly`는 App Store Connect에서 이미 쓰인 ID라 `annual`)
    static let plusProductID = "com.Ysoup.LeaveWise.plus.annual"
    /// 패밀리 연간 — 가족 공유 켬
    static let familyProductID = "com.Ysoup.LeaveWise.family.yearly"
    static let allProductIDs = [plusProductID, yearlyProductID, proProductID, familyProductID]

    /// 상품이 여는 트림
    static func tier(of productID: String) -> ProTier {
        switch productID {
        case plusProductID: return .plus
        case familyProductID: return .family
        case proProductID, yearlyProductID: return .pro
        default: return .free
        }
    }

    /// 2.4.0 전 마지막 빌드 번호. App Store 최초 다운로드가 이 빌드 이하면 기존 설치자다
    /// (빌드 번호는 지금까지 한 번도 줄어든 적이 없다 — Version.xcconfig).
    static let lastBuildBeforePaywallChange = 11
    private static let legacyUserKey = "proLegacyFreeFeatures"

    private var updateListenerTask: Task<Void, Never>?

    // TestFlight 빌드는 sandbox receipt을 사용
    var isTestFlight: Bool {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }

    // SwiftUI 옵저베이션을 위해 stored property로 보관하고, didSet으로 UserDefaults 동기화.
    // computed property로 두면 @Observable이 추적하지 못해 구매 직후 UI가 갱신되지 않음.
    /// 유료 트림(플러스 이상)인가 — 플러스 기능은 이것으로 본다.
    var isPro: Bool {
        didSet {
            UserDefaults.standard.set(isPro, forKey: "isPro")
        }
    }

    /// 지금 트림. TestFlight·DEBUG로 열린 경우는 패밀리.
    private(set) var tier: ProTier {
        didSet { UserDefaults.standard.set(tier.rawValue, forKey: Self.tierKey) }
    }
    private static let tierKey = "proTier"

    /// 프로 트림 이상 — 보너스 연차·캘린더 자동 감지
    var hasProTier: Bool { tier >= .pro }

    /// 무료 체험을 받을 수 있는 구독 상품
    private(set) var trialEligibleIDs: Set<String> = []

    enum PurchaseState {
        case notPurchased
        case purchased
        case pending
        case failed(String)
    }

    enum ActivePlan: Equatable {
        case lifetime
        /// 다음 갱신(또는 끝나는) 날
        case yearly(expires: Date?)
    }

    private init() {
        let defaults = UserDefaults.standard
        let storedIsPro = defaults.bool(forKey: "isPro")
        let isTF = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        self.isPro = storedIsPro || isTF
        if isTF {
            self.tier = .family
        } else if let raw = defaults.object(forKey: Self.tierKey) as? Int, let saved = ProTier(rawValue: raw) {
            self.tier = saved
        } else {
            // 2.4.0 전 평생 구매자는 트림 표시가 없다 — 권한 확인 전까지 프로로 둔다
            self.tier = storedIsPro ? .pro : .free
        }

        // 2.4.0을 처음 켜는 순간 이미 온보딩을 마친 기기라면 기존 설치자다.
        // 새로 설치한 사람은 여기서 false로 굳고, 온보딩을 마쳐도 바뀌지 않는다.
        // (GoldweekApp.init에서 shared를 먼저 만들기 때문에 온보딩보다 앞선다)
        if defaults.object(forKey: Self.legacyUserKey) == nil {
            defaults.set(defaults.bool(forKey: "hasCompletedOnboarding"), forKey: Self.legacyUserKey)
        }
        self.isLegacyUser = defaults.bool(forKey: Self.legacyUserKey)

        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await checkLegacyFromAppStore() }
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

    // MARK: - 기능별 권한

    /// 이 기능을 쓸 수 있는가 — Pro이거나, 2.4.0 전에 설치해 그 기능을 무료로 쓰던 사람.
    func has(_ feature: ProFeature) -> Bool {
        hasProTier || isLegacyUser
    }

    /// 지운 뒤 다시 설치한 기존 사용자 — 기기의 표시는 사라졌어도 App Store 최초 다운로드 빌드로 알아본다.
    private func checkLegacyFromAppStore() async {
        guard !isLegacyUser,
              case .verified(let app) = try? await AppTransaction.shared,
              Self.isLegacyBuild(app.originalAppVersion) else { return }
        await MainActor.run {
            UserDefaults.standard.set(true, forKey: Self.legacyUserKey)
            self.isLegacyUser = true
        }
    }

    /// `originalAppVersion`은 iOS에서 CFBundleVersion(빌드 번호)이다.
    /// 샌드박스는 "1.0"을 돌려주지만 TestFlight는 어차피 Pro라 상관없다.
    static func isLegacyBuild(_ originalAppVersion: String) -> Bool {
        guard let build = Int(originalAppVersion.split(separator: ".").first ?? "") else { return false }
        return build <= lastBuildBeforePaywallChange
    }

    // MARK: - Load Products

    var lifetimeProduct: Product? { products.first { $0.id == Self.proProductID } }
    var yearlyProduct: Product? { products.first { $0.id == Self.yearlyProductID } }

    func loadProducts() async {
        isLoading = true
        productLoadFailed = false
        defer { isLoading = false }

        do {
            let loaded = try await Product.products(for: Self.allProductIDs)
            products = Self.allProductIDs.compactMap { id in loaded.first { $0.id == id } }
            var eligible: Set<String> = []
            for product in products {
                guard let sub = product.subscription, sub.introductoryOffer?.paymentMode == .freeTrial,
                      await sub.isEligibleForIntroOffer else { continue }
                eligible.insert(product.id)
            }
            trialEligibleIDs = eligible
            productLoadFailed = products.isEmpty
            logDebug("StoreKit 제품 로드 완료: \(products.count)개", category: .app)
        } catch {
            productLoadFailed = true
            logError("StoreKit 제품 로드 실패: \(error.localizedDescription)", category: .app)
        }
    }

    // MARK: - Purchase

    func purchase(_ productID: String) async throws {
        if products.isEmpty { await loadProducts() }
        guard let product = products.first(where: { $0.id == productID }) else {
            throw ProPurchaseError.productNotFound
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
            await checkEntitlement()
            UsageReportingService.record(event: "purchase_plan:\(Self.planSlice(product.id))")
            logInfo("Pro 구매 완료: \(product.id)", category: .app)

        case .userCancelled:
            logInfo("사용자가 구매를 취소", category: .app)

        case .pending:
            purchaseState = .pending
            logInfo("구매 대기 중", category: .app)

        @unknown default:
            break
        }
    }

    /// 구매 이벤트 슬라이스 — 2.4.0 전 집계와 이어지게 프로 연간은 그대로 "yearly"
    static func planSlice(_ productID: String) -> String {
        switch productID {
        case plusProductID: return "plus"
        case familyProductID: return "family"
        case yearlyProductID: return "yearly"
        default: return "lifetime"
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

    /// 가진 상품 중 가장 높은 트림. 같은 트림이면 평생이 구독보다 앞선다.
    /// 구독이 끝나거나 환불되면 여기서 내려간다. 가족 공유로 받은 패밀리도 currentEntitlements 에 들어온다.
    func checkEntitlement() async {
        var plan: ActivePlan?
        var best: ProTier = .free
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result, transaction.revocationDate == nil else { continue }
            let t = Self.tier(of: transaction.productID)
            guard t != .free else { continue }
            let isLifetime = transaction.productID == Self.proProductID
            if t > best || (t == best && isLifetime) {
                best = t
                plan = isLifetime ? .lifetime : .yearly(expires: transaction.expirationDate)
            }
        }

        // 권한이 없을 때:
        // TestFlight 빌드는 sandbox에서 자동으로 Pro 부여 (init에서 이미 처리)
        // DEBUG 빌드는 UserDefaults에 저장된 값 존중 (시뮬레이터 테스트용)
        let finalPlan = plan, finalTier = best
        await MainActor.run {
            self.activePlan = finalPlan
            if finalPlan != nil {
                self.isPro = true
                self.tier = isTestFlight ? .family : finalTier
            } else {
                #if DEBUG
                let storedIsPro = UserDefaults.standard.bool(forKey: "isPro")
                self.isPro = storedIsPro || isTestFlight
                #else
                self.isPro = isTestFlight
                #endif
                self.tier = self.isPro ? .family : .free
            }
            self.purchaseState = self.isPro ? .purchased : .notPurchased
        }
    }

    // MARK: - Transaction Listener

    /// 갱신·만료·환불·가족 공유·오퍼 코드 — 어떤 변화든 권한을 처음부터 다시 센다.
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await self.checkEntitlement()
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

    /// 평생 상품 가격
    var proPrice: String {
        lifetimeProduct?.displayPrice ?? ""
    }

    /// 연간 구독 가격
    var yearlyPrice: String {
        yearlyProduct?.displayPrice ?? ""
    }

    /// 상품을 하나라도 불러왔는가 — 구매 버튼을 켤지
    var hasAnyPrice: Bool { !products.isEmpty }

    func product(_ id: String) -> Product? { products.first { $0.id == id } }

    /// 무료 체험 일수 — 받을 수 없거나 체험이 없으면 nil
    func trialDays(for productID: String) -> Int? {
        guard trialEligibleIDs.contains(productID),
              let period = product(productID)?.subscription?.introductoryOffer?.period else { return nil }
        switch period.unit {
        case .day: return period.value
        case .week: return period.value * 7
        case .month: return period.value * 30
        case .year: return period.value * 365
        @unknown default: return nil
        }
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
        case .swedish:
            switch self {
            case .productNotFound: return "Produkten hittades inte."
            case .verificationFailed: return "Köpverifieringen misslyckades."
            case .purchaseFailed: return "Köpet misslyckades."
            }
        case .norwegian:
            switch self {
            case .productNotFound: return "Fant ikke produktet."
            case .verificationFailed: return "Kjøpsverifiseringen mislyktes."
            case .purchaseFailed: return "Kjøpet mislyktes."
            }
        case .danish:
            switch self {
            case .productNotFound: return "Produktet blev ikke fundet."
            case .verificationFailed: return "Verificering af købet mislykkedes."
            case .purchaseFailed: return "Købet mislykkedes."
            }
        case .finnish:
            switch self {
            case .productNotFound: return "Tuotetta ei löytynyt."
            case .verificationFailed: return "Oston vahvistus epäonnistui."
            case .purchaseFailed: return "Osto epäonnistui."
            }
        case .polish:
            switch self {
            case .productNotFound: return "Nie znaleziono produktu."
            case .verificationFailed: return "Weryfikacja zakupu nie powiodła się."
            case .purchaseFailed: return "Zakup nie powiódł się."
            }
        case .czech:
            switch self {
            case .productNotFound: return "Produkt nebyl nalezen."
            case .verificationFailed: return "Ověření nákupu se nezdařilo."
            case .purchaseFailed: return "Nákup se nezdařil."
            }
        case .greek:
            switch self {
            case .productNotFound: return "Το προϊόν δεν βρέθηκε."
            case .verificationFailed: return "Η επαλήθευση της αγοράς απέτυχε."
            case .purchaseFailed: return "Η αγορά απέτυχε."
            }
        case .turkish:
            switch self {
            case .productNotFound: return "Ürün bulunamadı."
            case .verificationFailed: return "Satın alma doğrulanamadı."
            case .purchaseFailed: return "Satın alma başarısız oldu."
            }
        case .russian:
            switch self {
            case .productNotFound: return "Товар не найден."
            case .verificationFailed: return "Не удалось подтвердить покупку."
            case .purchaseFailed: return "Не удалось совершить покупку."
            }
        case .indonesian:
            switch self {
            case .productNotFound: return "Produk tidak ditemukan."
            case .verificationFailed: return "Verifikasi pembelian gagal."
            case .purchaseFailed: return "Pembelian gagal."
            }
        case .thai:
            switch self {
            case .productNotFound: return "ไม่พบสินค้า"
            case .verificationFailed: return "ยืนยันการซื้อไม่สำเร็จ"
            case .purchaseFailed: return "การซื้อไม่สำเร็จ"
            }
        case .vietnamese:
            switch self {
            case .productNotFound: return "Không tìm thấy sản phẩm."
            case .verificationFailed: return "Xác minh giao dịch mua thất bại."
            case .purchaseFailed: return "Mua không thành công."
            }
        case .dutch:
            switch self {
            case .productNotFound: return "Product niet gevonden."
            case .verificationFailed: return "Aankoopverificatie mislukt."
            case .purchaseFailed: return "Aankoop mislukt."
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
        case .german:
            switch self {
            case .productNotFound: return "Produkt nicht gefunden."
            case .verificationFailed: return "Kaufbestätigung fehlgeschlagen."
            case .purchaseFailed: return "Kauf fehlgeschlagen."
            }
        case .french:
            switch self {
            case .productNotFound: return "Produit introuvable."
            case .verificationFailed: return "Échec de la vérification de l’achat."
            case .purchaseFailed: return "Échec de l’achat."
            }
        case .spanish:
            switch self {
            case .productNotFound: return "Producto no encontrado."
            case .verificationFailed: return "No se pudo verificar la compra."
            case .purchaseFailed: return "No se pudo completar la compra."
            }
        case .italian:
            switch self {
            case .productNotFound: return "Prodotto non trovato."
            case .verificationFailed: return "Verifica dell’acquisto non riuscita."
            case .purchaseFailed: return "Acquisto non riuscito."
            }
        case .portuguese:
            switch self {
            case .productNotFound: return "Produto não encontrado."
            case .verificationFailed: return "Falha ao verificar a compra."
            case .purchaseFailed: return "Falha na compra."
            }
        case .chineseTraditional:
            switch self {
            case .productNotFound: return "找不到產品。"
            case .verificationFailed: return "購買驗證失敗。"
            case .purchaseFailed: return "購買失敗。"
            }
        }
    }
}
