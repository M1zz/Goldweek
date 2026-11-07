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
    public static var carryOverSetting: String {
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
    public static var carryOverOff: String {
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
    public static var carryOverAll: String {
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
    public static var carryOverExpirySetting: String {
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
    public static var carryOverNoExpiry: String {
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
    public static var carryOverFooter: String {
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
    public static func carryOverUpTo(_ d: String) -> String {
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
    public static func carryOverExpiryMonths(_ n: Int) -> String {
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
    public static func futureYearLeaveNote(year y: Int, remaining r: String) -> String {
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
    public static var homeOfferUpcoming: String { pick([.korean: "잡아 둔 휴가를 현황에 모아 볼까요?", .english: "Show your planned time off on the Overview?", .japanese: "予定した休暇を現況にまとめて表示しますか？", .chinese: "要在概况中集中显示已安排的休假吗？", .german: "Geplante Urlaube in der Übersicht anzeigen?", .french: "Afficher vos congés prévus dans l’aperçu ?", .spanish: "¿Mostrar tus vacaciones planeadas en el resumen?", .italian: "Mostrare le ferie in programma nella panoramica?", .portuguese: "Mostrar suas férias planejadas no resumo?", .chineseTraditional: "要在概況中集中顯示已安排的休假嗎？", .dutch: "Geplande vrije dagen in het overzicht tonen?", .swedish: "Visa planerad ledighet i översikten?", .norwegian: "Vise planlagt fri i oversikten?", .danish: "Vis planlagt fri i oversigten?", .finnish: "Näytetäänkö suunnitellut lomat yleiskatsauksessa?", .polish: "Pokazywać zaplanowany urlop w podsumowaniu?", .czech: "Zobrazit naplánované volno v přehledu?", .greek: "Να εμφανίζεται η προγραμματισμένη άδεια στην επισκόπηση;", .turkish: "Planlanan izinler özette gösterilsin mi?", .russian: "Показывать запланированный отпуск в обзоре?", .indonesian: "Tampilkan cuti yang direncanakan di ringkasan?", .thai: "แสดงวันลาที่วางไว้ในภาพรวมไหม", .vietnamese: "Hiện kỳ nghỉ đã lên lịch ở phần tổng quan?"]) }

    public static var homeOfferHolidays: String { pick([.korean: "곧 공휴일이 있어요. 다가오는 공휴일도 함께 볼까요?", .english: "A public holiday is coming up. Show upcoming holidays too?", .japanese: "もうすぐ祝日です。これからの祝日も一緒に表示しますか？", .chinese: "公共假日快到了。要一起显示即将到来的假日吗？", .german: "Bald ist ein Feiertag. Kommende Feiertage auch anzeigen?", .french: "Un jour férié approche. Afficher aussi les prochains jours fériés ?", .spanish: "Se acerca un festivo. ¿Mostrar también los próximos festivos?", .italian: "Sta per arrivare un giorno festivo. Mostrare anche i prossimi festivi?", .portuguese: "Um feriado está chegando. Mostrar também os próximos feriados?", .chineseTraditional: "公眾假期快到了。要一起顯示即將到來的假期嗎？", .dutch: "Er komt een feestdag aan. Ook komende feestdagen tonen?", .swedish: "En helgdag närmar sig. Visa kommande helgdagar också?", .norwegian: "En helligdag nærmer seg. Vise kommende helligdager også?", .danish: "En helligdag nærmer sig. Vis også kommende helligdage?", .finnish: "Pyhäpäivä lähestyy. Näytetäänkö myös tulevat pyhäpäivät?", .polish: "Zbliża się święto. Pokazywać też nadchodzące święta?", .czech: "Blíží se svátek. Zobrazit i nadcházející svátky?", .greek: "Πλησιάζει αργία. Να εμφανίζονται και οι επόμενες αργίες;", .turkish: "Yakında resmî tatil var. Yaklaşan tatiller de gösterilsin mi?", .russian: "Скоро праздник. Показывать и ближайшие праздники?", .indonesian: "Hari libur sudah dekat. Tampilkan juga hari libur mendatang?", .thai: "ใกล้วันหยุดแล้ว แสดงวันหยุดที่กำลังจะมาถึงด้วยไหม", .vietnamese: "Sắp đến ngày lễ. Hiện cả các ngày lễ sắp tới?"]) }

    public static var homeOfferYes: String { pick([.korean: "볼게요", .english: "Show", .japanese: "表示する", .chinese: "显示", .german: "Anzeigen", .french: "Afficher", .spanish: "Mostrar", .italian: "Mostra", .portuguese: "Mostrar", .chineseTraditional: "顯示", .dutch: "Tonen", .swedish: "Visa", .norwegian: "Vis", .danish: "Vis", .finnish: "Näytä", .polish: "Pokaż", .czech: "Zobrazit", .greek: "Εμφάνιση", .turkish: "Göster", .russian: "Показывать", .indonesian: "Tampilkan", .thai: "แสดง", .vietnamese: "Hiện"]) }

    public static var homeOfferNo: String { pick([.korean: "괜찮아요", .english: "No thanks", .japanese: "表示しない", .chinese: "不用了", .german: "Nein, danke", .french: "Non merci", .spanish: "No, gracias", .italian: "No, grazie", .portuguese: "Não, obrigado", .chineseTraditional: "不用了", .dutch: "Nee, bedankt", .swedish: "Nej tack", .norwegian: "Nei takk", .danish: "Nej tak", .finnish: "Ei kiitos", .polish: "Nie, dziękuję", .czech: "Ne, díky", .greek: "Όχι, ευχαριστώ", .turkish: "Hayır, teşekkürler", .russian: "Не нужно", .indonesian: "Tidak usah", .thai: "ไม่เป็นไร", .vietnamese: "Không, cảm ơn"]) }

    public static var homeGotIt: String { pick([.korean: "알겠어요", .english: "Got it", .japanese: "わかりました", .chinese: "知道了", .german: "Verstanden", .french: "Compris", .spanish: "Entendido", .italian: "Ho capito", .portuguese: "Entendi", .chineseTraditional: "知道了", .dutch: "Begrepen", .swedish: "Uppfattat", .norwegian: "Skjønner", .danish: "Forstået", .finnish: "Selvä", .polish: "Rozumiem", .czech: "Rozumím", .greek: "Εντάξει", .turkish: "Anladım", .russian: "Понятно", .indonesian: "Mengerti", .thai: "เข้าใจแล้ว", .vietnamese: "Đã hiểu"]) }

    public static var homePaceAlways: String { pick([.korean: "휴가 페이스 늘 보기", .english: "Always show leave pace", .japanese: "休暇ペースを常に表示", .chinese: "始终显示休假节奏", .german: "Urlaubstempo immer anzeigen", .french: "Toujours afficher le rythme des congés", .spanish: "Mostrar siempre el ritmo de vacaciones", .italian: "Mostra sempre il ritmo delle ferie", .portuguese: "Sempre mostrar o ritmo das férias", .chineseTraditional: "始終顯示休假節奏", .dutch: "Verloftempo altijd tonen", .swedish: "Visa alltid ledighetstakten", .norwegian: "Vis alltid fritempoet", .danish: "Vis altid ferietempoet", .finnish: "Näytä lomatahti aina", .polish: "Zawsze pokazuj tempo urlopu", .czech: "Vždy zobrazovat tempo čerpání volna", .greek: "Να εμφανίζεται πάντα ο ρυθμός αδειών", .turkish: "İzin hızını her zaman göster", .russian: "Всегда показывать темп отпуска", .indonesian: "Selalu tampilkan laju cuti", .thai: "แสดงจังหวะการลาเสมอ", .vietnamese: "Luôn hiện nhịp nghỉ phép"]) }

    public static var homePaceAlwaysDescription: String { pick([.korean: "끄면 쉬지 못했거나 연차가 남을 것 같을 때만 보여요.", .english: "When off, it appears only when you’re overdue for a break or likely to leave days unused.", .japanese: "オフにすると、休めていないときや年休が余りそうなときだけ表示します。", .chinese: "关闭后，仅在久未休息或年假可能用不完时显示。", .german: "Wenn aus, erscheint es nur, wenn eine Pause überfällig ist oder Urlaubstage verfallen könnten.", .french: "Désactivé, il n’apparaît que si une pause s’impose ou si des jours risquent d’être perdus.", .spanish: "Si está desactivado, solo aparece cuando te toca descansar o podrían sobrarte días.", .italian: "Se disattivato, appare solo quando ti serve una pausa o rischi di non usare dei giorni.", .portuguese: "Desligado, aparece só quando você precisa de pausa ou pode sobrar dias.", .chineseTraditional: "關閉後，僅在久未休息或年假可能用不完時顯示。", .dutch: "Uit: alleen zichtbaar als je toe bent aan rust of dagen dreigt over te houden.", .swedish: "Av: visas bara när du behöver vila eller kan få dagar över.", .norwegian: "Av: vises bare når du trenger en pause eller kan få dager til overs.", .danish: "Fra: vises kun, når du trænger til en pause eller kan få dage i overskud.", .finnish: "Pois päältä: näkyy vain, kun lepo on myöhässä tai lomapäiviä uhkaa jäädä käyttämättä.", .polish: "Wyłączone: pojawia się tylko, gdy należy Ci się odpoczynek lub mogą zostać niewykorzystane dni.", .czech: "Vypnuto: zobrazí se jen, když potřebuješ pauzu nebo ti můžou zbýt dny.", .greek: "Όταν είναι ανενεργό, εμφανίζεται μόνο όταν χρειάζεσαι διάλειμμα ή μπορεί να περισσέψουν μέρες.", .turkish: "Kapalıyken yalnızca mola gerektiğinde veya izin günleri artabilecekken görünür.", .russian: "Если выключено, появляется, только когда пора отдохнуть или дни могут сгореть.", .indonesian: "Jika mati, hanya muncul saat kamu perlu istirahat atau cuti bisa tersisa.", .thai: "เมื่อปิด จะแสดงเฉพาะตอนที่ควรพักหรือวันลาอาจเหลือ", .vietnamese: "Khi tắt, chỉ hiện khi bạn cần nghỉ hoặc có thể còn dư ngày phép."]) }

    public static var homeMoreActions: String { pick([.korean: "더 보기", .english: "More", .japanese: "その他", .chinese: "更多", .german: "Mehr", .french: "Plus", .spanish: "Más", .italian: "Altro", .portuguese: "Mais", .chineseTraditional: "更多", .dutch: "Meer", .swedish: "Mer", .norwegian: "Mer", .danish: "Mere", .finnish: "Lisää", .polish: "Więcej", .czech: "Další", .greek: "Περισσότερα", .turkish: "Diğer", .russian: "Ещё", .indonesian: "Lainnya", .thai: "เพิ่มเติม", .vietnamese: "Thêm"]) }

    public static func paceWarnSlow(year: Int, used: Int) -> String {
        pick([.korean: "올해가 \(year)% 지났는데 연차는 \(used)%만 잡혀 있어요. 남기 전에 계획해 보세요.", .english: "\(year)% of the year has passed, but only \(used)% of your leave is planned. Plan it before it goes unused.", .japanese: "今年が\(year)%過ぎましたが、年休は\(used)%しか予定がありません。余る前に計画しましょう。", .chinese: "今年已过去 \(year)%，年假只安排了 \(used)%。在用不完之前做好计划吧。", .german: "\(year) % des Jahres sind vorbei, aber erst \(used) % deines Urlaubs sind geplant. Plane ihn, bevor er verfällt.", .french: "\(year) % de l’année est passée, mais seulement \(used) % de vos congés sont prévus. Planifiez-les avant de les perdre.", .spanish: "Ha pasado el \(year) % del año y solo tienes planeado el \(used) % de tus vacaciones. Planéalas antes de que se pierdan.", .italian: "È passato il \(year)% dell’anno, ma hai programmato solo il \(used)% delle ferie. Pianificale prima di perderle.", .portuguese: "\(year)% do ano já passou, mas só \(used)% das suas férias estão planejadas. Planeje antes que sobrem.", .chineseTraditional: "今年已過去 \(year)%，年假只安排了 \(used)%。在用不完之前做好計畫吧。", .dutch: "\(year)% van het jaar is voorbij, maar pas \(used)% van je verlof is gepland. Plan het voordat het vervalt.", .swedish: "\(year) % av året har gått, men bara \(used) % av ledigheten är planerad. Planera innan den går förlorad.", .norwegian: "\(year) % av året har gått, men bare \(used) % av fridagene er planlagt. Planlegg før de går tapt.", .danish: "\(year) % af året er gået, men kun \(used) % af ferien er planlagt. Planlæg, før den går tabt.", .finnish: "Vuodesta on kulunut \(year) %, mutta lomista on suunniteltu vain \(used) %. Suunnittele ennen kuin ne jäävät käyttämättä.", .polish: "Minęło \(year)% roku, a zaplanowano tylko \(used)% urlopu. Zaplanuj, zanim przepadnie.", .czech: "Uběhlo \(year) % roku, ale naplánováno je jen \(used) % volna. Naplánuj ho, než propadne.", .greek: "Πέρασε το \(year)% της χρονιάς, αλλά έχεις προγραμματίσει μόνο το \(used)% της άδειας. Προγραμμάτισέ την πριν χαθεί.", .turkish: "Yılın %\(year)’i geçti ama izninin yalnızca %\(used)’i planlandı. Yanmadan planla.", .russian: "Прошло \(year)% года, а запланировано лишь \(used)% отпуска. Спланируйте, пока дни не сгорели.", .indonesian: "Sudah \(year)% tahun berlalu, tapi baru \(used)% cuti yang direncanakan. Rencanakan sebelum hangus.", .thai: "ปีนี้ผ่านไป \(year)% แต่วางวันลาไว้แค่ \(used)% วางแผนก่อนวันลาจะเหลือทิ้ง", .vietnamese: "Đã qua \(year)% năm nhưng mới lên kế hoạch \(used)% ngày phép. Hãy lên kế hoạch trước khi bị bỏ phí."])
    }

    public static func paceWarnFast(year: Int, used: Int) -> String {
        pick([.korean: "연차를 빠르게 쓰고 있어요. 올해가 \(year)% 지났고 연차는 \(used)%를 썼어요.", .english: "You’re using leave quickly: \(year)% of the year has passed and \(used)% of your leave is used.", .japanese: "年休の消化が早めです。今年が\(year)%過ぎ、年休は\(used)%使いました。", .chinese: "年假用得有点快。今年已过去 \(year)%，年假已用 \(used)%。", .german: "Du nimmst schnell Urlaub: \(year) % des Jahres sind vorbei, \(used) % deines Urlaubs sind verbraucht.", .french: "Vous utilisez vite vos congés : \(year) % de l’année est passée et \(used) % des congés sont pris.", .spanish: "Estás usando las vacaciones rápido: ha pasado el \(year) % del año y ya usaste el \(used) %.", .italian: "Stai usando le ferie in fretta: è passato il \(year)% dell’anno e hai usato il \(used)%.", .portuguese: "Você está usando as férias rápido: \(year)% do ano passou e \(used)% já foi usado.", .chineseTraditional: "年假用得有點快。今年已過去 \(year)%，年假已用 \(used)%。", .dutch: "Je gebruikt je verlof snel: \(year)% van het jaar is voorbij en \(used)% is opgenomen.", .swedish: "Du använder ledigheten snabbt: \(year) % av året har gått och \(used) % är använt.", .norwegian: "Du bruker fridagene raskt: \(year) % av året har gått og \(used) % er brukt.", .danish: "Du bruger ferien hurtigt: \(year) % af året er gået, og \(used) % er brugt.", .finnish: "Käytät lomia nopeasti: vuodesta on kulunut \(year) % ja lomista käytetty \(used) %.", .polish: "Szybko wykorzystujesz urlop: minęło \(year)% roku, a wykorzystano \(used)%.", .czech: "Čerpáš volno rychle: uběhlo \(year) % roku a vyčerpáno je \(used) %.", .greek: "Χρησιμοποιείς γρήγορα την άδεια: πέρασε το \(year)% της χρονιάς και έχεις πάρει το \(used)%.", .turkish: "İznini hızlı kullanıyorsun: yılın %\(year)’i geçti, iznin %\(used)’i kullanıldı.", .russian: "Вы быстро тратите отпуск: прошло \(year)% года, использовано \(used)%.", .indonesian: "Kamu memakai cuti dengan cepat: \(year)% tahun berlalu dan \(used)% cuti terpakai.", .thai: "คุณใช้วันลาเร็ว ปีนี้ผ่านไป \(year)% และใช้วันลาไป \(used)%", .vietnamese: "Bạn đang dùng phép khá nhanh: đã qua \(year)% năm và đã dùng \(used)% ngày phép."])
    }
}

// MARK: - 처음 쓰는 사람의 첫 단계 (캘린더): 잡아 둔 휴가 넣기
extension Strings {
    public static var plannedPromptTitle: String { pick([.korean: "앞으로 잡아 둔 휴가가 있나요?", .english: "Any time off already planned?", .japanese: "これから予定している休暇はありますか？", .chinese: "有已经安排好的休假吗？", .german: "Hast du schon Urlaub geplant?", .french: "Des congés déjà prévus ?", .spanish: "¿Tienes vacaciones ya planeadas?", .italian: "Hai già delle ferie in programma?", .portuguese: "Já tem férias planejadas?", .chineseTraditional: "有已經安排好的休假嗎？", .dutch: "Heb je al vrije dagen gepland?", .swedish: "Har du redan planerat ledighet?", .norwegian: "Har du allerede planlagt fri?", .danish: "Har du allerede planlagt fri?", .finnish: "Onko sinulla jo suunniteltuja lomia?", .polish: "Masz już zaplanowany urlop?", .czech: "Máš už naplánované volno?", .greek: "Έχεις ήδη προγραμματίσει άδεια;", .turkish: "Planladığın bir izin var mı?", .russian: "Уже запланировали отпуск?", .indonesian: "Sudah ada cuti yang direncanakan?", .thai: "มีวันลาที่วางไว้แล้วไหม", .vietnamese: "Bạn đã lên lịch kỳ nghỉ nào chưa?"]) }

    public static var plannedPromptDesc: String { pick([.korean: "정해 둔 날을 넣어 두면 남은 연차와 추천 휴가가 그만큼 맞춰져요.", .english: "Add the dates you’ve set, and your balance and suggestions adjust to match.", .japanese: "決まっている日を入れると、残りの年休とおすすめがそれに合わせて変わります。", .chinese: "填入已定的日期，剩余年假和推荐会随之调整。", .german: "Trag feste Termine ein, dann passen sich Resturlaub und Vorschläge an.", .french: "Ajoutez les dates fixées : votre solde et les suggestions s’ajustent.", .spanish: "Añade las fechas decididas y tu saldo y las sugerencias se ajustarán.", .italian: "Aggiungi le date decise: saldo e suggerimenti si adeguano.", .portuguese: "Adicione as datas definidas e o saldo e as sugestões se ajustam.", .chineseTraditional: "填入已定的日期，剩餘年假和推薦會隨之調整。", .dutch: "Voeg vastgelegde data toe; je saldo en suggesties passen zich aan.", .swedish: "Lägg till bestämda datum så anpassas saldot och förslagen.", .norwegian: "Legg inn bestemte datoer, så tilpasses saldoen og forslagene.", .danish: "Tilføj faste datoer, så tilpasses saldoen og forslagene.", .finnish: "Lisää sovitut päivät, niin saldo ja ehdotukset mukautuvat.", .polish: "Dodaj ustalone daty, a saldo i propozycje się dopasują.", .czech: "Přidej domluvená data a zůstatek i návrhy se upraví.", .greek: "Πρόσθεσε τις ημερομηνίες που έχεις ορίσει και το υπόλοιπο και οι προτάσεις προσαρμόζονται.", .turkish: "Belirlediğin tarihleri ekle; kalan izin ve öneriler buna göre ayarlanır.", .russian: "Добавьте выбранные даты — остаток и подсказки подстроятся.", .indonesian: "Tambahkan tanggal yang sudah ditentukan, sisa cuti dan saran akan menyesuaikan.", .thai: "ใส่วันที่กำหนดไว้ แล้ววันลาคงเหลือและคำแนะนำจะปรับตาม", .vietnamese: "Thêm những ngày đã định, số phép còn lại và gợi ý sẽ tự điều chỉnh."]) }

    public static var plannedPromptNone: String { pick([.korean: "아직 없어요", .english: "Not yet", .japanese: "まだない", .chinese: "还没有", .german: "Noch nicht", .french: "Pas encore", .spanish: "Todavía no", .italian: "Non ancora", .portuguese: "Ainda não", .chineseTraditional: "還沒有", .dutch: "Nog niet", .swedish: "Inte än", .norwegian: "Ikke ennå", .danish: "Ikke endnu", .finnish: "Ei vielä", .polish: "Jeszcze nie", .czech: "Zatím ne", .greek: "Όχι ακόμα", .turkish: "Henüz yok", .russian: "Пока нет", .indonesian: "Belum", .thai: "ยังไม่มี", .vietnamese: "Chưa có"]) }

    public static var plannedPromptAdd: String { pick([.korean: "날짜 고르기", .english: "Pick dates", .japanese: "日付を選ぶ", .chinese: "选择日期", .german: "Daten wählen", .french: "Choisir les dates", .spanish: "Elegir fechas", .italian: "Scegli le date", .portuguese: "Escolher datas", .chineseTraditional: "選擇日期", .dutch: "Data kiezen", .swedish: "Välj datum", .norwegian: "Velg datoer", .danish: "Vælg datoer", .finnish: "Valitse päivät", .polish: "Wybierz daty", .czech: "Vybrat data", .greek: "Επιλογή ημερομηνιών", .turkish: "Tarih seç", .russian: "Выбрать даты", .indonesian: "Pilih tanggal", .thai: "เลือกวันที่", .vietnamese: "Chọn ngày"]) }

    public static var plannedMoreTitle: String { pick([.korean: "잡아 둔 휴가가 더 있나요?", .english: "Any more planned time off?", .japanese: "ほかにも予定している休暇はありますか？", .chinese: "还有其他已安排的休假吗？", .german: "Noch weiterer geplanter Urlaub?", .french: "D’autres congés prévus ?", .spanish: "¿Más vacaciones planeadas?", .italian: "Altre ferie in programma?", .portuguese: "Mais férias planejadas?", .chineseTraditional: "還有其他已安排的休假嗎？", .dutch: "Nog meer geplande vrije dagen?", .swedish: "Mer planerad ledighet?", .norwegian: "Mer planlagt fri?", .danish: "Mere planlagt fri?", .finnish: "Onko muita suunniteltuja lomia?", .polish: "Masz jeszcze zaplanowany urlop?", .czech: "Máš ještě další naplánované volno?", .greek: "Έχεις κι άλλη προγραμματισμένη άδεια;", .turkish: "Planlanmış başka izin var mı?", .russian: "Есть ещё запланированный отпуск?", .indonesian: "Ada cuti lain yang direncanakan?", .thai: "มีวันลาที่วางไว้อีกไหม", .vietnamese: "Còn kỳ nghỉ nào đã lên lịch nữa không?"]) }

    public static var plannedDone: String { pick([.korean: "다 넣었어요", .english: "That’s all", .japanese: "これで全部", .chinese: "就这些", .german: "Das war’s", .french: "C’est tout", .spanish: "Eso es todo", .italian: "È tutto", .portuguese: "É só isso", .chineseTraditional: "就這些", .dutch: "Dat is alles", .swedish: "Det var allt", .norwegian: "Det var alt", .danish: "Det var det hele", .finnish: "Siinä kaikki", .polish: "To wszystko", .czech: "To je vše", .greek: "Αυτά ήταν", .turkish: "Hepsi bu", .russian: "Это всё", .indonesian: "Sudah semua", .thai: "ครบแล้ว", .vietnamese: "Vậy là đủ"]) }

    public static var plannedAddAnother: String { pick([.korean: "하나 더", .english: "Add another", .japanese: "もう一つ", .chinese: "再加一个", .german: "Noch einen", .french: "En ajouter un", .spanish: "Añadir otro", .italian: "Aggiungine un altro", .portuguese: "Adicionar outro", .chineseTraditional: "再加一個", .dutch: "Nog een", .swedish: "Lägg till fler", .norwegian: "Legg til en til", .danish: "Tilføj en til", .finnish: "Lisää toinen", .polish: "Dodaj kolejny", .czech: "Přidat další", .greek: "Προσθήκη άλλης", .turkish: "Bir tane daha", .russian: "Добавить ещё", .indonesian: "Tambah lagi", .thai: "เพิ่มอีก", .vietnamese: "Thêm nữa"]) }
}

// MARK: - 더 쉽게 넣기 (캡처 · 캘린더)
extension Strings {
    public static var easyEntryTitle: String { pick([.korean: "하나씩 넣기 번거롭다면", .english: "Too many to add one by one?", .japanese: "一つずつ入れるのが面倒なら", .chinese: "嫌一个个输入太麻烦？", .german: "Zu viele zum Einzeln-Eintragen?", .french: "Trop nombreux à saisir un par un ?", .spanish: "¿Demasiados para añadir uno a uno?", .italian: "Troppi da aggiungere uno per uno?", .portuguese: "Muitos para adicionar um por um?", .chineseTraditional: "嫌一個個輸入太麻煩？", .dutch: "Te veel om één voor één toe te voegen?", .swedish: "För många att lägga till en i taget?", .norwegian: "For mange å legge inn én og én?", .danish: "For mange at tilføje én ad gangen?", .finnish: "Liian monta lisättäväksi yksitellen?", .polish: "Za dużo, by dodawać po kolei?", .czech: "Příliš mnoho na přidávání po jednom?", .greek: "Πολλές για να τις προσθέσεις μία-μία;", .turkish: "Tek tek eklemek zahmetli mi?", .russian: "Долго вводить по одному?", .indonesian: "Repot menambah satu per satu?", .thai: "ใส่ทีละรายการยุ่งยากไหม", .vietnamese: "Thêm từng cái một quá phiền?"]) }

    public static var easyEntryPhoto: String { pick([.korean: "캡처로 넣기", .english: "From a screenshot", .japanese: "スクショから", .chinese: "从截图导入", .german: "Aus Screenshot", .french: "Depuis une capture", .spanish: "Desde una captura", .italian: "Da uno screenshot", .portuguese: "De uma captura", .chineseTraditional: "從截圖匯入", .dutch: "Uit screenshot", .swedish: "Från skärmdump", .norwegian: "Fra skjermbilde", .danish: "Fra skærmbillede", .finnish: "Kuvakaappauksesta", .polish: "Ze zrzutu ekranu", .czech: "Ze snímku obrazovky", .greek: "Από στιγμιότυπο", .turkish: "Ekran görüntüsünden", .russian: "Со скриншота", .indonesian: "Dari tangkapan layar", .thai: "จากภาพหน้าจอ", .vietnamese: "Từ ảnh chụp màn hình"]) }

    public static var easyEntryCalendar: String { pick([.korean: "캘린더에서", .english: "From Calendar", .japanese: "カレンダーから", .chinese: "从日历导入", .german: "Aus Kalender", .french: "Depuis Calendrier", .spanish: "Desde Calendario", .italian: "Da Calendario", .portuguese: "Do Calendário", .chineseTraditional: "從行事曆匯入", .dutch: "Uit Agenda", .swedish: "Från Kalender", .norwegian: "Fra Kalender", .danish: "Fra Kalender", .finnish: "Kalenterista", .polish: "Z Kalendarza", .czech: "Z Kalendáře", .greek: "Από Ημερολόγιο", .turkish: "Takvimden", .russian: "Из Календаря", .indonesian: "Dari Kalender", .thai: "จากปฏิทิน", .vietnamese: "Từ Lịch"]) }

    public static var photoStepOpen: String { pick([.korean: "회사 시스템이나 메신저에서 휴가 신청 내역 화면을 열어요", .english: "Open your leave request history in your company system or messenger", .japanese: "会社のシステムやメッセンジャーで休暇申請履歴の画面を開きます", .chinese: "在公司系统或通讯软件中打开休假申请记录页面", .german: "Öffne deinen Urlaubsantragsverlauf im Firmensystem oder Messenger", .french: "Ouvrez l’historique de vos demandes de congé dans l’outil de l’entreprise ou la messagerie", .spanish: "Abre el historial de solicitudes de vacaciones en el sistema de tu empresa o en la mensajería", .italian: "Apri lo storico delle richieste di ferie nel sistema aziendale o nella chat", .portuguese: "Abra o histórico de pedidos de férias no sistema da empresa ou no mensageiro", .chineseTraditional: "在公司系統或通訊軟體中打開休假申請紀錄頁面", .dutch: "Open je verlofaanvragen in het bedrijfssysteem of de chatapp", .swedish: "Öppna din ledighetshistorik i företagets system eller chatt", .norwegian: "Åpne fraværssøknadene dine i firmasystemet eller chatten", .danish: "Åbn dine ferieanmodninger i firmaets system eller chat", .finnish: "Avaa lomahakemushistoriasi yrityksen järjestelmässä tai viestisovelluksessa", .polish: "Otwórz historię wniosków urlopowych w systemie firmy lub komunikatorze", .czech: "Otevři historii žádostí o volno ve firemním systému nebo chatu", .greek: "Άνοιξε το ιστορικό αιτήσεων άδειας στο σύστημα της εταιρείας ή στο messenger", .turkish: "Şirket sisteminde veya mesajlaşma uygulamasında izin talep geçmişini aç", .russian: "Откройте историю заявок на отпуск в системе компании или мессенджере", .indonesian: "Buka riwayat pengajuan cuti di sistem kantor atau aplikasi pesan", .thai: "เปิดหน้าประวัติการขอลาในระบบของบริษัทหรือแอปแชต", .vietnamese: "Mở lịch sử xin nghỉ phép trong hệ thống công ty hoặc ứng dụng nhắn tin"]) }

    public static var photoStepCaptureFaceID: String { pick([.korean: "측면 버튼과 음량 높이기 버튼을 함께 눌러 캡처해요", .english: "Press the side button and volume up together to take a screenshot", .japanese: "サイドボタンと音量を上げるボタンを同時に押してスクショします", .chinese: "同时按侧边按钮和音量加键截屏", .german: "Drücke Seitentaste und Lauter gleichzeitig für einen Screenshot", .french: "Appuyez en même temps sur le bouton latéral et volume + pour faire une capture", .spanish: "Pulsa a la vez el botón lateral y subir volumen para hacer una captura", .italian: "Premi insieme il tasto laterale e volume su per lo screenshot", .portuguese: "Pressione o botão lateral e aumentar volume juntos para capturar a tela", .chineseTraditional: "同時按側邊按鈕和音量加鍵截圖", .dutch: "Druk tegelijk op de zijknop en volume omhoog voor een screenshot", .swedish: "Tryck på sidoknappen och volym upp samtidigt för en skärmdump", .norwegian: "Trykk sideknappen og volum opp samtidig for et skjermbilde", .danish: "Tryk på sideknappen og lydstyrke op samtidig for et skærmbillede", .finnish: "Paina sivupainiketta ja äänenvoimakkuus ylös yhtä aikaa", .polish: "Naciśnij jednocześnie przycisk boczny i głośniej, by zrobić zrzut", .czech: "Stiskni současně boční tlačítko a zvýšení hlasitosti", .greek: "Πάτησε μαζί το πλαϊνό κουμπί και την αύξηση έντασης για στιγμιότυπο", .turkish: "Ekran görüntüsü için yan düğme ile ses açma düğmesine birlikte bas", .russian: "Нажмите одновременно боковую кнопку и кнопку увеличения громкости", .indonesian: "Tekan tombol samping dan volume naik bersamaan untuk tangkapan layar", .thai: "กดปุ่มด้านข้างพร้อมปุ่มเพิ่มเสียงเพื่อจับภาพหน้าจอ", .vietnamese: "Nhấn đồng thời nút sườn và nút tăng âm lượng để chụp màn hình"]) }

    public static var photoStepCaptureHome: String { pick([.korean: "홈 버튼과 측면 버튼을 함께 눌러 캡처해요", .english: "Press the Home button and side button together to take a screenshot", .japanese: "ホームボタンとサイドボタンを同時に押してスクショします", .chinese: "同时按主屏幕按钮和侧边按钮截屏", .german: "Drücke Home- und Seitentaste gleichzeitig für einen Screenshot", .french: "Appuyez en même temps sur le bouton principal et le bouton latéral", .spanish: "Pulsa a la vez el botón de inicio y el lateral para hacer una captura", .italian: "Premi insieme il tasto Home e il tasto laterale", .portuguese: "Pressione o botão de início e o lateral juntos para capturar a tela", .chineseTraditional: "同時按主畫面按鈕和側邊按鈕截圖", .dutch: "Druk tegelijk op de thuisknop en de zijknop", .swedish: "Tryck på hemknappen och sidoknappen samtidigt", .norwegian: "Trykk Hjem-knappen og sideknappen samtidig", .danish: "Tryk på hjemknappen og sideknappen samtidig", .finnish: "Paina kotipainiketta ja sivupainiketta yhtä aikaa", .polish: "Naciśnij jednocześnie przycisk Początek i boczny", .czech: "Stiskni současně tlačítko plochy a boční tlačítko", .greek: "Πάτησε μαζί το κουμπί αφετηρίας και το πλαϊνό κουμπί", .turkish: "Ana Ekran düğmesiyle yan düğmeye birlikte bas", .russian: "Нажмите одновременно кнопку «Домой» и боковую кнопку", .indonesian: "Tekan tombol Utama dan tombol samping bersamaan", .thai: "กดปุ่มโฮมพร้อมปุ่มด้านข้างเพื่อจับภาพหน้าจอ", .vietnamese: "Nhấn đồng thời nút Home và nút sườn để chụp màn hình"]) }

    public static var photoStepPick: String { pick([.korean: "아래에서 캡처한 사진을 고르면 날짜·종류·일수를 알아서 읽어요", .english: "Pick the screenshot below and the dates, types and days are read for you", .japanese: "下でスクショを選ぶと、日付・種類・日数を自動で読み取ります", .chinese: "在下方选择截图，日期、类型和天数会自动识别", .german: "Wähle unten den Screenshot – Daten, Art und Tage werden automatisch erkannt", .french: "Choisissez la capture ci-dessous : dates, types et jours sont lus automatiquement", .spanish: "Elige la captura abajo y se leen solas las fechas, tipos y días", .italian: "Scegli lo screenshot qui sotto: date, tipi e giorni vengono letti da soli", .portuguese: "Escolha a captura abaixo e datas, tipos e dias são lidos automaticamente", .chineseTraditional: "在下方選擇截圖，日期、類型和天數會自動辨識", .dutch: "Kies hieronder de screenshot; data, soort en dagen worden vanzelf gelezen", .swedish: "Välj skärmdumpen nedan så läses datum, typ och dagar in automatiskt", .norwegian: "Velg skjermbildet nedenfor, så leses datoer, type og dager automatisk", .danish: "Vælg skærmbilledet nedenfor, så aflæses datoer, type og dage automatisk", .finnish: "Valitse kuvakaappaus alta, niin päivät, tyyppi ja määrä luetaan automaattisesti", .polish: "Wybierz zrzut poniżej, a daty, rodzaj i dni zostaną odczytane same", .czech: "Vyber snímek níže a data, druh i počet dní se načtou samy", .greek: "Διάλεξε το στιγμιότυπο παρακάτω και ημερομηνίες, τύπος και ημέρες διαβάζονται αυτόματα", .turkish: "Aşağıdan ekran görüntüsünü seç; tarih, tür ve gün sayısı otomatik okunur", .russian: "Выберите скриншот ниже — даты, тип и дни распознаются сами", .indonesian: "Pilih tangkapan layar di bawah, tanggal, jenis, dan jumlah hari terbaca otomatis", .thai: "เลือกภาพหน้าจอด้านล่าง แล้ววันที่ ประเภท และจำนวนวันจะถูกอ่านให้อัตโนมัติ", .vietnamese: "Chọn ảnh chụp bên dưới, ngày, loại và số ngày sẽ được đọc tự động"]) }

    public static var photoPrivacy: String { pick([.korean: "사진은 이 기기 안에서만 읽고 어디로도 보내지 않아요", .english: "Photos are read only on this device and never sent anywhere", .japanese: "写真はこの端末の中だけで読み取り、どこにも送信しません", .chinese: "照片只在本机内识别，不会发送到任何地方", .german: "Fotos werden nur auf diesem Gerät gelesen und nirgendwohin gesendet", .french: "Les photos sont lues uniquement sur cet appareil et ne sont envoyées nulle part", .spanish: "Las fotos se leen solo en este dispositivo y no se envían a ningún sitio", .italian: "Le foto vengono lette solo su questo dispositivo e non inviate altrove", .portuguese: "As fotos são lidas só neste aparelho e não são enviadas a lugar nenhum", .chineseTraditional: "照片只在本機內辨識，不會傳送到任何地方", .dutch: "Foto’s worden alleen op dit apparaat gelezen en nergens heen gestuurd", .swedish: "Bilder läses bara på den här enheten och skickas ingenstans", .norwegian: "Bilder leses bare på denne enheten og sendes ingen steder", .danish: "Billeder læses kun på denne enhed og sendes ingen steder hen", .finnish: "Kuvat luetaan vain tällä laitteella eikä niitä lähetetä minnekään", .polish: "Zdjęcia są odczytywane tylko na tym urządzeniu i nigdzie nie są wysyłane", .czech: "Fotky se čtou jen v tomto zařízení a nikam se neposílají", .greek: "Οι φωτογραφίες διαβάζονται μόνο σε αυτή τη συσκευή και δεν στέλνονται πουθενά", .turkish: "Fotoğraflar yalnızca bu cihazda okunur, hiçbir yere gönderilmez", .russian: "Фото распознаются только на этом устройстве и никуда не отправляются", .indonesian: "Foto hanya dibaca di perangkat ini dan tidak dikirim ke mana pun", .thai: "อ่านรูปภาพในเครื่องนี้เท่านั้น ไม่ส่งไปที่ใด", .vietnamese: "Ảnh chỉ được đọc trên thiết bị này và không gửi đi đâu cả"]) }
}

// MARK: - 빠른 휴가 넣기 (달력에서 고르고 바로 저장)

extension Strings {
    private static var quickLang: AppLanguage { LanguageManager.shared.currentLanguage }

    /// 고른 기간 요약 — "연차 2일 → 5일 쉼"
    public static func quickAddSummary(leave: Double, rest: Int) -> String {
        let d = dayCount(leave)
        switch quickLang {
        case .korean: return "연차 \(d) → \(rest)일 쉼"
        case .english: return "\(d) of leave → \(rest) days off"
        case .japanese: return "休暇\(d) → \(rest)日休み"
        case .chinese: return "用\(d)年假 → 连休\(rest)天"
        case .german: return "\(d) Urlaub → \(rest) Tage frei"
        case .french: return "\(d) de congé → \(rest) jours de repos"
        case .spanish: return "\(d) de vacaciones → \(rest) días libres"
        case .italian: return "\(d) di ferie → \(rest) giorni liberi"
        case .portuguese: return "\(d) de folga → \(rest) dias de descanso"
        case .chineseTraditional: return "用\(d)特休 → 連休\(rest)天"
        case .dutch: return "\(d) verlof → \(rest) dagen vrij"
        case .swedish: return "\(d) semester → \(rest) dagar ledigt"
        case .norwegian: return "\(d) ferie → \(rest) dager fri"
        case .danish: return "\(d) ferie → \(rest) dage fri"
        case .finnish: return "\(d) lomaa → \(rest) päivää vapaata"
        case .polish: return "\(d) urlopu → \(rest) dni wolnego"
        case .czech: return "\(d) dovolené → \(rest) dní volna"
        case .greek: return "\(d) άδεια → \(rest) ημέρες ελεύθερες"
        case .turkish: return "\(d) izin → \(rest) gün tatil"
        case .russian: return "\(d) отпуска → \(rest) дн. отдыха"
        case .indonesian: return "Cuti \(d) → libur \(rest) hari"
        case .thai: return "ลา \(d) → หยุด \(rest) วัน"
        case .vietnamese: return "Nghỉ phép \(d) → được nghỉ \(rest) ngày"
        }
    }

    /// 고른 날이 모두 쉬는 날일 때
    public static var quickAddNoLeaveNeeded: String {
        switch quickLang {
        case .korean: return "모두 쉬는 날이라 연차가 들지 않아요"
        case .english: return "These are all days off, so no leave is needed"
        case .japanese: return "すべて休みの日なので休暇は要りません"
        case .chinese: return "都是休息日，不用请年假"
        case .german: return "Das sind alles freie Tage, du brauchst keinen Urlaub"
        case .french: return "Ce sont tous des jours de repos, aucun congé nécessaire"
        case .spanish: return "Todos son días libres, no necesitas vacaciones"
        case .italian: return "Sono tutti giorni liberi, non servono ferie"
        case .portuguese: return "Todos são dias de folga, não precisa usar férias"
        case .chineseTraditional: return "都是休息日，不用請特休"
        case .dutch: return "Dit zijn allemaal vrije dagen, je hebt geen verlof nodig"
        case .swedish: return "Alla är lediga dagar, du behöver ingen semester"
        case .norwegian: return "Alle er fridager, du trenger ikke ferie"
        case .danish: return "Alle er fridage, du behøver ikke ferie"
        case .finnish: return "Kaikki ovat vapaapäiviä, lomaa ei tarvita"
        case .polish: return "To same dni wolne, urlop nie jest potrzebny"
        case .czech: return "Všechno jsou volné dny, dovolená není potřeba"
        case .greek: return "Είναι όλες ελεύθερες ημέρες, δεν χρειάζεται άδεια"
        case .turkish: return "Hepsi tatil günü, izin gerekmiyor"
        case .russian: return "Это все выходные, отпуск не нужен"
        case .indonesian: return "Semuanya hari libur, tidak perlu cuti"
        case .thai: return "เป็นวันหยุดทั้งหมด ไม่ต้องใช้วันลา"
        case .vietnamese: return "Đều là ngày nghỉ, không cần dùng phép"
        }
    }

    /// 하루만 더 쓰면 연휴가 이어질 때 — "하루만 더 쓰면 9연휴"
    public static func quickAddMagnet(rest: Int) -> String {
        switch quickLang {
        case .korean: return "하루만 더 쓰면 \(rest)연휴"
        case .english: return "One more day makes it \(rest) days off"
        case .japanese: return "あと1日で\(rest)連休"
        case .chinese: return "再请一天就是\(rest)连休"
        case .german: return "Ein Tag mehr ergibt \(rest) freie Tage"
        case .french: return "Un jour de plus et c'est \(rest) jours de repos"
        case .spanish: return "Un día más y son \(rest) días libres"
        case .italian: return "Un giorno in più e sono \(rest) giorni liberi"
        case .portuguese: return "Mais um dia e são \(rest) dias de descanso"
        case .chineseTraditional: return "再請一天就是\(rest)連休"
        case .dutch: return "Eén dag meer en je hebt \(rest) dagen vrij"
        case .swedish: return "En dag till ger \(rest) lediga dagar"
        case .norwegian: return "Én dag til gir \(rest) fridager"
        case .danish: return "Én dag mere giver \(rest) fridage"
        case .finnish: return "Yksi päivä lisää, niin vapaata on \(rest) päivää"
        case .polish: return "Jeszcze jeden dzień i masz \(rest) dni wolnego"
        case .czech: return "Ještě jeden den a máš \(rest) dní volna"
        case .greek: return "Μία ημέρα ακόμη και έχεις \(rest) ημέρες ελεύθερες"
        case .turkish: return "Bir gün daha alırsan \(rest) gün tatil"
        case .russian: return "Ещё один день, и отдых составит \(rest) дн."
        case .indonesian: return "Tambah satu hari jadi libur \(rest) hari"
        case .thai: return "ลาเพิ่มอีกวันเดียว ได้หยุด \(rest) วัน"
        case .vietnamese: return "Thêm một ngày là được nghỉ \(rest) ngày"
        }
    }

    /// 자석 제안 받기 버튼
    public static var quickAddAttach: String {
        switch quickLang {
        case .korean: return "붙이기"
        case .english: return "Add"
        case .japanese: return "追加"
        case .chinese: return "加上"
        case .german: return "Hinzufügen"
        case .french: return "Ajouter"
        case .spanish: return "Añadir"
        case .italian: return "Aggiungi"
        case .portuguese: return "Adicionar"
        case .chineseTraditional: return "加上"
        case .dutch: return "Toevoegen"
        case .swedish: return "Lägg till"
        case .norwegian: return "Legg til"
        case .danish: return "Tilføj"
        case .finnish: return "Lisää"
        case .polish: return "Dodaj"
        case .czech: return "Přidat"
        case .greek: return "Προσθήκη"
        case .turkish: return "Ekle"
        case .russian: return "Добавить"
        case .indonesian: return "Tambah"
        case .thai: return "เพิ่ม"
        case .vietnamese: return "Thêm"
        }
    }

    /// 반차 · 종류 · 메모를 고르는 원래 양식으로
    public static var quickAddMoreOptions: String {
        switch quickLang {
        case .korean: return "반차 · 종류 · 메모"
        case .english: return "Half Day, Type, Note"
        case .japanese: return "半休・種類・メモ"
        case .chinese: return "半天 · 类型 · 备注"
        case .german: return "Halber Tag, Art, Notiz"
        case .french: return "Demi-journée, type, note"
        case .spanish: return "Medio día, tipo, nota"
        case .italian: return "Mezza giornata, tipo, nota"
        case .portuguese: return "Meio período, tipo, nota"
        case .chineseTraditional: return "半天 · 類型 · 備註"
        case .dutch: return "Halve dag, soort, notitie"
        case .swedish: return "Halvdag, typ, anteckning"
        case .norwegian: return "Halv dag, type, notat"
        case .danish: return "Halv dag, type, note"
        case .finnish: return "Puolikas päivä, tyyppi, muistiinpano"
        case .polish: return "Pół dnia, rodzaj, notatka"
        case .czech: return "Půlden, druh, poznámka"
        case .greek: return "Μισή ημέρα, είδος, σημείωση"
        case .turkish: return "Yarım gün, tür, not"
        case .russian: return "Полдня, вид, заметка"
        case .indonesian: return "Setengah hari, jenis, catatan"
        case .thai: return "ครึ่งวัน · ประเภท · บันทึก"
        case .vietnamese: return "Nửa ngày, loại, ghi chú"
        }
    }

    /// 하루만 고른 동안의 안내 — 끝나는 날을 누르게, 금색의 뜻
    public static var quickAddHint: String {
        switch quickLang {
        case .korean: return "끝나는 날을 누르면 기간이 돼요. 금색일수록 연차 하루로 오래 쉬어요."
        case .english: return "Tap an end date to make a range. Gold days give a longer break for one day of leave."
        case .japanese: return "終わりの日をタップすると期間になります。金色ほど1日の休暇で長く休めます。"
        case .chinese: return "点结束日期即可选成一段。越金色，请一天年假休得越久。"
        case .german: return "Tippe auf ein Enddatum für einen Zeitraum. Goldene Tage bringen mit einem Urlaubstag die längste Pause."
        case .french: return "Touchez une date de fin pour choisir une période. Les jours dorés donnent la plus longue pause pour un jour de congé."
        case .spanish: return "Toca una fecha final para elegir un periodo. Los días dorados dan el descanso más largo con un día de vacaciones."
        case .italian: return "Tocca una data di fine per scegliere un periodo. I giorni dorati danno la pausa più lunga con un giorno di ferie."
        case .portuguese: return "Toque numa data final para escolher um período. Os dias dourados rendem a pausa mais longa com um dia de folga."
        case .chineseTraditional: return "點結束日期即可選成一段。越金色，請一天特休休得越久。"
        case .dutch: return "Tik op een einddatum voor een periode. Gouden dagen geven met één verlofdag de langste pauze."
        case .swedish: return "Tryck på ett slutdatum för att välja en period. Gyllene dagar ger längst ledighet för en semesterdag."
        case .norwegian: return "Trykk på en sluttdato for å velge en periode. Gylne dager gir lengst fri for én feriedag."
        case .danish: return "Tryk på en slutdato for at vælge en periode. Gyldne dage giver længst fri for én feriedag."
        case .finnish: return "Napauta loppupäivää valitaksesi jakson. Kultaiset päivät antavat pisimmän vapaan yhdellä lomapäivällä."
        case .polish: return "Stuknij datę końcową, aby wybrać okres. Złote dni dają najdłuższy odpoczynek za jeden dzień urlopu."
        case .czech: return "Klepnutím na koncové datum vybereš období. Zlaté dny dají za jeden den dovolené nejdelší volno."
        case .greek: return "Πάτησε μια ημερομηνία λήξης για να επιλέξεις διάστημα. Οι χρυσές ημέρες δίνουν το μεγαλύτερο διάλειμμα με μία ημέρα άδειας."
        case .turkish: return "Aralık seçmek için bitiş gününe dokun. Altın günler bir günlük izinle en uzun tatili verir."
        case .russian: return "Нажмите дату окончания, чтобы выбрать период. Золотые дни дают самый долгий отдых за один день отпуска."
        case .indonesian: return "Ketuk tanggal akhir untuk memilih rentang. Hari berwarna emas memberi libur terpanjang dengan satu hari cuti."
        case .thai: return "แตะวันสิ้นสุดเพื่อเลือกช่วง วันสีทองยิ่งเข้มยิ่งได้หยุดนานด้วยวันลาวันเดียว"
        case .vietnamese: return "Chạm vào ngày kết thúc để chọn khoảng. Ngày màu vàng cho kỳ nghỉ dài nhất với một ngày phép."
        }
    }

    /// 저장한 뒤 — "6일 쉬어요"
    public static func quickAddRestDays(_ n: Int) -> String {
        switch quickLang {
        case .korean: return "\(n)일 쉬어요"
        case .english: return "\(n) days off"
        case .japanese: return "\(n)日休めます"
        case .chinese: return "休息\(n)天"
        case .german: return "\(n) Tage frei"
        case .french: return "\(n) jours de repos"
        case .spanish: return "\(n) días libres"
        case .italian: return "\(n) giorni liberi"
        case .portuguese: return "\(n) dias de descanso"
        case .chineseTraditional: return "休息\(n)天"
        case .dutch: return "\(n) dagen vrij"
        case .swedish: return "\(n) dagar ledigt"
        case .norwegian: return "\(n) dager fri"
        case .danish: return "\(n) dage fri"
        case .finnish: return "\(n) päivää vapaata"
        case .polish: return "\(n) dni wolnego"
        case .czech: return "\(n) dní volna"
        case .greek: return "\(n) ημέρες ελεύθερες"
        case .turkish: return "\(n) gün tatil"
        case .russian: return "\(n) дн. отдыха"
        case .indonesian: return "Libur \(n) hari"
        case .thai: return "หยุด \(n) วัน"
        case .vietnamese: return "Nghỉ \(n) ngày"
        }
    }

    /// 저장한 뒤 남은 연차 — "남은 연차 9일"
    public static func quickAddRemaining(_ days: Double) -> String {
        let d = dayCount(days)
        switch quickLang {
        case .korean: return "남은 연차 \(d)"
        case .english: return "\(d) left"
        case .japanese: return "残り\(d)"
        case .chinese: return "剩余\(d)"
        case .german: return "Noch \(d)"
        case .french: return "Il reste \(d)"
        case .spanish: return "Quedan \(d)"
        case .italian: return "Restano \(d)"
        case .portuguese: return "Restam \(d)"
        case .chineseTraditional: return "剩餘\(d)"
        case .dutch: return "Nog \(d)"
        case .swedish: return "\(d) kvar"
        case .norwegian: return "\(d) igjen"
        case .danish: return "\(d) tilbage"
        case .finnish: return "Jäljellä \(d)"
        case .polish: return "Zostało: \(d)"
        case .czech: return "Zbývá \(d)"
        case .greek: return "Απομένουν \(d)"
        case .turkish: return "\(d) kaldı"
        case .russian: return "Осталось \(d)"
        case .indonesian: return "Sisa \(d)"
        case .thai: return "เหลือ \(d)"
        case .vietnamese: return "Còn \(d)"
        }
    }

    // MARK: - 쌓이는 연차 (미국 사용자 피드백)

    /// 설정 — 연차 받는 방식 (한 번에 / 쌓임)
    public static var accrualSetting: String {
        switch planLang {
        case .korean: return "연차 받는 방식"
        case .english: return "How You Earn Leave"
        case .japanese: return "休暇の付与方法"
        case .chinese: return "年假发放方式"
        case .german: return "Wie du Urlaub erhältst"
        case .french: return "Mode d’acquisition des congés"
        case .spanish: return "Cómo recibes tus días"
        case .italian: return "Come maturano le ferie"
        case .portuguese: return "Como você recebe folgas"
        case .chineseTraditional: return "特休發放方式"
        case .dutch: return "Hoe je verlof krijgt"
        case .swedish: return "Hur du får semester"
        case .norwegian: return "Hvordan du får ferie"
        case .danish: return "Sådan får du ferie"
        case .finnish: return "Miten lomaa kertyy"
        case .polish: return "Sposób naliczania urlopu"
        case .czech: return "Jak získáváte dovolenou"
        case .greek: return "Πώς παίρνετε άδεια"
        case .turkish: return "İzin nasıl verilir"
        case .russian: return "Как начисляется отпуск"
        case .indonesian: return "Cara mendapat cuti"
        case .thai: return "วิธีได้รับวันลา"
        case .vietnamese: return "Cách nhận ngày phép"
        }
    }

    /// 1년치를 한 번에 받음
    public static var accrualLumpSum: String {
        switch planLang {
        case .korean: return "1년치를 한 번에"
        case .english: return "All at once each year"
        case .japanese: return "1年分をまとめて"
        case .chinese: return "每年一次性发放"
        case .german: return "Einmal pro Jahr komplett"
        case .french: return "En une fois chaque année"
        case .spanish: return "Todos a la vez cada año"
        case .italian: return "Tutte insieme ogni anno"
        case .portuguese: return "Tudo de uma vez no ano"
        case .chineseTraditional: return "每年一次給足"
        case .dutch: return "In één keer per jaar"
        case .swedish: return "Allt på en gång varje år"
        case .norwegian: return "Alt på én gang hvert år"
        case .danish: return "Alt på én gang hvert år"
        case .finnish: return "Kerralla vuoden alussa"
        case .polish: return "Całość raz w roku"
        case .czech: return "Celá najednou každý rok"
        case .greek: return "Όλη μαζί κάθε χρόνο"
        case .turkish: return "Her yıl tek seferde"
        case .russian: return "Сразу за весь год"
        case .indonesian: return "Sekaligus tiap tahun"
        case .thai: return "ได้ครั้งเดียวทั้งปี"
        case .vietnamese: return "Nhận một lần mỗi năm"
        }
    }

    /// 급여일마다 쌓이는 양
    public static var accrualAmount: String {
        switch planLang {
        case .korean: return "급여일마다 쌓이는 양"
        case .english: return "Earned per pay period"
        case .japanese: return "給料日ごとにたまる量"
        case .chinese: return "每个发薪日累积"
        case .german: return "Pro Gehaltsperiode"
        case .french: return "Acquis par période de paie"
        case .spanish: return "Por periodo de pago"
        case .italian: return "Per periodo di paga"
        case .portuguese: return "Por período de pagamento"
        case .chineseTraditional: return "每個發薪日累積"
        case .dutch: return "Per loonperiode"
        case .swedish: return "Per löneperiod"
        case .norwegian: return "Per lønnsperiode"
        case .danish: return "Pr. lønperiode"
        case .finnish: return "Palkkakautta kohden"
        case .polish: return "Na okres rozliczeniowy"
        case .czech: return "Za výplatní období"
        case .greek: return "Ανά περίοδο μισθοδοσίας"
        case .turkish: return "Her maaş döneminde"
        case .russian: return "За расчётный период"
        case .indonesian: return "Per periode gaji"
        case .thai: return "ต่อรอบเงินเดือน"
        case .vietnamese: return "Mỗi kỳ lương"
        }
    }

    /// 단위 — 일
    public static var accrualUnitDays: String {
        switch planLang {
        case .korean: return "일"
        case .english: return "days"
        case .japanese: return "日"
        case .chinese: return "天"
        case .german: return "Tage"
        case .french: return "jours"
        case .spanish: return "días"
        case .italian: return "giorni"
        case .portuguese: return "dias"
        case .chineseTraditional: return "天"
        case .dutch: return "dagen"
        case .swedish: return "dagar"
        case .norwegian: return "dager"
        case .danish: return "dage"
        case .finnish: return "päivää"
        case .polish: return "dni"
        case .czech: return "dny"
        case .greek: return "ημέρες"
        case .turkish: return "gün"
        case .russian: return "дн."
        case .indonesian: return "hari"
        case .thai: return "วัน"
        case .vietnamese: return "ngày"
        }
    }

    /// 단위 — 시간
    public static var accrualUnitHours: String {
        switch planLang {
        case .korean: return "시간"
        case .english: return "hours"
        case .japanese: return "時間"
        case .chinese: return "小时"
        case .german: return "Std."
        case .french: return "heures"
        case .spanish: return "horas"
        case .italian: return "ore"
        case .portuguese: return "horas"
        case .chineseTraditional: return "小時"
        case .dutch: return "uur"
        case .swedish: return "timmar"
        case .norwegian: return "timer"
        case .danish: return "timer"
        case .finnish: return "tuntia"
        case .polish: return "godz."
        case .czech: return "hod."
        case .greek: return "ώρες"
        case .turkish: return "saat"
        case .russian: return "ч"
        case .indonesian: return "jam"
        case .thai: return "ชั่วโมง"
        case .vietnamese: return "giờ"
        }
    }

    /// 최근 급여일 — 매주·2주마다·매달의 기준
    public static var accrualPayDay: String {
        switch planLang {
        case .korean: return "최근 급여일"
        case .english: return "A recent payday"
        case .japanese: return "直近の給料日"
        case .chinese: return "最近一次发薪日"
        case .german: return "Letzter Zahltag"
        case .french: return "Dernier jour de paie"
        case .spanish: return "Último día de pago"
        case .italian: return "Ultimo giorno di paga"
        case .portuguese: return "Último dia de pagamento"
        case .chineseTraditional: return "最近一次發薪日"
        case .dutch: return "Laatste betaaldag"
        case .swedish: return "Senaste lönedag"
        case .norwegian: return "Siste lønningsdag"
        case .danish: return "Seneste lønningsdag"
        case .finnish: return "Viimeisin palkkapäivä"
        case .polish: return "Ostatni dzień wypłaty"
        case .czech: return "Poslední výplatní den"
        case .greek: return "Τελευταία ημέρα πληρωμής"
        case .turkish: return "Son maaş günü"
        case .russian: return "Последний день зарплаты"
        case .indonesian: return "Hari gajian terakhir"
        case .thai: return "วันเงินเดือนออกล่าสุด"
        case .vietnamese: return "Ngày nhận lương gần nhất"
        }
    }

    /// 지금까지 쌓인 연차
    public static var accrualEarnedSoFar: String {
        switch planLang {
        case .korean: return "지금까지 쌓인 연차"
        case .english: return "Earned so far"
        case .japanese: return "これまでにたまった休暇"
        case .chinese: return "目前已累积"
        case .german: return "Bisher angesammelt"
        case .french: return "Acquis jusqu’ici"
        case .spanish: return "Acumulado hasta hoy"
        case .italian: return "Maturate finora"
        case .portuguese: return "Acumulado até agora"
        case .chineseTraditional: return "目前已累積"
        case .dutch: return "Tot nu toe opgebouwd"
        case .swedish: return "Intjänat hittills"
        case .norwegian: return "Opptjent hittil"
        case .danish: return "Optjent indtil nu"
        case .finnish: return "Kertynyt tähän mennessä"
        case .polish: return "Naliczone do dziś"
        case .czech: return "Dosud naspořeno"
        case .greek: return "Έχουν συσσωρευτεί"
        case .turkish: return "Şimdiye kadar biriken"
        case .russian: return "Начислено на сегодня"
        case .indonesian: return "Terkumpul sejauh ini"
        case .thai: return "สะสมถึงตอนนี้"
        case .vietnamese: return "Đã tích lũy đến nay"
        }
    }

    /// 연말까지 쌓일 연차 — 쌓임일 때 '총 연차' 자리
    public static var accrualYearTotal: String {
        switch planLang {
        case .korean: return "연말까지 쌓일 연차"
        case .english: return "By the end of the year"
        case .japanese: return "年度末までにたまる休暇"
        case .chinese: return "到年底将累积"
        case .german: return "Bis Jahresende"
        case .french: return "D’ici la fin de l’année"
        case .spanish: return "Hasta fin de año"
        case .italian: return "Entro fine anno"
        case .portuguese: return "Até o fim do ano"
        case .chineseTraditional: return "到年底將累積"
        case .dutch: return "Tot het einde van het jaar"
        case .swedish: return "Till årets slut"
        case .norwegian: return "Innen årets slutt"
        case .danish: return "Inden årets udgang"
        case .finnish: return "Vuoden loppuun mennessä"
        case .polish: return "Do końca roku"
        case .czech: return "Do konce roku"
        case .greek: return "Έως το τέλος του έτους"
        case .turkish: return "Yıl sonuna kadar"
        case .russian: return "К концу года"
        case .indonesian: return "Hingga akhir tahun"
        case .thai: return "ภายในสิ้นปี"
        case .vietnamese: return "Đến cuối năm"
        }
    }

    /// 쌓이는 연차 설명
    public static var accrualFooter: String {
        switch planLang {
        case .korean: return "회사가 급여일마다 연차를 조금씩 쌓아 준다면 고르세요. 휴가는 그날까지 쌓인 연차로 넣을 수 있고, 뒤에 잡아 둔 휴가 몫도 남겨 둡니다. 시간으로 적으면 하루 근무 시간으로 일수를 셉니다."
        case .english: return "Choose this if your employer adds leave each payday. You can book time off with what you’ll have earned by that day, and the app keeps enough for leave you’ve already planned later. Hours are converted to days using your workday length."
        case .japanese: return "給料日ごとに休暇が少しずつ付与される会社なら選んでください。休暇はその日までにたまった分で登録でき、あとに予定した休暇の分も残しておきます。時間で入力すると1日の勤務時間で日数に換算します。"
        case .chinese: return "如果公司在每个发薪日累积一点年假，请选择此项。可以用到那天为止累积的年假来安排休假，并为之后已安排的休假留出余量。按小时填写时，会按每天的工作时长换算成天数。"
        case .german: return "Wähle das, wenn dein Arbeitgeber dir mit jeder Gehaltszahlung Urlaub gutschreibt. Du kannst Urlaub mit dem eintragen, was bis zu diesem Tag angesammelt ist, und die App hält genug für später geplanten Urlaub zurück. Stunden werden über deine tägliche Arbeitszeit in Tage umgerechnet."
        case .french: return "Choisissez cette option si votre employeur crédite des congés à chaque paie. Vous pouvez poser des congés avec ce que vous aurez acquis à cette date, et l’app garde de quoi couvrir les congés déjà prévus plus tard. Les heures sont converties en jours selon la durée de votre journée de travail."
        case .spanish: return "Elígelo si tu empresa te suma días en cada pago. Puedes reservar vacaciones con lo que tendrás acumulado ese día, y la app guarda lo necesario para las que ya planeaste más adelante. Las horas se convierten en días según tu jornada laboral."
        case .italian: return "Scegli questa opzione se l’azienda ti accredita ferie a ogni busta paga. Puoi inserire le ferie con quanto avrai maturato entro quel giorno, e l’app tiene da parte quanto serve per quelle già pianificate più avanti. Le ore vengono convertite in giorni in base alla tua giornata lavorativa."
        case .portuguese: return "Escolha esta opção se a empresa acrescenta folgas a cada pagamento. Você pode marcar folgas com o que terá acumulado até aquele dia, e o app reserva o suficiente para as que já planejou depois. Horas são convertidas em dias pela sua jornada de trabalho."
        case .chineseTraditional: return "如果公司在每個發薪日累積一點特休，請選這項。可以用到那天為止累積的特休來排假，也會為之後已排好的假留下額度。用小時填寫時，會依每天的工作時數換算成天數。"
        case .dutch: return "Kies dit als je werkgever bij elke loonbetaling verlof opbouwt. Je kunt verlof boeken met wat je op die dag hebt opgebouwd, en de app houdt genoeg over voor verlof dat je later al hebt gepland. Uren worden omgerekend naar dagen op basis van je werkdag."
        case .swedish: return "Välj detta om din arbetsgivare lägger till semester vid varje löneutbetalning. Du kan boka ledigt med det du har tjänat in till den dagen, och appen sparar tillräckligt för ledighet du redan har planerat senare. Timmar räknas om till dagar utifrån din arbetsdag."
        case .norwegian: return "Velg dette hvis arbeidsgiveren legger til ferie for hver lønnsutbetaling. Du kan legge inn fri med det du har opptjent til den dagen, og appen holder av nok til fri du allerede har planlagt senere. Timer regnes om til dager ut fra arbeidsdagen din."
        case .danish: return "Vælg dette, hvis din arbejdsgiver lægger ferie til ved hver lønudbetaling. Du kan booke fri med det, du har optjent til den dag, og appen holder nok tilbage til fri, du allerede har planlagt senere. Timer regnes om til dage ud fra din arbejdsdag."
        case .finnish: return "Valitse tämä, jos työnantaja kerryttää lomaa jokaisena palkkapäivänä. Voit merkitä lomaa sillä, mitä on kertynyt siihen päivään mennessä, ja sovellus jättää riittävästi myöhemmin suunnitelluille lomille. Tunnit muutetaan päiviksi työpäiväsi pituuden mukaan."
        case .polish: return "Wybierz to, jeśli pracodawca dolicza urlop przy każdej wypłacie. Urlop możesz zaplanować z tego, co narośnie do danego dnia, a aplikacja zostawi zapas na urlopy zaplanowane później. Godziny są przeliczane na dni według długości dnia pracy."
        case .czech: return "Zvolte, pokud vám zaměstnavatel připisuje dovolenou s každou výplatou. Dovolenou můžete zadat z toho, co do daného dne naspoříte, a aplikace ponechá dost na dovolenou naplánovanou později. Hodiny se převádějí na dny podle délky pracovního dne."
        case .greek: return "Επιλέξτε το αν ο εργοδότης σας προσθέτει άδεια σε κάθε μισθοδοσία. Μπορείτε να κλείσετε άδεια με όσα θα έχετε συσσωρεύσει έως εκείνη τη μέρα, και η εφαρμογή κρατά αρκετά για άδειες που έχετε ήδη προγραμματίσει αργότερα. Οι ώρες μετατρέπονται σε ημέρες με βάση τη διάρκεια της εργάσιμης ημέρας σας."
        case .turkish: return "İşvereniniz her maaş gününde izin ekliyorsa bunu seçin. İzni o güne kadar biriken miktarla girebilirsiniz; uygulama daha sonra planladığınız izinler için de yeterince ayırır. Saatler, günlük çalışma sürenize göre güne çevrilir."
        case .russian: return "Выберите, если работодатель начисляет отпуск с каждой зарплатой. Отпуск можно запланировать из того, что накопится к этому дню, а приложение оставит запас на уже запланированный позже отпуск. Часы переводятся в дни по длительности вашего рабочего дня."
        case .indonesian: return "Pilih ini jika perusahaan menambah cuti setiap gajian. Kamu bisa mencatat cuti dengan jumlah yang sudah terkumpul sampai hari itu, dan aplikasi menyisakan cukup untuk cuti yang sudah direncanakan setelahnya. Jam diubah ke hari sesuai lama hari kerjamu."
        case .thai: return "เลือกข้อนี้ถ้าบริษัทเพิ่มวันลาให้ทุกครั้งที่จ่ายเงินเดือน คุณลงวันลาได้ตามที่สะสมถึงวันนั้น และแอปจะกันส่วนไว้สำหรับวันลาที่วางแผนไว้หลังจากนั้น ถ้ากรอกเป็นชั่วโมง จะแปลงเป็นวันตามชั่วโมงทำงานต่อวัน"
        case .vietnamese: return "Chọn mục này nếu công ty cộng phép cho bạn mỗi kỳ lương. Bạn có thể đặt lịch nghỉ bằng số phép đã tích lũy đến ngày đó, và ứng dụng sẽ chừa đủ cho những ngày nghỉ đã lên kế hoạch sau đó. Số giờ được đổi sang ngày theo thời gian làm việc mỗi ngày của bạn."
        }
    }

    /// 홈 — 쌓이는 연차: 지금 쓸 수 있는 {n} · 지금까지 쌓인 {m}
    public static func accrualHomeLine(available n: String, earned m: String) -> String {
        switch planLang {
        case .korean: return "지금 쓸 수 있는 연차 \(n) · 지금까지 \(m) 쌓임"
        case .english: return "Available now \(n) · \(m) earned so far"
        case .japanese: return "今使える休暇 \(n)・これまでに\(m)"
        case .chinese: return "现在可用 \(n) · 已累积 \(m)"
        case .german: return "Jetzt verfügbar: \(n) · bisher \(m) angesammelt"
        case .french: return "Disponible maintenant : \(n) · \(m) acquis jusqu’ici"
        case .spanish: return "Disponible ahora: \(n) · \(m) acumulados"
        case .italian: return "Disponibili ora: \(n) · \(m) maturate finora"
        case .portuguese: return "Disponível agora: \(n) · \(m) acumulados"
        case .chineseTraditional: return "現在可用 \(n) · 已累積 \(m)"
        case .dutch: return "Nu beschikbaar: \(n) · \(m) opgebouwd"
        case .swedish: return "Tillgängligt nu: \(n) · \(m) intjänat"
        case .norwegian: return "Tilgjengelig nå: \(n) · \(m) opptjent"
        case .danish: return "Til rådighed nu: \(n) · \(m) optjent"
        case .finnish: return "Käytettävissä nyt \(n) · kertynyt \(m)"
        case .polish: return "Dostępne teraz: \(n) · naliczone \(m)"
        case .czech: return "K dispozici teď: \(n) · naspořeno \(m)"
        case .greek: return "Διαθέσιμες τώρα: \(n) · συσσωρεύτηκαν \(m)"
        case .turkish: return "Şu an kullanılabilir: \(n) · biriken \(m)"
        case .russian: return "Доступно сейчас: \(n) · начислено \(m)"
        case .indonesian: return "Tersedia sekarang \(n) · terkumpul \(m)"
        case .thai: return "ใช้ได้ตอนนี้ \(n) · สะสมแล้ว \(m)"
        case .vietnamese: return "Dùng được ngay \(n) · đã tích lũy \(m)"
        }
    }

    /// 휴가 넣기 — 그날까지 쌓인 연차로 쓸 수 있는 {r}
    public static func accrualByDateNote(_ r: String) -> String {
        switch planLang {
        case .korean: return "이날까지 쌓인 연차로 \(r) 쓸 수 있어요"
        case .english: return "By this day you’ll have \(r) to use"
        case .japanese: return "この日までにたまる休暇で\(r)使えます"
        case .chinese: return "到这一天可用 \(r)"
        case .german: return "Bis zu diesem Tag stehen dir \(r) zur Verfügung"
        case .french: return "À cette date, vous aurez \(r) disponibles"
        case .spanish: return "Para ese día tendrás \(r) disponibles"
        case .italian: return "Per quel giorno avrai \(r) disponibili"
        case .portuguese: return "Até esse dia você terá \(r) disponíveis"
        case .chineseTraditional: return "到這一天可用 \(r)"
        case .dutch: return "Op die dag heb je \(r) beschikbaar"
        case .swedish: return "Den dagen har du \(r) att använda"
        case .norwegian: return "Den dagen har du \(r) å bruke"
        case .danish: return "Den dag har du \(r) til rådighed"
        case .finnish: return "Siihen päivään mennessä käytettävissä \(r)"
        case .polish: return "Do tego dnia będziesz mieć \(r)"
        case .czech: return "K tomuto dni budete mít \(r)"
        case .greek: return "Έως εκείνη τη μέρα θα έχετε \(r)"
        case .turkish: return "O güne kadar kullanabileceğin: \(r)"
        case .russian: return "К этому дню будет доступно \(r)"
        case .indonesian: return "Sampai hari itu tersedia \(r)"
        case .thai: return "ถึงวันนั้นจะใช้ได้ \(r)"
        case .vietnamese: return "Đến ngày đó bạn có \(r) để dùng"
        }
    }

    /// 올해 넘어온 연차 — 직접 적기 (비우면 자동)
    public static var carryOverManualLabel: String {
        switch planLang {
        case .korean: return "올해 넘어온 연차"
        case .english: return "Carried over this year"
        case .japanese: return "今年度に繰り越した休暇"
        case .chinese: return "今年结转的年假"
        case .german: return "In dieses Jahr übertragen"
        case .french: return "Reportés sur cette année"
        case .spanish: return "Arrastrados a este año"
        case .italian: return "Riportate quest’anno"
        case .portuguese: return "Transferidas para este ano"
        case .chineseTraditional: return "今年遞延的特休"
        case .dutch: return "Meegenomen naar dit jaar"
        case .swedish: return "Sparat till i år"
        case .norwegian: return "Overført til i år"
        case .danish: return "Overført til i år"
        case .finnish: return "Siirretty tälle vuodelle"
        case .polish: return "Przeniesione na ten rok"
        case .czech: return "Převedeno do letoška"
        case .greek: return "Μεταφέρθηκαν φέτος"
        case .turkish: return "Bu yıla devreden"
        case .russian: return "Перенесено на этот год"
        case .indonesian: return "Dibawa ke tahun ini"
        case .thai: return "ยกมาปีนี้"
        case .vietnamese: return "Chuyển sang năm nay"
        }
    }

    /// 직접 안 적었을 때 보이는 자동 계산값 — {d} 일수
    public static func carryOverManualAuto(_ d: String) -> String {
        switch planLang {
        case .korean: return "자동 \(d)"
        case .english: return "Auto \(d)"
        case .japanese: return "自動 \(d)"
        case .chinese: return "自动 \(d)"
        case .german: return "Automatisch \(d)"
        case .french: return "Auto \(d)"
        case .spanish: return "Auto \(d)"
        case .italian: return "Auto \(d)"
        case .portuguese: return "Automático \(d)"
        case .chineseTraditional: return "自動 \(d)"
        case .dutch: return "Automatisch \(d)"
        case .swedish: return "Automatiskt \(d)"
        case .norwegian: return "Automatisk \(d)"
        case .danish: return "Automatisk \(d)"
        case .finnish: return "Automaattinen \(d)"
        case .polish: return "Automatycznie \(d)"
        case .czech: return "Automaticky \(d)"
        case .greek: return "Αυτόματα \(d)"
        case .turkish: return "Otomatik \(d)"
        case .russian: return "Авто \(d)"
        case .indonesian: return "Otomatis \(d)"
        case .thai: return "อัตโนมัติ \(d)"
        case .vietnamese: return "Tự động \(d)"
        }
    }

    /// 쌓이는 주기 이름 (설정의 '연차 받는 방식' 고르기)

}

// MARK: - 휴가 넣기 화면의 '지난 휴가' — 쉬었던 날을 여러 날 한 번에 고른다

extension Strings {
    public static var quickAddModeUpcoming: String {
        pick([.korean: "앞으로 쉴 날", .english: "Upcoming", .japanese: "これからの休み", .chinese: "以后的假期",
              .german: "Geplant", .french: "À venir", .spanish: "Próximas", .italian: "In programma",
              .portuguese: "Próximas", .chineseTraditional: "之後的假期", .dutch: "Gepland", .swedish: "Kommande",
              .norwegian: "Kommende", .danish: "Kommende", .finnish: "Tulevat", .polish: "Nadchodzące",
              .czech: "Plánované", .greek: "Επερχόμενες", .turkish: "Gelecek", .russian: "Будущие",
              .indonesian: "Mendatang", .thai: "วันลาที่จะถึง", .vietnamese: "Sắp tới"])
    }

    public static var quickAddModePast: String {
        pick([.korean: "지난 휴가", .english: "Already taken", .japanese: "取った休み", .chinese: "已休的假",
              .german: "Schon genommen", .french: "Déjà pris", .spanish: "Ya tomadas", .italian: "Già prese",
              .portuguese: "Já tiradas", .chineseTraditional: "已休的假", .dutch: "Al opgenomen", .swedish: "Redan tagna",
              .norwegian: "Allerede tatt", .danish: "Allerede taget", .finnish: "Jo pidetyt", .polish: "Już wykorzystane",
              .czech: "Už vybrané", .greek: "Ήδη ληφθείσες", .turkish: "Kullanılanlar", .russian: "Уже взятые",
              .indonesian: "Sudah diambil", .thai: "ลาไปแล้ว", .vietnamese: "Đã nghỉ"])
    }

    public static var quickAddPastEmpty: String {
        pick([.korean: "쉬었던 날을 모두 눌러 주세요", .english: "Tap every day you took off",
              .japanese: "休んだ日をすべてタップしてください", .chinese: "点选所有休过假的日子",
              .german: "Tippe alle Tage an, an denen du frei hattest", .french: "Touchez chaque jour où vous étiez en congé",
              .spanish: "Toca cada día que libraste", .italian: "Tocca ogni giorno in cui eri in ferie",
              .portuguese: "Toque em cada dia de folga", .chineseTraditional: "點選所有休過假的日子",
              .dutch: "Tik op elke dag dat je vrij was", .swedish: "Tryck på varje dag du var ledig",
              .norwegian: "Trykk på hver dag du hadde fri", .danish: "Tryk på hver dag, du havde fri",
              .finnish: "Napauta jokaista vapaapäivääsi", .polish: "Stuknij każdy dzień, w którym miałeś wolne",
              .czech: "Klepni na každý den, kdy jsi měl volno", .greek: "Πάτησε κάθε μέρα που πήρες άδεια",
              .turkish: "İzin yaptığın her güne dokun", .russian: "Отметьте все дни, когда вы отдыхали",
              .indonesian: "Ketuk setiap hari kamu cuti", .thai: "แตะทุกวันที่คุณลาไปแล้ว",
              .vietnamese: "Chạm vào mọi ngày bạn đã nghỉ"])
    }

    public static func quickAddPastSummary(_ days: Int) -> String {
        pick([.korean: "지난 휴가 \(days)일", .english: days == 1 ? "1 day taken" : "\(days) days taken",
              .japanese: "取った休み\(days)日", .chinese: "已休\(days)天", .german: days == 1 ? "1 Tag genommen" : "\(days) Tage genommen",
              .french: days == 1 ? "1 jour pris" : "\(days) jours pris", .spanish: days == 1 ? "1 día tomado" : "\(days) días tomados",
              .italian: days == 1 ? "1 giorno preso" : "\(days) giorni presi", .portuguese: days == 1 ? "1 dia tirado" : "\(days) dias tirados",
              .chineseTraditional: "已休\(days)天", .dutch: days == 1 ? "1 dag opgenomen" : "\(days) dagen opgenomen",
              .swedish: days == 1 ? "1 dag tagen" : "\(days) dagar tagna", .norwegian: days == 1 ? "1 dag tatt" : "\(days) dager tatt",
              .danish: days == 1 ? "1 dag taget" : "\(days) dage taget", .finnish: "\(days) pv pidetty",
              .polish: "Wykorzystane dni: \(days)", .czech: "Vybrané dny: \(days)", .greek: "Ημέρες άδειας: \(days)",
              .turkish: "\(days) gün izin", .russian: "Взято дней: \(days)", .indonesian: "\(days) hari cuti",
              .thai: "ลาไปแล้ว \(days) วัน", .vietnamese: "Đã nghỉ \(days) ngày"])
    }

    public static var quickAddPastHint: String {
        pick([.korean: "여러 날을 한 번에 고를 수 있어요. 다른 달로 넘겨도 고른 날은 그대로 남아요. 다시 누르면 빠져요.",
              .english: "Pick as many days as you like. They stay picked when you change months. Tap again to remove one.",
              .japanese: "何日でもまとめて選べます。月を変えても選んだ日はそのまま。もう一度タップで外せます。",
              .chinese: "可以一次选多天。换到别的月份，已选的日子也会保留。再点一次即可取消。",
              .german: "Wähle beliebig viele Tage. Sie bleiben gewählt, wenn du den Monat wechselst. Nochmal tippen entfernt sie.",
              .french: "Choisissez autant de jours que vous voulez. Ils restent choisis quand vous changez de mois. Touchez à nouveau pour en retirer un.",
              .spanish: "Elige todos los días que quieras. Siguen elegidos al cambiar de mes. Toca otra vez para quitar uno.",
              .italian: "Scegli tutti i giorni che vuoi. Restano scelti anche cambiando mese. Tocca di nuovo per toglierne uno.",
              .portuguese: "Escolha quantos dias quiser. Eles continuam escolhidos ao mudar de mês. Toque de novo para tirar um.",
              .chineseTraditional: "可以一次選多天。換到別的月份，已選的日子也會保留。再點一次即可取消。",
              .dutch: "Kies zoveel dagen als je wilt. Ze blijven gekozen als je van maand wisselt. Tik nog eens om er een te verwijderen.",
              .swedish: "Välj så många dagar du vill. De ligger kvar när du byter månad. Tryck igen för att ta bort en.",
              .norwegian: "Velg så mange dager du vil. De blir stående når du bytter måned. Trykk igjen for å fjerne en.",
              .danish: "Vælg så mange dage, du vil. De bliver valgt, når du skifter måned. Tryk igen for at fjerne en.",
              .finnish: "Valitse niin monta päivää kuin haluat. Ne pysyvät valittuina, vaikka vaihdat kuukautta. Poista napauttamalla uudelleen.",
              .polish: "Wybierz dowolnie wiele dni. Zostają wybrane po zmianie miesiąca. Stuknij ponownie, aby usunąć.",
              .czech: "Vyber kolik dní chceš. Zůstanou vybrané i po změně měsíce. Dalším klepnutím den odebereš.",
              .greek: "Διάλεξε όσες μέρες θέλεις. Μένουν επιλεγμένες όταν αλλάζεις μήνα. Πάτησε ξανά για να αφαιρέσεις μία.",
              .turkish: "İstediğin kadar gün seç. Ay değiştirince de seçili kalır. Kaldırmak için tekrar dokun.",
              .russian: "Выбирайте сколько угодно дней. Они сохраняются при смене месяца. Нажмите ещё раз, чтобы убрать.",
              .indonesian: "Pilih sebanyak hari yang kamu mau. Tetap terpilih saat ganti bulan. Ketuk lagi untuk menghapus.",
              .thai: "เลือกได้หลายวันพร้อมกัน เปลี่ยนเดือนแล้ววันที่เลือกยังอยู่ แตะซ้ำเพื่อเอาออก",
              .vietnamese: "Chọn bao nhiêu ngày cũng được. Đổi tháng thì ngày đã chọn vẫn giữ nguyên. Chạm lại để bỏ."])
    }

    public static func quickAddPastSaved(_ days: Int) -> String {
        pick([.korean: "지난 휴가 \(days)일을 넣었어요", .english: days == 1 ? "Added 1 day you took off" : "Added \(days) days you took off",
              .japanese: "取った休み\(days)日を記録しました", .chinese: "已记下\(days)天休假",
              .german: days == 1 ? "1 freier Tag eingetragen" : "\(days) freie Tage eingetragen",
              .french: days == 1 ? "1 jour de congé ajouté" : "\(days) jours de congé ajoutés",
              .spanish: days == 1 ? "Se añadió 1 día libre" : "Se añadieron \(days) días libres",
              .italian: days == 1 ? "Aggiunto 1 giorno di ferie" : "Aggiunti \(days) giorni di ferie",
              .portuguese: days == 1 ? "1 dia de folga adicionado" : "\(days) dias de folga adicionados",
              .chineseTraditional: "已記下\(days)天休假", .dutch: days == 1 ? "1 vrije dag toegevoegd" : "\(days) vrije dagen toegevoegd",
              .swedish: days == 1 ? "1 ledig dag tillagd" : "\(days) lediga dagar tillagda",
              .norwegian: days == 1 ? "1 fridag lagt til" : "\(days) fridager lagt til",
              .danish: days == 1 ? "1 fridag tilføjet" : "\(days) fridage tilføjet", .finnish: "Lisätty \(days) pv vapaata",
              .polish: "Dodano dni wolnych: \(days)", .czech: "Přidané dny volna: \(days)", .greek: "Προστέθηκαν ημέρες άδειας: \(days)",
              .turkish: "\(days) gün izin eklendi", .russian: "Добавлено дней отдыха: \(days)", .indonesian: "\(days) hari cuti ditambahkan",
              .thai: "เพิ่มวันลา \(days) วันแล้ว", .vietnamese: "Đã thêm \(days) ngày nghỉ"])
    }
}
