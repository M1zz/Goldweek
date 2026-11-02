//
//  Strings+PlanAhead.swift
//  Goldweek
//
//  미리 계획(내년 연차) · 남은 연차 이월 문구 (네덜란드 사용자 피드백)
//

import Foundation

extension Strings {
    private static var planLang: AppLanguage { LanguageManager.shared.currentLanguage }

    /// 설정 — 남은 연차 이월
    static var carryOverSetting: String {
        switch planLang {
        case .korean: return "남은 연차 이월"
        case .english: return "Carry Over Unused Leave"
        case .japanese: return "残った休暇の繰り越し"
        case .chinese: return "剩余年假结转"
        case .german: return "Resturlaub übertragen"
        case .french: return "Report des congés restants"
        case .spanish: return "Arrastrar días sobrantes"
        case .italian: return "Riporto ferie residue"
        case .portuguese: return "Transferir folgas restantes"
        case .chineseTraditional: return "剩餘特休遞延"
        case .dutch: return "Resterend verlof meenemen"
        case .swedish: return "Spara outtagna dagar"
        case .norwegian: return "Overfør ubrukte dager"
        case .danish: return "Overfør ubrugte dage"
        case .finnish: return "Siirrä käyttämättömät päivät"
        case .polish: return "Przenoszenie zaległego urlopu"
        case .czech: return "Převod nevyčerpané dovolené"
        case .greek: return "Μεταφορά υπολοίπου άδειας"
        case .turkish: return "Kalan izni devret"
        case .russian: return "Перенос остатка отпуска"
        case .indonesian: return "Bawa sisa cuti"
        case .thai: return "ยกวันลาที่เหลือไปปีหน้า"
        case .vietnamese: return "Chuyển phép còn lại sang năm sau"
        }
    }

    /// 이월 안 함
    static var carryOverOff: String {
        switch planLang {
        case .korean: return "안 함"
        case .english: return "Off"
        case .japanese: return "しない"
        case .chinese: return "不结转"
        case .german: return "Aus"
        case .french: return "Non"
        case .spanish: return "No"
        case .italian: return "No"
        case .portuguese: return "Não"
        case .chineseTraditional: return "不遞延"
        case .dutch: return "Uit"
        case .swedish: return "Av"
        case .norwegian: return "Av"
        case .danish: return "Fra"
        case .finnish: return "Pois"
        case .polish: return "Wyłączone"
        case .czech: return "Vypnuto"
        case .greek: return "Όχι"
        case .turkish: return "Kapalı"
        case .russian: return "Нет"
        case .indonesian: return "Tidak"
        case .thai: return "ปิด"
        case .vietnamese: return "Tắt"
        }
    }

    /// 남은 만큼 전부
    static var carryOverAll: String {
        switch planLang {
        case .korean: return "남은 만큼 전부"
        case .english: return "All remaining days"
        case .japanese: return "残り全部"
        case .chinese: return "全部剩余天数"
        case .german: return "Alle Resttage"
        case .french: return "Tous les jours restants"
        case .spanish: return "Todos los días sobrantes"
        case .italian: return "Tutti i giorni residui"
        case .portuguese: return "Todos os dias restantes"
        case .chineseTraditional: return "全部剩餘天數"
        case .dutch: return "Alle resterende dagen"
        case .swedish: return "Alla kvarvarande dagar"
        case .norwegian: return "Alle gjenværende dager"
        case .danish: return "Alle resterende dage"
        case .finnish: return "Kaikki jäljellä olevat"
        case .polish: return "Wszystkie pozostałe dni"
        case .czech: return "Všechny zbývající dny"
        case .greek: return "Όλες οι υπόλοιπες μέρες"
        case .turkish: return "Kalan tüm günler"
        case .russian: return "Все оставшиеся дни"
        case .indonesian: return "Semua sisa hari"
        case .thai: return "ทุกวันที่เหลือ"
        case .vietnamese: return "Toàn bộ số ngày còn lại"
        }
    }

