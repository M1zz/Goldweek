//
//  Strings+LeaveCustomization.swift
//  Goldweek
//
//  시간 단위 휴가 · 휴가 종류와 색 · 여러 달 보기 문구 (이탈리아 사용자 피드백)
//

import Foundation

extension Strings {
    private static var currentLang: AppLanguage { LanguageManager.shared.currentLanguage }

    /// 시간 단위 휴가 이름 (길이 버튼)
    static var hoursLengthName: String {
        switch currentLang {
        case .korean: return "시간 단위"
        case .english: return "By hours"
        case .japanese: return "時間単位"
        case .chinese: return "按小时"
        case .german: return "Stunden"
        case .french: return "En heures"
        case .spanish: return "Por horas"
        case .italian: return "A ore"
        case .portuguese: return "Por horas"
        case .chineseTraditional: return "按小時"
        case .dutch: return "Uren"
        case .swedish: return "Timmar"
        case .norwegian: return "Timer"
        case .danish: return "Timer"
        case .finnish: return "Tunnit"
        case .polish: return "Godziny"
        case .czech: return "Hodiny"
        case .greek: return "Ώρες"
        case .turkish: return "Saatlik"
        case .russian: return "По часам"
        case .indonesian: return "Per jam"
        }
    }

    /// 길이 버튼 아래 작은 글씨
    static var hoursLengthHint: String {
        switch currentLang {
        case .korean: return "시·분"
        case .english: return "h · min"
        case .japanese: return "時間・分"
        case .chinese: return "时·分"
        case .german: return "Std. · Min."
        case .french: return "h · min"
        case .spanish: return "h · min"
        case .italian: return "ore · min"
        case .portuguese: return "h · min"
        case .chineseTraditional: return "時·分"
        case .dutch: return "u · min"
        case .swedish: return "tim · min"
        case .norwegian: return "t · min"
        case .danish: return "t · min"
        case .finnish: return "h · min"
        case .polish: return "godz. · min"
        case .czech: return "h · min"
        case .greek: return "ώρ. · λεπ."
        case .turkish: return "sa · dk"
        case .russian: return "ч · мин"
        case .indonesian: return "jam · mnt"
        }
    }

    /// 시간 단위 휴가 — 시간 스테퍼
    static var leaveHoursLabel: String {
        switch currentLang {
        case .korean: return "시간"
        case .english: return "Hours"
        case .japanese: return "時間"
        case .chinese: return "小时"
        case .german: return "Stunden"
        case .french: return "Heures"
        case .spanish: return "Horas"
        case .italian: return "Ore"
        case .portuguese: return "Horas"
        case .chineseTraditional: return "小時"
        case .dutch: return "Uren"
        case .swedish: return "Timmar"
        case .norwegian: return "Timer"
        case .danish: return "Timer"
        case .finnish: return "Tunnit"
        case .polish: return "Godziny"
        case .czech: return "Hodiny"
        case .greek: return "Ώρες"
        case .turkish: return "Saat"
        case .russian: return "Часы"
        case .indonesian: return "Jam"
        }
    }

    /// 시간 단위 휴가 — 분 스테퍼
    static var leaveMinutesLabel: String {
        switch currentLang {
        case .korean: return "분"
        case .english: return "Minutes"
        case .japanese: return "分"
        case .chinese: return "分钟"
        case .german: return "Minuten"
        case .french: return "Minutes"
        case .spanish: return "Minutos"
        case .italian: return "Minuti"
        case .portuguese: return "Minutos"
        case .chineseTraditional: return "分鐘"
        case .dutch: return "Minuten"
        case .swedish: return "Minuter"
        case .norwegian: return "Minutter"
        case .danish: return "Minutter"
        case .finnish: return "Minuutit"
        case .polish: return "Minuty"
        case .czech: return "Minuty"
        case .greek: return "Λεπτά"
        case .turkish: return "Dakika"
        case .russian: return "Минуты"
        case .indonesian: return "Menit"
        }
    }

    /// 시간 단위 휴가 설명 — {days} 하루 근무 시간
    static func hoursLeaveFooter(workday w: String) -> String {
        switch currentLang {
        case .korean: return "하루 근무 시간(\(w))을 기준으로 일수로 바꿔 연차에서 빼요. 근무 시간은 설정에서 바꿀 수 있어요."
        case .english: return "Converted to days using your \(w) workday and taken from your leave. You can change the workday length in Settings."
        case .japanese: return "1日の勤務時間（\(w)）で日数に換算して休暇から差し引きます。勤務時間は設定で変えられます。"
        case .chinese: return "按每天工作时长（\(w)）换算成天数，从年假中扣除。工作时长可以在设置中修改。"
        case .german: return "Wird mit deinem Arbeitstag (\(w)) in Tage umgerechnet und vom Urlaub abgezogen. Die Länge des Arbeitstags kannst du in den Einstellungen ändern."
        case .french: return "Converti en jours selon votre journée de travail (\(w)) et déduit de vos congés. Vous pouvez changer la durée de la journée dans les Réglages."
        case .spanish: return "Se convierte en días según tu jornada (\(w)) y se descuenta de tus vacaciones. Puedes cambiar la jornada en Ajustes."
        case .italian: return "Viene convertito in giorni in base alla tua giornata lavorativa (\(w)) e scalato dalle ferie. Puoi cambiare la durata della giornata nelle Impostazioni."
        case .portuguese: return "Convertido em dias pela sua jornada (\(w)) e descontado das suas folgas. Você pode mudar a jornada nos Ajustes."
        case .chineseTraditional: return "依每天工作時數（\(w)）換算成天數，從特休中扣除。工作時數可以在設定中修改。"
        case .dutch: return "Wordt omgerekend naar dagen met je werkdag (\(w)) en van je verlof afgetrokken. De lengte van je werkdag pas je aan in Instellingen."
        case .swedish: return "Räknas om till dagar utifrån din arbetsdag (\(w)) och dras från din semester. Du kan ändra arbetsdagens längd i Inställningar."
        case .norwegian: return "Regnes om til dager ut fra arbeidsdagen din (\(w)) og trekkes fra ferien. Du kan endre lengden på arbeidsdagen i Innstillinger."
        case .danish: return "Omregnes til dage ud fra din arbejdsdag (\(w)) og trækkes fra din ferie. Du kan ændre arbejdsdagens længde i Indstillinger."
        case .finnish: return "Muunnetaan päiviksi työpäiväsi (\(w)) mukaan ja vähennetään lomasta. Työpäivän pituuden voit muuttaa asetuksista."
        case .polish: return "Przeliczane na dni według Twojego dnia pracy (\(w)) i odejmowane od urlopu. Długość dnia pracy zmienisz w Ustawieniach."
        case .czech: return "Přepočítá se na dny podle tvého pracovního dne (\(w)) a odečte se z dovolené. Délku pracovního dne změníš v Nastavení."
        case .greek: return "Μετατρέπεται σε ημέρες με βάση την εργάσιμη μέρα σου (\(w)) και αφαιρείται από την άδεια. Τη διάρκεια της εργάσιμης μέρας την αλλάζεις στις Ρυθμίσεις."
        case .turkish: return "Günlük çalışma sürene (\(w)) göre güne çevrilir ve izninden düşülür. Çalışma süresini Ayarlar'dan değiştirebilirsin."
        case .russian: return "Переводится в дни по вашему рабочему дню (\(w)) и вычитается из отпуска. Длину рабочего дня можно изменить в настройках."
        case .indonesian: return "Diubah ke hari berdasarkan jam kerjamu (\(w)) dan dipotong dari cuti. Lama jam kerja bisa diubah di Pengaturan."
        }
    }

    /// 설정 — 하루 근무 시간
    static var workdayLengthSetting: String {
        switch currentLang {
        case .korean: return "하루 근무 시간"
        case .english: return "Workday Length"
        case .japanese: return "1日の勤務時間"
        case .chinese: return "每天工作时长"
        case .german: return "Länge des Arbeitstags"
        case .french: return "Durée de la journée"
        case .spanish: return "Duración de la jornada"
        case .italian: return "Durata della giornata"
        case .portuguese: return "Duração da jornada"
        case .chineseTraditional: return "每天工作時數"
        case .dutch: return "Lengte werkdag"
        case .swedish: return "Arbetsdagens längd"
        case .norwegian: return "Lengde på arbeidsdag"
        case .danish: return "Arbejdsdagens længde"
        case .finnish: return "Työpäivän pituus"
        case .polish: return "Długość dnia pracy"
        case .czech: return "Délka pracovního dne"
        case .greek: return "Διάρκεια εργάσιμης"
        case .turkish: return "Günlük çalışma süresi"
        case .russian: return "Длина рабочего дня"
        case .indonesian: return "Lama jam kerja"
        }
    }

    /// 설정·화면 제목 — 휴가 종류와 색
    static var leaveKindsTitle: String {
        switch currentLang {
        case .korean: return "휴가 종류와 색"
        case .english: return "Leave Types & Colors"
        case .japanese: return "休暇の種類と色"
        case .chinese: return "假期类型与颜色"
        case .german: return "Urlaubsarten & Farben"
        case .french: return "Types de congé et couleurs"
        case .spanish: return "Tipos de permiso y colores"
        case .italian: return "Tipi di permesso e colori"
        case .portuguese: return "Tipos de folga e cores"
        case .chineseTraditional: return "假別與顏色"
        case .dutch: return "Verloftypen en kleuren"
        case .swedish: return "Ledighetstyper och färger"
        case .norwegian: return "Fraværstyper og farger"
        case .danish: return "Fraværstyper og farver"
        case .finnish: return "Vapaatyypit ja värit"
        case .polish: return "Rodzaje urlopu i kolory"
        case .czech: return "Typy volna a barvy"
        case .greek: return "Τύποι άδειας και χρώματα"
        case .turkish: return "İzin türleri ve renkler"
        case .russian: return "Виды отпуска и цвета"
        case .indonesian: return "Jenis cuti dan warna"
        }
    }

