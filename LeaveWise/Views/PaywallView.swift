//
//  PaywallView.swift
//  LeaveWise
//
//  Pro 기능 업그레이드 페이월 뷰 (다국어 지원)
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var proManager = ProManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featureComparisonSection
                    pricingSection
                    purchaseButtons
                    footerSection
                }
                .padding()
            }
            .navigationTitle(Strings.leaveWisePro)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Strings.cancel) {
                        dismiss()
                    }
                }
            }
        }
        .alert(isSuccess ? Strings.purchaseSuccess : Strings.purchaseError, 
               isPresented: $showingAlert) {
            Button(Strings.confirm) {
                if isSuccess {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .background(
                    Circle()
                        .fill(.yellow.opacity(0.2))
                        .frame(width: 100, height: 100)
                )
            
            Text(Strings.leaveWisePro)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(Strings.unlockAllFeatures)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Feature Comparison Section
    
    private var featureComparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Strings.featureComparison)
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("기능")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(Strings.freeVersion)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 80)
                    
                    Text(Strings.proVersion)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 80)
                }
                .padding()
                .background(Color(.systemGray6))
                
                Divider()
                
                // Features
                featureRow(
                    feature: Strings.basicLeaveManagement,
                    freeSupported: true,
                    proSupported: true
                )
                
                Divider()
                
                featureRow(
                    feature: Strings.leaveRecommendations,
                    freeText: Strings.limitedRecommendations,
                    proText: Strings.unlimitedRecommendations
                )
                
                Divider()
                
                featureRow(
                    feature: Strings.yearSelector,
                    freeText: Strings.currentYearOnly,
                    proText: Strings.allYears
                )
                
                Divider()
                
                featureRow(
                    feature: Strings.bonusLeaveManagement,
                    freeSupported: false,
                    proSupported: true
                )
                
                Divider()
                
                featureRow(
                    feature: Strings.iCloudBackup,
                    freeSupported: false,
                    proSupported: true
                )
                
                Divider()
                
                featureRow(
                    feature: Strings.systemCalendarSync,
                    freeSupported: false,
                    proSupported: true
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
    
    private func featureRow(
        feature: String,
        freeSupported: Bool? = nil,
        proSupported: Bool? = nil,
        freeText: String? = nil,
        proText: String? = nil
    ) -> some View {
        HStack {
            Text(feature)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Free column
            Group {
                if let text = freeText {
                    Text(text)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                } else if let supported = freeSupported {
                    Image(systemName: supported ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundColor(supported ? .green : .red)
                }
            }
            .frame(width: 80)
            
            // Pro column
            Group {
                if let text = proText {
                    Text(text)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                } else if let supported = proSupported {
                    Image(systemName: supported ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundColor(supported ? .green : .red)
                }
            }
            .frame(width: 80)
        }
        .padding()
    }
    
    // MARK: - Pricing Section
    
    private var pricingSection: some View {
        VStack(spacing: 12) {
            if !proManager.proPrice.isEmpty {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Strings.leaveWisePro)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(Strings.oneTimePurchase)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(proManager.proPrice)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentColor, lineWidth: 2)
                        )
                )
            }
            
            HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                Text(Strings.noSubscription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Purchase Buttons
    
    private var purchaseButtons: some View {
        VStack(spacing: 12) {
            // Purchase button
            Button(action: purchasePro) {
                HStack {
                    if proManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "crown.fill")
                    }
                    
                    Text(proManager.isLoading ? Strings.purchasing : Strings.purchase)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(proManager.isLoading ? Color.gray : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(proManager.isLoading)
            
            // Restore button
            Button(action: restorePurchases) {
                Text(Strings.restorePurchase)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
            }
            .disabled(proManager.isLoading)
        }
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("💡")
                .font(.title2)
            
            Text(Strings.oneTimePurchase)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }
    
    // MARK: - Actions
    
    private func purchasePro() {
        Task {
            do {
                try await proManager.purchase()
                await MainActor.run {
                    isSuccess = true
                    alertMessage = Strings.youArePro
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isSuccess = false
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            await proManager.restorePurchases()
            await MainActor.run {
                if proManager.isPro {
                    isSuccess = true
                    alertMessage = Strings.restoreSuccess
                    showingAlert = true
                } else {
                    isSuccess = false
                    alertMessage = "구매 기록을 찾을 수 없습니다."
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Pro Banner Component

struct ProBannerView: View {
    @State private var showingPaywall = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text(Strings.upgradeToPro)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Text(Strings.proFeaturesBanner)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: {
                showingPaywall = true
            }) {
                Text(Strings.upgradeToPro)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accentColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                )
        )
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
}

#Preview("Pro Banner") {
    ProBannerView()
        .padding()
}