    /// 설정 — 넘어온 연차 사용 기한
    static var carryOverExpirySetting: String {
        switch planLang {
        case .korean: return "넘어온 연차 사용 기한"
        case .english: return "Use Carried-Over Days By"
        case .japanese: return "繰り越し分の使用期限"
        case .chinese: return "结转天数的使用期限"
        case .german: return "Übertragene Tage nutzbar bis"
        case .french: return "Jours reportés à utiliser avant"
        case .spanish: return "Usar días arrastrados antes de"
        case .italian: return "Usa le ferie riportate entro"
        case .portuguese: return "Usar dias transferidos até"
        case .chineseTraditional: return "遞延天數的使用期限"
        case .dutch: return "Meegenomen dagen opnemen vóór"
        case .swedish: return "Sparade dagar ska tas ut inom"
        case .norwegian: return "Overførte dager må brukes innen"
        case .danish: return "Overførte dage skal bruges inden"
        case .finnish: return "Siirretyt päivät käytettävä"
        case .polish: return "Przeniesiony urlop wykorzystaj w ciągu"
        case .czech: return "Převedené dny vyčerpej do"
        case .greek: return "Οι μεταφερμένες μέρες ισχύουν για"
        case .turkish: return "Devreden günleri kullanma süresi"
        case .russian: return "Перенесённые дни использовать в течение"
        case .indonesian: return "Sisa cuti dipakai paling lambat"
        case .thai: return "ใช้วันลาที่ยกมาได้ถึง"
        case .vietnamese: return "Hạn dùng phép chuyển sang"
        }
    }

    /// 기한 없음
    static var carryOverNoExpiry: String {
        switch planLang {
        case .korean: return "기한 없음"
        case .english: return "No limit"
        case .japanese: return "期限なし"
        case .chinese: return "无期限"
        case .german: return "Unbegrenzt"
        case .french: return "Sans limite"
        case .spanish: return "Sin límite"
        case .italian: return "Nessun limite"
        case .portuguese: return "Sem limite"
        case .chineseTraditional: return "無期限"
        case .dutch: return "Geen limiet"
        case .swedish: return "Ingen gräns"
        case .norwegian: return "Ingen grense"
        case .danish: return "Ingen grænse"
        case .finnish: return "Ei rajaa"
        case .polish: return "Bez limitu"
        case .czech: return "Bez omezení"
        case .greek: return "Χωρίς όριο"
        case .turkish: return "Süresiz"
        case .russian: return "Без ограничения"
        case .indonesian: return "Tanpa batas"
        case .thai: return "ไม่จำกัด"
        case .vietnamese: return "Không giới hạn"
        }
    }