    /// 휴가 종류 화면 설명
    static var leaveKindsFooter: String {
        switch currentLang {
        case .korean: return "종류마다 색을 정하면 달력에서 그 색으로 보여요. 회사에서 쓰는 휴가 이름이 따로 있으면 새 종류로 만들어 쓰세요."
        case .english: return "Each type shows in its own color on the calendar. If your company uses its own leave names, create them as new types."
        case .japanese: return "種類ごとに色を決めると、カレンダーにその色で表示されます。会社独自の休暇名があれば、新しい種類として作れます。"
        case .chinese: return "为每种类型设定颜色后，日历会用该颜色显示。如果公司有自己的假期名称，可以新建类型来使用。"
        case .german: return "Jede Art erscheint im Kalender in ihrer Farbe. Hat deine Firma eigene Bezeichnungen, lege sie als neue Arten an."
        case .french: return "Chaque type apparaît dans sa couleur sur le calendrier. Si votre entreprise utilise ses propres noms de congé, créez-les comme nouveaux types."
        case .spanish: return "Cada tipo aparece con su color en el calendario. Si tu empresa usa sus propios nombres de permiso, créalos como tipos nuevos."
        case .italian: return "Ogni tipo appare nel calendario con il suo colore. Se la tua azienda usa nomi propri (ROL, ex festività…), creali come nuovi tipi."
        case .portuguese: return "Cada tipo aparece com sua cor no calendário. Se sua empresa usa nomes próprios de folga, crie-os como novos tipos."
        case .chineseTraditional: return "每種假別設定顏色後，行事曆會以該顏色顯示。如果公司有自己的假別名稱，可以新增假別來使用。"
        case .dutch: return "Elk type verschijnt in zijn eigen kleur in de kalender. Gebruikt je bedrijf eigen namen voor verlof, maak die dan aan als nieuwe types."
        case .swedish: return "Varje typ visas i sin egen färg i kalendern. Har ditt företag egna namn på ledighet kan du skapa dem som nya typer."
        case .norwegian: return "Hver type vises i sin egen farge i kalenderen. Bruker firmaet ditt egne navn på fravær, kan du lage dem som nye typer."
        case .danish: return "Hver type vises i sin egen farve i kalenderen. Bruger din virksomhed egne navne for fravær, kan du oprette dem som nye typer."
        case .finnish: return "Jokainen tyyppi näkyy kalenterissa omalla värillään. Jos yritykselläsi on omia nimiä vapaille, luo ne uusiksi tyypeiksi."
        case .polish: return "Każdy rodzaj ma w kalendarzu swój kolor. Jeśli firma używa własnych nazw urlopów, utwórz je jako nowe rodzaje."
        case .czech: return "Každý typ se v kalendáři zobrazí svou barvou. Pokud tvoje firma používá vlastní názvy volna, vytvoř je jako nové typy."
        case .greek: return "Κάθε τύπος εμφανίζεται στο ημερολόγιο με το δικό του χρώμα. Αν η εταιρεία σου έχει δικά της ονόματα αδειών, φτιάξ' τα ως νέους τύπους."
        case .turkish: return "Her tür takvimde kendi rengiyle görünür. Şirketin kendi izin adlarını kullanıyorsa bunları yeni tür olarak oluştur."
        case .russian: return "Каждый вид отображается в календаре своим цветом. Если в вашей компании свои названия отпусков, создайте их как новые виды."
        case .indonesian: return "Setiap jenis tampil di kalender dengan warnanya sendiri. Jika perusahaanmu punya nama cuti sendiri, buat sebagai jenis baru."
        }
    }

    /// 휴가 종류 화면 — 기본 종류 섹션
    static var builtInLeaveKinds: String {
        switch currentLang {
        case .korean: return "기본 종류"
        case .english: return "Built-in Types"
        case .japanese: return "標準の種類"
        case .chinese: return "默认类型"
        case .german: return "Standardarten"
        case .french: return "Types par défaut"
        case .spanish: return "Tipos predeterminados"
        case .italian: return "Tipi predefiniti"
        case .portuguese: return "Tipos padrão"
        case .chineseTraditional: return "預設假別"
        case .dutch: return "Standaardtypes"
        case .swedish: return "Standardtyper"
        case .norwegian: return "Standardtyper"
        case .danish: return "Standardtyper"
        case .finnish: return "Vakiotyypit"
        case .polish: return "Rodzaje domyślne"
        case .czech: return "Výchozí typy"
        case .greek: return "Προεπιλεγμένοι τύποι"
        case .turkish: return "Varsayılan türler"
        case .russian: return "Стандартные виды"
        case .indonesian: return "Jenis bawaan"
        }
    }

    /// 휴가 종류 화면 — 직접 만든 종류 섹션
    static var myLeaveKinds: String {
        switch currentLang {
        case .korean: return "내가 만든 종류"
        case .english: return "My Types"
        case .japanese: return "自分で作った種類"
        case .chinese: return "我创建的类型"
        case .german: return "Eigene Arten"
        case .french: return "Mes types"
        case .spanish: return "Mis tipos"
        case .italian: return "I miei tipi"
        case .portuguese: return "Meus tipos"
        case .chineseTraditional: return "我建立的假別"
        case .dutch: return "Mijn types"
        case .swedish: return "Mina typer"
        case .norwegian: return "Mine typer"
        case .danish: return "Mine typer"
        case .finnish: return "Omat tyypit"
        case .polish: return "Moje rodzaje"
        case .czech: return "Moje typy"
        case .greek: return "Οι τύποι μου"
        case .turkish: return "Türlerim"
        case .russian: return "Мои виды"
        case .indonesian: return "Jenis buatanku"
        }
    }

    /// 새 휴가 종류 버튼
    static var addLeaveKind: String {
        switch currentLang {
        case .korean: return "새 종류 만들기"
        case .english: return "New Type"
        case .japanese: return "新しい種類を作る"
        case .chinese: return "新建类型"
        case .german: return "Neue Art"
        case .french: return "Nouveau type"
        case .spanish: return "Nuevo tipo"
        case .italian: return "Nuovo tipo"
        case .portuguese: return "Novo tipo"
        case .chineseTraditional: return "新增假別"
        case .dutch: return "Nieuw type"
        case .swedish: return "Ny typ"
        case .norwegian: return "Ny type"
        case .danish: return "Ny type"
        case .finnish: return "Uusi tyyppi"
        case .polish: return "Nowy rodzaj"
        case .czech: return "Nový typ"
        case .greek: return "Νέος τύπος"
        case .turkish: return "Yeni tür"
        case .russian: return "Новый вид"
        case .indonesian: return "Jenis baru"
        }
    }

    /// 새 휴가 종류 — 이름 칸
    static var leaveKindName: String {
        switch currentLang {
        case .korean: return "이름"
        case .english: return "Name"
        case .japanese: return "名前"
        case .chinese: return "名称"
        case .german: return "Name"
        case .french: return "Nom"
        case .spanish: return "Nombre"
        case .italian: return "Nome"
        case .portuguese: return "Nome"
        case .chineseTraditional: return "名稱"
        case .dutch: return "Naam"
        case .swedish: return "Namn"
        case .norwegian: return "Navn"
        case .danish: return "Navn"
        case .finnish: return "Nimi"
        case .polish: return "Nazwa"
        case .czech: return "Název"
        case .greek: return "Όνομα"
        case .turkish: return "Ad"
        case .russian: return "Название"
        case .indonesian: return "Nama"
        }
    }

    /// 새 휴가 종류 — 색
    static var leaveKindColor: String {
        switch currentLang {
        case .korean: return "색"
        case .english: return "Color"
        case .japanese: return "色"
        case .chinese: return "颜色"
        case .german: return "Farbe"
        case .french: return "Couleur"
        case .spanish: return "Color"
        case .italian: return "Colore"
        case .portuguese: return "Cor"
        case .chineseTraditional: return "顏色"
        case .dutch: return "Kleur"
        case .swedish: return "Färg"
        case .norwegian: return "Farge"
        case .danish: return "Farve"
        case .finnish: return "Väri"
        case .polish: return "Kolor"
        case .czech: return "Barva"
        case .greek: return "Χρώμα"
        case .turkish: return "Renk"
        case .russian: return "Цвет"
        case .indonesian: return "Warna"
        }
    }

    /// 새 휴가 종류 — 연차 차감
    static var leaveKindDeducts: String {
        switch currentLang {
        case .korean: return "연차에서 빼기"
        case .english: return "Counts against annual leave"
        case .japanese: return "有給休暇から引く"
        case .chinese: return "从年假中扣除"
        case .german: return "Vom Jahresurlaub abziehen"
        case .french: return "Déduire des congés annuels"
        case .spanish: return "Descontar de las vacaciones"
        case .italian: return "Scala dalle ferie"
        case .portuguese: return "Descontar das férias"
        case .chineseTraditional: return "從特休扣除"
        case .dutch: return "Van jaarverlof aftrekken"
        case .swedish: return "Dra från semestern"
        case .norwegian: return "Trekk fra ferien"
        case .danish: return "Træk fra ferien"
        case .finnish: return "Vähennä vuosilomasta"
        case .polish: return "Odejmij od urlopu"
        case .czech: return "Odečíst z dovolené"
        case .greek: return "Αφαίρεση από την ετήσια άδεια"
        case .turkish: return "Yıllık izinden düş"
        case .russian: return "Вычитать из отпуска"
        case .indonesian: return "Potong dari cuti tahunan"
        }
    }

    /// 기본 종류 색 되돌리기
    static var resetLeaveColor: String {
        switch currentLang {
        case .korean: return "기본 색으로"
        case .english: return "Reset Color"
        case .japanese: return "標準の色に戻す"
        case .chinese: return "恢复默认颜色"
        case .german: return "Farbe zurücksetzen"
        case .french: return "Couleur par défaut"
        case .spanish: return "Restablecer color"
        case .italian: return "Colore predefinito"
        case .portuguese: return "Cor padrão"
        case .chineseTraditional: return "恢復預設顏色"
        case .dutch: return "Kleur herstellen"
        case .swedish: return "Återställ färg"
        case .norwegian: return "Tilbakestill farge"
        case .danish: return "Nulstil farve"
        case .finnish: return "Palauta väri"
        case .polish: return "Przywróć kolor"
        case .czech: return "Obnovit barvu"
        case .greek: return "Επαναφορά χρώματος"
        case .turkish: return "Rengi sıfırla"
        case .russian: return "Сбросить цвет"
        case .indonesian: return "Atur ulang warna"
        }
    }

    /// 달력 보기 범위 (접근성 라벨)
    static var calendarSpanLabel: String {
        switch currentLang {
        case .korean: return "달력 보기 범위"
        case .english: return "Calendar Range"
        case .japanese: return "カレンダーの表示範囲"
        case .chinese: return "日历显示范围"
        case .german: return "Kalenderzeitraum"
        case .french: return "Période affichée"
        case .spanish: return "Periodo del calendario"
        case .italian: return "Periodo del calendario"
        case .portuguese: return "Período do calendário"
        case .chineseTraditional: return "行事曆顯示範圍"
        case .dutch: return "Kalenderperiode"
        case .swedish: return "Kalenderperiod"
        case .norwegian: return "Kalenderperiode"
        case .danish: return "Kalenderperiode"
        case .finnish: return "Kalenterin jakso"
        case .polish: return "Zakres kalendarza"
        case .czech: return "Rozsah kalendáře"
        case .greek: return "Εύρος ημερολογίου"
        case .turkish: return "Takvim aralığı"
        case .russian: return "Период календаря"
        case .indonesian: return "Rentang kalender"
        }
    }

    /// 여러 달 보기 — 달을 누르면 그 달로
    static var calendarOverviewHint: String {
        switch currentLang {
        case .korean: return "달을 누르면 그 달을 자세히 볼 수 있어요"
        case .english: return "Tap a month to see it in detail"
        case .japanese: return "月をタップすると詳しく見られます"
        case .chinese: return "点按月份可查看详情"
        case .german: return "Tippe auf einen Monat für die Details"
        case .french: return "Touchez un mois pour le voir en détail"
        case .spanish: return "Toca un mes para verlo en detalle"
        case .italian: return "Tocca un mese per vederlo nel dettaglio"
        case .portuguese: return "Toque em um mês para ver os detalhes"
        case .chineseTraditional: return "點一下月份即可查看詳情"
        case .dutch: return "Tik op een maand voor de details"
        case .swedish: return "Tryck på en månad för att se detaljer"
        case .norwegian: return "Trykk på en måned for å se detaljer"
        case .danish: return "Tryk på en måned for at se detaljer"
        case .finnish: return "Napauta kuukautta nähdäksesi tiedot"
        case .polish: return "Stuknij miesiąc, aby zobaczyć szczegóły"
        case .czech: return "Klepnutím na měsíc zobrazíš podrobnosti"
        case .greek: return "Πάτησε έναν μήνα για λεπτομέρειες"
        case .turkish: return "Ayrıntılar için bir aya dokun"
        case .russian: return "Нажмите на месяц, чтобы открыть его"
        case .indonesian: return "Ketuk bulan untuk melihat detailnya"
        }
    }

