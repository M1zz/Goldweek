import Foundation
import GoldweekCore

/// 앱에만 있는 타입(SwiftData 계산 등)을 쓰는 문구. 나머지 문구는 GoldweekCore 에 있다.
extension Strings {

    static func accrualPeriodName(_ period: LeaveUsageCalculator.Accrual.Period) -> String {
        switch period {
        case .weekly:
            switch LanguageManager.shared.currentLanguage {
            case .korean: return "매주 쌓임"
            case .english: return "Accrues weekly"
            case .japanese: return "毎週たまる"
            case .chinese: return "每周累积"
            case .german: return "Wöchentlich angesammelt"
            case .french: return "Acquis chaque semaine"
            case .spanish: return "Se acumula cada semana"
            case .italian: return "Maturate ogni settimana"
            case .portuguese: return "Acumula toda semana"
            case .chineseTraditional: return "每週累積"
            case .dutch: return "Elke week opgebouwd"
            case .swedish: return "Tjänas in varje vecka"
            case .norwegian: return "Opptjenes hver uke"
            case .danish: return "Optjenes hver uge"
            case .finnish: return "Kertyy viikoittain"
            case .polish: return "Narasta co tydzień"
            case .czech: return "Přibývá každý týden"
            case .greek: return "Συσσωρεύεται κάθε εβδομάδα"
            case .turkish: return "Her hafta birikir"
            case .russian: return "Начисляется каждую неделю"
            case .indonesian: return "Bertambah tiap minggu"
            case .thai: return "สะสมทุกสัปดาห์"
            case .vietnamese: return "Cộng dồn mỗi tuần"
            }
        case .biweekly:
            switch LanguageManager.shared.currentLanguage {
            case .korean: return "2주마다 쌓임"
            case .english: return "Accrues every 2 weeks"
            case .japanese: return "2週ごとにたまる"
            case .chinese: return "每两周累积"
            case .german: return "Alle 2 Wochen angesammelt"
            case .french: return "Acquis toutes les 2 semaines"
            case .spanish: return "Se acumula cada 2 semanas"
            case .italian: return "Maturate ogni 2 settimane"
            case .portuguese: return "Acumula a cada 2 semanas"
            case .chineseTraditional: return "每兩週累積"
            case .dutch: return "Elke 2 weken opgebouwd"
            case .swedish: return "Tjänas in varannan vecka"
            case .norwegian: return "Opptjenes annenhver uke"
            case .danish: return "Optjenes hver anden uge"
            case .finnish: return "Kertyy 2 viikon välein"
            case .polish: return "Narasta co 2 tygodnie"
            case .czech: return "Přibývá každé 2 týdny"
            case .greek: return "Συσσωρεύεται κάθε 2 εβδομάδες"
            case .turkish: return "2 haftada bir birikir"
            case .russian: return "Начисляется раз в 2 недели"
            case .indonesian: return "Bertambah tiap 2 minggu"
            case .thai: return "สะสมทุก 2 สัปดาห์"
            case .vietnamese: return "Cộng dồn mỗi 2 tuần"
            }
        case .semimonthly:
            switch LanguageManager.shared.currentLanguage {
            case .korean: return "한 달에 두 번 쌓임 (15일·말일)"
            case .english: return "Twice a month (15th & last day)"
            case .japanese: return "月2回たまる（15日・月末）"
            case .chinese: return "每月累积两次（15日、月末）"
            case .german: return "Zweimal im Monat (15. & Monatsende)"
            case .french: return "Deux fois par mois (le 15 et en fin de mois)"
            case .spanish: return "Dos veces al mes (día 15 y fin de mes)"
            case .italian: return "Due volte al mese (il 15 e a fine mese)"
            case .portuguese: return "Duas vezes por mês (dia 15 e fim do mês)"
            case .chineseTraditional: return "每月累積兩次（15日、月底）"
            case .dutch: return "Twee keer per maand (de 15e en eind van de maand)"
            case .swedish: return "Två gånger i månaden (den 15:e och sista)"
            case .norwegian: return "To ganger i måneden (den 15. og siste)"
            case .danish: return "To gange om måneden (den 15. og sidste)"
            case .finnish: return "Kahdesti kuussa (15. ja kuun viimeinen)"
            case .polish: return "Dwa razy w miesiącu (15. i ostatni dzień)"
            case .czech: return "Dvakrát měsíčně (15. a poslední den)"
            case .greek: return "Δύο φορές τον μήνα (15 και τέλος μήνα)"
            case .turkish: return "Ayda iki kez (15'i ve ay sonu)"
            case .russian: return "Дважды в месяц (15-го и в конце месяца)"
            case .indonesian: return "Dua kali sebulan (tgl 15 & akhir bulan)"
            case .thai: return "เดือนละ 2 ครั้ง (วันที่ 15 และสิ้นเดือน)"
            case .vietnamese: return "Hai lần mỗi tháng (ngày 15 và cuối tháng)"
            }
        case .monthly:
            switch LanguageManager.shared.currentLanguage {
            case .korean: return "매달 쌓임"
            case .english: return "Accrues monthly"
            case .japanese: return "毎月たまる"
            case .chinese: return "每月累积"
            case .german: return "Monatlich angesammelt"
            case .french: return "Acquis chaque mois"
            case .spanish: return "Se acumula cada mes"
            case .italian: return "Maturate ogni mese"
            case .portuguese: return "Acumula todo mês"
            case .chineseTraditional: return "每月累積"
            case .dutch: return "Elke maand opgebouwd"
            case .swedish: return "Tjänas in varje månad"
            case .norwegian: return "Opptjenes hver måned"
            case .danish: return "Optjenes hver måned"
            case .finnish: return "Kertyy kuukausittain"
            case .polish: return "Narasta co miesiąc"
            case .czech: return "Přibývá každý měsíc"
            case .greek: return "Συσσωρεύεται κάθε μήνα"
            case .turkish: return "Her ay birikir"
            case .russian: return "Начисляется каждый месяц"
            case .indonesian: return "Bertambah tiap bulan"
            case .thai: return "สะสมทุกเดือน"
            case .vietnamese: return "Cộng dồn mỗi tháng"
            }
        }
    }
}