    /// 설정 — 이월 설명
    static var carryOverFooter: String {
        switch planLang {
        case .korean: return "회사가 허락하면 올해 못 쓴 연차를 다음 해로 넘길 수 있어요. 넘어온 연차는 새 해 연차에 더해지고, 기한이 있으면 그 전에 쓴 만큼만 남아요. 내년 휴가는 지금도 미리 잡을 수 있고, 내년 연차에서 빠져요."
        case .english: return "If your employer allows it, days you don't use this year move to the next. They're added to next year's leave, and if they expire, only what you've used by then counts. You can already plan next year's time off now; it comes out of next year's leave."
        case .japanese: return "会社が認めていれば、今年使わなかった休暇を翌年に繰り越せます。繰り越し分は翌年の休暇に加わり、期限があればそれまでに使った分だけ残ります。来年の休暇は今から計画でき、来年の休暇から引かれます。"
        case .chinese: return "如果公司允许，今年没用完的年假可以结转到下一年。结转的天数会加到新一年的年假里；如果有期限，只保留期限前用掉的部分。明年的假期现在就能提前安排，会从明年的年假中扣除。"
        case .german: return "Wenn dein Arbeitgeber es erlaubt, wandern ungenutzte Tage ins nächste Jahr. Sie kommen zum Urlaub des neuen Jahres dazu; verfallen sie, zählt nur, was du bis dahin genommen hast. Urlaub fürs nächste Jahr kannst du schon jetzt planen – er geht vom nächsten Jahr ab."
        case .french: return "Si votre employeur l’autorise, les jours non pris cette année passent à l’année suivante. Ils s’ajoutent aux congés de la nouvelle année et, s’ils expirent, seul ce que vous avez pris avant compte. Vous pouvez déjà planifier l’an prochain : ces congés sont déduits de l’année suivante."
        case .spanish: return "Si tu empresa lo permite, los días que no uses este año pasan al siguiente. Se suman a las vacaciones del nuevo año y, si caducan, solo cuenta lo que hayas usado antes. Ya puedes planificar el año que viene: se descuenta de las vacaciones del próximo año."
        case .italian: return "Se l’azienda lo consente, i giorni non usati quest’anno passano all’anno successivo. Si sommano alle ferie del nuovo anno e, se scadono, conta solo quanto hai usato entro la scadenza. Puoi già pianificare l’anno prossimo: verrà scalato dalle ferie del prossimo anno."
        case .portuguese: return "Se a sua empresa permitir, os dias que você não usar este ano passam para o próximo. Eles somam às folgas do novo ano e, se vencerem, só conta o que você usou antes. Você já pode planejar o ano que vem: sai das folgas do próximo ano."
        case .chineseTraditional: return "如果公司允許，今年沒用完的特休可以遞延到下一年。遞延天數會加到新一年的特休；如果有期限，只保留期限前用掉的部分。明年的假現在就能先排，會從明年的特休扣除。"
        case .dutch: return "Als je werkgever het toestaat, gaan dagen die je dit jaar niet opneemt mee naar volgend jaar. Ze komen bij het verlof van het nieuwe jaar; vervallen ze, dan telt alleen wat je vóór die datum opnam. Je kunt volgend jaar nu al plannen – het gaat van het verlof van volgend jaar af."
        case .swedish: return "Om arbetsgivaren tillåter det flyttas dagar du inte tar ut i år till nästa år. De läggs till nästa års semester, och om de förfaller räknas bara det du tagit ut innan dess. Du kan redan nu planera nästa år – det dras från nästa års semester."
        case .norwegian: return "Hvis arbeidsgiveren tillater det, overføres dager du ikke bruker i år til neste år. De legges til neste års ferie, og hvis de utløper, teller bare det du har brukt før det. Du kan allerede nå planlegge neste år – det trekkes fra neste års ferie."
        case .danish: return "Hvis din arbejdsgiver tillader det, overføres dage, du ikke bruger i år, til næste år. De lægges til næste års ferie, og hvis de udløber, tæller kun det, du har brugt inden da. Du kan allerede nu planlægge næste år – det trækkes fra næste års ferie."
        case .finnish: return "Jos työnantaja sallii, tänä vuonna käyttämättömät päivät siirtyvät seuraavalle vuodelle. Ne lisätään uuden vuoden lomaan, ja jos ne vanhenevat, vain siihen mennessä käytetyt lasketaan. Voit jo nyt suunnitella ensi vuotta – se vähennetään ensi vuoden lomasta."
        case .polish: return "Jeśli pracodawca na to pozwala, niewykorzystane dni przechodzą na kolejny rok. Dodają się do urlopu nowego roku, a jeśli wygasają, liczy się tylko to, co wykorzystasz przed terminem. Już teraz możesz planować przyszły rok – urlop zostanie odjęty z przyszłorocznej puli."
        case .czech: return "Pokud to zaměstnavatel dovolí, nevyčerpané dny přejdou do dalšího roku. Přičtou se k dovolené nového roku, a pokud propadnou, počítá se jen to, co do té doby vyčerpáš. Už teď můžeš plánovat příští rok – odečte se z dovolené na příští rok."
        case .greek: return "Αν το επιτρέπει ο εργοδότης σου, οι μέρες που δεν παίρνεις φέτος περνούν στην επόμενη χρονιά. Προστίθενται στην άδεια της νέας χρονιάς και, αν λήγουν, μετράει μόνο ό,τι πήρες ως τότε. Μπορείς ήδη να προγραμματίσεις την επόμενη χρονιά – αφαιρείται από την άδεια της επόμενης χρονιάς."
        case .turkish: return "İşverenin izin veriyorsa bu yıl kullanmadığın günler gelecek yıla devreder. Yeni yılın iznine eklenir; süresi dolarsa yalnızca o zamana kadar kullandığın kısım sayılır. Gelecek yılı şimdiden planlayabilirsin – gelecek yılın izninden düşülür."
        case .russian: return "Если работодатель разрешает, неиспользованные дни переходят на следующий год. Они добавляются к отпуску нового года, а если у них есть срок, учитывается только то, что вы успели использовать. Следующий год можно планировать уже сейчас — дни спишутся из отпуска следующего года."
        case .indonesian: return "Jika perusahaanmu mengizinkan, sisa cuti tahun ini dibawa ke tahun berikutnya. Sisa itu ditambahkan ke cuti tahun baru, dan jika ada batas waktu, hanya yang terpakai sebelum batas itu yang dihitung. Cuti tahun depan sudah bisa direncanakan sekarang dan diambil dari jatah tahun depan."
        case .thai: return "ถ้าบริษัทอนุญาต วันลาที่ไม่ได้ใช้ในปีนี้จะยกไปปีหน้า โดยบวกเพิ่มในวันลาของปีหน้า และถ้ามีวันหมดอายุ จะนับเฉพาะวันที่ใช้ก่อนถึงกำหนด วางแผนวันลาของปีหน้าได้ตั้งแต่ตอนนี้ โดยจะหักจากวันลาของปีหน้า"
        case .vietnamese: return "Nếu công ty cho phép, số phép chưa dùng năm nay sẽ được chuyển sang năm sau và cộng vào phép năm mới. Nếu có hạn dùng, chỉ phần đã dùng trước hạn được tính. Bạn có thể lên kế hoạch nghỉ năm sau ngay từ bây giờ, số ngày đó sẽ trừ vào phép năm sau."
        }
    }