    /// 직접 만든 종류 삭제 설명 — 기록은 남는다
    static var deleteLeaveKindNote: String {
        switch currentLang {
        case .korean: return "이 종류로 등록한 휴가는 지워지지 않고 기본 종류로 보여요."
        case .english: return "Leave you added with this type stays, shown under its built-in type."
        case .japanese: return "この種類で登録した休暇は消えず、標準の種類で表示されます。"
        case .chinese: return "用此类型登记的假期不会删除，会显示为默认类型。"
        case .german: return "Damit eingetragener Urlaub bleibt erhalten und erscheint unter der Standardart."
        case .french: return "Les congés enregistrés avec ce type restent et s’affichent sous le type par défaut."
        case .spanish: return "Los permisos registrados con este tipo se mantienen y se muestran con el tipo predeterminado."
        case .italian: return "I permessi registrati con questo tipo restano e vengono mostrati con il tipo predefinito."
        case .portuguese: return "As folgas registradas com este tipo continuam e aparecem com o tipo padrão."
        case .chineseTraditional: return "用此假別登記的假不會刪除，會顯示為預設假別。"
        case .dutch: return "Verlof met dit type blijft staan en wordt getoond onder het standaardtype."
        case .swedish: return "Ledighet du lagt till med den här typen finns kvar och visas under standardtypen."
        case .norwegian: return "Fravær du har lagt inn med denne typen blir værende og vises under standardtypen."
        case .danish: return "Fravær med denne type bliver liggende og vises under standardtypen."
        case .finnish: return "Tällä tyypillä lisätyt vapaat säilyvät ja näkyvät vakiotyyppinä."
        case .polish: return "Urlopy dodane z tym rodzajem zostaną i będą widoczne jako rodzaj domyślny."
        case .czech: return "Volno zadané s tímto typem zůstane a zobrazí se pod výchozím typem."
        case .greek: return "Οι άδειες με αυτόν τον τύπο μένουν και εμφανίζονται με τον προεπιλεγμένο τύπο."
        case .turkish: return "Bu türle eklenen izinler silinmez, varsayılan türle görünür."
        case .russian: return "Отпуска этого вида останутся и будут показаны как стандартный вид."
        case .indonesian: return "Cuti dengan jenis ini tetap ada dan tampil sebagai jenis bawaan."
        }
    }

    /// "2시간 30분" · "2 h 30 min" — 앱 언어 기준
    static func durationText(minutes: Int) -> String {
        let f = DateComponentsFormatter()
        f.allowedUnits = minutes >= 60 ? [.hour, .minute] : [.minute]
        f.unitsStyle = .abbreviated
        f.zeroFormattingBehavior = .dropAll
        var cal = Calendar.current
        cal.locale = Locale(identifier: localeIdentifier)
        f.calendar = cal
        return f.string(from: TimeInterval(max(0, minutes) * 60)) ?? "\(minutes)"
    }

    /// 달력 보기 범위 이름 — "1개월" · "6 mo" · "1 yr" (앱 언어 기준)
    static func calendarSpanName(months: Int) -> String {
        let f = DateComponentsFormatter()
        f.allowedUnits = months >= 12 ? [.year] : [.month]
        f.unitsStyle = .short
        var cal = Calendar.current
        cal.locale = Locale(identifier: localeIdentifier)
        f.calendar = cal
        return f.string(from: DateComponents(year: months >= 12 ? months / 12 : nil, month: months >= 12 ? nil : months)) ?? "\(months)"
    }
}

// MARK: - 종류별 합계 · 연간 한도 · 요일별 근무 시간 · 종류 순서 (이탈리아 피드백 2차)

