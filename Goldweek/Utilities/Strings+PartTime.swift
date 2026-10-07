//
//  Strings+PartTime.swift
//  Goldweek
//
//  파트타임 쉬는 요일 · 이번 주만 옮기기 문구 (네덜란드 사용자 피드백)
//

import Foundation

extension Strings {
    private static var partTimeLang: AppLanguage { LanguageManager.shared.currentLanguage }

    /// 설정 — 매주 쉬는 요일 (파트타임)
    static var partTimeDaysSetting: String {
        switch partTimeLang {
        case .korean: return "매주 쉬는 요일"
        case .english: return "Regular Days Off"
        case .japanese: return "毎週の休み"
        case .chinese: return "每周固定休息日"
        case .german: return "Feste freie Tage"
        case .french: return "Jours de repos fixes"
        case .spanish: return "Días libres fijos"
        case .italian: return "Giorni liberi fissi"
        case .portuguese: return "Folgas fixas"
        case .chineseTraditional: return "每週固定休息日"
        case .dutch: return "Vaste vrije dagen"
        case .swedish: return "Fasta lediga dagar"
        case .norwegian: return "Faste fridager"
        case .danish: return "Faste fridage"
        case .finnish: return "Vakiovapaapäivät"
        case .polish: return "Stałe dni wolne"
        case .czech: return "Pravidelné volné dny"
        case .greek: return "Σταθερά ρεπό"
        case .turkish: return "Sabit izin günleri"
        case .russian: return "Постоянные выходные"
        case .indonesian: return "Hari libur tetap"
        }
    }

    /// 설정 — 매주 쉬는 요일 설명
    static var partTimeDaysFooter: String {
        switch partTimeLang {
        case .korean: return "파트타임처럼 매주 일하지 않는 요일을 고르세요. 그날은 주말처럼 연차에서 빠지지 않아요. 어느 주에 동료와 바꾸면 달력에서 그 날을 눌러 이번 주만 옮길 수 있어요."
        case .english: return "Pick the weekdays you don't work, like a part-time day. They're never taken from your leave, just like weekends. If you trade days with a colleague, tap that day on the calendar to move it for just that week."
        case .japanese: return "パートタイムのように毎週働かない曜日を選んでください。週末と同じく休暇から引かれません。同僚と交代する週は、カレンダーでその日をタップしてその週だけ移せます。"
        case .chinese: return "选择每周不上班的日子（例如兼职）。和周末一样，不会从年假中扣除。如果某周和同事换班，可以在日历中点按那天，只调整这一周。"
        case .german: return "Wähle die Wochentage, an denen du nicht arbeitest, etwa bei Teilzeit. Sie zählen wie das Wochenende nicht als Urlaub. Tauschst du mit Kollegen, tippe im Kalender auf den Tag und verschiebe ihn nur für diese Woche."
        case .french: return "Choisissez les jours où vous ne travaillez pas, comme un temps partiel. Comme le week-end, ils ne sont pas déduits de vos congés. Si vous échangez avec un collègue, touchez ce jour dans le calendrier pour le déplacer cette semaine seulement."
        case .spanish: return "Elige los días que no trabajas, como en una jornada parcial. Igual que el fin de semana, no se descuentan de tus vacaciones. Si cambias con un compañero, toca ese día en el calendario para moverlo solo esa semana."
        case .italian: return "Scegli i giorni in cui non lavori, come nel part-time. Come il weekend, non vengono scalati dalle ferie. Se fai cambio con un collega, tocca quel giorno nel calendario per spostarlo solo per quella settimana."
        case .portuguese: return "Escolha os dias em que você não trabalha, como em meio período. Assim como o fim de semana, eles não contam como folga. Se trocar com um colega, toque nesse dia no calendário para mudá-lo só naquela semana."
        case .chineseTraditional: return "選擇每週不上班的日子（例如兼職）。和週末一樣，不會從特休扣除。如果某週和同事換班，可以在行事曆點一下那天，只調整這一週。"
        case .dutch: return "Kies de dagen waarop je niet werkt, zoals bij parttime. Net als het weekend gaan ze niet van je verlof af. Ruil je met een collega, tik dan in de kalender op die dag om hem alleen die week te verplaatsen."
        case .swedish: return "Välj veckodagarna du inte jobbar, till exempel vid deltid. Precis som helgen dras de inte från semestern. Byter du med en kollega trycker du på dagen i kalendern och flyttar den bara den veckan."
        case .norwegian: return "Velg ukedagene du ikke jobber, for eksempel ved deltid. Akkurat som helgen trekkes de ikke fra ferien. Bytter du med en kollega, trykker du på dagen i kalenderen og flytter den bare den uken."
        case .danish: return "Vælg de ugedage, du ikke arbejder, fx ved deltid. Ligesom weekenden trækkes de ikke fra din ferie. Bytter du med en kollega, så tryk på dagen i kalenderen og flyt den kun for den uge."
        case .finnish: return "Valitse viikonpäivät, joina et tee töitä, kuten osa-aikatyössä. Viikonlopun tapaan niitä ei vähennetä lomasta. Jos vaihdat kollegan kanssa, napauta päivää kalenterissa ja siirrä se vain sille viikolle."
        case .polish: return "Wybierz dni, w które nie pracujesz, np. przy niepełnym etacie. Tak jak weekend nie są odejmowane od urlopu. Jeśli zamieniasz się z kimś, stuknij ten dzień w kalendarzu i przenieś go tylko w tym tygodniu."
        case .czech: return "Vyber dny, kdy nepracuješ, třeba při částečném úvazku. Stejně jako víkend se neodečítají z dovolené. Když se vyměníš s kolegou, klepni na ten den v kalendáři a přesuň ho jen pro ten týden."
        case .greek: return "Διάλεξε τις μέρες που δεν δουλεύεις, όπως στη μερική απασχόληση. Όπως το σαββατοκύριακο, δεν αφαιρούνται από την άδεια. Αν αλλάξεις με συνάδελφο, πάτησε τη μέρα στο ημερολόγιο και μετακίνησέ τη μόνο για εκείνη την εβδομάδα."
        case .turkish: return "Yarı zamanlı gibi çalışmadığın günleri seç. Hafta sonu gibi izninden düşülmez. Bir iş arkadaşınla değiştirirsen takvimde o güne dokunup yalnızca o hafta için taşıyabilirsin."
        case .russian: return "Выберите дни недели, когда вы не работаете, например при неполной занятости. Как и выходные, они не вычитаются из отпуска. Если меняетесь с коллегой, нажмите на этот день в календаре и перенесите его только на эту неделю."
        case .indonesian: return "Pilih hari yang kamu tidak bekerja, seperti kerja paruh waktu. Sama seperti akhir pekan, hari itu tidak memotong cuti. Jika bertukar dengan rekan, ketuk hari itu di kalender untuk memindahkannya hanya minggu itu."
        }
    }

