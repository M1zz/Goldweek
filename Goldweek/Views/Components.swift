//
//  Components.swift
//  Goldweek
//
//  공통 UI 컴포넌트
//

import SwiftUI
import GoldweekCore

// MARK: - 국가 선택 (대륙 → 나라)

/// 메뉴용 국가 목록 — 대륙마다 하위 메뉴, 맨 아래 직접 입력
struct CountryMenuItems: View {
    var selected: Country?
    var includeCustom = true
    let onSelect: (Country) -> Void

    var body: some View {
        ForEach(Continent.allCases) { continent in
            Menu {
                ForEach(continent.countries) { country in
                    countryButton(country)
                }
            } label: {
                Label(continent.displayName, systemImage: continent.icon)
            }
        }
        if includeCustom {
            Divider()
            countryButton(.custom)
        }
    }

    private func countryButton(_ country: Country) -> some View {
        Button {
            onSelect(country)
        } label: {
            if country == selected {
                Label("\(country.flag) \(country.displayName)", systemImage: "checkmark")
            } else {
                Text("\(country.flag) \(country.displayName)")
            }
        }
    }
}

/// 설정에서 push 하는 국가 선택 화면 — 대륙을 고르면 그 대륙 나라 목록. 검색하면 바로 나라 목록.
struct CountrySelectionView: View {
    @Binding var selection: Country
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var searchResults: [Country] {
        let q = query.trimmingCharacters(in: .whitespaces)
        return Country.allCases.filter {
            $0.displayName.range(of: q, options: [.caseInsensitive, .diacriticInsensitive]) != nil
                || $0.regionCode.caseInsensitiveCompare(q) == .orderedSame
        }
    }

    var body: some View {
        List {
            if query.trimmingCharacters(in: .whitespaces).isEmpty {
                Section {
                    ForEach(Continent.allCases) { continent in
                        NavigationLink {
                            CountryListView(title: continent.displayName, countries: continent.countries,
                                            selection: $selection, onPick: { dismiss() })
                        } label: {
                            HStack {
                                Label(continent.displayName, systemImage: continent.icon)
                                Spacer()
                                // 지금 고른 나라가 이 대륙이면 옆에 보여 준다
                                if selection.continent == continent {
                                    Text("\(selection.flag) \(selection.displayName)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                Section {
                    CountryRow(country: .custom, isSelected: selection == .custom) {
                        selection = .custom
                        dismiss()
                    }
                } footer: {
                    Text(Strings.customCountryBuiltInInfo)
                }
            } else if searchResults.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                ForEach(searchResults) { country in
                    CountryRow(country: country, isSelected: selection == country) {
                        selection = country
                        dismiss()
                    }
                }
            }
        }
        .searchable(text: $query, prompt: Strings.countrySearchPrompt)
        .navigationTitle(Strings.country)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CountryListView: View {
    let title: String
    let countries: [Country]
    @Binding var selection: Country
    let onPick: () -> Void

    var body: some View {
        List(countries) { country in
            CountryRow(country: country, isSelected: selection == country) {
                selection = country
                onPick()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CountryRow: View {
    let country: Country
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(country.flag) \(country.displayName)")
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                        .fontWeight(.semibold)
                }
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