    /// 최대 N일 — {d} 일수
    static func carryOverUpTo(_ d: String) -> String {
        switch planLang {
        case .korean: return "최대 \(d)"
        case .english: return "Up to \(d)"
        case .japanese: return "最大\(d)"
        case .chinese: return "最多\(d)"
        case .german: return "Bis zu \(d)"
        case .french: return "Jusqu’à \(d)"
        case .spanish: return "Hasta \(d)"
        case .italian: return "Fino a \(d)"
        case .portuguese: return "Até \(d)"
        case .chineseTraditional: return "最多\(d)"
        case .dutch: return "Tot \(d)"
        case .swedish: return "Upp till \(d)"
        case .norwegian: return "Opptil \(d)"
        case .danish: return "Op til \(d)"
        case .finnish: return "Enintään \(d)"
        case .polish: return "Do \(d)"
        case .czech: return "Až \(d)"
        case .greek: return "Έως \(d)"
        case .turkish: return "En fazla \(d)"
        case .russian: return "До \(d)"
        case .indonesian: return "Hingga \(d)"
        case .thai: return "สูงสุด \(d)"
        case .vietnamese: return "Tối đa \(d)"
        }
    }

    /// 새 해 시작 후 N개월 — {n} 개월 수
    static func carryOverExpiryMonths(_ n: Int) -> String {
        switch planLang {
        case .korean: return "새 해 시작 후 \(n)개월"
        case .english: return "\(n) months into the new year"
        case .japanese: return "新年度開始から\(n)か月"
        case .chinese: return "新年度开始后\(n)个月"
        case .german: return "\(n) Monate nach Jahresbeginn"
        case .french: return "\(n) mois après le début de l’année"
        case .spanish: return "\(n) meses tras el inicio del año"
        case .italian: return "\(n) mesi dall’inizio dell’anno"
        case .portuguese: return "\(n) meses após o início do ano"
        case .chineseTraditional: return "新年度開始後\(n)個月"
        case .dutch: return "\(n) maanden na het begin van het jaar"
        case .swedish: return "\(n) månader in på året"
        case .norwegian: return "\(n) måneder inn i året"
        case .danish: return "\(n) måneder inde i året"
        case .finnish: return "\(n) kk vuoden alusta"
        case .polish: return "\(n) mies. od początku roku"
        case .czech: return "\(n) měsíců od začátku roku"
        case .greek: return "\(n) μήνες από την αρχή της χρονιάς"
        case .turkish: return "Yeni yılın ilk \(n) ayı"
        case .russian: return "\(n) мес. с начала года"
        case .indonesian: return "\(n) bulan sejak awal tahun"
        case .thai: return "\(n) เดือนแรกของปีใหม่"
        case .vietnamese: return "\(n) tháng đầu năm mới"
        }
    }