extension Strings {
    /// 종류별 합계 — 휴가 종류마다 쓴 날·시간 (이탈리아 피드백)
    static var statsByKindTitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "종류별 합계"
        case .english: return "Totals by leave kind"
        case .japanese: return "種類別の合計"
        case .chinese: return "按类型统计"
        case .german: return "Summe nach Art"
        case .french: return "Totaux par type"
        case .spanish: return "Totales por tipo"
        case .italian: return "Totale per tipo di permesso"
        case .portuguese: return "Totais por tipo"
        case .chineseTraditional: return "按類型統計"
        case .dutch: return "Totalen per soort"
        case .swedish: return "Summa per typ"
        case .norwegian: return "Sum per type"
        case .danish: return "Sum pr. type"
        case .finnish: return "Yhteensä tyypeittäin"
        case .polish: return "Suma według rodzaju"
        case .czech: return "Součet podle druhu"
        case .greek: return "Σύνολα ανά είδος"
        case .turkish: return "Türe göre toplam"
        case .russian: return "Итоги по видам"
        case .indonesian: return "Total per jenis"
        }
    }

    /// 종류별 합계 아래 설명
    static var statsByKindFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "끝난 예정 휴가는 사용으로 셉니다. 종일·반차는 그 요일 근무 시간으로 바꿔 시간을 셉니다."
        case .english: return "Planned leave that has passed counts as used. Full and half days are converted to hours using that weekday's work hours."
        case .japanese: return "終わった予定の休暇は使用済みとして数えます。終日・半休はその曜日の勤務時間で時間に換算します。"
        case .chinese: return "已结束的计划假期算作已使用。全天和半天按当天的工作时长换算成小时。"
        case .german: return "Vergangener geplanter Urlaub zählt als genommen. Ganze und halbe Tage werden mit der Arbeitszeit des Wochentags in Stunden umgerechnet."
        case .french: return "Les congés prévus déjà passés comptent comme utilisés. Les journées et demi-journées sont converties en heures selon l'horaire de ce jour."
        case .spanish: return "Las ausencias previstas ya pasadas cuentan como usadas. Los días completos y medios se convierten en horas según el horario de ese día."
        case .italian: return "I permessi previsti già passati contano come usati. Giornate intere e mezze giornate sono convertite in ore secondo l'orario di quel giorno."
        case .portuguese: return "Folgas previstas que já passaram contam como usadas. Dias inteiros e meios dias são convertidos em horas pelo horário daquele dia."
        case .chineseTraditional: return "已結束的計畫假期算作已使用。全天和半天按當天的工作時數換算成小時。"
        case .dutch: return "Gepland verlof dat voorbij is telt als gebruikt. Hele en halve dagen worden omgerekend naar uren met de werktijd van die weekdag."
        case .swedish: return "Planerad ledighet som har passerat räknas som använd. Hela och halva dagar räknas om till timmar med den veckodagens arbetstid."
        case .norwegian: return "Planlagt fri som er passert regnes som brukt. Hele og halve dager regnes om til timer med arbeidstiden for den ukedagen."
        case .danish: return "Planlagt fri, der er overstået, tæller som brugt. Hele og halve dage omregnes til timer med arbejdstiden for den ugedag."
        case .finnish: return "Mennyt suunniteltu vapaa lasketaan käytetyksi. Kokonaiset ja puolikkaat päivät muutetaan tunneiksi kyseisen viikonpäivän työajalla."
        case .polish: return "Zaplanowany urlop, który minął, liczy się jako wykorzystany. Całe i pół dnia są przeliczane na godziny według czasu pracy w dany dzień tygodnia."
        case .czech: return "Plánované volno, které už proběhlo, se počítá jako využité. Celé a půl dny se převádějí na hodiny podle pracovní doby daného dne."
        case .greek: return "Οι προγραμματισμένες άδειες που πέρασαν μετρούν ως χρησιμοποιημένες. Οι ολόκληρες και μισές ημέρες μετατρέπονται σε ώρες με το ωράριο εκείνης της ημέρας."
        case .turkish: return "Geçmiş planlı izinler kullanılmış sayılır. Tam ve yarım günler o günün çalışma saatine göre saate çevrilir."
        case .russian: return "Прошедший запланированный отпуск считается использованным. Полные и половинные дни переводятся в часы по рабочему времени этого дня недели."
        case .indonesian: return "Cuti terencana yang sudah lewat dihitung terpakai. Hari penuh dan setengah hari dihitung ke jam menurut jam kerja hari itu."
        }
    }

    /// 연간 한도 섹션 제목 (monte ore)
    static var allowanceSection: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "연간 한도"
        case .english: return "Yearly allowance"
        case .japanese: return "年間の上限"
        case .chinese: return "年度额度"
        case .german: return "Jahreskontingent"
        case .french: return "Quota annuel"
        case .spanish: return "Cupo anual"
        case .italian: return "Monte annuo"
        case .portuguese: return "Cota anual"
        case .chineseTraditional: return "年度額度"
        case .dutch: return "Jaartegoed"
        case .swedish: return "Årlig kvot"
        case .norwegian: return "Årlig kvote"
        case .danish: return "Årlig kvote"
        case .finnish: return "Vuosikiintiö"
        case .polish: return "Roczny limit"
        case .czech: return "Roční nárok"
        case .greek: return "Ετήσιο όριο"
        case .turkish: return "Yıllık hak"
        case .russian: return "Годовой лимит"
        case .indonesian: return "Jatah tahunan"
        }
    }

    /// 연간 한도 켜기
    static var allowanceToggle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "한도 정하기"
        case .english: return "Set a yearly allowance"
        case .japanese: return "上限を決める"
        case .chinese: return "设置年度额度"
        case .german: return "Kontingent festlegen"
        case .french: return "Définir un quota"
        case .spanish: return "Definir un cupo"
        case .italian: return "Imposta un monte annuo"
        case .portuguese: return "Definir uma cota"
        case .chineseTraditional: return "設定年度額度"
        case .dutch: return "Tegoed instellen"
        case .swedish: return "Ange kvot"
        case .norwegian: return "Angi kvote"
        case .danish: return "Angiv kvote"
        case .finnish: return "Aseta kiintiö"
        case .polish: return "Ustaw limit"
        case .czech: return "Nastavit nárok"
        case .greek: return "Ορισμός ορίου"
        case .turkish: return "Hak belirle"
        case .russian: return "Задать лимит"
        case .indonesian: return "Atur jatah"
        }
    }

    /// 한도 단위 — 일
    static var allowanceUnitDays: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "일"
        case .english: return "Days"
        case .japanese: return "日"
        case .chinese: return "天"
        case .german: return "Tage"
        case .french: return "Jours"
        case .spanish: return "Días"
        case .italian: return "Giorni"
        case .portuguese: return "Dias"
        case .chineseTraditional: return "天"
        case .dutch: return "Dagen"
        case .swedish: return "Dagar"
        case .norwegian: return "Dager"
        case .danish: return "Dage"
        case .finnish: return "Päivät"
        case .polish: return "Dni"
        case .czech: return "Dny"
        case .greek: return "Ημέρες"
        case .turkish: return "Gün"
        case .russian: return "Дни"
        case .indonesian: return "Hari"
        }
    }

    /// 한도 단위 피커 제목
    static var allowanceUnitLabel: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "단위"
        case .english: return "Unit"
        case .japanese: return "単位"
        case .chinese: return "单位"
        case .german: return "Einheit"
        case .french: return "Unité"
        case .spanish: return "Unidad"
        case .italian: return "Unità"
        case .portuguese: return "Unidade"
        case .chineseTraditional: return "單位"
        case .dutch: return "Eenheid"
        case .swedish: return "Enhet"
        case .norwegian: return "Enhet"
        case .danish: return "Enhed"
        case .finnish: return "Yksikkö"
        case .polish: return "Jednostka"
        case .czech: return "Jednotka"
        case .greek: return "Μονάδα"
        case .turkish: return "Birim"
        case .russian: return "Единица"
        case .indonesian: return "Satuan"
        }
    }

    /// 연간 한도 설명
    static var allowanceFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "해마다 연차 기준월부터 새로 셉니다. 종일·반차로 쓴 날은 그 요일 근무 시간으로 바꿔 뺍니다."
        case .english: return "Resets every year from your leave year start month. Full and half days are subtracted using that weekday's work hours."
        case .japanese: return "毎年、年休の基準月から数え直します。終日・半休はその曜日の勤務時間で差し引きます。"
        case .chinese: return "每年从年假起始月重新计算。全天和半天按当天的工作时长扣除。"
        case .german: return "Beginnt jedes Jahr ab dem Startmonat deines Urlaubsjahres neu. Ganze und halbe Tage werden mit der Arbeitszeit des Wochentags abgezogen."
        case .french: return "Repart à zéro chaque année au mois de début de votre année de congés. Les journées et demi-journées sont déduites selon l'horaire de ce jour."
        case .spanish: return "Se reinicia cada año desde el mes de inicio de tu año de vacaciones. Los días completos y medios se descuentan según el horario de ese día."
        case .italian: return "Riparte ogni anno dal mese di inizio del tuo anno ferie. Giornate intere e mezze giornate vengono scalate con l'orario di quel giorno."
        case .portuguese: return "Recomeça todo ano a partir do mês de início do seu ano de férias. Dias inteiros e meios dias são descontados pelo horário daquele dia."
        case .chineseTraditional: return "每年從年假起始月重新計算。全天和半天按當天的工作時數扣除。"
        case .dutch: return "Begint elk jaar opnieuw vanaf de startmaand van je verlofjaar. Hele en halve dagen gaan eraf met de werktijd van die weekdag."
        case .swedish: return "Börjar om varje år från startmånaden för ditt semesterår. Hela och halva dagar dras av med den veckodagens arbetstid."
        case .norwegian: return "Starter på nytt hvert år fra startmåneden for ferieåret ditt. Hele og halve dager trekkes fra med arbeidstiden for den ukedagen."
        case .danish: return "Starter forfra hvert år fra startmåneden for dit ferieår. Hele og halve dage trækkes fra med arbejdstiden for den ugedag."
        case .finnish: return "Alkaa joka vuosi alusta lomavuotesi alkukuukaudesta. Kokonaiset ja puolikkaat päivät vähennetään kyseisen viikonpäivän työajalla."
        case .polish: return "Liczony od nowa co roku od miesiąca początku roku urlopowego. Całe i pół dnia odejmowane są według czasu pracy w dany dzień tygodnia."
        case .czech: return "Počítá se každý rok znovu od měsíce začátku dovolenkového roku. Celé a půl dny se odečítají podle pracovní doby daného dne."
        case .greek: return "Μηδενίζεται κάθε χρόνο από τον μήνα έναρξης του έτους αδειών. Οι ολόκληρες και μισές ημέρες αφαιρούνται με το ωράριο εκείνης της ημέρας."
        case .turkish: return "Her yıl izin yılı başlangıç ayından itibaren yeniden sayılır. Tam ve yarım günler o günün çalışma saatine göre düşülür."
        case .russian: return "Каждый год считается заново с месяца начала отпускного года. Полные и половинные дни вычитаются по рабочему времени этого дня недели."
        case .indonesian: return "Dihitung ulang setiap tahun mulai bulan awal tahun cuti. Hari penuh dan setengah hari dikurangi menurut jam kerja hari itu."
        }
    }

    /// 한도를 넘게 썼을 때
    static func allowanceOver(_ amount: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "한도보다 \(amount) 더 썼어요"
        case .english: return "\(amount) over the allowance"
        case .japanese: return "上限を\(amount)超えています"
        case .chinese: return "超出额度 \(amount)"
        case .german: return "\(amount) über dem Kontingent"
        case .french: return "\(amount) au-delà du quota"
        case .spanish: return "\(amount) por encima del cupo"
        case .italian: return "\(amount) oltre il monte annuo"
        case .portuguese: return "\(amount) acima da cota"
        case .chineseTraditional: return "超出額度 \(amount)"
        case .dutch: return "\(amount) boven het tegoed"
        case .swedish: return "\(amount) över kvoten"
        case .norwegian: return "\(amount) over kvoten"
        case .danish: return "\(amount) over kvoten"
        case .finnish: return "\(amount) yli kiintiön"
        case .polish: return "\(amount) ponad limit"
        case .czech: return "\(amount) nad nárok"
        case .greek: return "\(amount) πάνω από το όριο"
        case .turkish: return "Haktan \(amount) fazla"
        case .russian: return "Превышение на \(amount)"
        case .indonesian: return "Lebih \(amount) dari jatah"
        }
    }

    /// 휴가 등록 화면 — 이걸 등록하면 남는 한도
    static func allowanceAfterThis(_ amount: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "등록하면 이 종류 한도가 \(amount) 남아요"
        case .english: return "After this, \(amount) of this kind's allowance is left"
        case .japanese: return "登録すると、この種類の上限は残り\(amount)です"
        case .chinese: return "登记后该类型额度剩余 \(amount)"
        case .german: return "Danach bleiben \(amount) von diesem Kontingent"
        case .french: return "Après cela, il reste \(amount) sur ce quota"
        case .spanish: return "Después quedarán \(amount) de este cupo"
        case .italian: return "Dopo questo restano \(amount) del monte annuo"
        case .portuguese: return "Depois disso restam \(amount) desta cota"
        case .chineseTraditional: return "登記後該類型額度剩餘 \(amount)"
        case .dutch: return "Hierna blijft \(amount) van dit tegoed over"
        case .swedish: return "Därefter återstår \(amount) av kvoten"
        case .norwegian: return "Etter dette gjenstår \(amount) av kvoten"
        case .danish: return "Herefter er der \(amount) tilbage af kvoten"
        case .finnish: return "Tämän jälkeen kiintiötä jää \(amount)"
        case .polish: return "Po tym zostanie \(amount) z limitu"
        case .czech: return "Poté zbude \(amount) z nároku"
        case .greek: return "Μετά από αυτό απομένουν \(amount) από το όριο"
        case .turkish: return "Bundan sonra bu haktan \(amount) kalır"
        case .russian: return "После этого останется \(amount) лимита"
        case .indonesian: return "Setelah ini sisa jatah \(amount)"
        }
    }

    /// 휴가 등록 화면 — 이걸 등록하면 한도를 넘는다 (막지는 않음)
    static func allowanceOverAfterThis(_ amount: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "등록하면 이 종류 한도를 \(amount) 넘어요"
        case .english: return "This goes \(amount) over this kind's allowance"
        case .japanese: return "登録するとこの種類の上限を\(amount)超えます"
        case .chinese: return "登记后将超出该类型额度 \(amount)"
        case .german: return "Damit überschreitest du das Kontingent um \(amount)"
        case .french: return "Cela dépasse ce quota de \(amount)"
        case .spanish: return "Esto supera este cupo en \(amount)"
        case .italian: return "Così superi il monte annuo di \(amount)"
        case .portuguese: return "Isso ultrapassa esta cota em \(amount)"
        case .chineseTraditional: return "登記後將超出該類型額度 \(amount)"
        case .dutch: return "Hiermee ga je \(amount) over dit tegoed"
        case .swedish: return "Detta går \(amount) över kvoten"
        case .norwegian: return "Dette går \(amount) over kvoten"
        case .danish: return "Dette går \(amount) over kvoten"
        case .finnish: return "Tämä ylittää kiintiön \(amount)"
        case .polish: return "To przekroczy limit o \(amount)"
        case .czech: return "Tím překročíte nárok o \(amount)"
        case .greek: return "Αυτό ξεπερνά το όριο κατά \(amount)"
        case .turkish: return "Bu, hakkı \(amount) aşar"
        case .russian: return "Это превысит лимит на \(amount)"
        case .indonesian: return "Ini melebihi jatah sebesar \(amount)"
        }
    }

    /// 휴가 종류 순서 바꾸기 안내
    static var leaveKindsOrderFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "편집을 눌러 끌어서 순서를 바꾸면 휴가 등록·수정 화면에도 그 순서로 나와요."
        case .english: return "Tap Edit and drag to reorder. Adding and editing leave use the same order."
        case .japanese: return "編集をタップしてドラッグすると並べ替えられます。休暇の登録・編集画面も同じ順になります。"
        case .chinese: return "点按编辑并拖动即可排序。登记和修改假期时也按这个顺序显示。"
        case .german: return "Tippe auf Bearbeiten und ziehe zum Sortieren. Eintragen und Bearbeiten nutzen dieselbe Reihenfolge."
        case .french: return "Touchez Modifier et faites glisser pour réordonner. L'ajout et la modification suivent le même ordre."
        case .spanish: return "Toca Editar y arrastra para reordenar. Añadir y editar usan el mismo orden."
        case .italian: return "Tocca Modifica e trascina per riordinare. Inserimento e modifica usano lo stesso ordine."
        case .portuguese: return "Toque em Editar e arraste para reordenar. Adicionar e editar usam a mesma ordem."
        case .chineseTraditional: return "點一下編輯並拖移即可排序。登記和修改假期時也按這個順序顯示。"
        case .dutch: return "Tik op Wijzig en sleep om te ordenen. Toevoegen en wijzigen gebruiken dezelfde volgorde."
        case .swedish: return "Tryck på Redigera och dra för att ändra ordning. Samma ordning används när du lägger till och ändrar."
        case .norwegian: return "Trykk på Rediger og dra for å endre rekkefølge. Samme rekkefølge brukes når du legger til og endrer."
        case .danish: return "Tryk på Rediger og træk for at ændre rækkefølge. Samme rækkefølge bruges, når du tilføjer og ændrer."
        case .finnish: return "Napauta Muokkaa ja vedä järjestääksesi. Lisäys ja muokkaus käyttävät samaa järjestystä."
        case .polish: return "Stuknij Edytuj i przeciągnij, aby zmienić kolejność. Dodawanie i edycja używają tej samej kolejności."
        case .czech: return "Klepněte na Upravit a přetažením změňte pořadí. Přidávání a úpravy používají stejné pořadí."
        case .greek: return "Πατήστε Επεξεργασία και σύρετε για αναδιάταξη. Η προσθήκη και η επεξεργασία ακολουθούν την ίδια σειρά."
        case .turkish: return "Düzenle'ye dokunup sürükleyerek sıralayın. Ekleme ve düzenleme aynı sırayı kullanır."
        case .russian: return "Нажмите «Изменить» и перетащите, чтобы изменить порядок. Добавление и правка используют тот же порядок."
        case .indonesian: return "Ketuk Edit lalu seret untuk mengurutkan. Menambah dan mengubah cuti memakai urutan yang sama."
        }
    }

    /// 편집 끝
    static var doneEditing: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "완료"
        case .english: return "Done"
        case .japanese: return "完了"
        case .chinese: return "完成"
        case .german: return "Fertig"
        case .french: return "OK"
        case .spanish: return "Listo"
        case .italian: return "Fine"
        case .portuguese: return "OK"
        case .chineseTraditional: return "完成"
        case .dutch: return "Klaar"
        case .swedish: return "Klar"
        case .norwegian: return "Ferdig"
        case .danish: return "Færdig"
        case .finnish: return "Valmis"
        case .polish: return "Gotowe"
        case .czech: return "Hotovo"
        case .greek: return "Τέλος"
        case .turkish: return "Bitti"
        case .russian: return "Готово"
        case .indonesian: return "Selesai"
        }
    }

    /// 휴가 종류 목록 헤더 (기본 + 직접 만든 종류)
    static var allLeaveKindsHeader: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "휴가 종류"
        case .english: return "Leave kinds"
        case .japanese: return "休暇の種類"
        case .chinese: return "假期类型"
        case .german: return "Urlaubsarten"
        case .french: return "Types de congé"
        case .spanish: return "Tipos de ausencia"
        case .italian: return "Tipi di permesso"
        case .portuguese: return "Tipos de folga"
        case .chineseTraditional: return "假期類型"
        case .dutch: return "Verlofsoorten"
        case .swedish: return "Ledighetstyper"
        case .norwegian: return "Typer fravær"
        case .danish: return "Fraværstyper"
        case .finnish: return "Vapaatyypit"
        case .polish: return "Rodzaje urlopu"
        case .czech: return "Druhy volna"
        case .greek: return "Είδη άδειας"
        case .turkish: return "İzin türleri"
        case .russian: return "Виды отпуска"
        case .indonesian: return "Jenis cuti"
        }
    }

    /// 요일별 근무 시간 (월~목 7시간 30분, 금 7시간 같은 경우)
    static var workdayByWeekdayTitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "요일별 근무 시간"
        case .english: return "Hours by weekday"
        case .japanese: return "曜日ごとの勤務時間"
        case .chinese: return "按星期设置工时"
        case .german: return "Arbeitszeit je Wochentag"
        case .french: return "Horaire par jour"
        case .spanish: return "Horario por día"
        case .italian: return "Orario per giorno"
        case .portuguese: return "Horário por dia"
        case .chineseTraditional: return "按星期設定工時"
        case .dutch: return "Werktijd per dag"
        case .swedish: return "Arbetstid per veckodag"
        case .norwegian: return "Arbeidstid per ukedag"
        case .danish: return "Arbejdstid pr. ugedag"
        case .finnish: return "Työaika viikonpäivittäin"
        case .polish: return "Godziny wg dnia tygodnia"
        case .czech: return "Pracovní doba podle dne"
        case .greek: return "Ωράριο ανά ημέρα"
        case .turkish: return "Güne göre çalışma saati"
        case .russian: return "Часы по дням недели"
        case .indonesian: return "Jam kerja per hari"
        }
    }

    /// 요일별 근무 시간 설명
    static var workdayByWeekdayFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "요일마다 근무 시간이 다르면 따로 정하세요. 시간 단위 휴가를 일수로 바꿀 때와 종류별 시간 합계에 씁니다."
        case .english: return "Set this if your hours differ by day. Used to turn hourly leave into days and to total hours per leave kind."
        case .japanese: return "曜日によって勤務時間が違う場合に設定します。時間単位の休暇を日数に換算するときと、種類別の時間合計に使います。"
        case .chinese: return "如果每天工时不同，请分别设置。用于把按小时的假期换算成天数，以及按类型统计小时。"
        case .german: return "Lege das fest, wenn deine Arbeitszeit je Tag unterschiedlich ist. Wird zum Umrechnen von Stundenurlaub in Tage und für Stundensummen je Art genutzt."
        case .french: return "À régler si vos horaires varient selon le jour. Sert à convertir les heures en jours et à totaliser les heures par type."
        case .spanish: return "Configúralo si tu horario cambia según el día. Se usa para pasar horas a días y para sumar horas por tipo."
        case .italian: return "Impostalo se l'orario cambia a seconda del giorno. Serve a convertire i permessi a ore in giorni e a sommare le ore per tipo."
        case .portuguese: return "Defina se seu horário muda conforme o dia. Usado para converter horas em dias e somar horas por tipo."
        case .chineseTraditional: return "如果每天工時不同，請分別設定。用於把按小時的假期換算成天數，以及按類型統計小時。"
        case .dutch: return "Stel dit in als je werktijd per dag verschilt. Wordt gebruikt om uren om te rekenen naar dagen en om uren per soort op te tellen."
        case .swedish: return "Ange detta om arbetstiden skiljer sig mellan dagar. Används för att räkna om timmar till dagar och summera timmar per typ."
        case .norwegian: return "Angi dette hvis arbeidstiden varierer fra dag til dag. Brukes til å regne timer om til dager og summere timer per type."
        case .danish: return "Angiv dette, hvis arbejdstiden varierer fra dag til dag. Bruges til at omregne timer til dage og summere timer pr. type."
        case .finnish: return "Aseta, jos työaikasi vaihtelee päivittäin. Käytetään tuntien muuttamiseen päiviksi ja tuntien summaamiseen tyypeittäin."
        case .polish: return "Ustaw, jeśli godziny pracy różnią się w zależności od dnia. Służy do przeliczania godzin na dni i sumowania godzin wg rodzaju."
        case .czech: return "Nastavte, pokud se pracovní doba liší podle dne. Slouží k převodu hodin na dny a k součtu hodin podle druhu."
        case .greek: return "Ορίστε το αν το ωράριο αλλάζει ανά ημέρα. Χρησιμοποιείται για μετατροπή ωρών σε ημέρες και για σύνολα ωρών ανά είδος."
        case .turkish: return "Çalışma saatiniz güne göre değişiyorsa ayarlayın. Saatlik izni güne çevirmek ve türe göre saat toplamak için kullanılır."
        case .russian: return "Укажите, если рабочее время зависит от дня. Используется для перевода часов в дни и подсчёта часов по видам."
        case .indonesian: return "Atur jika jam kerja berbeda tiap hari. Dipakai untuk mengubah jam ke hari dan menjumlah jam per jenis."
        }
    }

    /// 요일별 근무 시간 — 기본값 그대로
    static var workdayDefaultTag: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "기본"
        case .english: return "Default"
        case .japanese: return "標準"
        case .chinese: return "默认"
        case .german: return "Standard"
        case .french: return "Par défaut"
        case .spanish: return "Predeterminado"
        case .italian: return "Predefinito"
        case .portuguese: return "Padrão"
        case .chineseTraditional: return "預設"
        case .dutch: return "Standaard"
        case .swedish: return "Standard"
        case .norwegian: return "Standard"
        case .danish: return "Standard"
        case .finnish: return "Oletus"
        case .polish: return "Domyślnie"
        case .czech: return "Výchozí"
        case .greek: return "Προεπιλογή"
        case .turkish: return "Varsayılan"
        case .russian: return "По умолчанию"
        case .indonesian: return "Bawaan"
        }
    }

    /// 요일별 근무 시간 모두 기본값으로
    static var resetWorkdayHours: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "모두 기본 근무 시간으로"
        case .english: return "Reset all to default"
        case .japanese: return "すべて標準に戻す"
        case .chinese: return "全部恢复默认"
        case .german: return "Alle auf Standard"
        case .french: return "Tout remettre par défaut"
        case .spanish: return "Restablecer todo"
        case .italian: return "Ripristina tutti"
        case .portuguese: return "Restaurar todos"
        case .chineseTraditional: return "全部恢復預設"
        case .dutch: return "Alles terug naar standaard"
        case .swedish: return "Återställ alla"
        case .norwegian: return "Tilbakestill alle"
        case .danish: return "Nulstil alle"
        case .finnish: return "Palauta kaikki"
        case .polish: return "Przywróć wszystkie"
        case .czech: return "Obnovit vše"
        case .greek: return "Επαναφορά όλων"
        case .turkish: return "Tümünü sıfırla"
        case .russian: return "Сбросить все"
        case .indonesian: return "Kembalikan semua"
        }
    }
}

