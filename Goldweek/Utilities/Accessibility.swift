//
//  Accessibility.swift
//  Goldweek
//
//  VoiceOver 접근성 표준 modifier 및 라벨 빌더
//

import SwiftUI

// MARK: - View Modifiers

extension View {
    /// 카드 단위로 자식 요소를 하나의 VoiceOver 엔티티로 묶는다.
    /// 카드/리스트 행/요약 박스에 사용.
    func voCard(_ label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(label))
            .accessibilityHint(hint.map(Text.init) ?? Text(""))
    }

    /// 버튼/탭 가능한 요소를 단일 VoiceOver 버튼으로 묶는다.
    /// 활성화 트레이트가 포함되어 "이중 탭하여 활성화" 안내가 나온다.
    func voButton(_ label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(label))
            .accessibilityHint(hint.map(Text.init) ?? Text(""))
            .accessibilityAddTraits(.isButton)
    }

    /// 장식용 아이콘/이모지/색상 표시를 VoiceOver에서 숨긴다.
    /// 의미가 없는 시각 요소(구분점, 장식 이모지, 그라데이션 등)에 사용.
    func voDecorative() -> some View {
        self.accessibilityHidden(true)
    }

    /// 토글/선택 상태를 VoiceOver에 알린다.
    func voSelected(_ isSelected: Bool) -> some View {
        self.accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// 헤더(섹션 제목)임을 VoiceOver에 알린다.
    func voHeader() -> some View {
        self.accessibilityAddTraits(.isHeader)
    }
}

// MARK: - 화면 밖 변화 알리기

/// 저장·삭제처럼 **화면이 거의 안 바뀌는** 일이 끝났을 때 VoiceOver 가 소리 내어 알린다.
/// (밀어서 지우면 행이 사라질 뿐이라, 화면을 못 보는 사람은 지워졌는지 알 수 없다.)
enum A11yAnnounce {
    static func post(_ message: String) {
        var text = AttributedString(message)
        // 지금 읽고 있는 것을 끊지 않고 이어서 읽는다
        text.accessibilitySpeechAnnouncementPriority = .high
        AccessibilityNotification.Announcement(text).post()
    }
}

// MARK: - 사진 위 배지 배경

/// 사진 위에 흰 글자를 얹는 배지 배경.
/// 평소에는 반투명 재질이지만 '투명도 줄이기' 를 켜면 불투명한 어두운 바탕,
/// '대비 증가' 를 켜면 더 짙은 바탕으로 바꿔 흰 글자가 사진에 묻히지 않게 한다.
private struct LegibleBadgeBackground: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        if reduceTransparency || contrast == .increased {
            content.background(Color.black.opacity(contrast == .increased ? 0.85 : 0.7))
        } else {
            content.background(.ultraThinMaterial)
        }
    }
}

extension View {
    func legibleBadgeBackground() -> some View {
        modifier(LegibleBadgeBackground())
    }
}

// MARK: - VoiceOver Label Builders

/// 화면 곳곳에서 재사용되는 VoiceOver 문구 빌더.
/// 시각적 라벨을 그대로 읽으면 어색한 경우(아이콘+숫자+단위 분리, 색만으로 상태 표시 등)
/// 자연어 한 문장으로 합쳐서 반환한다.
enum VoiceOverLabel {