    /// 내년 휴가 등록 — {y}년 연차에서 빠짐, 남은 {r}
    static func futureYearLeaveNote(year y: Int, remaining r: String) -> String {
        switch planLang {
        case .korean: return "\(String(y))년 연차에서 빠져요 · 그해 남은 연차 \(r)"
        case .english: return "Comes out of your \(String(y)) leave · \(r) left that year"
        case .japanese: return "\(String(y))年の休暇から引かれます・その年の残り\(r)"
        case .chinese: return "将从\(String(y))年的年假中扣除 · 当年剩余\(r)"
        case .german: return "Geht vom Urlaub \(String(y)) ab · dort noch \(r)"
        case .french: return "Déduit de vos congés \(String(y)) · il reste \(r) cette année-là"
        case .spanish: return "Se descuenta de las vacaciones de \(String(y)) · quedan \(r) ese año"
        case .italian: return "Viene scalato dalle ferie \(String(y)) · restano \(r) quell’anno"
        case .portuguese: return "Sai das folgas de \(String(y)) · restam \(r) naquele ano"
        case .chineseTraditional: return "將從\(String(y))年的特休扣除 · 當年剩餘\(r)"
        case .dutch: return "Gaat van je verlof voor \(String(y)) af · nog \(r) dat jaar"
        case .swedish: return "Dras från semestern \(String(y)) · \(r) kvar det året"
        case .norwegian: return "Trekkes fra ferien for \(String(y)) · \(r) igjen det året"
        case .danish: return "Trækkes fra ferien for \(String(y)) · \(r) tilbage det år"
        case .finnish: return "Vähennetään vuoden \(String(y)) lomasta · jäljellä \(r)"
        case .polish: return "Odejmowane z urlopu na \(String(y)) · zostaje \(r)"
        case .czech: return "Odečte se z dovolené na \(String(y)) · zbývá \(r)"
        case .greek: return "Αφαιρείται από την άδεια του \(String(y)) · μένουν \(r)"
        case .turkish: return "\(String(y)) izninden düşülür · o yıl kalan \(r)"
        case .russian: return "Спишется из отпуска на \(String(y)) · останется \(r)"
        case .indonesian: return "Diambil dari cuti \(String(y)) · sisa \(r) tahun itu"
        case .thai: return "หักจากวันลาปี \(String(y)) · ปีนั้นเหลือ \(r)"
        case .vietnamese: return "Trừ vào phép năm \(String(y)) · năm đó còn \(r)"
        }
    }
}

// MARK: - 현황 구성 (2026-11-02) — 고른 것만, 경고는 필요할 때만

extension Strings {
    static var homeOfferUpcoming: String { pick([.korean: "잡아 둔 휴가를 현황에 모아 볼까요?", .english: "Show your planned time off on the Overview?", .japanese: "予定した休暇を現況にまとめて表示しますか？", .chinese: "要在概况中集中显示已安排的休假吗？", .german: "Geplante Urlaube in der Übersicht anzeigen?", .french: "Afficher vos congés prévus dans l’aperçu ?", .spanish: "¿Mostrar tus vacaciones planeadas en el resumen?", .italian: "Mostrare le ferie in programma nella panoramica?", .portuguese: "Mostrar suas férias planejadas no resumo?", .chineseTraditional: "要在概況中集中顯示已安排的休假嗎？", .dutch: "Geplande vrije dagen in het overzicht tonen?", .swedish: "Visa planerad ledighet i översikten?", .norwegian: "Vise planlagt fri i oversikten?", .danish: "Vis planlagt fri i oversigten?", .finnish: "Näytetäänkö suunnitellut lomat yleiskatsauksessa?", .polish: "Pokazywać zaplanowany urlop w podsumowaniu?", .czech: "Zobrazit naplánované volno v přehledu?", .greek: "Να εμφανίζεται η προγραμματισμένη άδεια στην επισκόπηση;", .turkish: "Planlanan izinler özette gösterilsin mi?", .russian: "Показывать запланированный отпуск в обзоре?", .indonesian: "Tampilkan cuti yang direncanakan di ringkasan?", .thai: "แสดงวันลาที่วางไว้ในภาพรวมไหม", .vietnamese: "Hiện kỳ nghỉ đã lên lịch ở phần tổng quan?"]) }

    static var homeOfferHolidays: String { pick([.korean: "곧 공휴일이 있어요. 다가오는 공휴일도 함께 볼까요?", .english: "A public holiday is coming up. Show upcoming holidays too?", .japanese: "もうすぐ祝日です。これからの祝日も一緒に表示しますか？", .chinese: "公共假日快到了。要一起显示即将到来的假日吗？", .german: "Bald ist ein Feiertag. Kommende Feiertage auch anzeigen?", .french: "Un jour férié approche. Afficher aussi les prochains jours fériés ?", .spanish: "Se acerca un festivo. ¿Mostrar también los próximos festivos?", .italian: "Sta per arrivare un giorno festivo. Mostrare anche i prossimi festivi?", .portuguese: "Um feriado está chegando. Mostrar também os próximos feriados?", .chineseTraditional: "公眾假期快到了。要一起顯示即將到來的假期嗎？", .dutch: "Er komt een feestdag aan. Ook komende feestdagen tonen?", .swedish: "En helgdag närmar sig. Visa kommande helgdagar också?", .norwegian: "En helligdag nærmer seg. Vise kommende helligdager også?", .danish: "En helligdag nærmer sig. Vis også kommende helligdage?", .finnish: "Pyhäpäivä lähestyy. Näytetäänkö myös tulevat pyhäpäivät?", .polish: "Zbliża się święto. Pokazywać też nadchodzące święta?", .czech: "Blíží se svátek. Zobrazit i nadcházející svátky?", .greek: "Πλησιάζει αργία. Να εμφανίζονται και οι επόμενες αργίες;", .turkish: "Yakında resmî tatil var. Yaklaşan tatiller de gösterilsin mi?", .russian: "Скоро праздник. Показывать и ближайшие праздники?", .indonesian: "Hari libur sudah dekat. Tampilkan juga hari libur mendatang?", .thai: "ใกล้วันหยุดแล้ว แสดงวันหยุดที่กำลังจะมาถึงด้วยไหม", .vietnamese: "Sắp đến ngày lễ. Hiện cả các ngày lễ sắp tới?"]) }