    /// 날짜 상세 — 고정 쉬는 날
    static var partTimeRegularDayOff: String {
        switch partTimeLang {
        case .korean: return "고정 쉬는 날"
        case .english: return "Regular day off"
        case .japanese: return "いつもの休み"
        case .chinese: return "固定休息日"
        case .german: return "Fester freier Tag"
        case .french: return "Jour de repos fixe"
        case .spanish: return "Día libre fijo"
        case .italian: return "Giorno libero fisso"
        case .portuguese: return "Folga fixa"
        case .chineseTraditional: return "固定休息日"
        case .dutch: return "Vaste vrije dag"
        case .swedish: return "Fast ledig dag"
        case .norwegian: return "Fast fridag"
        case .danish: return "Fast fridag"
        case .finnish: return "Vakiovapaapäivä"
        case .polish: return "Stały dzień wolny"
        case .czech: return "Pravidelný volný den"
        case .greek: return "Σταθερό ρεπό"
        case .turkish: return "Sabit izin günü"
        case .russian: return "Постоянный выходной"
        case .indonesian: return "Hari libur tetap"
        }
    }

    /// 날짜 상세 — 이번 주만 옮기기 버튼
    static var partTimeMoveThisWeek: String {
        switch partTimeLang {
        case .korean: return "이번 주만 다른 날로 옮기기"
        case .english: return "Move it this week only"
        case .japanese: return "今週だけ別の日に移す"
        case .chinese: return "仅本周换到其他日子"
        case .german: return "Nur diese Woche verschieben"
        case .french: return "Déplacer cette semaine seulement"
        case .spanish: return "Moverlo solo esta semana"
        case .italian: return "Spostalo solo questa settimana"
        case .portuguese: return "Mudar só nesta semana"
        case .chineseTraditional: return "僅本週換到其他日子"
        case .dutch: return "Alleen deze week verplaatsen"
        case .swedish: return "Flytta bara den här veckan"
        case .norwegian: return "Flytt bare denne uken"
        case .danish: return "Flyt kun i denne uge"
        case .finnish: return "Siirrä vain tällä viikolla"
        case .polish: return "Przenieś tylko w tym tygodniu"
        case .czech: return "Přesunout jen tento týden"
        case .greek: return "Μετακίνηση μόνο αυτή την εβδομάδα"
        case .turkish: return "Yalnızca bu hafta taşı"
        case .russian: return "Перенести только на этой неделе"
        case .indonesian: return "Pindahkan untuk minggu ini saja"
        }
    }