// MARK: - 이전 연차 입력 — 시간 단위 · 남은 연차로 입력 (대만 피드백)

extension Strings {
    /// 이전 연차 입력 — 사용한 만큼
    static var pastLeaveModeUsed: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "사용한 연차"
        case .english: return "Leave used"
        case .japanese: return "使った有給"
        case .chinese: return "已用年假"
        case .german: return "Genommen"
        case .french: return "Congés pris"
        case .spanish: return "Usadas"
        case .italian: return "Ferie usate"
        case .portuguese: return "Usadas"
        case .chineseTraditional: return "已用特休"
        case .dutch: return "Gebruikt"
        case .swedish: return "Använt"
        case .norwegian: return "Brukt"
        case .danish: return "Brugt"
        case .finnish: return "Käytetty"
        case .polish: return "Wykorzystany"
        case .czech: return "Využitá"
        case .greek: return "Χρησιμοποιημένη"
        case .turkish: return "Kullanılan"
        case .russian: return "Использовано"
        case .indonesian: return "Terpakai"
        }
    }

    /// 이전 연차 입력 — 지금 남은 만큼 (중간에 앱을 시작한 경우)
    static var pastLeaveModeRemaining: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "지금 남은 연차"
        case .english: return "Leave left now"
        case .japanese: return "今の残り有給"
        case .chinese: return "目前剩余年假"
        case .german: return "Jetzt übrig"
        case .french: return "Restant aujourd'hui"
        case .spanish: return "Quedan ahora"
        case .italian: return "Ferie residue ora"
        case .portuguese: return "Restantes agora"
        case .chineseTraditional: return "目前剩餘特休"
        case .dutch: return "Nu over"
        case .swedish: return "Kvar nu"
        case .norwegian: return "Igjen nå"
        case .danish: return "Tilbage nu"
        case .finnish: return "Jäljellä nyt"
        case .polish: return "Zostało teraz"
        case .czech: return "Zbývá teď"
        case .greek: return "Απομένει τώρα"
        case .turkish: return "Şu an kalan"
        case .russian: return "Осталось сейчас"
        case .indonesian: return "Sisa sekarang"
        }
    }

    /// 남은 연차로 넣으면 사용 연차로 바꿔 기록
    static func pastLeaveWillRecordUsed(_ amount: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "사용한 연차 \(amount)로 기록돼요"
        case .english: return "Recorded as \(amount) used"
        case .japanese: return "使った有給\(amount)として記録します"
        case .chinese: return "将记录为已用 \(amount)"
        case .german: return "Wird als \(amount) genommen erfasst"
        case .french: return "Enregistré comme \(amount) pris"
        case .spanish: return "Se registrará como \(amount) usadas"
        case .italian: return "Registrate come \(amount) usate"
        case .portuguese: return "Registrado como \(amount) usadas"
        case .chineseTraditional: return "將記錄為已用 \(amount)"
        case .dutch: return "Wordt opgeslagen als \(amount) gebruikt"
        case .swedish: return "Sparas som \(amount) använt"
        case .norwegian: return "Lagres som \(amount) brukt"
        case .danish: return "Gemmes som \(amount) brugt"
        case .finnish: return "Tallennetaan käytetyksi: \(amount)"
        case .polish: return "Zapisane jako wykorzystane: \(amount)"
        case .czech: return "Uloží se jako využito \(amount)"
        case .greek: return "Καταγράφεται ως χρησιμοποιημένη \(amount)"
        case .turkish: return "Kullanılan \(amount) olarak kaydedilir"
        case .russian: return "Будет записано как использовано \(amount)"
        case .indonesian: return "Dicatat sebagai terpakai \(amount)"
        }
    }

    /// 남은 연차가 받은 연차보다 많을 때
    static var pastLeaveRemainingTooMuch: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "올해 받은 연차보다 많아요. 설정에서 총 연차를 먼저 바꿔 주세요."
        case .english: return "That's more than this year's total. Change your total leave in Settings first."
        case .japanese: return "今年の付与日数より多いです。先に設定で総日数を変更してください。"
        case .chinese: return "超过了今年的年假总数。请先在设置中修改年假总数。"
        case .german: return "Das ist mehr als dein Jahresurlaub. Ändere zuerst den Gesamturlaub in den Einstellungen."
        case .french: return "C'est plus que le total de l'année. Modifiez d'abord le total dans Réglages."
        case .spanish: return "Es más que el total del año. Cambia primero el total en Ajustes."
        case .italian: return "È più del totale dell'anno. Modifica prima il totale ferie nelle Impostazioni."
        case .portuguese: return "É mais que o total do ano. Altere primeiro o total nos Ajustes."
        case .chineseTraditional: return "超過今年的特休總數。請先在設定中修改特休總數。"
        case .dutch: return "Dat is meer dan je jaartotaal. Pas eerst je totale verlof aan in Instellingen."
        case .swedish: return "Det är mer än årets totala. Ändra totalen i Inställningar först."
        case .norwegian: return "Det er mer enn årets totale. Endre totalen i Innstillinger først."
        case .danish: return "Det er mere end årets samlede. Ret totalen i Indstillinger først."
        case .finnish: return "Se on enemmän kuin vuoden kokonaismäärä. Muuta ensin kokonaismäärä asetuksista."
        case .polish: return "To więcej niż roczna pula. Najpierw zmień łączny urlop w Ustawieniach."
        case .czech: return "To je víc než roční nárok. Nejdřív změňte celkovou dovolenou v Nastavení."
        case .greek: return "Είναι περισσότερο από το σύνολο της χρονιάς. Αλλάξτε πρώτα το σύνολο στις Ρυθμίσεις."
        case .turkish: return "Bu yılın toplamından fazla. Önce Ayarlar'da toplam izni değiştirin."
        case .russian: return "Это больше годового количества. Сначала измените общее число в настройках."
        case .indonesian: return "Lebih dari total tahun ini. Ubah total cuti di Pengaturan dulu."
        }
    }

    /// 이미 일괄 입력한 기록이 있을 때
    static var pastLeaveReplacesExisting: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "전에 일괄 입력한 값은 이 값으로 바뀌어요."
        case .english: return "Your earlier bulk entry will be replaced."
        case .japanese: return "以前の一括入力はこの値に置き換わります。"
        case .chinese: return "之前的批量录入将被替换。"
        case .german: return "Deine frühere Sammeleingabe wird ersetzt."
        case .french: return "Votre saisie groupée précédente sera remplacée."
        case .spanish: return "Tu entrada en bloque anterior se reemplazará."
        case .italian: return "L'inserimento in blocco precedente verrà sostituito."
        case .portuguese: return "Sua entrada em lote anterior será substituída."
        case .chineseTraditional: return "先前的批次輸入將被取代。"
        case .dutch: return "Je eerdere bulkinvoer wordt vervangen."
        case .swedish: return "Din tidigare samlade inmatning ersätts."
        case .norwegian: return "Den tidligere samlede registreringen erstattes."
        case .danish: return "Din tidligere samlede indtastning erstattes."
        case .finnish: return "Aiempi kertasyöttö korvataan."
        case .polish: return "Wcześniejszy wpis zbiorczy zostanie zastąpiony."
        case .czech: return "Dřívější hromadný záznam bude nahrazen."
        case .greek: return "Η προηγούμενη μαζική εισαγωγή θα αντικατασταθεί."
        case .turkish: return "Önceki toplu giriş değiştirilecek."
        case .russian: return "Прежняя запись будет заменена."
        case .indonesian: return "Input sekaligus sebelumnya akan diganti."
        }
    }
}