    static var homeOfferYes: String { pick([.korean: "볼게요", .english: "Show", .japanese: "表示する", .chinese: "显示", .german: "Anzeigen", .french: "Afficher", .spanish: "Mostrar", .italian: "Mostra", .portuguese: "Mostrar", .chineseTraditional: "顯示", .dutch: "Tonen", .swedish: "Visa", .norwegian: "Vis", .danish: "Vis", .finnish: "Näytä", .polish: "Pokaż", .czech: "Zobrazit", .greek: "Εμφάνιση", .turkish: "Göster", .russian: "Показывать", .indonesian: "Tampilkan", .thai: "แสดง", .vietnamese: "Hiện"]) }

    static var homeOfferNo: String { pick([.korean: "괜찮아요", .english: "No thanks", .japanese: "表示しない", .chinese: "不用了", .german: "Nein, danke", .french: "Non merci", .spanish: "No, gracias", .italian: "No, grazie", .portuguese: "Não, obrigado", .chineseTraditional: "不用了", .dutch: "Nee, bedankt", .swedish: "Nej tack", .norwegian: "Nei takk", .danish: "Nej tak", .finnish: "Ei kiitos", .polish: "Nie, dziękuję", .czech: "Ne, díky", .greek: "Όχι, ευχαριστώ", .turkish: "Hayır, teşekkürler", .russian: "Не нужно", .indonesian: "Tidak usah", .thai: "ไม่เป็นไร", .vietnamese: "Không, cảm ơn"]) }

    static var homeGotIt: String { pick([.korean: "알겠어요", .english: "Got it", .japanese: "わかりました", .chinese: "知道了", .german: "Verstanden", .french: "Compris", .spanish: "Entendido", .italian: "Ho capito", .portuguese: "Entendi", .chineseTraditional: "知道了", .dutch: "Begrepen", .swedish: "Uppfattat", .norwegian: "Skjønner", .danish: "Forstået", .finnish: "Selvä", .polish: "Rozumiem", .czech: "Rozumím", .greek: "Εντάξει", .turkish: "Anladım", .russian: "Понятно", .indonesian: "Mengerti", .thai: "เข้าใจแล้ว", .vietnamese: "Đã hiểu"]) }

    static var homePaceAlways: String { pick([.korean: "휴가 페이스 늘 보기", .english: "Always show leave pace", .japanese: "休暇ペースを常に表示", .chinese: "始终显示休假节奏", .german: "Urlaubstempo immer anzeigen", .french: "Toujours afficher le rythme des congés", .spanish: "Mostrar siempre el ritmo de vacaciones", .italian: "Mostra sempre il ritmo delle ferie", .portuguese: "Sempre mostrar o ritmo das férias", .chineseTraditional: "始終顯示休假節奏", .dutch: "Verloftempo altijd tonen", .swedish: "Visa alltid ledighetstakten", .norwegian: "Vis alltid fritempoet", .danish: "Vis altid ferietempoet", .finnish: "Näytä lomatahti aina", .polish: "Zawsze pokazuj tempo urlopu", .czech: "Vždy zobrazovat tempo čerpání volna", .greek: "Να εμφανίζεται πάντα ο ρυθμός αδειών", .turkish: "İzin hızını her zaman göster", .russian: "Всегда показывать темп отпуска", .indonesian: "Selalu tampilkan laju cuti", .thai: "แสดงจังหวะการลาเสมอ", .vietnamese: "Luôn hiện nhịp nghỉ phép"]) }