    /// 옮길 날 고르기 시트 제목
    static var partTimeMoveTitle: String {
        switch partTimeLang {
        case .korean: return "어느 날 대신 쉬나요?"
        case .english: return "Which day do you take off instead?"
        case .japanese: return "代わりにどの日を休みますか？"
        case .chinese: return "改在哪一天休息？"
        case .german: return "Welchen Tag nimmst du stattdessen frei?"
        case .french: return "Quel jour prenez-vous à la place ?"
        case .spanish: return "¿Qué día libras en su lugar?"
        case .italian: return "Quale giorno prendi libero al suo posto?"
        case .portuguese: return "Qual dia você folga no lugar?"
        case .chineseTraditional: return "改在哪一天休息？"
        case .dutch: return "Welke dag neem je in plaats daarvan vrij?"
        case .swedish: return "Vilken dag är du ledig i stället?"
        case .norwegian: return "Hvilken dag har du fri i stedet?"
        case .danish: return "Hvilken dag holder du fri i stedet?"
        case .finnish: return "Minä päivänä olet vapaalla sen sijaan?"
        case .polish: return "Który dzień bierzesz wolny zamiast tego?"
        case .czech: return "Který den máš místo toho volno?"
        case .greek: return "Ποια μέρα παίρνεις ρεπό αντί γι' αυτή;"
        case .turkish: return "Bunun yerine hangi gün izinlisin?"
        case .russian: return "Какой день будет выходным вместо него?"
        case .indonesian: return "Hari apa kamu libur sebagai gantinya?"
        }
    }

    /// 날짜 상세 — 옮겨 와서 쉬는 날
    static var partTimeMovedOff: String {
        switch partTimeLang {
        case .korean: return "쉬는 날 (옮겨 옴)"
        case .english: return "Day off (moved here)"
        case .japanese: return "休み（移動）"
        case .chinese: return "休息日（调换）"
        case .german: return "Freier Tag (verschoben)"
        case .french: return "Jour de repos (déplacé)"
        case .spanish: return "Día libre (movido)"
        case .italian: return "Giorno libero (spostato)"
        case .portuguese: return "Folga (mudada)"
        case .chineseTraditional: return "休息日（調換）"
        case .dutch: return "Vrije dag (verplaatst)"
        case .swedish: return "Ledig dag (flyttad)"
        case .norwegian: return "Fridag (flyttet)"
        case .danish: return "Fridag (flyttet)"
        case .finnish: return "Vapaapäivä (siirretty)"
        case .polish: return "Dzień wolny (przeniesiony)"
        case .czech: return "Volný den (přesunutý)"
        case .greek: return "Ρεπό (μετακινήθηκε)"
        case .turkish: return "İzin günü (taşındı)"
        case .russian: return "Выходной (перенесён)"
        case .indonesian: return "Hari libur (dipindah)"
        }
    }

    /// 날짜 상세 — 원래 쉬는 날인데 이번 주는 일함
    static var partTimeMovedWork: String {
        switch partTimeLang {
        case .korean: return "이번 주는 일하는 날 (쉬는 날 옮김)"
        case .english: return "Working this week (day off moved)"
        case .japanese: return "今週は出勤（休みを移動）"
        case .chinese: return "本周上班（休息日已调换）"
        case .german: return "Diese Woche Arbeitstag (frei verschoben)"
        case .french: return "Travaillé cette semaine (repos déplacé)"
        case .spanish: return "Esta semana trabajas (día libre movido)"
        case .italian: return "Questa settimana lavori (giorno libero spostato)"
        case .portuguese: return "Nesta semana você trabalha (folga mudada)"
        case .chineseTraditional: return "本週上班（休息日已調換）"
        case .dutch: return "Deze week werkdag (vrije dag verplaatst)"
        case .swedish: return "Arbetsdag den här veckan (ledig dag flyttad)"
        case .norwegian: return "Arbeidsdag denne uken (fridag flyttet)"
        case .danish: return "Arbejdsdag i denne uge (fridag flyttet)"
        case .finnish: return "Työpäivä tällä viikolla (vapaa siirretty)"
        case .polish: return "W tym tygodniu pracujesz (wolne przeniesione)"
        case .czech: return "Tento týden pracuješ (volno přesunuto)"
        case .greek: return "Εργάσιμη αυτή την εβδομάδα (το ρεπό μετακινήθηκε)"
        case .turkish: return "Bu hafta çalışıyorsun (izin taşındı)"
        case .russian: return "На этой неделе рабочий (выходной перенесён)"
        case .indonesian: return "Minggu ini hari kerja (libur dipindah)"
        }
    }

    /// 옮긴 것 되돌리기
    static var partTimeUndoMove: String {
        switch partTimeLang {
        case .korean: return "원래대로"
        case .english: return "Undo move"
        case .japanese: return "元に戻す"
        case .chinese: return "恢复原样"
        case .german: return "Rückgängig"
        case .french: return "Annuler le déplacement"
        case .spanish: return "Deshacer"
        case .italian: return "Annulla spostamento"
        case .portuguese: return "Desfazer"
        case .chineseTraditional: return "恢復原樣"
        case .dutch: return "Ongedaan maken"
        case .swedish: return "Ångra flytt"
        case .norwegian: return "Angre flytting"
        case .danish: return "Fortryd flytning"
        case .finnish: return "Kumoa siirto"
        case .polish: return "Cofnij przeniesienie"
        case .czech: return "Vrátit zpět"
        case .greek: return "Αναίρεση"
        case .turkish: return "Geri al"
        case .russian: return "Отменить перенос"
        case .indonesian: return "Batalkan pindah"
        }
    }
}