// MARK: - 넘겨 쓰는 한도 · 학교 달력 가져오기 (미국 교사 피드백, 2026-10-12)

extension Strings {
    /// 남은 한도 다음 해로 넘기기
    static var allowanceCarryToggle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "남은 양을 다음 해로 넘겨요"
        case .english: return "Unused balance rolls over"
        case .japanese: return "残りを翌年に繰り越す"
        case .chinese: return "剩余额度结转到下一年"
        case .german: return "Rest ins nächste Jahr übertragen"
        case .french: return "Le solde non utilisé est reporté"
        case .spanish: return "El saldo no usado se acumula"
        case .italian: return "Il residuo passa all'anno successivo"
        case .portuguese: return "O saldo não usado acumula"
        case .chineseTraditional: return "剩餘額度結轉到下一年"
        case .dutch: return "Restant gaat mee naar volgend jaar"
        case .swedish: return "Outnyttjat saldo förs över"
        case .norwegian: return "Ubrukt saldo overføres"
        case .danish: return "Ubrugt saldo overføres"
        case .finnish: return "Käyttämätön saldo siirtyy"
        case .polish: return "Niewykorzystane przechodzi na kolejny rok"
        case .czech: return "Nevyčerpané se převádí"
        case .greek: return "Το υπόλοιπο μεταφέρεται"
        case .turkish: return "Kalan bakiye devreder"
        case .russian: return "Остаток переносится"
        case .indonesian: return "Sisa dibawa ke tahun berikutnya"
        }
    }

    /// 넘겨 쓰기 시작 해에 쌓여 있던 양
    static func allowanceStartBalance(_ year: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\(year) 시작 때 쌓인 양"
        case .english: return "Built up by \(year)"
        case .japanese: return "\(year)開始時の繰越分"
        case .chinese: return "\(year)开始时的累计额度"
        case .german: return "Angespart bis \(year)"
        case .french: return "Cumulé au début de \(year)"
        case .spanish: return "Acumulado al inicio de \(year)"
        case .italian: return "Accumulato a inizio \(year)"
        case .portuguese: return "Acumulado no início de \(year)"
        case .chineseTraditional: return "\(year)開始時的累計額度"
        case .dutch: return "Opgebouwd tot \(year)"
        case .swedish: return "Intjänat till \(year)"
        case .norwegian: return "Opptjent til \(year)"
        case .danish: return "Optjent til \(year)"
        case .finnish: return "Kertynyt \(year) alkuun"
        case .polish: return "Zebrane do \(year)"
        case .czech: return "Naspořeno k \(year)"
        case .greek: return "Συσσωρευμένο έως \(year)"
        case .turkish: return "\(year) başında biriken"
        case .russian: return "Накоплено к \(year)"
        case .indonesian: return "Terkumpul hingga \(year)"
        }
    }

    /// 넘겨 쓰기 켰을 때 설명
    static var allowanceCarryOnFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "해마다 남은 양이 다음 해 한도에 더해져요 (쌓이는 병가처럼). 지금까지 이미 쌓인 양을 위에 넣으세요."
        case .english: return "Whatever is left each year is added to next year, like sick days that roll over. Enter what you have already built up above."
        case .japanese: return "毎年の残りが翌年の上限に加算されます（繰り越せる病気休暇のように）。これまでに貯まった分を上に入力してください。"
        case .chinese: return "每年剩下的额度会加到下一年（像可累积的病假）。请在上面填写目前已累积的额度。"
        case .german: return "Was übrig bleibt, kommt jedes Jahr dazu – wie übertragbare Krankheitstage. Trage oben ein, was du schon angespart hast."
        case .french: return "Ce qui reste chaque année s'ajoute à l'année suivante, comme des jours de maladie cumulables. Indiquez ci-dessus ce que vous avez déjà cumulé."
        case .spanish: return "Lo que sobra cada año se suma al siguiente, como los días de enfermedad acumulables. Indica arriba lo que ya tienes acumulado."
        case .italian: return "Quello che resta ogni anno si aggiunge all'anno dopo, come i giorni di malattia cumulabili. Inserisci sopra quanto hai già accumulato."
        case .portuguese: return "O que sobra a cada ano soma-se ao seguinte, como dias de doença acumuláveis. Informe acima o que você já acumulou."
        case .chineseTraditional: return "每年剩下的額度會加到下一年（像可累積的病假）。請在上面填寫目前已累積的額度。"
        case .dutch: return "Wat elk jaar overblijft komt bij het volgende jaar, zoals opbouwende ziektedagen. Vul hierboven in wat je al hebt opgebouwd."
        case .swedish: return "Det som blir över varje år läggs till nästa år, som sjukdagar som sparas. Ange ovan vad du redan har samlat."
        case .norwegian: return "Det som er igjen hvert år legges til neste år, som sykedager som spares. Skriv over hva du allerede har opptjent."
        case .danish: return "Det, der er tilbage hvert år, lægges til næste år, som sygedage der opspares. Angiv ovenfor, hvad du allerede har optjent."
        case .finnish: return "Joka vuosi jäljelle jäävä lisätään seuraavaan vuoteen, kuten kertyvät sairauspäivät. Syötä yllä jo kertynyt määrä."
        case .polish: return "To, co zostaje co roku, dolicza się do kolejnego roku, jak kumulowane dni chorobowe. Wpisz wyżej, ile już masz zebrane."
        case .czech: return "Co každý rok zbude, přičte se k dalšímu roku, jako převáděné dny nemoci. Nahoře zadejte, co už máte naspořeno."
        case .greek: return "Ό,τι περισσεύει κάθε χρόνο προστίθεται στον επόμενο, όπως οι αναρρωτικές που μεταφέρονται. Βάλτε πάνω όσα έχετε ήδη συγκεντρώσει."
        case .turkish: return "Her yıl kalan miktar bir sonraki yıla eklenir, biriken hastalık izni gibi. Şimdiye kadar biriktirdiğinizi yukarıya girin."
        case .russian: return "Остаток каждого года добавляется к следующему, как накапливаемые больничные. Укажите выше, сколько уже накоплено."
        case .indonesian: return "Sisa tiap tahun ditambahkan ke tahun berikutnya, seperti cuti sakit yang terakumulasi. Masukkan yang sudah terkumpul di atas."
        }
    }

    /// 넘겨 쓰기 껐을 때 설명
    static var allowanceCarryOffFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "끄면 남은 양은 해가 바뀌면 사라져요 (개인 휴가처럼)."
        case .english: return "When off, anything left resets at the end of the leave year, like personal days."
        case .japanese: return "オフにすると、残りは年度が変わると消えます（個人休暇のように）。"
        case .chinese: return "关闭后，剩余额度在年度结束时清零（像事假一样）。"
        case .german: return "Wenn aus, verfällt der Rest zum Jahresende – wie persönliche freie Tage."
        case .french: return "Désactivé, le reste est perdu en fin d'année, comme les jours personnels."
        case .spanish: return "Si está desactivado, lo que sobra se pierde al final del año, como los días personales."
        case .italian: return "Se disattivato, il residuo si azzera a fine anno, come i giorni personali."
        case .portuguese: return "Desativado, o que sobra zera no fim do ano, como os dias pessoais."
        case .chineseTraditional: return "關閉後，剩餘額度在年度結束時歸零（像事假一樣）。"
        case .dutch: return "Uit: wat overblijft vervalt aan het eind van het jaar, zoals persoonlijke dagen."
        case .swedish: return "Av: det som blir över försvinner vid årets slut, som personliga dagar."
        case .norwegian: return "Av: det som er igjen forsvinner ved årets slutt, som personlige dager."
        case .danish: return "Fra: det, der er tilbage, bortfalder ved årets udgang, som personlige dage."
        case .finnish: return "Pois päältä: jäljelle jäävä nollautuu vuoden lopussa, kuten henkilökohtaiset päivät."
        case .polish: return "Wyłączone: to, co zostanie, przepada z końcem roku, jak dni osobiste."
        case .czech: return "Vypnuto: zbytek na konci roku propadá, jako osobní dny."
        case .greek: return "Απενεργοποιημένο: ό,τι περισσεύει χάνεται στο τέλος του έτους, όπως οι προσωπικές ημέρες."
        case .turkish: return "Kapalıyken kalan miktar yıl sonunda sıfırlanır, kişisel izin günleri gibi."
        case .russian: return "Если выключено, остаток сгорает в конце года, как личные дни."
        case .indonesian: return "Jika mati, sisa hangus di akhir tahun, seperti hari pribadi."
        }
    }

    /// 지난해에서 넘어온 양
    static func allowanceCarriedIn(_ amount: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "지난해에서 넘어온 \(amount) 포함"
        case .english: return "Includes \(amount) rolled over"
        case .japanese: return "前年からの繰越 \(amount) を含む"
        case .chinese: return "含上年结转 \(amount)"
        case .german: return "Inkl. \(amount) aus dem Vorjahr"
        case .french: return "Dont \(amount) reportés"
        case .spanish: return "Incluye \(amount) acumulados"
        case .italian: return "Inclusi \(amount) riportati"
        case .portuguese: return "Inclui \(amount) acumulados"
        case .chineseTraditional: return "含上年結轉 \(amount)"
        case .dutch: return "Inclusief \(amount) overgedragen"
        case .swedish: return "Inkl. \(amount) överfört"
        case .norwegian: return "Inkl. \(amount) overført"
        case .danish: return "Inkl. \(amount) overført"
        case .finnish: return "Sisältää \(amount) siirtyneenä"
        case .polish: return "W tym \(amount) z poprzedniego roku"
        case .czech: return "Včetně \(amount) převedených"
        case .greek: return "Περιλαμβάνει \(amount) από μεταφορά"
        case .turkish: return "\(amount) devreden dahil"
        case .russian: return "Включая \(amount) перенесённых"
        case .indonesian: return "Termasuk \(amount) dari tahun lalu"
        }
    }

    /// 학교 달력 가져오기
    static var schoolImportTitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "학교 달력 가져오기"
        case .english: return "Import school calendar"
        case .japanese: return "学校カレンダーを読み込む"
        case .chinese: return "导入学校日历"
        case .german: return "Schulkalender importieren"
        case .french: return "Importer le calendrier scolaire"
        case .spanish: return "Importar calendario escolar"
        case .italian: return "Importa calendario scolastico"
        case .portuguese: return "Importar calendário escolar"
        case .chineseTraditional: return "匯入學校行事曆"
        case .dutch: return "Schoolkalender importeren"
        case .swedish: return "Importera skolkalender"
        case .norwegian: return "Importer skolekalender"
        case .danish: return "Importér skolekalender"
        case .finnish: return "Tuo koulun kalenteri"
        case .polish: return "Importuj kalendarz szkolny"
        case .czech: return "Importovat školní kalendář"
        case .greek: return "Εισαγωγή σχολικού ημερολογίου"
        case .turkish: return "Okul takvimini içe aktar"
        case .russian: return "Импорт школьного календаря"
        case .indonesian: return "Impor kalender sekolah"
        }
    }

    /// 학교 달력 가져오기 안내
    static var schoolImportGuide: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "학교 달력 사진·PDF를 고르거나 글을 붙여 넣으세요. 칸으로 된 달력보다 날짜 목록(주요 일정) 부분을 잘 읽어요."
        case .english: return "Choose a photo or PDF of your school calendar, or paste its text. A list of key dates reads better than a grid."
        case .japanese: return "学校カレンダーの写真・PDFを選ぶか、文字を貼り付けてください。マス目のカレンダーより日付の一覧（主な予定）の方がよく読めます。"
        case .chinese: return "选择学校日历的照片或 PDF，或粘贴文字。日期列表（重要日程）比格子日历更容易识别。"
        case .german: return "Wähle ein Foto oder PDF des Schulkalenders oder füge den Text ein. Eine Liste wichtiger Termine wird besser erkannt als ein Raster."
        case .french: return "Choisissez une photo ou un PDF du calendrier scolaire, ou collez le texte. Une liste des dates clés se lit mieux qu'une grille."
        case .spanish: return "Elige una foto o PDF del calendario escolar, o pega el texto. Una lista de fechas clave se lee mejor que una cuadrícula."
        case .italian: return "Scegli una foto o un PDF del calendario scolastico, oppure incolla il testo. Un elenco di date si legge meglio di una griglia."
        case .portuguese: return "Escolha uma foto ou PDF do calendário escolar, ou cole o texto. Uma lista de datas importantes é lida melhor que uma grade."
        case .chineseTraditional: return "選擇學校行事曆的照片或 PDF，或貼上文字。日期清單（重要行程）比格子行事曆更容易辨識。"
        case .dutch: return "Kies een foto of pdf van de schoolkalender, of plak de tekst. Een lijst met belangrijke data leest beter dan een raster."
        case .swedish: return "Välj ett foto eller en PDF av skolkalendern, eller klistra in texten. En lista med viktiga datum läses bättre än ett rutnät."
        case .norwegian: return "Velg et bilde eller en PDF av skolekalenderen, eller lim inn teksten. En liste med viktige datoer leses bedre enn et rutenett."
        case .danish: return "Vælg et foto eller en PDF af skolekalenderen, eller indsæt teksten. En liste med vigtige datoer læses bedre end et gitter."
        case .finnish: return "Valitse koulun kalenterin kuva tai PDF tai liitä teksti. Tärkeiden päivien luettelo luetaan paremmin kuin ruudukko."
        case .polish: return "Wybierz zdjęcie lub PDF kalendarza szkolnego albo wklej tekst. Lista ważnych dat czyta się lepiej niż siatka."
        case .czech: return "Vyberte fotku nebo PDF školního kalendáře, nebo vložte text. Seznam důležitých dat se čte lépe než mřížka."
        case .greek: return "Επιλέξτε φωτογραφία ή PDF του σχολικού ημερολογίου ή επικολλήστε το κείμενο. Μια λίστα ημερομηνιών διαβάζεται καλύτερα από πλέγμα."
        case .turkish: return "Okul takviminin fotoğrafını veya PDF'ini seçin ya da metni yapıştırın. Önemli tarihler listesi ızgaradan daha iyi okunur."
        case .russian: return "Выберите фото или PDF школьного календаря либо вставьте текст. Список ключевых дат читается лучше, чем сетка."
        case .indonesian: return "Pilih foto atau PDF kalender sekolah, atau tempel teksnya. Daftar tanggal penting lebih mudah dibaca daripada kisi."
        }
    }

    /// PDF·파일 고르기
    static var schoolImportChooseFile: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "PDF·파일 고르기"
        case .english: return "Choose PDF or file"
        case .japanese: return "PDF・ファイルを選ぶ"
        case .chinese: return "选择 PDF 或文件"
        case .german: return "PDF oder Datei wählen"
        case .french: return "Choisir un PDF ou un fichier"
        case .spanish: return "Elegir PDF o archivo"
        case .italian: return "Scegli PDF o file"
        case .portuguese: return "Escolher PDF ou arquivo"
        case .chineseTraditional: return "選擇 PDF 或檔案"
        case .dutch: return "Pdf of bestand kiezen"
        case .swedish: return "Välj PDF eller fil"
        case .norwegian: return "Velg PDF eller fil"
        case .danish: return "Vælg PDF eller fil"
        case .finnish: return "Valitse PDF tai tiedosto"
        case .polish: return "Wybierz PDF lub plik"
        case .czech: return "Vybrat PDF nebo soubor"
        case .greek: return "Επιλογή PDF ή αρχείου"
        case .turkish: return "PDF veya dosya seç"
        case .russian: return "Выбрать PDF или файл"
        case .indonesian: return "Pilih PDF atau file"
        }
    }

    /// 글 붙여 넣기
    static var schoolImportPaste: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "글 붙여 넣기"
        case .english: return "Paste text"
        case .japanese: return "テキストを貼り付け"
        case .chinese: return "粘贴文字"
        case .german: return "Text einfügen"
        case .french: return "Coller du texte"
        case .spanish: return "Pegar texto"
        case .italian: return "Incolla testo"
        case .portuguese: return "Colar texto"
        case .chineseTraditional: return "貼上文字"
        case .dutch: return "Tekst plakken"
        case .swedish: return "Klistra in text"
        case .norwegian: return "Lim inn tekst"
        case .danish: return "Indsæt tekst"
        case .finnish: return "Liitä teksti"
        case .polish: return "Wklej tekst"
        case .czech: return "Vložit text"
        case .greek: return "Επικόλληση κειμένου"
        case .turkish: return "Metin yapıştır"
        case .russian: return "Вставить текст"
        case .indonesian: return "Tempel teks"
        }
    }

    /// 날짜 읽기
    static var schoolImportRead: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "날짜 읽기"
        case .english: return "Find dates"
        case .japanese: return "日付を読み取る"
        case .chinese: return "识别日期"
        case .german: return "Daten erkennen"
        case .french: return "Trouver les dates"
        case .spanish: return "Buscar fechas"
        case .italian: return "Trova le date"
        case .portuguese: return "Encontrar datas"
        case .chineseTraditional: return "辨識日期"
        case .dutch: return "Data zoeken"
        case .swedish: return "Hitta datum"
        case .norwegian: return "Finn datoer"
        case .danish: return "Find datoer"
        case .finnish: return "Etsi päivät"
        case .polish: return "Znajdź daty"
        case .czech: return "Najít data"
        case .greek: return "Εύρεση ημερομηνιών"
        case .turkish: return "Tarihleri bul"
        case .russian: return "Найти даты"
        case .indonesian: return "Cari tanggal"
        }
    }

    /// 학년도
    static var schoolImportSchoolYear: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "학년도"
        case .english: return "School year"
        case .japanese: return "学年度"
        case .chinese: return "学年"
        case .german: return "Schuljahr"
        case .french: return "Année scolaire"
        case .spanish: return "Curso escolar"
        case .italian: return "Anno scolastico"
        case .portuguese: return "Ano letivo"
        case .chineseTraditional: return "學年度"
        case .dutch: return "Schooljaar"
        case .swedish: return "Läsår"
        case .norwegian: return "Skoleår"
        case .danish: return "Skoleår"
        case .finnish: return "Lukuvuosi"
        case .polish: return "Rok szkolny"
        case .czech: return "Školní rok"
        case .greek: return "Σχολικό έτος"
        case .turkish: return "Eğitim yılı"
        case .russian: return "Учебный год"
        case .indonesian: return "Tahun ajaran"
        }
    }

    /// 학교 달력 결과 설명
    static var schoolImportFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "쉬는 날은 내 방학으로 넣어 연차에서 빠지지 않고, 공휴일 앞뒤 휴가 제한도 그 앞뒤에 걸려요. 시험 주간 같은 날은 휴가 불가 기간으로 넣으면 추천이 피해요."
        case .english: return "Days off are added as your breaks: no leave is taken, and the no-leave-around-holidays rule applies before and after them. Add testing weeks as no-leave periods and suggestions will avoid them."
        case .japanese: return "休みの日は自分の休暇期間として追加され、有給から引かれず、祝日前後の休暇制限もその前後に適用されます。試験週などは休暇不可期間にすると、おすすめが避けます。"
        case .chinese: return "休息日会作为我的假期加入，不扣年假，节假日前后的请假限制也会作用于其前后。考试周等可设为禁止请假期间，推荐会避开。"
        case .german: return "Freie Tage werden als deine Ferien eingetragen: kein Urlaub wird abgezogen, und die Sperre rund um Feiertage gilt auch davor und danach. Prüfungswochen als Urlaubssperre eintragen, dann meiden die Vorschläge sie."
        case .french: return "Les jours de repos sont ajoutés comme vos vacances : aucun congé n'est décompté et la règle autour des fériés s'applique avant et après. Ajoutez les semaines d'examens comme périodes sans congé pour que les suggestions les évitent."
        case .spanish: return "Los días libres se añaden como tus vacaciones: no se descuentan y la regla de no pedir días junto a festivos se aplica antes y después. Añade las semanas de exámenes como periodos sin vacaciones y las sugerencias las evitarán."
        case .italian: return "I giorni liberi vengono aggiunti come tue vacanze: non scalano ferie e la regola sui giorni vicino alle festività vale anche prima e dopo. Aggiungi le settimane di verifiche come periodi senza ferie e i suggerimenti le eviteranno."
        case .portuguese: return "As folgas entram como suas férias: não descontam e a regra de não tirar folga perto de feriados vale antes e depois delas. Adicione semanas de provas como períodos sem folga e as sugestões vão evitá-las."
        case .chineseTraditional: return "休息日會作為我的假期加入，不扣特休，假日前後的請假限制也會作用於其前後。考試週等可設為禁止請假期間，推薦會避開。"
        case .dutch: return "Vrije dagen worden toegevoegd als jouw vakanties: er gaat geen verlof af en de regel rond feestdagen geldt ervoor en erna. Voeg toetsweken toe als verlofstop, dan vermijden suggesties ze."
        case .swedish: return "Lediga dagar läggs till som dina lov: ingen semester dras och regeln kring helgdagar gäller före och efter. Lägg till provveckor som spärrperioder så undviker förslagen dem."
        case .norwegian: return "Fridager legges til som dine ferier: ingen ferie trekkes, og regelen rundt helligdager gjelder før og etter. Legg til prøveuker som perioder uten fri, så unngår forslagene dem."
        case .danish: return "Fridage tilføjes som dine ferier: der trækkes ingen ferie, og reglen omkring helligdage gælder før og efter. Tilføj prøveuger som perioder uden fri, så undgår forslagene dem."
        case .finnish: return "Vapaapäivät lisätään omiksi lomiksi: lomaa ei vähennetä, ja pyhien ympärillä oleva rajoitus koskee myös niiden alkua ja loppua. Lisää koeviikot lomakieltoina, niin ehdotukset välttävät ne."
        case .polish: return "Dni wolne dodają się jako Twoje ferie: urlop nie jest odejmowany, a zakaz urlopu przy świętach działa też przed i po nich. Dodaj tygodnie egzaminów jako okresy bez urlopu, a propozycje je ominą."
        case .czech: return "Volné dny se přidají jako vaše prázdniny: dovolená se neodečítá a pravidlo kolem svátků platí i před nimi a po nich. Týdny testů přidejte jako období bez dovolené a návrhy se jim vyhnou."
        case .greek: return "Οι ελεύθερες μέρες προστίθενται ως δικές σας διακοπές: δεν αφαιρείται άδεια και ο κανόνας γύρω από τις αργίες ισχύει πριν και μετά. Προσθέστε τις εβδομάδες εξετάσεων ως περιόδους χωρίς άδεια για να τις αποφεύγουν οι προτάσεις."
        case .turkish: return "İzin günleri tatiliniz olarak eklenir: izin düşülmez ve tatil öncesi/sonrası kuralı bunların önünde ve arkasında da geçerlidir. Sınav haftalarını izin yasağı olarak ekleyin, öneriler onlardan kaçınsın."
        case .russian: return "Выходные добавляются как ваши каникулы: отпуск не списывается, а правило о днях рядом с праздниками действует до и после них. Недели тестов добавьте как периоды без отпуска — подсказки их обойдут."
        case .indonesian: return "Hari libur ditambahkan sebagai liburan Anda: cuti tidak dipotong, dan aturan sekitar hari libur berlaku sebelum dan sesudahnya. Tambahkan minggu ujian sebagai periode tanpa cuti agar saran menghindarinya."
        }
    }

    /// 날짜 못 찾음
    static var schoolImportNothingFound: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "날짜를 찾지 못했어요. 날짜 목록이 보이게 다시 찍거나 글을 붙여 넣어 보세요."
        case .english: return "No dates found. Try a photo of the list of dates, or paste the text."
        case .japanese: return "日付が見つかりませんでした。日付の一覧が写るように撮り直すか、文字を貼り付けてみてください。"
        case .chinese: return "没有找到日期。请重新拍摄日期列表，或粘贴文字。"
        case .german: return "Keine Daten gefunden. Fotografiere die Terminliste oder füge den Text ein."
        case .french: return "Aucune date trouvée. Photographiez la liste des dates ou collez le texte."
        case .spanish: return "No se encontraron fechas. Prueba con una foto de la lista de fechas o pega el texto."
        case .italian: return "Nessuna data trovata. Prova con una foto dell'elenco delle date o incolla il testo."
        case .portuguese: return "Nenhuma data encontrada. Tente uma foto da lista de datas ou cole o texto."
        case .chineseTraditional: return "沒有找到日期。請重新拍攝日期清單，或貼上文字。"
        case .dutch: return "Geen data gevonden. Probeer een foto van de lijst met data of plak de tekst."
        case .swedish: return "Inga datum hittades. Prova ett foto av datumlistan eller klistra in texten."
        case .norwegian: return "Fant ingen datoer. Prøv et bilde av datolisten eller lim inn teksten."
        case .danish: return "Ingen datoer fundet. Prøv et foto af datolisten, eller indsæt teksten."
        case .finnish: return "Päiviä ei löytynyt. Kokeile kuvaa päivälistasta tai liitä teksti."
        case .polish: return "Nie znaleziono dat. Spróbuj zdjęcia listy dat lub wklej tekst."
        case .czech: return "Nenalezena žádná data. Zkuste fotku seznamu dat nebo vložte text."
        case .greek: return "Δεν βρέθηκαν ημερομηνίες. Δοκιμάστε φωτογραφία της λίστας ή επικολλήστε το κείμενο."
        case .turkish: return "Tarih bulunamadı. Tarih listesinin fotoğrafını deneyin veya metni yapıştırın."
        case .russian: return "Даты не найдены. Сфотографируйте список дат или вставьте текст."
        case .indonesian: return "Tanggal tidak ditemukan. Coba foto daftar tanggal atau tempel teksnya."
        }
    }

    /// 쉬는 날
    static var schoolImportDayOff: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "쉬는 날"
        case .english: return "Day off"
        case .japanese: return "休み"
        case .chinese: return "休息日"
        case .german: return "Frei"
        case .french: return "Jour de repos"
        case .spanish: return "Día libre"
        case .italian: return "Giorno libero"
        case .portuguese: return "Folga"
        case .chineseTraditional: return "休息日"
        case .dutch: return "Vrij"
        case .swedish: return "Ledig"
        case .norwegian: return "Fri"
        case .danish: return "Fri"
        case .finnish: return "Vapaa"
        case .polish: return "Wolne"
        case .czech: return "Volno"
        case .greek: return "Ρεπό"
        case .turkish: return "Tatil"
        case .russian: return "Выходной"
        case .indonesian: return "Libur"
        }
    }

    /// 이미 쉬는 날
    static var schoolImportAlreadyOff: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "이미 쉬는 날이에요"
        case .english: return "Already a day off"
        case .japanese: return "すでに休みの日です"
        case .chinese: return "已经是休息日"
        case .german: return "Bereits frei"
        case .french: return "Déjà un jour de repos"
        case .spanish: return "Ya es día libre"
        case .italian: return "Già giorno libero"
        case .portuguese: return "Já é folga"
        case .chineseTraditional: return "已經是休息日"
        case .dutch: return "Al een vrije dag"
        case .swedish: return "Redan ledig"
        case .norwegian: return "Allerede fri"
        case .danish: return "Allerede fri"
        case .finnish: return "Jo vapaapäivä"
        case .polish: return "Już wolne"
        case .czech: return "Už je volno"
        case .greek: return "Ήδη ρεπό"
        case .turkish: return "Zaten tatil"
        case .russian: return "Уже выходной"
        case .indonesian: return "Sudah libur"
        }
    }

    /// 이름 없는 학교 쉬는 날
    static var schoolImportUntitled: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "학교 쉬는 날"
        case .english: return "No school"
        case .japanese: return "学校休み"
        case .chinese: return "学校放假"
        case .german: return "Schulfrei"
        case .french: return "Pas d'école"
        case .spanish: return "Sin clases"
        case .italian: return "Scuola chiusa"
        case .portuguese: return "Sem aula"
        case .chineseTraditional: return "學校放假"
        case .dutch: return "Geen school"
        case .swedish: return "Skolfritt"
        case .norwegian: return "Skolefri"
        case .danish: return "Skolefri"
        case .finnish: return "Ei koulua"
        case .polish: return "Dzień wolny od szkoły"
        case .czech: return "Ředitelské volno"
        case .greek: return "Χωρίς σχολείο"
        case .turkish: return "Okul yok"
        case .russian: return "Нет занятий"
        case .indonesian: return "Sekolah libur"
        }
    }

    /// 고른 항목 넣기
    static func schoolImportAdd(_ n: Int) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\(n)개 넣기"
        case .english: return "Add \(n)"
        case .japanese: return "\(n)件追加"
        case .chinese: return "添加 \(n) 项"
        case .german: return "\(n) hinzufügen"
        case .french: return "Ajouter \(n)"
        case .spanish: return "Añadir \(n)"
        case .italian: return "Aggiungi \(n)"
        case .portuguese: return "Adicionar \(n)"
        case .chineseTraditional: return "新增 \(n) 項"
        case .dutch: return "\(n) toevoegen"
        case .swedish: return "Lägg till \(n)"
        case .norwegian: return "Legg til \(n)"
        case .danish: return "Tilføj \(n)"
        case .finnish: return "Lisää \(n)"
        case .polish: return "Dodaj \(n)"
        case .czech: return "Přidat \(n)"
        case .greek: return "Προσθήκη \(n)"
        case .turkish: return "\(n) ekle"
        case .russian: return "Добавить \(n)"
        case .indonesian: return "Tambah \(n)"
        }
    }
}

