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