    static var homePaceAlwaysDescription: String { pick([.korean: "끄면 쉬지 못했거나 연차가 남을 것 같을 때만 보여요.", .english: "When off, it appears only when you’re overdue for a break or likely to leave days unused.", .japanese: "オフにすると、休めていないときや年休が余りそうなときだけ表示します。", .chinese: "关闭后，仅在久未休息或年假可能用不完时显示。", .german: "Wenn aus, erscheint es nur, wenn eine Pause überfällig ist oder Urlaubstage verfallen könnten.", .french: "Désactivé, il n’apparaît que si une pause s’impose ou si des jours risquent d’être perdus.", .spanish: "Si está desactivado, solo aparece cuando te toca descansar o podrían sobrarte días.", .italian: "Se disattivato, appare solo quando ti serve una pausa o rischi di non usare dei giorni.", .portuguese: "Desligado, aparece só quando você precisa de pausa ou pode sobrar dias.", .chineseTraditional: "關閉後，僅在久未休息或年假可能用不完時顯示。", .dutch: "Uit: alleen zichtbaar als je toe bent aan rust of dagen dreigt over te houden.", .swedish: "Av: visas bara när du behöver vila eller kan få dagar över.", .norwegian: "Av: vises bare når du trenger en pause eller kan få dager til overs.", .danish: "Fra: vises kun, når du trænger til en pause eller kan få dage i overskud.", .finnish: "Pois päältä: näkyy vain, kun lepo on myöhässä tai lomapäiviä uhkaa jäädä käyttämättä.", .polish: "Wyłączone: pojawia się tylko, gdy należy Ci się odpoczynek lub mogą zostać niewykorzystane dni.", .czech: "Vypnuto: zobrazí se jen, když potřebuješ pauzu nebo ti můžou zbýt dny.", .greek: "Όταν είναι ανενεργό, εμφανίζεται μόνο όταν χρειάζεσαι διάλειμμα ή μπορεί να περισσέψουν μέρες.", .turkish: "Kapalıyken yalnızca mola gerektiğinde veya izin günleri artabilecekken görünür.", .russian: "Если выключено, появляется, только когда пора отдохнуть или дни могут сгореть.", .indonesian: "Jika mati, hanya muncul saat kamu perlu istirahat atau cuti bisa tersisa.", .thai: "เมื่อปิด จะแสดงเฉพาะตอนที่ควรพักหรือวันลาอาจเหลือ", .vietnamese: "Khi tắt, chỉ hiện khi bạn cần nghỉ hoặc có thể còn dư ngày phép."]) }

    static var homeMoreActions: String { pick([.korean: "더 보기", .english: "More", .japanese: "その他", .chinese: "更多", .german: "Mehr", .french: "Plus", .spanish: "Más", .italian: "Altro", .portuguese: "Mais", .chineseTraditional: "更多", .dutch: "Meer", .swedish: "Mer", .norwegian: "Mer", .danish: "Mere", .finnish: "Lisää", .polish: "Więcej", .czech: "Další", .greek: "Περισσότερα", .turkish: "Diğer", .russian: "Ещё", .indonesian: "Lainnya", .thai: "เพิ่มเติม", .vietnamese: "Thêm"]) }

