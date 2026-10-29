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
        case .thai: return "วันหยุดประจำ"
        case .vietnamese: return "Ngày nghỉ cố định"
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
        case .thai: return "เลือกวันที่คุณไม่ต้องทำงาน เช่น วันหยุดของงานพาร์ตไทม์ วันเหล่านี้ไม่หักวันลาเหมือนวันหยุดสุดสัปดาห์ ถ้าสลับวันกับเพื่อนร่วมงาน แตะวันนั้นในปฏิทินเพื่อย้ายเฉพาะสัปดาห์นั้น"
        case .vietnamese: return "Chọn những ngày trong tuần bạn không đi làm, như ngày nghỉ của công việc bán thời gian. Giống cuối tuần, những ngày này không bị trừ phép. Nếu đổi ca với đồng nghiệp, hãy chạm vào ngày đó trên lịch để dời riêng tuần đó."
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
        case .thai: return "วันหยุดประจำ"
        case .vietnamese: return "Ngày nghỉ cố định"
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
        case .thai: return "ย้ายเฉพาะสัปดาห์นี้"
        case .vietnamese: return "Chỉ dời trong tuần này"
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
        case .thai: return "จะหยุดวันไหนแทน"
        case .vietnamese: return "Bạn nghỉ bù vào ngày nào?"
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
        case .thai: return "วันหยุด (ย้ายมา)"
        case .vietnamese: return "Ngày nghỉ (đã dời sang)"
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
        case .thai: return "สัปดาห์นี้ทำงาน (ย้ายวันหยุดแล้ว)"
        case .vietnamese: return "Tuần này đi làm (đã dời ngày nghỉ)"
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
        case .thai: return "ยกเลิกการย้าย"
        case .vietnamese: return "Hoàn tác dời ngày"
        }
    }
}

// MARK: - 근무 형태 · 교대 근무 · 시간 단위 휴가 켜기 (교대 근무 피드백, 2026-10-12)

