//
//  Strings+CountryRequest.swift
//  Goldweek
//
//  지원하지 않는 나라 — 피드백으로 지원 요청
//

import Foundation

extension Strings {
    private static var requestLang: AppLanguage { LanguageManager.shared.currentLanguage }

    /// 지원하지 않는 나라 안내 — {r} 지역 이름
    static func unsupportedCountryRequest(region r: String) -> String {
        switch requestLang {
        case .korean: return "아직 \(r) 공휴일은 지원하지 않아요. 피드백으로 나라 지원을 요청해 주세요."
        case .english: return "\(r) isn't supported yet. Send us feedback to request it."
        case .japanese: return "\(r)の祝日にはまだ対応していません。フィードバックで対応をリクエストしてください。"
        case .chinese: return "暂不支持\(r)的节假日。欢迎通过反馈申请支持这个国家。"
        case .german: return "\(r) wird noch nicht unterstützt. Schick uns Feedback, um es dir zu wünschen."
        case .french: return "\(r) n’est pas encore pris en charge. Envoyez-nous un avis pour le demander."
        case .spanish: return "\(r) aún no está disponible. Envíanos tus comentarios para solicitarlo."
        case .italian: return "\(r) non è ancora supportato. Mandaci un feedback per richiederlo."
        case .portuguese: return "\(r) ainda não é compatível. Envie um feedback para pedir."
        case .chineseTraditional: return "尚未支援\(r)的假日。歡迎透過意見回饋申請支援這個國家。"
        case .dutch: return "\(r) wordt nog niet ondersteund. Stuur ons feedback om het aan te vragen."
        case .swedish: return "\(r) stöds inte än. Skicka feedback för att be om det."
        case .norwegian: return "\(r) støttes ikke ennå. Send oss tilbakemelding for å be om det."
        case .danish: return "\(r) understøttes ikke endnu. Send os feedback for at bede om det."
        case .finnish: return "\(r) ei ole vielä tuettu. Lähetä palautetta ja pyydä tukea."
        case .polish: return "\(r) nie jest jeszcze obsługiwany. Wyślij opinię, aby o to poprosić."
        case .czech: return "\(r) zatím není podporováno. Pošli nám zpětnou vazbu a požádej o podporu."
        case .greek: return "Η χώρα \(r) δεν υποστηρίζεται ακόμη. Στείλε μας σχόλια για να τη ζητήσεις."
        case .turkish: return "\(r) henüz desteklenmiyor. İstemek için bize geri bildirim gönder."
        case .russian: return "\(r) пока не поддерживается. Напишите нам отзыв, чтобы попросить добавить."
        case .indonesian: return "\(r) belum didukung. Kirim masukan untuk memintanya."
        }
    }

    /// 나라 지원 요청 버튼
    static var requestCountrySupport: String {
        switch requestLang {
        case .korean: return "나라 지원 요청하기"
        case .english: return "Request This Country"
        case .japanese: return "この国をリクエスト"
        case .chinese: return "申请支持这个国家"
        case .german: return "Land anfragen"
        case .french: return "Demander ce pays"
        case .spanish: return "Solicitar este país"
        case .italian: return "Richiedi questo paese"
        case .portuguese: return "Pedir este país"
        case .chineseTraditional: return "申請支援這個國家"
        case .dutch: return "Dit land aanvragen"
        case .swedish: return "Be om det här landet"
        case .norwegian: return "Be om dette landet"
        case .danish: return "Bed om dette land"
        case .finnish: return "Pyydä tätä maata"
        case .polish: return "Poproś o ten kraj"
        case .czech: return "Požádat o tuto zemi"
        case .greek: return "Ζήτησε αυτή τη χώρα"
        case .turkish: return "Bu ülkeyi iste"
        case .russian: return "Попросить эту страну"
        case .indonesian: return "Minta negara ini"
        }
    }
}