    /// 연차 잔여 요약: "연차 21일 중 12일 사용, 9일 남음"
    static func leaveBalance(total: Double, used: Double, remaining: Double) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let t = formatDays(total)
        let u = formatDays(used)
        let r = formatDays(remaining)
        switch lang {
        case .korean: return "연차 \(t)일 중 \(u)일 사용, \(r)일 남음"
        case .english: return "\(u) of \(t) days used, \(r) remaining"
        case .swedish: return "\(u) av \(t) dagar använda, \(r) kvar"
        case .norwegian: return "\(u) av \(t) dager brukt, \(r) igjen"
        case .danish: return "\(u) af \(t) dage brugt, \(r) tilbage"
        case .finnish: return "\(u)/\(t) päivää käytetty, \(r) jäljellä"
        case .polish: return "Wykorzystano \(u) z \(t) dni, zostało \(r)"
        case .czech: return "Využito \(u) z \(t) dní, zbývá \(r)"
        case .greek: return "\(u) από \(t) ημέρες χρησιμοποιήθηκαν, απομένουν \(r)"
        case .turkish: return "\(t) günün \(u) günü kullanıldı, \(r) gün kaldı"
        case .russian: return "Отпуск: \(t) \(ruPlural(total, "день", "дня", "дней")), использовано \(u), осталось \(r)"
        case .indonesian: return "\(u) dari \(t) hari terpakai, sisa \(r)"
        case .thai: return "ใช้แล้ว \(u) จาก \(t) วัน คงเหลือ \(r)"
        case .vietnamese: return "Đã dùng \(u)/\(t) ngày, còn lại \(r)"
        case .dutch: return "\(u) van \(t) dagen gebruikt, \(r) over"
        case .japanese: return "有給\(t)日中\(u)日使用、残り\(r)日"
        case .chinese: return "年假\(t)天中已使用\(u)天，剩余\(r)天"
        case .german: return "\(u) von \(t) Tagen genommen, \(r) übrig"
        case .french: return "\(u) jours sur \(t) utilisés, \(r) restants"
        case .spanish: return "\(u) de \(t) días usados, quedan \(r)"
        case .italian: return "\(u) giorni su \(t) usati, \(r) rimanenti"
        case .portuguese: return "\(u) de \(t) dias usados, \(r) restantes"
        case .chineseTraditional: return "特休 \(t) 天中已使用 \(u) 天，剩餘 \(r) 天"
        }
    }

    /// 보너스 일수: "보너스 사용 가능 3.5일"
    static func bonus(days: Double) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let d = formatDays(days)
        switch lang {
        case .korean: return "보너스 사용 가능 \(d)일"
        case .english: return "Bonus available: \(d) days"
        case .swedish: return "Bonus tillgänglig: \(d) dagar"
        case .norwegian: return "Bonus tilgjengelig: \(d) dager"
        case .danish: return "Bonus tilgængelig: \(d) dage"
        case .finnish: return "Bonusta käytettävissä: \(d) päivää"
        case .polish: return "Dostępny bonus: \(d) dni"
        case .czech: return "Dostupný bonus, dní: \(d)"
        case .greek: return "Διαθέσιμο μπόνους: \(d) ημέρες"
        case .turkish: return "Kullanılabilir bonus: \(d) gün"
        case .russian: return "Доступно бонусных дней: \(d)"
        case .indonesian: return "Cuti bonus tersedia: \(d) hari"
        case .thai: return "วันลาโบนัสที่ใช้ได้: \(d) วัน"
        case .vietnamese: return "Phép thưởng còn dùng được: \(d) ngày"
        case .dutch: return "Bonus beschikbaar: \(d) dagen"
        case .japanese: return "ボーナス使用可能 \(d)日"
        case .chinese: return "可用奖励 \(d) 天"
        case .german: return "Bonus verfügbar: \(d) Tage"
        case .french: return "Bonus disponible : \(d) jours"
        case .spanish: return "Días extra disponibles: \(d)"
        case .italian: return d == "1" ? "Ferie bonus disponibili: 1 giorno" : "Ferie bonus disponibili: \(d) giorni"
        case .portuguese: return d == "1" ? "Folga bônus disponível: 1 dia" : "Folga bônus disponível: \(d) dias"
        case .chineseTraditional: return "可用獎勵特休 \(d) 天"
        }
    }

    /// 다가오는 휴가 행: "11월 3일 월요일부터 5일까지, 연차 3일, 5일 남음"
    static func upcomingLeave(dateRange: String, typeLabel: String, days: Double, dDay: Int) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let d = formatDays(days)
        switch lang {
        case .korean: return "\(dateRange), \(typeLabel) \(d)일, \(dDay)일 남음"
        case .english: return "\(dateRange), \(typeLabel) \(d) days, in \(dDay) days"
        case .swedish: return "\(dateRange), \(typeLabel) \(d) dagar, om \(dDay) dagar"
        case .norwegian: return "\(dateRange), \(typeLabel) \(d) dager, om \(dDay) dager"
        case .danish: return "\(dateRange), \(typeLabel) \(d) dage, om \(dDay) dage"
        case .finnish: return "\(dateRange), \(typeLabel) \(d) päivää, \(dDay) päivän päästä"
        case .polish: return "\(dateRange), \(typeLabel): \(d) dni, za \(dDay) dni"
        case .czech: return "\(dateRange), \(typeLabel), dní: \(d), za \(dDay) d"
        case .greek: return "\(dateRange), \(typeLabel) \(d) ημέρες, σε \(dDay) ημέρες"
        case .turkish: return "\(dateRange), \(typeLabel) \(d) gün, \(dDay) gün sonra"
        case .russian: return "\(dateRange), \(typeLabel): \(d) \(ruPlural(days, "день", "дня", "дней")), через \(dDay) \(ruPlural(dDay, "день", "дня", "дней"))"
        case .indonesian: return "\(dateRange), \(typeLabel) \(d) hari, \(dDay) hari lagi"
        case .thai: return "\(dateRange), \(typeLabel) \(d) วัน, อีก \(dDay) วัน"
        case .vietnamese: return "\(dateRange), \(typeLabel) \(d) ngày, còn \(dDay) ngày nữa"
        case .dutch: return "\(dateRange), \(typeLabel) \(d) dagen, over \(dDay) dagen"
        case .japanese: return "\(dateRange)、\(typeLabel)\(d)日、あと\(dDay)日"
        case .chinese: return "\(dateRange)，\(typeLabel)\(d)天，还有\(dDay)天"
        case .german: return "\(dateRange), \(typeLabel) \(d) Tage, in \(dDay) Tagen"
        case .french: return "\(dateRange), \(typeLabel) \(d) jours, dans \(dDay) jours"
        case .spanish: return "\(dateRange), \(typeLabel) \(d) \(d == "1" ? "día" : "días"), dentro de \(dDay) \(dDay == 1 ? "día" : "días")"
        case .italian: return "\(dateRange), \(typeLabel) \(d) \(d == "1" ? "giorno" : "giorni"), tra \(dDay) \(dDay == 1 ? "giorno" : "giorni")"
        case .portuguese: return "\(dateRange), \(typeLabel) \(d) \(d == "1" ? "dia" : "dias"), daqui a \(dDay) \(dDay == 1 ? "dia" : "dias")"
        case .chineseTraditional: return "\(dateRange)，\(typeLabel) \(d) 天，\(dDay) 天後"
        }
    }

    /// 추천 황금연휴: "10월 1일부터 6일까지 6일 연휴, 연차 2일 필요, 추천 점수 92"
    static func recommendation(dateRange: String, totalDays: Int, leavesNeeded: Int, score: Int?) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let scorePart: String = {
            guard let score else { return "" }
            switch lang {
            case .korean: return ", 추천 점수 \(score)"
            case .english: return ", recommendation score \(score)"
            case .swedish: return ", rekommendationspoäng \(score)"
            case .norwegian: return ", anbefalingsscore \(score)"
            case .danish: return ", anbefalingsscore \(score)"
            case .finnish: return ", suosituspisteet \(score)"
            case .polish: return ", ocena rekomendacji \(score)"
            case .czech: return ", skóre doporučení \(score)"
            case .greek: return ", βαθμός πρότασης \(score)"
            case .turkish: return ", öneri puanı \(score)"
            case .russian: return ", оценка \(score)"
            case .indonesian: return ", skor rekomendasi \(score)"
            case .thai: return ", คะแนนแนะนำ \(score)"
            case .vietnamese: return ", điểm gợi ý \(score)"
            case .dutch: return ", aanbevelingsscore \(score)"
            case .japanese: return "、おすすめスコア\(score)"
            case .chinese: return "，推荐分数\(score)"
            case .german: return ", Empfehlungswert \(score)"
            case .french: return ", score de recommandation \(score)"
            case .spanish: return ", puntuación de recomendación \(score)"
            case .italian: return ", punteggio del suggerimento \(score)"
            case .portuguese: return ", pontuação da sugestão \(score)"
            case .chineseTraditional: return "，推薦分數 \(score)"
            }
        }()
        switch lang {
        case .korean: return "\(dateRange), 총 \(totalDays)일 연휴, 연차 \(leavesNeeded)일 필요\(scorePart)"
        case .english: return "\(dateRange), \(totalDays)-day holiday, \(leavesNeeded) leave days required\(scorePart)"
        case .swedish: return "\(dateRange), \(totalDays) dagars ledighet, \(leavesNeeded) semesterdagar krävs\(scorePart)"
        case .norwegian: return "\(dateRange), \(totalDays) dagers fri, \(leavesNeeded) feriedager kreves\(scorePart)"
        case .danish: return "\(dateRange), \(totalDays) dages fri, \(leavesNeeded) feriedage påkrævet\(scorePart)"
        case .finnish: return "\(dateRange), \(totalDays) päivän vapaa, \(leavesNeeded) lomapäivää tarvitaan\(scorePart)"
        case .polish: return "\(dateRange), \(totalDays) dni wolnego, wymaga urlopu: \(leavesNeeded) dni\(scorePart)"
        case .czech: return "\(dateRange), volno v kuse (dní: \(totalDays)), potřebná dovolená (dní: \(leavesNeeded))\(scorePart)"
        case .greek: return "\(dateRange), αργίες \(totalDays) ημερών, απαιτούνται \(leavesNeeded) ημέρες άδειας\(scorePart)"
        case .turkish: return "\(dateRange), \(totalDays) günlük tatil, \(leavesNeeded) izin günü gerekli\(scorePart)"
        case .russian: return "\(dateRange), отдых \(totalDays) \(ruPlural(totalDays, "день", "дня", "дней")), нужно \(leavesNeeded) \(ruPlural(leavesNeeded, "день", "дня", "дней")) отпуска\(scorePart)"
        case .indonesian: return "\(dateRange), libur \(totalDays) hari, perlu \(leavesNeeded) hari cuti\(scorePart)"
        case .thai: return "\(dateRange), หยุด \(totalDays) วัน, ต้องลา \(leavesNeeded) วัน\(scorePart)"
        case .vietnamese: return "\(dateRange), nghỉ \(totalDays) ngày, cần \(leavesNeeded) ngày phép\(scorePart)"
        case .dutch: return "\(dateRange), vakantie van \(totalDays) dagen, \(leavesNeeded) verlofdagen nodig\(scorePart)"
        case .japanese: return "\(dateRange)、合計\(totalDays)日の連休、有給\(leavesNeeded)日必要\(scorePart)"
        case .chinese: return "\(dateRange)，共\(totalDays)天连假，需请\(leavesNeeded)天年假\(scorePart)"
        case .german: return "\(dateRange), \(totalDays) Tage frei, \(leavesNeeded) Urlaubstage nötig\(scorePart)"
        case .french: return "\(dateRange), \(totalDays) jours de repos, \(leavesNeeded) jours de congé nécessaires\(scorePart)"
        case .spanish: return "\(dateRange), \(totalDays) días libres seguidos, \(leavesNeeded == 1 ? "1 día de vacaciones necesario" : "\(leavesNeeded) días de vacaciones necesarios")\(scorePart)"
        case .italian: return "\(dateRange), \(totalDays) giorni di fila, \(leavesNeeded == 1 ? "1 giorno di ferie necessario" : "\(leavesNeeded) giorni di ferie necessari")\(scorePart)"
        case .portuguese: return "\(dateRange), feriadão de \(totalDays) dias, \(leavesNeeded == 1 ? "1 dia de férias necessário" : "\(leavesNeeded) dias de férias necessários")\(scorePart)"
        case .chineseTraditional: return "\(dateRange)，共連休 \(totalDays) 天，需請 \(leavesNeeded) 天特休\(scorePart)"
        }
    }

    /// 항공권 카드: "서울에서 홍콩, 11월 3일부터 7일, 대한항공 직항, 42만 8천원"
    static func flight(origin: String, destination: String, dateRange: String, airline: String?, direct: Bool, priceText: String) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let airlinePart = airline.map { " \($0)" } ?? ""
        let directPart: String = {
            guard direct else { return "" }
            switch lang {
            case .korean: return " 직항"
            case .english: return " direct"
            case .swedish: return " direkt"
            case .norwegian: return " direkte"
            case .danish: return " direkte"
            case .finnish: return " suora"
            case .polish: return " bezpośredni"
            case .czech: return " přímý"
            case .greek: return " απευθείας"
            case .turkish: return " direkt"
            case .russian: return " прямой рейс"
            case .indonesian: return " langsung"
            case .thai: return " บินตรง"
            case .vietnamese: return " bay thẳng"
            case .dutch: return " direct"
            case .japanese: return " 直行"
            case .chinese: return " 直飞"
            case .german: return " Direktflug"
            case .french: return " direct"
            case .spanish: return " directo"
            case .italian: return " diretto"
            case .portuguese: return " direto"
            case .chineseTraditional: return " 直飛"
            }
        }()
        switch lang {
        case .korean: return "\(origin)에서 \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .english: return "\(origin) to \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .swedish: return "\(origin) till \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .norwegian: return "\(origin) til \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .danish: return "\(origin) til \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .finnish: return "\(origin)–\(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .polish: return "\(origin) – \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .czech: return "\(origin) – \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .greek: return "\(origin) προς \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .turkish: return "\(origin) - \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .russian: return "\(origin) — \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .indonesian: return "\(origin) ke \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .thai: return "\(origin) ไป \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .vietnamese: return "\(origin) đến \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .dutch: return "\(origin) naar \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .japanese: return "\(origin)から\(destination)、\(dateRange)、\(airlinePart)\(directPart)、\(priceText)"
        case .chinese: return "\(origin)到\(destination)，\(dateRange)，\(airlinePart)\(directPart)，\(priceText)"
        case .german: return "\(origin) nach \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .french: return "\(origin) vers \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .spanish: return "\(origin) a \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .italian: return "Da \(origin) a \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .portuguese: return "\(origin) para \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .chineseTraditional: return "\(origin) 飛往 \(destination)，\(dateRange)，\(airlinePart)\(directPart)，\(priceText)"
        }
    }

    /// 숙박 카드: "호텔명, 별점 4.5, 1박 12만원"
    static func accommodation(name: String, rating: Double?, priceText: String) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let ratingPart: String = {
            guard let rating else { return "" }
            let r = String(format: "%.1f", rating)
            switch lang {
            case .korean: return ", 별점 \(r)"
            case .english: return ", rating \(r)"
            case .swedish: return ", betyg \(r)"
            case .norwegian: return ", vurdering \(r)"
            case .danish: return ", vurdering \(r)"
            case .finnish: return ", arvosana \(r)"
            case .polish: return ", ocena \(r)"
            case .czech: return ", hodnocení \(r)"
            case .greek: return ", βαθμολογία \(r)"
            case .turkish: return ", puan \(r)"
            case .russian: return ", рейтинг \(r)"
            case .indonesian: return ", rating \(r)"
            case .thai: return ", คะแนน \(r)"
            case .vietnamese: return ", đánh giá \(r)"
            case .dutch: return ", beoordeling \(r)"
            case .japanese: return "、評価\(r)"
            case .chinese: return "，评分\(r)"
            case .german: return ", Bewertung \(r)"
            case .french: return ", note \(r)"
            case .spanish: return ", valoración \(r)"
            case .italian: return ", valutazione \(r)"
            case .portuguese: return ", avaliação \(r)"
            case .chineseTraditional: return "，評分 \(r)"
            }
        }()
        switch lang {
        case .korean: return "\(name)\(ratingPart), \(priceText)"
        case .english: return "\(name)\(ratingPart), \(priceText)"
        case .swedish: return "\(name)\(ratingPart), \(priceText)"
        case .norwegian: return "\(name)\(ratingPart), \(priceText)"
        case .danish: return "\(name)\(ratingPart), \(priceText)"
        case .finnish: return "\(name)\(ratingPart), \(priceText)"
        case .polish: return "\(name)\(ratingPart), \(priceText)"
        case .czech: return "\(name)\(ratingPart), \(priceText)"
        case .greek: return "\(name)\(ratingPart), \(priceText)"
        case .turkish: return "\(name)\(ratingPart), \(priceText)"
        case .russian: return "\(name)\(ratingPart), \(priceText)"
        case .indonesian: return "\(name)\(ratingPart), \(priceText)"
        case .thai: return "\(name)\(ratingPart), \(priceText)"
        case .vietnamese: return "\(name)\(ratingPart), \(priceText)"
        case .dutch: return "\(name)\(ratingPart), \(priceText)"
        case .japanese: return "\(name)\(ratingPart)、\(priceText)"
        case .chinese: return "\(name)\(ratingPart)，\(priceText)"
        case .german: return "\(name)\(ratingPart), \(priceText)"
        case .french: return "\(name)\(ratingPart), \(priceText)"
        case .spanish: return "\(name)\(ratingPart), \(priceText)"
        case .italian: return "\(name)\(ratingPart), \(priceText)"
        case .portuguese: return "\(name)\(ratingPart), \(priceText)"
        case .chineseTraditional: return "\(name)\(ratingPart)，\(priceText)"
        }
    }

    /// D-Day 표시: "오늘", "5일 남음", "3일 지남"
    static func dDay(_ daysRemaining: Int) -> String {
        let lang = LanguageManager.shared.currentLanguage
        if daysRemaining == 0 {
            switch lang {
            case .korean: return "오늘"
            case .english: return "Today"
            case .swedish: return "Idag"
            case .norwegian: return "I dag"
            case .danish: return "I dag"
            case .finnish: return "Tänään"
            case .polish: return "Dziś"
            case .czech: return "Dnes"
            case .greek: return "Σήμερα"
            case .turkish: return "Bugün"
            case .russian: return "Сегодня"
            case .indonesian: return "Hari ini"
            case .thai: return "วันนี้"
            case .vietnamese: return "Hôm nay"
            case .dutch: return "Vandaag"
            case .japanese: return "今日"
            case .chinese: return "今天"
            case .german: return "Heute"
            case .french: return "Aujourd’hui"
            case .spanish: return "Hoy"
            case .italian: return "Oggi"
            case .portuguese: return "Hoje"
            case .chineseTraditional: return "今天"
            }
        }
        let n = abs(daysRemaining)
        if daysRemaining > 0 {
            switch lang {
            case .korean: return "\(n)일 남음"
            case .english: return "in \(n) days"
            case .swedish: return "om \(n) dagar"
            case .norwegian: return "om \(n) dager"
            case .danish: return "om \(n) dage"
            case .finnish: return "\(n) päivän päästä"
            case .polish: return "za \(n) dni"
            case .czech: return "za \(n) d"
            case .greek: return "σε \(n) ημέρες"
            case .turkish: return "\(n) gün sonra"
            case .russian: return "через \(n) \(ruPlural(n, "день", "дня", "дней"))"
            case .indonesian: return "\(n) hari lagi"
            case .thai: return "อีก \(n) วัน"
            case .vietnamese: return "\(n) ngày nữa"
            case .dutch: return "over \(n) dagen"
            case .japanese: return "あと\(n)日"
            case .chinese: return "还有\(n)天"
            case .german: return "in \(n) Tagen"
            case .french: return "dans \(n) jours"
            case .spanish: return n == 1 ? "dentro de 1 día" : "dentro de \(n) días"
            case .italian: return n == 1 ? "tra 1 giorno" : "tra \(n) giorni"
            case .portuguese: return n == 1 ? "daqui a 1 dia" : "daqui a \(n) dias"
            case .chineseTraditional: return "\(n) 天後"
            }
        } else {
            switch lang {
            case .korean: return "\(n)일 지남"
            case .english: return "\(n) days ago"
            case .swedish: return "för \(n) dagar sedan"
            case .norwegian: return "for \(n) dager siden"
            case .danish: return "for \(n) dage siden"
            case .finnish: return "\(n) päivää sitten"
            case .polish: return "\(n) dni temu"
            case .czech: return "před \(n) d"
            case .greek: return "πριν από \(n) ημέρες"
            case .turkish: return "\(n) gün önce"
            case .russian: return "\(n) \(ruPlural(n, "день", "дня", "дней")) назад"
            case .indonesian: return "\(n) hari lalu"
            case .thai: return "\(n) วันที่แล้ว"
            case .vietnamese: return "\(n) ngày trước"
            case .dutch: return "\(n) dagen geleden"
            case .japanese: return "\(n)日経過"
            case .chinese: return "已过\(n)天"
            case .german: return "vor \(n) Tagen"
            case .french: return "il y a \(n) jours"
            case .spanish: return n == 1 ? "hace 1 día" : "hace \(n) días"
            case .italian: return n == 1 ? "1 giorno fa" : "\(n) giorni fa"
            case .portuguese: return n == 1 ? "há 1 dia" : "há \(n) dias"
            case .chineseTraditional: return "\(n) 天前"
            }
        }
    }

    // MARK: - Helpers

    private static func formatDays(_ days: Double) -> String {
        if days == days.rounded() {
            return "\(Int(days))"
        }
        return String(format: "%.1f", days)
    }
}