extension Strings {
    /// 근무 형태
    static var workPatternTitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "근무 형태"
        case .english: return "Work schedule"
        case .japanese: return "勤務形態"
        case .chinese: return "工作方式"
        case .german: return "Arbeitsmodell"
        case .french: return "Type d'horaire"
        case .spanish: return "Tipo de jornada"
        case .italian: return "Tipo di orario"
        case .portuguese: return "Tipo de jornada"
        case .chineseTraditional: return "工作方式"
        case .dutch: return "Werkrooster"
        case .swedish: return "Arbetsschema"
        case .norwegian: return "Arbeidsordning"
        case .danish: return "Arbejdsform"
        case .finnish: return "Työaikamuoto"
        case .polish: return "Tryb pracy"
        case .czech: return "Pracovní režim"
        case .greek: return "Τύπος ωραρίου"
        case .turkish: return "Çalışma düzeni"
        case .russian: return "График работы"
        case .indonesian: return "Pola kerja"
        case .thai: return "รูปแบบการทำงาน"
        case .vietnamese: return "Hình thức làm việc"
        }
    }

    /// 근무 형태 — 고정
    static var workPatternFixed: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "고정 근무"
        case .english: return "Fixed schedule"
        case .japanese: return "固定勤務"
        case .chinese: return "固定排班"
        case .german: return "Feste Arbeitstage"
        case .french: return "Horaire fixe"
        case .spanish: return "Horario fijo"
        case .italian: return "Orario fisso"
        case .portuguese: return "Horário fixo"
        case .chineseTraditional: return "固定排班"
        case .dutch: return "Vast rooster"
        case .swedish: return "Fast schema"
        case .norwegian: return "Fast arbeidstid"
        case .danish: return "Fast arbejdstid"
        case .finnish: return "Kiinteä työaika"
        case .polish: return "Stały grafik"
        case .czech: return "Pevná pracovní doba"
        case .greek: return "Σταθερό ωράριο"
        case .turkish: return "Sabit çalışma"
        case .russian: return "Постоянный график"
        case .indonesian: return "Jadwal tetap"
        case .thai: return "ทำงานวันประจำ"
        case .vietnamese: return "Lịch cố định"
        }
    }

    /// 고정 근무 설명
    static var workPatternFixedDesc: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "매주 같은 요일에 일하고 주말에 쉬어요"
        case .english: return "Same days every week, weekends off"
        case .japanese: return "毎週同じ曜日に働き、週末は休み"
        case .chinese: return "每周固定几天上班，周末休息"
        case .german: return "Jede Woche dieselben Tage, Wochenende frei"
        case .french: return "Mêmes jours chaque semaine, week-end libre"
        case .spanish: return "Mismos días cada semana, fines de semana libres"
        case .italian: return "Stessi giorni ogni settimana, weekend libero"
        case .portuguese: return "Mesmos dias toda semana, fins de semana livres"
        case .chineseTraditional: return "每週固定幾天上班，週末休息"
        case .dutch: return "Elke week dezelfde dagen, weekend vrij"
        case .swedish: return "Samma dagar varje vecka, ledig på helgen"
        case .norwegian: return "Samme dager hver uke, fri i helgene"
        case .danish: return "Samme dage hver uge, fri i weekenden"
        case .finnish: return "Samat päivät joka viikko, viikonloput vapaat"
        case .polish: return "Te same dni co tydzień, weekendy wolne"
        case .czech: return "Každý týden stejné dny, víkendy volno"
        case .greek: return "Ίδιες ημέρες κάθε εβδομάδα, Σαββατοκύριακα ελεύθερα"
        case .turkish: return "Her hafta aynı günler, hafta sonu izin"
        case .russian: return "Одни и те же дни каждую неделю, выходные свободны"
        case .indonesian: return "Hari yang sama tiap minggu, akhir pekan libur"
        case .thai: return "ทำงานวันเดิมทุกสัปดาห์ หยุดเสาร์-อาทิตย์"
        case .vietnamese: return "Làm cùng các ngày mỗi tuần, nghỉ cuối tuần"
        }
    }

    /// 근무 형태 — 파트타임
    static var workPatternPartTime: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "파트타임"
        case .english: return "Part-time"
        case .japanese: return "パートタイム"
        case .chinese: return "兼职"
        case .german: return "Teilzeit"
        case .french: return "Temps partiel"
        case .spanish: return "Media jornada"
        case .italian: return "Part-time"
        case .portuguese: return "Meio período"
        case .chineseTraditional: return "兼職"
        case .dutch: return "Deeltijd"
        case .swedish: return "Deltid"
        case .norwegian: return "Deltid"
        case .danish: return "Deltid"
        case .finnish: return "Osa-aika"
        case .polish: return "Niepełny etat"
        case .czech: return "Částečný úvazek"
        case .greek: return "Μερική απασχόληση"
        case .turkish: return "Yarı zamanlı"
        case .russian: return "Неполный день"
        case .indonesian: return "Paruh waktu"
        case .thai: return "พาร์ตไทม์"
        case .vietnamese: return "Bán thời gian"
        }
    }

    /// 파트타임 설명
    static var workPatternPartTimeDesc: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "매주 정해진 요일에도 쉬어요"
        case .english: return "A set weekday off every week"
        case .japanese: return "毎週決まった曜日も休み"
        case .chinese: return "每周固定某天也休息"
        case .german: return "Jede Woche ein fester freier Wochentag"
        case .french: return "Un jour fixe de repos chaque semaine"
        case .spanish: return "Un día fijo libre cada semana"
        case .italian: return "Un giorno fisso libero ogni settimana"
        case .portuguese: return "Um dia fixo de folga toda semana"
        case .chineseTraditional: return "每週固定某天也休息"
        case .dutch: return "Elke week een vaste vrije dag"
        case .swedish: return "En fast ledig veckodag varje vecka"
        case .norwegian: return "En fast fridag hver uke"
        case .danish: return "En fast fridag hver uge"
        case .finnish: return "Kiinteä vapaapäivä joka viikko"
        case .polish: return "Stały wolny dzień w każdym tygodniu"
        case .czech: return "Pevný volný den každý týden"
        case .greek: return "Μια σταθερή ρεπό ημέρα κάθε εβδομάδα"
        case .turkish: return "Her hafta sabit bir izin günü"
        case .russian: return "Постоянный выходной день каждую неделю"
        case .indonesian: return "Satu hari libur tetap tiap minggu"
        case .thai: return "หยุดวันที่กำหนดไว้ทุกสัปดาห์ด้วย"
        case .vietnamese: return "Nghỉ thêm các ngày cố định mỗi tuần"
        }
    }

    /// 근무 형태 — 교대
    static var workPatternShift: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "교대 근무"
        case .english: return "Shift work"
        case .japanese: return "シフト勤務"
        case .chinese: return "轮班"
        case .german: return "Schichtarbeit"
        case .french: return "Travail posté"
        case .spanish: return "Trabajo por turnos"
        case .italian: return "Turni"
        case .portuguese: return "Trabalho por turnos"
        case .chineseTraditional: return "輪班"
        case .dutch: return "Ploegendienst"
        case .swedish: return "Skiftarbete"
        case .norwegian: return "Skiftarbeid"
        case .danish: return "Skifteholdsarbejde"
        case .finnish: return "Vuorotyö"
        case .polish: return "Praca zmianowa"
        case .czech: return "Směnný provoz"
        case .greek: return "Βάρδιες"
        case .turkish: return "Vardiyalı çalışma"
        case .russian: return "Сменная работа"
        case .indonesian: return "Kerja shift"
        case .thai: return "ทำงานเป็นกะ"
        case .vietnamese: return "Làm theo ca"
        }
    }

    /// 교대 근무 설명
    static var workPatternShiftDesc: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "쉬는 날이 주마다 바뀌어요"
        case .english: return "Days off change from week to week"
        case .japanese: return "休みの日が週ごとに変わる"
        case .chinese: return "休息日每周都不同"
        case .german: return "Freie Tage wechseln von Woche zu Woche"
        case .french: return "Les jours de repos changent chaque semaine"
        case .spanish: return "Los días libres cambian cada semana"
        case .italian: return "I giorni liberi cambiano ogni settimana"
        case .portuguese: return "Os dias de folga mudam a cada semana"
        case .chineseTraditional: return "休息日每週都不同"
        case .dutch: return "Vrije dagen verschillen per week"
        case .swedish: return "Lediga dagar varierar från vecka till vecka"
        case .norwegian: return "Fridagene varierer fra uke til uke"
        case .danish: return "Fridagene skifter fra uge til uge"
        case .finnish: return "Vapaapäivät vaihtelevat viikoittain"
        case .polish: return "Dni wolne zmieniają się co tydzień"
        case .czech: return "Volné dny se mění každý týden"
        case .greek: return "Τα ρεπό αλλάζουν κάθε εβδομάδα"
        case .turkish: return "İzin günleri haftadan haftaya değişir"
        case .russian: return "Выходные меняются каждую неделю"
        case .indonesian: return "Hari libur berubah tiap minggu"
        case .thai: return "วันหยุดเปลี่ยนไปทุกสัปดาห์"
        case .vietnamese: return "Ngày nghỉ thay đổi theo từng tuần"
        }
    }

    /// 근무 형태 설정 설명
    static var workPatternFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "고른 형태에 맞는 설정만 보여요. 형태를 바꿔도 전에 넣은 쉬는 날은 남아 있어요."
        case .english: return "Only the settings for your schedule are shown. Days off you entered are kept if you switch."
        case .japanese: return "選んだ形態に合う設定だけが表示されます。形態を変えても入力した休みは残ります。"
        case .chinese: return "只显示与所选方式相关的设置。切换后之前输入的休息日仍会保留。"
        case .german: return "Es werden nur die passenden Einstellungen gezeigt. Eingetragene freie Tage bleiben beim Wechsel erhalten."
        case .french: return "Seuls les réglages de votre horaire s'affichent. Les jours saisis sont conservés si vous changez."
        case .spanish: return "Solo se muestran los ajustes de tu jornada. Los días libres que pusiste se conservan si cambias."
        case .italian: return "Vengono mostrate solo le impostazioni del tuo orario. I giorni liberi inseriti restano se cambi."
        case .portuguese: return "Só aparecem os ajustes da sua jornada. As folgas que você inseriu ficam guardadas se mudar."
        case .chineseTraditional: return "只顯示與所選方式相關的設定。切換後先前輸入的休息日仍會保留。"
        case .dutch: return "Alleen de instellingen voor jouw rooster worden getoond. Ingevoerde vrije dagen blijven bewaard als je wisselt."
        case .swedish: return "Bara inställningarna för ditt schema visas. Lediga dagar du lagt in sparas om du byter."
        case .norwegian: return "Bare innstillingene for arbeidsordningen din vises. Fridager du har lagt inn beholdes hvis du bytter."
        case .danish: return "Kun indstillingerne for din arbejdsform vises. Fridage, du har indtastet, bevares, hvis du skifter."
        case .finnish: return "Vain työaikamuotoosi liittyvät asetukset näytetään. Syötetyt vapaapäivät säilyvät, jos vaihdat."
        case .polish: return "Widać tylko ustawienia dla Twojego trybu. Wpisane dni wolne zostaną zachowane po zmianie."
        case .czech: return "Zobrazí se jen nastavení pro váš režim. Zadané volné dny zůstanou i po změně."
        case .greek: return "Εμφανίζονται μόνο οι ρυθμίσεις του ωραρίου σας. Τα ρεπό που βάλατε κρατιούνται αν αλλάξετε."
        case .turkish: return "Yalnızca düzeninize uygun ayarlar görünür. Değiştirseniz de girdiğiniz izin günleri korunur."
        case .russian: return "Показываются только настройки вашего графика. Введённые выходные сохранятся при смене."
        case .indonesian: return "Hanya pengaturan pola kerja Anda yang tampil. Hari libur yang dimasukkan tetap tersimpan jika diganti."
        case .thai: return "แสดงเฉพาะการตั้งค่าที่ตรงกับรูปแบบที่เลือก วันหยุดที่ใส่ไว้แล้วจะยังอยู่แม้เปลี่ยนรูปแบบ"
        case .vietnamese: return "Chỉ hiện cài đặt phù hợp với hình thức đã chọn. Khi đổi hình thức, các ngày nghỉ đã nhập vẫn được giữ."
        }
    }

    /// 시간 단위 휴가 켜기
    static var hourlyLeaveToggle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "시간 단위로도 휴가를 써요"
        case .english: return "I take leave by the hour"
        case .japanese: return "時間単位でも休暇を取る"
        case .chinese: return "我也按小时请假"
        case .german: return "Ich nehme auch stundenweise frei"
        case .french: return "Je prends aussi des congés à l'heure"
        case .spanish: return "También tomo permisos por horas"
        case .italian: return "Uso anche permessi a ore"
        case .portuguese: return "Também tiro folga por horas"
        case .chineseTraditional: return "我也按小時請假"
        case .dutch: return "Ik neem ook verlof per uur"
        case .swedish: return "Jag tar även ledigt per timme"
        case .norwegian: return "Jeg tar også fri per time"
        case .danish: return "Jeg tager også fri pr. time"
        case .finnish: return "Pidän vapaata myös tunneittain"
        case .polish: return "Biorę też urlop na godziny"
        case .czech: return "Beru volno i po hodinách"
        case .greek: return "Παίρνω άδεια και με την ώρα"
        case .turkish: return "Saatlik izin de kullanıyorum"
        case .russian: return "Беру отгулы и по часам"
        case .indonesian: return "Saya juga cuti per jam"
        case .thai: return "ฉันลาเป็นชั่วโมงด้วย"
        case .vietnamese: return "Tôi cũng nghỉ theo giờ"
        }
    }

    /// 시간 단위 휴가 설명
    static var hourlyLeaveDesc: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "켜면 휴가를 시·분으로 넣고, 하루·요일별 근무 시간과 시간 한도를 정할 수 있어요."
        case .english: return "Turn on to enter leave in hours and minutes and set daily hours and hour allowances."
        case .japanese: return "オンにすると休暇を時間・分で入力し、勤務時間や時間の上限を設定できます。"
        case .chinese: return "开启后可按小时和分钟登记假期，并设置每日工时和小时额度。"
        case .german: return "Aktiviere es, um Urlaub in Stunden und Minuten einzutragen und Arbeitszeiten sowie Stundenkontingente festzulegen."
        case .french: return "Activez pour saisir des congés en heures et minutes et définir horaires et quotas d'heures."
        case .spanish: return "Actívalo para registrar ausencias en horas y minutos y fijar horarios y cupos de horas."
        case .italian: return "Attivalo per inserire permessi in ore e minuti e impostare orari e monte ore."
        case .portuguese: return "Ative para registrar folgas em horas e minutos e definir horários e cotas de horas."
        case .chineseTraditional: return "開啟後可按小時和分鐘登記假期，並設定每日工時和小時額度。"
        case .dutch: return "Zet aan om verlof in uren en minuten in te voeren en werktijden en urentegoed in te stellen."
        case .swedish: return "Slå på för att ange ledighet i timmar och minuter och ställa in arbetstid och timkvoter."
        case .norwegian: return "Slå på for å legge inn fri i timer og minutter og angi arbeidstid og timekvoter."
        case .danish: return "Slå til for at angive fri i timer og minutter og indstille arbejdstid og timekvoter."
        case .finnish: return "Ota käyttöön, niin voit syöttää vapaat tunteina ja minuutteina ja asettaa työajat ja tuntikiintiöt."
        case .polish: return "Włącz, aby wpisywać urlop w godzinach i minutach oraz ustawić czas pracy i limity godzin."
        case .czech: return "Zapněte pro zadávání volna v hodinách a minutách a nastavení pracovní doby a hodinových nároků."
        case .greek: return "Ενεργοποιήστε για να καταχωρείτε άδεια σε ώρες και λεπτά και να ορίζετε ωράριο και όρια ωρών."
        case .turkish: return "Açarsanız izni saat ve dakika olarak girip çalışma saatlerini ve saat haklarını belirleyebilirsiniz."
        case .russian: return "Включите, чтобы вводить отпуск в часах и минутах и задать рабочее время и лимиты часов."
        case .indonesian: return "Aktifkan untuk mencatat cuti dalam jam dan menit serta mengatur jam kerja dan jatah jam."
        case .thai: return "เปิดเพื่อบันทึกการลาเป็นชั่วโมงและนาที และกำหนดชั่วโมงทำงานต่อวัน ชั่วโมงทำงานแต่ละวัน และโควตาเป็นชั่วโมง"
        case .vietnamese: return "Bật để ghi phép theo giờ và phút, đặt số giờ làm mỗi ngày, theo từng thứ và hạn mức theo giờ."
        }
    }

    /// 교대 근무 일정 화면
    static var shiftScheduleTitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "교대 근무 일정"
        case .english: return "Shift schedule"
        case .japanese: return "シフト表"
        case .chinese: return "轮班表"
        case .german: return "Schichtplan"
        case .french: return "Planning des postes"
        case .spanish: return "Calendario de turnos"
        case .italian: return "Calendario turni"
        case .portuguese: return "Escala de turnos"
        case .chineseTraditional: return "輪班表"
        case .dutch: return "Dienstrooster"
        case .swedish: return "Skiftschema"
        case .norwegian: return "Vaktplan"
        case .danish: return "Vagtplan"
        case .finnish: return "Työvuorolista"
        case .polish: return "Grafik zmian"
        case .czech: return "Rozpis směn"
        case .greek: return "Πρόγραμμα βαρδιών"
        case .turkish: return "Vardiya planı"
        case .russian: return "График смен"
        case .indonesian: return "Jadwal shift"
        case .thai: return "ตารางกะ"
        case .vietnamese: return "Lịch ca"
        }
    }

    /// 교대 근무 일정 설명
    static var shiftScheduleFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "날짜를 눌러 근무와 휴무를 바꾸세요. 휴무인 날은 연차에서 빠지지 않고, 추천도 쉬는 날로 봐요."
        case .english: return "Tap a day to switch between work and off. Days off aren't taken from your leave, and suggestions treat them as rest days."
        case .japanese: return "日付をタップして勤務と休みを切り替えます。休みの日は有給から引かれず、おすすめでも休日として扱います。"
        case .chinese: return "点按日期在上班和休息之间切换。休息日不扣年假，推荐也会把它当作休息日。"
        case .german: return "Tippe auf einen Tag, um zwischen Arbeit und frei zu wechseln. Freie Tage zählen nicht als Urlaub und gelten bei Vorschlägen als Ruhetage."
        case .french: return "Touchez un jour pour basculer entre travail et repos. Les jours de repos ne sont pas décomptés et les suggestions les traitent comme repos."
        case .spanish: return "Toca un día para cambiar entre trabajo y libre. Los días libres no se descuentan y las sugerencias los cuentan como descanso."
        case .italian: return "Tocca un giorno per passare tra lavoro e riposo. I giorni liberi non scalano ferie e i suggerimenti li considerano di riposo."
        case .portuguese: return "Toque num dia para alternar entre trabalho e folga. As folgas não descontam férias e as sugestões as tratam como descanso."
        case .chineseTraditional: return "點一下日期在上班和休息之間切換。休息日不扣特休，推薦也會把它當作休息日。"
        case .dutch: return "Tik op een dag om te wisselen tussen werk en vrij. Vrije dagen gaan niet van je verlof af en tellen in suggesties als rustdag."
        case .swedish: return "Tryck på en dag för att växla mellan arbete och ledig. Lediga dagar dras inte från semestern och räknas som vilodagar i förslag."
        case .norwegian: return "Trykk på en dag for å bytte mellom jobb og fri. Fridager trekkes ikke fra ferien og regnes som hviledager i forslag."
        case .danish: return "Tryk på en dag for at skifte mellem arbejde og fri. Fridage trækkes ikke fra ferien og tæller som hviledage i forslag."
        case .finnish: return "Napauta päivää vaihtaaksesi työn ja vapaan välillä. Vapaapäiviä ei vähennetä lomasta, ja ehdotukset pitävät niitä lepopäivinä."
        case .polish: return "Stuknij dzień, aby przełączyć pracę i wolne. Dni wolne nie zmniejszają urlopu, a propozycje traktują je jako odpoczynek."
        case .czech: return "Klepnutím na den přepnete mezi prací a volnem. Volné dny se neodečítají z dovolené a návrhy je berou jako odpočinek."
        case .greek: return "Πατήστε μια ημέρα για εναλλαγή εργασίας και ρεπό. Τα ρεπό δεν αφαιρούνται από την άδεια και οι προτάσεις τα θεωρούν ξεκούραση."
        case .turkish: return "Çalışma ve izin arasında geçmek için bir güne dokunun. İzin günleri izninizden düşülmez ve önerilerde dinlenme günü sayılır."
        case .russian: return "Нажмите на день, чтобы переключить работу и выходной. Выходные не вычитаются из отпуска и в подсказках считаются днями отдыха."
        case .indonesian: return "Ketuk hari untuk beralih antara kerja dan libur. Hari libur tidak memotong cuti dan dianggap hari istirahat dalam saran."
        case .thai: return "แตะวันที่เพื่อสลับระหว่างวันทำงานกับวันหยุด วันหยุดจะไม่หักวันลา และคำแนะนำจะนับเป็นวันพัก"
        case .vietnamese: return "Chạm vào ngày để đổi giữa đi làm và nghỉ. Ngày nghỉ không bị trừ phép và được tính là ngày nghỉ trong gợi ý."
        }
    }

    /// 근무
    static var shiftWork: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "근무"
        case .english: return "Work"
        case .japanese: return "勤務"
        case .chinese: return "上班"
        case .german: return "Arbeit"
        case .french: return "Travail"
        case .spanish: return "Trabajo"
        case .italian: return "Lavoro"
        case .portuguese: return "Trabalho"
        case .chineseTraditional: return "上班"
        case .dutch: return "Werk"
        case .swedish: return "Arbete"
        case .norwegian: return "Jobb"
        case .danish: return "Arbejde"
        case .finnish: return "Työ"
        case .polish: return "Praca"
        case .czech: return "Práce"
        case .greek: return "Εργασία"
        case .turkish: return "Çalışma"
        case .russian: return "Работа"
        case .indonesian: return "Kerja"
        case .thai: return "ทำงาน"
        case .vietnamese: return "Làm"
        }
    }

    /// 휴무
    static var shiftOff: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "휴무"
        case .english: return "Off"
        case .japanese: return "休み"
        case .chinese: return "休息"
        case .german: return "Frei"
        case .french: return "Repos"
        case .spanish: return "Libre"
        case .italian: return "Riposo"
        case .portuguese: return "Folga"
        case .chineseTraditional: return "休息"
        case .dutch: return "Vrij"
        case .swedish: return "Ledig"
        case .norwegian: return "Fri"
        case .danish: return "Fri"
        case .finnish: return "Vapaa"
        case .polish: return "Wolne"
        case .czech: return "Volno"
        case .greek: return "Ρεπό"
        case .turkish: return "İzin"
        case .russian: return "Выходной"
        case .indonesian: return "Libur"
        case .thai: return "หยุด"
        case .vietnamese: return "Nghỉ"
        }
    }

    /// 이 날 휴무로
    static var shiftMarkOff: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "이 날 쉬어요"
        case .english: return "Mark as day off"
        case .japanese: return "この日は休み"
        case .chinese: return "这天休息"
        case .german: return "Als frei markieren"
        case .french: return "Marquer comme repos"
        case .spanish: return "Marcar como libre"
        case .italian: return "Segna come riposo"
        case .portuguese: return "Marcar como folga"
        case .chineseTraditional: return "這天休息"
        case .dutch: return "Markeren als vrij"
        case .swedish: return "Markera som ledig"
        case .norwegian: return "Merk som fridag"
        case .danish: return "Markér som fridag"
        case .finnish: return "Merkitse vapaaksi"
        case .polish: return "Oznacz jako wolne"
        case .czech: return "Označit jako volno"
        case .greek: return "Σήμανση ως ρεπό"
        case .turkish: return "İzin günü yap"
        case .russian: return "Отметить выходным"
        case .indonesian: return "Tandai libur"
        case .thai: return "หยุดวันนี้"
        case .vietnamese: return "Nghỉ ngày này"
        }
    }

    /// 이 날 근무로
    static var shiftMarkWork: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "이 날 일해요"
        case .english: return "Mark as workday"
        case .japanese: return "この日は勤務"
        case .chinese: return "这天上班"
        case .german: return "Als Arbeitstag markieren"
        case .french: return "Marquer comme travaillé"
        case .spanish: return "Marcar como laborable"
        case .italian: return "Segna come lavorativo"
        case .portuguese: return "Marcar como dia de trabalho"
        case .chineseTraditional: return "這天上班"
        case .dutch: return "Markeren als werkdag"
        case .swedish: return "Markera som arbetsdag"
        case .norwegian: return "Merk som arbeidsdag"
        case .danish: return "Markér som arbejdsdag"
        case .finnish: return "Merkitse työpäiväksi"
        case .polish: return "Oznacz jako pracujący"
        case .czech: return "Označit jako pracovní"
        case .greek: return "Σήμανση ως εργάσιμη"
        case .turkish: return "Çalışma günü yap"
        case .russian: return "Отметить рабочим"
        case .indonesian: return "Tandai hari kerja"
        case .thai: return "ทำงานวันนี้"
        case .vietnamese: return "Làm ngày này"
        }
    }

    /// 교대 휴무 표시
    static var shiftMarkedOff: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "교대 휴무"
        case .english: return "Shift day off"
        case .japanese: return "シフト休み"
        case .chinese: return "轮班休息"
        case .german: return "Schichtfrei"
        case .french: return "Repos (postes)"
        case .spanish: return "Libre por turno"
        case .italian: return "Riposo da turno"
        case .portuguese: return "Folga de turno"
        case .chineseTraditional: return "輪班休息"
        case .dutch: return "Vrij volgens rooster"
        case .swedish: return "Ledig enligt schema"
        case .norwegian: return "Fri etter vaktplan"
        case .danish: return "Fri ifølge vagtplan"
        case .finnish: return "Vuorovapaa"
        case .polish: return "Wolne wg grafiku"
        case .czech: return "Volno podle směn"
        case .greek: return "Ρεπό βάρδιας"
        case .turkish: return "Vardiya izni"
        case .russian: return "Выходной по графику"
        case .indonesian: return "Libur shift"
        case .thai: return "วันหยุดกะ"
        case .vietnamese: return "Nghỉ theo ca"
        }
    }

    /// 교대 근무 표시
    static var shiftMarkedWork: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "교대 근무일"
        case .english: return "Shift workday"
        case .japanese: return "シフト勤務日"
        case .chinese: return "轮班上班"
        case .german: return "Schichtarbeitstag"
        case .french: return "Jour travaillé (postes)"
        case .spanish: return "Día de turno"
        case .italian: return "Giorno di turno"
        case .portuguese: return "Dia de turno"
        case .chineseTraditional: return "輪班上班"
        case .dutch: return "Werkdag volgens rooster"
        case .swedish: return "Arbetsdag enligt schema"
        case .norwegian: return "Arbeidsdag etter vaktplan"
        case .danish: return "Arbejdsdag ifølge vagtplan"
        case .finnish: return "Vuorotyöpäivä"
        case .polish: return "Dzień pracy wg grafiku"
        case .czech: return "Pracovní den podle směn"
        case .greek: return "Εργάσιμη βάρδιας"
        case .turkish: return "Vardiya iş günü"
        case .russian: return "Рабочий день по графику"
        case .indonesian: return "Hari kerja shift"
        case .thai: return "วันทำงานกะ"
        case .vietnamese: return "Ngày làm theo ca"
        }
    }

    /// 교대 표시 되돌리기
    static var shiftUndo: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "원래대로"
        case .english: return "Reset"
        case .japanese: return "元に戻す"
        case .chinese: return "恢复"
        case .german: return "Zurücksetzen"
        case .french: return "Rétablir"
        case .spanish: return "Restablecer"
        case .italian: return "Ripristina"
        case .portuguese: return "Restaurar"
        case .chineseTraditional: return "恢復"
        case .dutch: return "Herstellen"
        case .swedish: return "Återställ"
        case .norwegian: return "Tilbakestill"
        case .danish: return "Nulstil"
        case .finnish: return "Palauta"
        case .polish: return "Przywróć"
        case .czech: return "Obnovit"
        case .greek: return "Επαναφορά"
        case .turkish: return "Sıfırla"
        case .russian: return "Сбросить"
        case .indonesian: return "Kembalikan"
        case .thai: return "คืนค่าเดิม"
        case .vietnamese: return "Khôi phục"
        }
    }

    /// 지난주
    static var shiftPrevWeek: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "지난주"
        case .english: return "Previous week"
        case .japanese: return "前の週"
        case .chinese: return "上一周"
        case .german: return "Vorige Woche"
        case .french: return "Semaine précédente"
        case .spanish: return "Semana anterior"
        case .italian: return "Settimana precedente"
        case .portuguese: return "Semana anterior"
        case .chineseTraditional: return "上一週"
        case .dutch: return "Vorige week"
        case .swedish: return "Föregående vecka"
        case .norwegian: return "Forrige uke"
        case .danish: return "Forrige uge"
        case .finnish: return "Edellinen viikko"
        case .polish: return "Poprzedni tydzień"
        case .czech: return "Předchozí týden"
        case .greek: return "Προηγούμενη εβδομάδα"
        case .turkish: return "Önceki hafta"
        case .russian: return "Предыдущая неделя"
        case .indonesian: return "Minggu sebelumnya"
        case .thai: return "สัปดาห์ก่อน"
        case .vietnamese: return "Tuần trước"
        }
    }

    /// 다음 주
    static var shiftNextWeek: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "다음 주"
        case .english: return "Next week"
        case .japanese: return "次の週"
        case .chinese: return "下一周"
        case .german: return "Nächste Woche"
        case .french: return "Semaine suivante"
        case .spanish: return "Semana siguiente"
        case .italian: return "Settimana successiva"
        case .portuguese: return "Próxima semana"
        case .chineseTraditional: return "下一週"
        case .dutch: return "Volgende week"
        case .swedish: return "Nästa vecka"
        case .norwegian: return "Neste uke"
        case .danish: return "Næste uge"
        case .finnish: return "Seuraava viikko"
        case .polish: return "Następny tydzień"
        case .czech: return "Další týden"
        case .greek: return "Επόμενη εβδομάδα"
        case .turkish: return "Sonraki hafta"
        case .russian: return "Следующая неделя"
        case .indonesian: return "Minggu berikutnya"
        case .thai: return "สัปดาห์หน้า"
        case .vietnamese: return "Tuần sau"
        }
    }

    /// 이번 주
    static var shiftThisWeek: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "이번 주"
        case .english: return "This week"
        case .japanese: return "今週"
        case .chinese: return "本周"
        case .german: return "Diese Woche"
        case .french: return "Cette semaine"
        case .spanish: return "Esta semana"
        case .italian: return "Questa settimana"
        case .portuguese: return "Esta semana"
        case .chineseTraditional: return "本週"
        case .dutch: return "Deze week"
        case .swedish: return "Denna vecka"
        case .norwegian: return "Denne uken"
        case .danish: return "Denne uge"
        case .finnish: return "Tämä viikko"
        case .polish: return "Ten tydzień"
        case .czech: return "Tento týden"
        case .greek: return "Αυτή την εβδομάδα"
        case .turkish: return "Bu hafta"
        case .russian: return "Эта неделя"
        case .indonesian: return "Minggu ini"
        case .thai: return "สัปดาห์นี้"
        case .vietnamese: return "Tuần này"
        }
    }

    static func workPatternName(_ p: WorkPattern) -> String {
        switch p {
        case .fixed: return workPatternFixed
        case .partTime: return workPatternPartTime
        case .shift: return workPatternShift
        }
    }

    static func workPatternDesc(_ p: WorkPattern) -> String {
        switch p {
        case .fixed: return workPatternFixedDesc
        case .partTime: return workPatternPartTimeDesc
        case .shift: return workPatternShiftDesc
        }
    }
}