// MARK: - 같은 날 여러 휴가 (이탈리아 피드백 3차)

extension Strings {
    /// 반차·시간 단위 휴가가 있는 날에 다른 휴가를 더 넣는 버튼
    static var addAnotherLeaveOnThisDate: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "이 날짜에 다른 휴가 추가"
        case .english: return "Add another leave on this date"
        case .japanese: return "この日付に別の休暇を追加"
        case .chinese: return "在此日期再登记一项休假"
        case .german: return "Weiteren Urlaub für dieses Datum eintragen"
        case .french: return "Ajouter un autre congé à cette date"
        case .spanish: return "Añadir otro permiso este día"
        case .italian: return "Aggiungi un altro giustificativo in questa data"
        case .portuguese: return "Adicionar outra ausência nesta data"
        case .chineseTraditional: return "在這天再登記一項休假"
        case .dutch: return "Nog een verlof toevoegen op deze datum"
        case .swedish: return "Lägg till en till ledighet på det här datumet"
        case .norwegian: return "Legg til et annet fravær på denne datoen"
        case .danish: return "Tilføj endnu et fravær på denne dato"
        case .finnish: return "Lisää toinen poissaolo tälle päivälle"
        case .polish: return "Dodaj kolejną nieobecność w tym dniu"
        case .czech: return "Přidat další volno na toto datum"
        case .greek: return "Προσθήκη άλλης άδειας σε αυτή την ημερομηνία"
        case .turkish: return "Bu tarihe başka bir izin ekle"
        case .russian: return "Добавить ещё один отпуск на эту дату"
        case .indonesian: return "Catat cuti lain di tanggal ini"
        }
    }
}