    static func paceWarnSlow(year: Int, used: Int) -> String {
        pick([.korean: "올해가 \(year)% 지났는데 연차는 \(used)%만 잡혀 있어요. 남기 전에 계획해 보세요.", .english: "\(year)% of the year has passed, but only \(used)% of your leave is planned. Plan it before it goes unused.", .japanese: "今年が\(year)%過ぎましたが、年休は\(used)%しか予定がありません。余る前に計画しましょう。", .chinese: "今年已过去 \(year)%，年假只安排了 \(used)%。在用不完之前做好计划吧。", .german: "\(year) % des Jahres sind vorbei, aber erst \(used) % deines Urlaubs sind geplant. Plane ihn, bevor er verfällt.", .french: "\(year) % de l’année est passée, mais seulement \(used) % de vos congés sont prévus. Planifiez-les avant de les perdre.", .spanish: "Ha pasado el \(year) % del año y solo tienes planeado el \(used) % de tus vacaciones. Planéalas antes de que se pierdan.", .italian: "È passato il \(year)% dell’anno, ma hai programmato solo il \(used)% delle ferie. Pianificale prima di perderle.", .portuguese: "\(year)% do ano já passou, mas só \(used)% das suas férias estão planejadas. Planeje antes que sobrem.", .chineseTraditional: "今年已過去 \(year)%，年假只安排了 \(used)%。在用不完之前做好計畫吧。", .dutch: "\(year)% van het jaar is voorbij, maar pas \(used)% van je verlof is gepland. Plan het voordat het vervalt.", .swedish: "\(year) % av året har gått, men bara \(used) % av ledigheten är planerad. Planera innan den går förlorad.", .norwegian: "\(year) % av året har gått, men bare \(used) % av fridagene er planlagt. Planlegg før de går tapt.", .danish: "\(year) % af året er gået, men kun \(used) % af ferien er planlagt. Planlæg, før den går tabt.", .finnish: "Vuodesta on kulunut \(year) %, mutta lomista on suunniteltu vain \(used) %. Suunnittele ennen kuin ne jäävät käyttämättä.", .polish: "Minęło \(year)% roku, a zaplanowano tylko \(used)% urlopu. Zaplanuj, zanim przepadnie.", .czech: "Uběhlo \(year) % roku, ale naplánováno je jen \(used) % volna. Naplánuj ho, než propadne.", .greek: "Πέρασε το \(year)% της χρονιάς, αλλά έχεις προγραμματίσει μόνο το \(used)% της άδειας. Προγραμμάτισέ την πριν χαθεί.", .turkish: "Yılın %\(year)’i geçti ama izninin yalnızca %\(used)’i planlandı. Yanmadan planla.", .russian: "Прошло \(year)% года, а запланировано лишь \(used)% отпуска. Спланируйте, пока дни не сгорели.", .indonesian: "Sudah \(year)% tahun berlalu, tapi baru \(used)% cuti yang direncanakan. Rencanakan sebelum hangus.", .thai: "ปีนี้ผ่านไป \(year)% แต่วางวันลาไว้แค่ \(used)% วางแผนก่อนวันลาจะเหลือทิ้ง", .vietnamese: "Đã qua \(year)% năm nhưng mới lên kế hoạch \(used)% ngày phép. Hãy lên kế hoạch trước khi bị bỏ phí."])
    }

    static func paceWarnFast(year: Int, used: Int) -> String {
        pick([.korean: "연차를 빠르게 쓰고 있어요. 올해가 \(year)% 지났고 연차는 \(used)%를 썼어요.", .english: "You’re using leave quickly: \(year)% of the year has passed and \(used)% of your leave is used.", .japanese: "年休の消化が早めです。今年が\(year)%過ぎ、年休は\(used)%使いました。", .chinese: "年假用得有点快。今年已过去 \(year)%，年假已用 \(used)%。", .german: "Du nimmst schnell Urlaub: \(year) % des Jahres sind vorbei, \(used) % deines Urlaubs sind verbraucht.", .french: "Vous utilisez vite vos congés : \(year) % de l’année est passée et \(used) % des congés sont pris.", .spanish: "Estás usando las vacaciones rápido: ha pasado el \(year) % del año y ya usaste el \(used) %.", .italian: "Stai usando le ferie in fretta: è passato il \(year)% dell’anno e hai usato il \(used)%.", .portuguese: "Você está usando as férias rápido: \(year)% do ano passou e \(used)% já foi usado.", .chineseTraditional: "年假用得有點快。今年已過去 \(year)%，年假已用 \(used)%。", .dutch: "Je gebruikt je verlof snel: \(year)% van het jaar is voorbij en \(used)% is opgenomen.", .swedish: "Du använder ledigheten snabbt: \(year) % av året har gått och \(used) % är använt.", .norwegian: "Du bruker fridagene raskt: \(year) % av året har gått og \(used) % er brukt.", .danish: "Du bruger ferien hurtigt: \(year) % af året er gået, og \(used) % er brugt.", .finnish: "Käytät lomia nopeasti: vuodesta on kulunut \(year) % ja lomista käytetty \(used) %.", .polish: "Szybko wykorzystujesz urlop: minęło \(year)% roku, a wykorzystano \(used)%.", .czech: "Čerpáš volno rychle: uběhlo \(year) % roku a vyčerpáno je \(used) %.", .greek: "Χρησιμοποιείς γρήγορα την άδεια: πέρασε το \(year)% της χρονιάς και έχεις πάρει το \(used)%.", .turkish: "İznini hızlı kullanıyorsun: yılın %\(year)’i geçti, iznin %\(used)’i kullanıldı.", .russian: "Вы быстро тратите отпуск: прошло \(year)% года, использовано \(used)%.", .indonesian: "Kamu memakai cuti dengan cepat: \(year)% tahun berlalu dan \(used)% cuti terpakai.", .thai: "คุณใช้วันลาเร็ว ปีนี้ผ่านไป \(year)% และใช้วันลาไป \(used)%", .vietnamese: "Bạn đang dùng phép khá nhanh: đã qua \(year)% năm và đã dùng \(used)% ngày phép."])
    }
}