// MARK: - 캘린더 앱으로 휴가 보내기 (캘린더 동기화 피드백, 2026-10-12)

extension Strings {
    /// 캘린더 앱으로 휴가 보내기
    static var calendarExportToggle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "캘린더 앱에 휴가 보내기"
        case .english: return "Send leave to Calendar"
        case .japanese: return "カレンダーに休暇を送る"
        case .chinese: return "将假期同步到日历"
        case .german: return "Urlaub an Kalender senden"
        case .french: return "Envoyer les congés vers Calendrier"
        case .spanish: return "Enviar ausencias a Calendario"
        case .italian: return "Invia i permessi a Calendario"
        case .portuguese: return "Enviar folgas ao Calendário"
        case .chineseTraditional: return "將假期同步到行事曆"
        case .dutch: return "Verlof naar Agenda sturen"
        case .swedish: return "Skicka ledighet till Kalender"
        case .norwegian: return "Send fri til Kalender"
        case .danish: return "Send fri til Kalender"
        case .finnish: return "Lähetä vapaat Kalenteriin"
        case .polish: return "Wysyłaj urlopy do Kalendarza"
        case .czech: return "Posílat volno do Kalendáře"
        case .greek: return "Αποστολή αδειών στο Ημερολόγιο"
        case .turkish: return "İzinleri Takvim'e gönder"
        case .russian: return "Отправлять отпуска в Календарь"
        case .indonesian: return "Kirim cuti ke Kalender"
        case .thai: return "ส่งวันลาไปที่แอปปฏิทิน"
        case .vietnamese: return "Gửi ngày nghỉ sang Lịch"
        }
    }

    /// 캘린더 앱으로 보내기 설명
    static var calendarExportDesc: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\"Goldweek 연차\" 캘린더에 휴가가 저절로 들어가고, 고치거나 지우면 함께 바뀌어요. iCloud 캘린더면 Mac·iPad 같은 다른 기기와 캘린더 앱에서도 보여요. 끄면 이 캘린더를 지워요."
        case .english: return "Your leave goes into a \"Goldweek\" calendar automatically and updates when you edit or delete it. It lives in iCloud, so it shows on Mac, iPad and other calendar apps. Turning this off removes that calendar."
        case .japanese: return "「Goldweek」カレンダーに休暇が自動で入り、編集・削除すると一緒に変わります。iCloudなのでMac・iPadなどでも見えます。オフにするとこのカレンダーを削除します。"
        case .chinese: return "假期会自动加入“Goldweek”日历，修改或删除时同步更新。保存在iCloud，可在Mac、iPad等设备上查看。关闭后会删除该日历。"
        case .german: return "Dein Urlaub landet automatisch in einem Kalender „Goldweek“ und wird beim Bearbeiten oder Löschen angepasst. Er liegt in iCloud und ist auf Mac, iPad und anderen Kalender-Apps sichtbar. Beim Ausschalten wird der Kalender entfernt."
        case .french: return "Vos congés vont automatiquement dans un calendrier « Goldweek » et suivent vos modifications. Il est dans iCloud, donc visible sur Mac, iPad et d'autres apps. Désactiver supprime ce calendrier."
        case .spanish: return "Tus ausencias se añaden solas a un calendario «Goldweek» y se actualizan al editarlas o borrarlas. Está en iCloud, así que se ve en Mac, iPad y otras apps. Al desactivarlo se borra ese calendario."
        case .italian: return "I permessi finiscono da soli in un calendario «Goldweek» e si aggiornano quando li modifichi o elimini. È su iCloud, quindi lo vedi anche su Mac, iPad e altre app. Disattivando, il calendario viene rimosso."
        case .portuguese: return "Suas folgas vão automaticamente para um calendário \"Goldweek\" e mudam quando você edita ou apaga. Fica no iCloud, então aparece no Mac, iPad e outros apps. Desativar remove esse calendário."
        case .chineseTraditional: return "假期會自動加入「Goldweek」行事曆，修改或刪除時同步更新。儲存在iCloud，可在Mac、iPad等裝置上查看。關閉後會刪除該行事曆。"
        case .dutch: return "Je verlof komt vanzelf in een agenda \"Goldweek\" en past zich aan als je wijzigt of verwijdert. Hij staat in iCloud, dus zichtbaar op Mac, iPad en andere apps. Uitzetten verwijdert die agenda."
        case .swedish: return "Din ledighet hamnar automatiskt i kalendern \"Goldweek\" och uppdateras när du ändrar eller tar bort. Den ligger i iCloud och syns på Mac, iPad och andra appar. Stänger du av tas kalendern bort."
        case .norwegian: return "Fri legges automatisk i kalenderen \"Goldweek\" og oppdateres når du endrer eller sletter. Den ligger i iCloud og vises på Mac, iPad og andre apper. Slår du av, fjernes kalenderen."
        case .danish: return "Din fri lægges automatisk i kalenderen \"Goldweek\" og opdateres, når du ændrer eller sletter. Den ligger i iCloud og vises på Mac, iPad og andre apps. Slår du fra, fjernes kalenderen."
        case .finnish: return "Vapaat menevät automaattisesti \"Goldweek\"-kalenteriin ja päivittyvät, kun muokkaat tai poistat. Kalenteri on iCloudissa, joten se näkyy Macilla, iPadilla ja muissa sovelluksissa. Poistaminen käytöstä poistaa kalenterin."
        case .polish: return "Urlopy trafiają same do kalendarza „Goldweek” i zmieniają się przy edycji lub usunięciu. Jest w iCloud, więc widać go na Macu, iPadzie i w innych aplikacjach. Wyłączenie usuwa ten kalendarz."
        case .czech: return "Volno se samo zapisuje do kalendáře „Goldweek“ a mění se při úpravě či smazání. Je v iCloudu, takže je vidět na Macu, iPadu i v jiných aplikacích. Vypnutím se kalendář odstraní."
        case .greek: return "Οι άδειες μπαίνουν αυτόματα στο ημερολόγιο «Goldweek» και ενημερώνονται όταν τις αλλάζετε ή διαγράφετε. Είναι στο iCloud, άρα φαίνεται σε Mac, iPad και άλλες εφαρμογές. Αν το απενεργοποιήσετε, το ημερολόγιο διαγράφεται."
        case .turkish: return "İzinleriniz otomatik olarak \"Goldweek\" takvimine girer, düzenleyince veya silince güncellenir. iCloud'da olduğu için Mac, iPad ve diğer uygulamalarda görünür. Kapatırsanız bu takvim silinir."
        case .russian: return "Отпуска сами попадают в календарь «Goldweek» и меняются при правке или удалении. Он в iCloud, поэтому виден на Mac, iPad и в других приложениях. При выключении календарь удаляется."
        case .indonesian: return "Cuti otomatis masuk ke kalender \"Goldweek\" dan ikut berubah saat diubah atau dihapus. Ada di iCloud, jadi terlihat di Mac, iPad, dan aplikasi lain. Mematikannya akan menghapus kalender itu."
        case .thai: return "วันลาจะเข้าไปในปฏิทิน \"Goldweek วันลา\" โดยอัตโนมัติ และเปลี่ยนตามเมื่อคุณแก้ไขหรือลบ ถ้าเป็นปฏิทิน iCloud จะเห็นใน Mac, iPad และแอปปฏิทินอื่นด้วย ปิดแล้วปฏิทินนี้จะถูกลบ"
        case .vietnamese: return "Ngày nghỉ tự động vào lịch \"Goldweek Nghỉ phép\" và cập nhật khi bạn sửa hoặc xóa. Nếu là lịch iCloud, bạn sẽ thấy cả trên Mac, iPad và các ứng dụng lịch khác. Tắt đi sẽ xóa lịch này."
        }
    }

    /// 캘린더 접근 거부
    static var calendarAccessDenied: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "캘린더 접근이 꺼져 있어요. 설정 앱 > Goldweek > 캘린더에서 전체 접근을 허용해 주세요."
        case .english: return "Calendar access is off. Allow Full Access in Settings > Goldweek > Calendars."
        case .japanese: return "カレンダーへのアクセスがオフです。設定 > Goldweek > カレンダーでフルアクセスを許可してください。"
        case .chinese: return "日历访问已关闭。请在设置 > Goldweek > 日历中允许完全访问。"
        case .german: return "Kalenderzugriff ist aus. Erlaube vollen Zugriff unter Einstellungen > Goldweek > Kalender."
        case .french: return "L'accès au calendrier est désactivé. Autorisez l'accès complet dans Réglages > Goldweek > Calendriers."
        case .spanish: return "El acceso al calendario está desactivado. Permite el acceso total en Ajustes > Goldweek > Calendarios."
        case .italian: return "L'accesso al calendario è disattivato. Consenti l'accesso completo in Impostazioni > Goldweek > Calendari."
        case .portuguese: return "O acesso ao calendário está desativado. Permita acesso total em Ajustes > Goldweek > Calendários."
        case .chineseTraditional: return "行事曆存取已關閉。請在設定 > Goldweek > 行事曆中允許完整取用。"
        case .dutch: return "Agendatoegang staat uit. Sta volledige toegang toe in Instellingen > Goldweek > Agenda's."
        case .swedish: return "Kalenderåtkomst är av. Tillåt full åtkomst i Inställningar > Goldweek > Kalendrar."
        case .norwegian: return "Kalendertilgang er av. Tillat full tilgang i Innstillinger > Goldweek > Kalendere."
        case .danish: return "Kalenderadgang er slået fra. Tillad fuld adgang i Indstillinger > Goldweek > Kalendere."
        case .finnish: return "Kalenterin käyttö on pois päältä. Salli täysi käyttö kohdassa Asetukset > Goldweek > Kalenterit."
        case .polish: return "Dostęp do kalendarza jest wyłączony. Zezwól na pełny dostęp w Ustawienia > Goldweek > Kalendarze."
        case .czech: return "Přístup ke kalendáři je vypnutý. Povolte plný přístup v Nastavení > Goldweek > Kalendáře."
        case .greek: return "Η πρόσβαση στο ημερολόγιο είναι ανενεργή. Επιτρέψτε πλήρη πρόσβαση στις Ρυθμίσεις > Goldweek > Ημερολόγια."
        case .turkish: return "Takvim erişimi kapalı. Ayarlar > Goldweek > Takvimler'den tam erişime izin verin."
        case .russian: return "Доступ к календарю выключен. Разрешите полный доступ в Настройки > Goldweek > Календари."
        case .indonesian: return "Akses kalender mati. Izinkan akses penuh di Pengaturan > Goldweek > Kalender."
        case .thai: return "การเข้าถึงปฏิทินปิดอยู่ กรุณาอนุญาตการเข้าถึงทั้งหมดใน การตั้งค่า > Goldweek > ปฏิทิน"
        case .vietnamese: return "Quyền truy cập Lịch đang tắt. Hãy cho phép Toàn quyền truy cập trong Cài đặt > Goldweek > Lịch."
        }
    }
}
