//
//  Strings+FamilyAnniversary.swift
//  Goldweek
//
//  가족 기념일 문구 (23개 언어)
//

import Foundation

extension Strings {
    static var familyAnniversariesTitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "가족 기념일"
        case .english: return "Family Occasions"
        case .japanese: return "家族の記念日"
        case .chinese: return "家庭纪念日"
        case .german: return "Familientage"
        case .french: return "Dates de famille"
        case .spanish: return "Fechas familiares"
        case .italian: return "Ricorrenze di famiglia"
        case .portuguese: return "Datas da família"
        case .chineseTraditional: return "家庭紀念日"
        case .dutch: return "Familiedagen"
        case .swedish: return "Familjens högtidsdagar"
        case .norwegian: return "Familiens merkedager"
        case .danish: return "Familiens mærkedage"
        case .finnish: return "Perheen merkkipäivät"
        case .polish: return "Rodzinne święta"
        case .czech: return "Rodinná výročí"
        case .greek: return "Οικογενειακές γιορτές"
        case .turkish: return "Aile günleri"
        case .russian: return "Семейные даты"
        case .indonesian: return "Hari penting keluarga"
        case .thai: return "วันสำคัญของครอบครัว"
        case .vietnamese: return "Ngày kỷ niệm gia đình"
        }
    }

    static var familyAnniversaryTag: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "가족 기념일"
        case .english: return "Family occasion"
        case .japanese: return "家族の記念日"
        case .chinese: return "家庭纪念日"
        case .german: return "Familientag"
        case .french: return "Date de famille"
        case .spanish: return "Fecha familiar"
        case .italian: return "Ricorrenza di famiglia"
        case .portuguese: return "Data da família"
        case .chineseTraditional: return "家庭紀念日"
        case .dutch: return "Familiedag"
        case .swedish: return "Familjedag"
        case .norwegian: return "Merkedag"
        case .danish: return "Mærkedag"
        case .finnish: return "Perheen merkkipäivä"
        case .polish: return "Rodzinne święto"
        case .czech: return "Rodinné výročí"
        case .greek: return "Οικογενειακή γιορτή"
        case .turkish: return "Aile günü"
        case .russian: return "Семейная дата"
        case .indonesian: return "Hari keluarga"
        case .thai: return "วันสำคัญของครอบครัว"
        case .vietnamese: return "Ngày của gia đình"
        }
    }

    static var familyAnniversariesSubtitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "생신·결혼기념일·기일을 챙기고 휴가 내기"
        case .english: return "Birthdays, anniversaries and remembrance days"
        case .japanese: return "誕生日・結婚記念日・命日を忘れずに休む"
        case .chinese: return "记住生日、结婚纪念日和忌日，提前休假"
        case .german: return "Geburtstage, Hochzeitstage und Gedenktage"
        case .french: return "Anniversaires, mariages et jours de mémoire"
        case .spanish: return "Cumpleaños, aniversarios y días de recuerdo"
        case .italian: return "Compleanni, anniversari e giorni del ricordo"
        case .portuguese: return "Aniversários, casamentos e datas de memória"
        case .chineseTraditional: return "記住生日、結婚紀念日和忌日，提前請假"
        case .dutch: return "Verjaardagen, trouwdagen en gedenkdagen"
        case .swedish: return "Födelsedagar, bröllopsdagar och minnesdagar"
        case .norwegian: return "Bursdager, bryllupsdager og minnedager"
        case .danish: return "Fødselsdage, bryllupsdage og mindedage"
        case .finnish: return "Syntymäpäivät, hääpäivät ja muistopäivät"
        case .polish: return "Urodziny, rocznice ślubu i dni pamięci"
        case .czech: return "Narozeniny, výročí svatby a dny vzpomínek"
        case .greek: return "Γενέθλια, επέτειοι γάμου και μνημόσυνα"
        case .turkish: return "Doğum günleri, evlilik yıl dönümleri ve anma günleri"
        case .russian: return "Дни рождения, годовщины свадьбы и дни памяти"
        case .indonesian: return "Ulang tahun, hari pernikahan, dan hari peringatan"
        case .thai: return "วันเกิด วันครบรอบแต่งงาน และวันรำลึก"
        case .vietnamese: return "Sinh nhật, ngày cưới và ngày giỗ"
        }
    }

    static var familyAnniversariesFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "가족에게는 공휴일 같은 날이에요. 달력에 하트로 표시하고, 2주 전에 휴가를 챙기라고 알려 드려요. 그날이 든 연휴 추천도 앞세워요. 연차 계산은 그대로예요."
        case .english: return "These days are holidays for your family. They get a heart on the calendar, a reminder two weeks ahead to book time off, and suggested breaks that include them come first. Your leave balance doesn't change."
        case .japanese: return "家族にとっては祝日のような日です。カレンダーにハートで表示し、2週間前に休みを取るようお知らせします。その日を含む連休のおすすめも優先します。有給の計算は変わりません。"
        case .chinese: return "对家人来说，这些日子就像节假日。日历上会用爱心标出，提前两周提醒你安排休假，包含这一天的连休推荐也会优先显示。年假计算不受影响。"
        case .german: return "Für deine Familie sind das Feiertage. Sie bekommen ein Herz im Kalender, zwei Wochen vorher eine Erinnerung, Urlaub zu nehmen, und Vorschläge mit diesen Tagen stehen oben. Dein Urlaubskonto bleibt gleich."
        case .french: return "Pour votre famille, ce sont des jours fériés. Ils sont marqués d’un cœur dans le calendrier, un rappel arrive deux semaines avant pour poser un congé, et les suggestions qui les incluent passent en premier. Votre solde ne change pas."
        case .spanish: return "Para tu familia son días festivos. Se marcan con un corazón en el calendario, recibes un aviso dos semanas antes para pedir el día y las sugerencias que los incluyen salen primero. Tu saldo de vacaciones no cambia."
        case .italian: return "Per la tua famiglia sono giorni di festa. Hanno un cuore nel calendario, ricevi un promemoria due settimane prima per chiedere ferie e i suggerimenti che li includono vengono prima. Il saldo ferie non cambia."
        case .portuguese: return "Para sua família, são como feriados. Eles ganham um coração no calendário, um lembrete duas semanas antes para pedir folga, e as sugestões que os incluem aparecem primeiro. Seu saldo não muda."
        case .chineseTraditional: return "對家人來說，這些日子就像國定假日。行事曆上會用愛心標出，提前兩週提醒你安排請假，包含這一天的連假推薦也會優先顯示。特休計算不受影響。"
        case .dutch: return "Voor je familie zijn dit feestdagen. Ze krijgen een hartje in de kalender, twee weken van tevoren een herinnering om vrij te vragen, en voorstellen met deze dagen komen eerst. Je verlofsaldo verandert niet."
        case .swedish: return "För familjen är det här helgdagar. De får ett hjärta i kalendern, en påminnelse två veckor innan om att ta ledigt, och förslag som innehåller dem visas först. Ditt semestersaldo påverkas inte."
        case .norwegian: return "For familien er dette helligdager. De får et hjerte i kalenderen, en påminnelse to uker før om å ta fri, og forslag som inneholder dem kommer først. Feriesaldoen endres ikke."
        case .danish: return "For familien er det helligdage. De får et hjerte i kalenderen, en påmindelse to uger før om at tage fri, og forslag med dem kommer først. Din feriesaldo ændres ikke."
        case .finnish: return "Perheelle nämä ovat juhlapäiviä. Ne merkitään kalenteriin sydämellä, saat muistutuksen kaksi viikkoa ennen vapaan pyytämisestä, ja niitä sisältävät ehdotukset näytetään ensin. Lomasaldosi ei muutu."
        case .polish: return "Dla rodziny to święta. Mają serduszko w kalendarzu, dwa tygodnie wcześniej dostaniesz przypomnienie o wzięciu wolnego, a propozycje z tymi dniami są na górze. Saldo urlopu się nie zmienia."
        case .czech: return "Pro rodinu jsou to svátky. V kalendáři mají srdíčko, dva týdny předem ti přijde připomínka, ať si vezmeš volno, a návrhy s těmito dny jsou první. Zůstatek dovolené se nemění."
        case .greek: return "Για την οικογένεια είναι γιορτές. Σημειώνονται με καρδιά στο ημερολόγιο, λαμβάνεις υπενθύμιση δύο εβδομάδες πριν για να πάρεις άδεια και οι προτάσεις που τις περιλαμβάνουν μπαίνουν πρώτες. Το υπόλοιπο άδειας δεν αλλάζει."
        case .turkish: return "Bu günler ailen için bayram gibidir. Takvimde kalple işaretlenir, iki hafta önce izin alman için hatırlatılır ve bu günleri içeren öneriler öne çıkar. İzin bakiyen değişmez."
        case .russian: return "Для семьи это праздники. В календаре они отмечены сердечком, за две недели придёт напоминание взять выходной, а варианты отдыха с этими днями будут первыми. Остаток отпуска не меняется."
        case .indonesian: return "Bagi keluarga, hari-hari ini seperti hari libur. Ditandai hati di kalender, ada pengingat dua minggu sebelumnya untuk mengambil cuti, dan saran libur yang mencakupnya tampil lebih dulu. Saldo cuti tidak berubah."
        case .thai: return "สำหรับครอบครัว วันเหล่านี้ก็เหมือนวันหยุด จะมีรูปหัวใจในปฏิทิน แจ้งเตือนล่วงหน้าสองสัปดาห์ให้ลา และคำแนะนำวันหยุดที่มีวันนี้จะขึ้นก่อน วันลาคงเหลือไม่เปลี่ยน"
        case .vietnamese: return "Với gia đình, đây là những ngày như ngày lễ. Chúng được đánh dấu trái tim trên lịch, bạn được nhắc trước hai tuần để xin nghỉ, và gợi ý kỳ nghỉ có những ngày này sẽ hiện trước. Số ngày phép không đổi."
        }
    }

    static var anniversaryEmpty: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "생신이나 결혼기념일을 넣어 보세요"
        case .english: return "Add a birthday or wedding anniversary"
        case .japanese: return "誕生日や結婚記念日を追加しましょう"
        case .chinese: return "添加生日或结婚纪念日吧"
        case .german: return "Füge einen Geburtstag oder Hochzeitstag hinzu"
        case .french: return "Ajoutez un anniversaire ou une date de mariage"
        case .spanish: return "Añade un cumpleaños o un aniversario de boda"
        case .italian: return "Aggiungi un compleanno o un anniversario di matrimonio"
        case .portuguese: return "Adicione um aniversário ou uma data de casamento"
        case .chineseTraditional: return "新增生日或結婚紀念日吧"
        case .dutch: return "Voeg een verjaardag of trouwdag toe"
        case .swedish: return "Lägg till en födelsedag eller bröllopsdag"
        case .norwegian: return "Legg til en bursdag eller bryllupsdag"
        case .danish: return "Tilføj en fødselsdag eller bryllupsdag"
        case .finnish: return "Lisää syntymäpäivä tai hääpäivä"
        case .polish: return "Dodaj urodziny lub rocznicę ślubu"
        case .czech: return "Přidej narozeniny nebo výročí svatby"
        case .greek: return "Πρόσθεσε γενέθλια ή επέτειο γάμου"
        case .turkish: return "Bir doğum günü ya da evlilik yıl dönümü ekle"
        case .russian: return "Добавьте день рождения или годовщину свадьбы"
        case .indonesian: return "Tambahkan ulang tahun atau hari pernikahan"
        case .thai: return "เพิ่มวันเกิดหรือวันครบรอบแต่งงาน"
        case .vietnamese: return "Thêm sinh nhật hoặc ngày cưới"
        }
    }

    static var anniversaryAddTitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "기념일 추가"
        case .english: return "Add Occasion"
        case .japanese: return "記念日を追加"
        case .chinese: return "添加纪念日"
        case .german: return "Tag hinzufügen"
        case .french: return "Ajouter une date"
        case .spanish: return "Añadir fecha"
        case .italian: return "Aggiungi ricorrenza"
        case .portuguese: return "Adicionar data"
        case .chineseTraditional: return "新增紀念日"
        case .dutch: return "Dag toevoegen"
        case .swedish: return "Lägg till dag"
        case .norwegian: return "Legg til dag"
        case .danish: return "Tilføj dag"
        case .finnish: return "Lisää päivä"
        case .polish: return "Dodaj datę"
        case .czech: return "Přidat výročí"
        case .greek: return "Προσθήκη γιορτής"
        case .turkish: return "Gün ekle"
        case .russian: return "Добавить дату"
        case .indonesian: return "Tambah hari"
        case .thai: return "เพิ่มวันสำคัญ"
        case .vietnamese: return "Thêm ngày"
        }
    }

    static var anniversaryEditTitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "기념일 수정"
        case .english: return "Edit Occasion"
        case .japanese: return "記念日を編集"
        case .chinese: return "编辑纪念日"
        case .german: return "Tag bearbeiten"
        case .french: return "Modifier la date"
        case .spanish: return "Editar fecha"
        case .italian: return "Modifica ricorrenza"
        case .portuguese: return "Editar data"
        case .chineseTraditional: return "編輯紀念日"
        case .dutch: return "Dag bewerken"
        case .swedish: return "Redigera dag"
        case .norwegian: return "Rediger dag"
        case .danish: return "Rediger dag"
        case .finnish: return "Muokkaa päivää"
        case .polish: return "Edytuj datę"
        case .czech: return "Upravit výročí"
        case .greek: return "Επεξεργασία γιορτής"
        case .turkish: return "Günü düzenle"
        case .russian: return "Изменить дату"
        case .indonesian: return "Ubah hari"
        case .thai: return "แก้ไขวันสำคัญ"
        case .vietnamese: return "Sửa ngày"
        }
    }

    static var anniversaryDeleteTitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "이 기념일을 지울까요?"
        case .english: return "Delete this occasion?"
        case .japanese: return "この記念日を削除しますか？"
        case .chinese: return "删除这个纪念日？"
        case .german: return "Diesen Tag löschen?"
        case .french: return "Supprimer cette date ?"
        case .spanish: return "¿Eliminar esta fecha?"
        case .italian: return "Eliminare questa ricorrenza?"
        case .portuguese: return "Excluir esta data?"
        case .chineseTraditional: return "刪除這個紀念日？"
        case .dutch: return "Deze dag verwijderen?"
        case .swedish: return "Radera den här dagen?"
        case .norwegian: return "Slette denne dagen?"
        case .danish: return "Slet denne dag?"
        case .finnish: return "Poistetaanko tämä päivä?"
        case .polish: return "Usunąć tę datę?"
        case .czech: return "Smazat toto výročí?"
        case .greek: return "Διαγραφή αυτής της γιορτής;"
        case .turkish: return "Bu gün silinsin mi?"
        case .russian: return "Удалить эту дату?"
        case .indonesian: return "Hapus hari ini?"
        case .thai: return "ลบวันสำคัญนี้ไหม"
        case .vietnamese: return "Xóa ngày này?"
        }
    }

    static var anniversaryKindSection: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "종류"
        case .english: return "Type"
        case .japanese: return "種類"
        case .chinese: return "类型"
        case .german: return "Art"
        case .french: return "Type"
        case .spanish: return "Tipo"
        case .italian: return "Tipo"
        case .portuguese: return "Tipo"
        case .chineseTraditional: return "類型"
        case .dutch: return "Soort"
        case .swedish: return "Typ"
        case .norwegian: return "Type"
        case .danish: return "Type"
        case .finnish: return "Tyyppi"
        case .polish: return "Rodzaj"
        case .czech: return "Druh"
        case .greek: return "Είδος"
        case .turkish: return "Tür"
        case .russian: return "Тип"
        case .indonesian: return "Jenis"
        case .thai: return "ประเภท"
        case .vietnamese: return "Loại"
        }
    }

    static var anniversaryRelationSection: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "누구의 날인가요"
        case .english: return "Whose day is it?"
        case .japanese: return "誰の日ですか"
        case .chinese: return "是谁的日子"
        case .german: return "Wessen Tag ist es?"
        case .french: return "De qui s’agit-il ?"
        case .spanish: return "¿De quién es el día?"
        case .italian: return "Di chi è la giornata?"
        case .portuguese: return "De quem é o dia?"
        case .chineseTraditional: return "是誰的日子"
        case .dutch: return "Wiens dag is het?"
        case .swedish: return "Vems dag är det?"
        case .norwegian: return "Hvem sin dag er det?"
        case .danish: return "Hvis dag er det?"
        case .finnish: return "Kenen päivä?"
        case .polish: return "Czyj to dzień?"
        case .czech: return "Čí je to den?"
        case .greek: return "Ποιανού είναι η μέρα;"
        case .turkish: return "Kimin günü?"
        case .russian: return "Чей это день?"
        case .indonesian: return "Hari siapa?"
        case .thai: return "เป็นวันของใคร"
        case .vietnamese: return "Ngày của ai?"
        }
    }

    static var anniversaryRelationPlaceholder: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "관계 (예: 엄마)"
        case .english: return "Relationship (e.g. Mom)"
        case .japanese: return "続柄（例：母）"
        case .chinese: return "关系（例如：妈妈）"
        case .german: return "Beziehung (z. B. Mama)"
        case .french: return "Lien (ex. : Maman)"
        case .spanish: return "Parentesco (p. ej., mamá)"
        case .italian: return "Parentela (es. mamma)"
        case .portuguese: return "Parentesco (ex.: mãe)"
        case .chineseTraditional: return "關係（例如：媽媽）"
        case .dutch: return "Relatie (bijv. mama)"
        case .swedish: return "Relation (t.ex. mamma)"
        case .norwegian: return "Relasjon (f.eks. mamma)"
        case .danish: return "Relation (f.eks. mor)"
        case .finnish: return "Suhde (esim. äiti)"
        case .polish: return "Relacja (np. mama)"
        case .czech: return "Vztah (např. máma)"
        case .greek: return "Σχέση (π.χ. μαμά)"
        case .turkish: return "Yakınlık (ör. annem)"
        case .russian: return "Кто это (например, мама)"
        case .indonesian: return "Hubungan (mis. Ibu)"
        case .thai: return "ความสัมพันธ์ (เช่น แม่)"
        case .vietnamese: return "Quan hệ (vd: mẹ)"
        }
    }

    static var anniversaryLunarToggle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "음력"
        case .english: return "Lunar calendar"
        case .japanese: return "旧暦"
        case .chinese: return "农历"
        case .german: return "Mondkalender"
        case .french: return "Calendrier lunaire"
        case .spanish: return "Calendario lunar"
        case .italian: return "Calendario lunare"
        case .portuguese: return "Calendário lunar"
        case .chineseTraditional: return "農曆"
        case .dutch: return "Maankalender"
        case .swedish: return "Månkalender"
        case .norwegian: return "Månekalender"
        case .danish: return "Månekalender"
        case .finnish: return "Kuukalenteri"
        case .polish: return "Kalendarz księżycowy"
        case .czech: return "Lunární kalendář"
        case .greek: return "Σεληνιακό ημερολόγιο"
        case .turkish: return "Ay takvimi"
        case .russian: return "Лунный календарь"
        case .indonesian: return "Kalender lunar"
        case .thai: return "จันทรคติ"
        case .vietnamese: return "Âm lịch"
        }
    }

    static var anniversaryLunarFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "고른 날의 음력 날짜를 해마다 양력으로 옮겨 맞춰요. 음력 생신이나 제사에 쓰세요."
        case .english: return "Each year follows the lunar date of the day you picked. Use it for lunar birthdays and memorial rites."
        case .japanese: return "選んだ日の旧暦の日付に合わせて、毎年の日付を決めます。旧暦の誕生日や法事に使えます。"
        case .chinese: return "每年按所选日期的农历日子换算成公历。适合农历生日和祭日。"
        case .german: return "Jedes Jahr richtet sich nach dem Mondkalenderdatum des gewählten Tages – für Geburtstage und Gedenktage nach dem Mondkalender."
        case .french: return "Chaque année suit la date lunaire du jour choisi. Pratique pour les anniversaires et les commémorations au calendrier lunaire."
        case .spanish: return "Cada año sigue la fecha lunar del día elegido. Úsalo para cumpleaños y conmemoraciones del calendario lunar."
        case .italian: return "Ogni anno segue la data lunare del giorno scelto. Utile per compleanni e commemorazioni secondo il calendario lunare."
        case .portuguese: return "A cada ano segue a data lunar do dia escolhido. Use para aniversários e homenagens pelo calendário lunar."
        case .chineseTraditional: return "每年依所選日期的農曆日子換算成國曆。適合農曆生日和忌日。"
        case .dutch: return "Elk jaar volgt de maandatum van de gekozen dag. Handig voor verjaardagen en gedenkdagen volgens de maankalender."
        case .swedish: return "Varje år följer måndatumet för dagen du valde. Passar för födelsedagar och minnesdagar enligt månkalendern."
        case .norwegian: return "Hvert år følger månedatoen for dagen du valgte. Passer for bursdager og minnedager etter månekalenderen."
        case .danish: return "Hvert år følger månedatoen for den dag, du valgte. Passer til fødselsdage og mindedage efter månekalenderen."
        case .finnish: return "Joka vuosi seuraa valitun päivän kuukalenterin päivämäärää. Sopii kuukalenterin syntymäpäiviin ja muistopäiviin."
        case .polish: return "Co roku według daty księżycowej wybranego dnia. Do urodzin i rocznic liczonych według kalendarza księżycowego."
        case .czech: return "Každý rok se řídí lunárním datem zvoleného dne. Hodí se pro narozeniny a výročí podle lunárního kalendáře."
        case .greek: return "Κάθε χρόνο ακολουθεί τη σεληνιακή ημερομηνία της μέρας που διάλεξες. Για γενέθλια και μνημόσυνα με το σεληνιακό ημερολόγιο."
        case .turkish: return "Her yıl seçtiğin günün ay takvimindeki tarihine göre belirlenir. Ay takvimine göre doğum günleri ve anmalar için."
        case .russian: return "Каждый год дата считается по лунному календарю выбранного дня. Для дней рождения и памятных дат по лунному календарю."
        case .indonesian: return "Setiap tahun mengikuti tanggal lunar dari hari yang dipilih. Cocok untuk ulang tahun dan peringatan menurut kalender lunar."
        case .thai: return "แต่ละปีจะตามวันจันทรคติของวันที่เลือก ใช้กับวันเกิดหรือวันทำบุญตามจันทรคติ"
        case .vietnamese: return "Mỗi năm sẽ theo ngày âm lịch của ngày đã chọn. Dùng cho sinh nhật âm lịch và ngày giỗ."
        }
    }

    static var anniversaryDateFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "처음 날짜(태어난 해·결혼한 해)를 넣으면 몇 번째인지도 세어 드려요."
        case .english: return "Enter the original date, with the birth or wedding year, to see which anniversary it is."
        case .japanese: return "最初の日付（生まれた年・結婚した年）を入れると、何回目かも数えます。"
        case .chinese: return "填写最初的日期（出生年份、结婚年份），还会算出是第几个。"
        case .german: return "Mit dem ursprünglichen Datum (Geburts- oder Hochzeitsjahr) siehst du auch, der wievielte es ist."
        case .french: return "Indiquez la date d’origine (année de naissance ou de mariage) pour voir de quel anniversaire il s’agit."
        case .spanish: return "Pon la fecha original (año de nacimiento o de boda) para ver cuántos años se cumplen."
        case .italian: return "Inserisci la data originale (anno di nascita o di matrimonio) per sapere quanti anni sono."
        case .portuguese: return "Informe a data original (ano de nascimento ou de casamento) para ver quantos anos são."
        case .chineseTraditional: return "填寫最初的日期（出生年份、結婚年份），還會算出是第幾個。"
        case .dutch: return "Vul de oorspronkelijke datum in (geboorte- of trouwjaar) om te zien het hoeveelste het is."
        case .swedish: return "Ange det ursprungliga datumet (födelse- eller bröllopsår) så ser du hur många år det blir."
        case .norwegian: return "Skriv inn den opprinnelige datoen (fødsels- eller bryllupsår) for å se hvor mange år det blir."
        case .danish: return "Angiv den oprindelige dato (fødsels- eller bryllupsår) for at se, hvor mange år det bliver."
        case .finnish: return "Anna alkuperäinen päivä (syntymä- tai hääpäivän vuosi), niin näet monesko se on."
        case .polish: return "Podaj pierwotną datę (rok urodzenia lub ślubu), a zobaczysz, która to rocznica."
        case .czech: return "Zadej původní datum (rok narození nebo svatby) a uvidíš, kolikáté výročí to je."
        case .greek: return "Βάλε την αρχική ημερομηνία (έτος γέννησης ή γάμου) για να δεις πόσα χρόνια κλείνουν."
        case .turkish: return "Asıl tarihi (doğum ya da evlilik yılıyla) girersen kaçıncı yıl olduğunu da görürsün."
        case .russian: return "Укажите исходную дату (год рождения или свадьбы), чтобы видеть, какая это годовщина."
        case .indonesian: return "Masukkan tanggal awal (tahun lahir atau menikah) untuk melihat yang keberapa."
        case .thai: return "ใส่วันแรก (ปีเกิดหรือปีที่แต่งงาน) เพื่อดูว่าครบกี่ปี"
        case .vietnamese: return "Nhập ngày gốc (năm sinh hoặc năm cưới) để xem là lần thứ mấy."
        }
    }

    static var anniversaryNamePlaceholder: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "비워 두면 관계와 종류로 보여요"
        case .english: return "Optional, shown as relationship and type"
        case .japanese: return "空欄なら続柄と種類で表示"
        case .chinese: return "留空则显示关系和类型"
        case .german: return "Optional – sonst Beziehung und Art"
        case .french: return "Facultatif, sinon lien et type"
        case .spanish: return "Opcional; si no, parentesco y tipo"
        case .italian: return "Facoltativo, altrimenti parentela e tipo"
        case .portuguese: return "Opcional; senão, parentesco e tipo"
        case .chineseTraditional: return "留空則顯示關係和類型"
        case .dutch: return "Optioneel, anders relatie en soort"
        case .swedish: return "Valfritt, annars relation och typ"
        case .norwegian: return "Valgfritt, ellers relasjon og type"
        case .danish: return "Valgfrit, ellers relation og type"
        case .finnish: return "Valinnainen, muuten suhde ja tyyppi"
        case .polish: return "Opcjonalnie, inaczej relacja i rodzaj"
        case .czech: return "Volitelné, jinak vztah a druh"
        case .greek: return "Προαιρετικό, αλλιώς σχέση και είδος"
        case .turkish: return "İsteğe bağlı; boşsa yakınlık ve tür"
        case .russian: return "Необязательно — иначе «кто» и тип"
        case .indonesian: return "Opsional, jika kosong pakai hubungan dan jenis"
        case .thai: return "ไม่ใส่ก็ได้ จะแสดงความสัมพันธ์และประเภท"
        case .vietnamese: return "Không bắt buộc, để trống sẽ hiện quan hệ và loại"
        }
    }

    static var anniversaryRemindToggle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "미리 알림"
        case .english: return "Reminders"
        case .japanese: return "事前のお知らせ"
        case .chinese: return "提前提醒"
        case .german: return "Erinnerungen"
        case .french: return "Rappels"
        case .spanish: return "Recordatorios"
        case .italian: return "Promemoria"
        case .portuguese: return "Lembretes"
        case .chineseTraditional: return "提前提醒"
        case .dutch: return "Herinneringen"
        case .swedish: return "Påminnelser"
        case .norwegian: return "Påminnelser"
        case .danish: return "Påmindelser"
        case .finnish: return "Muistutukset"
        case .polish: return "Przypomnienia"
        case .czech: return "Připomínky"
        case .greek: return "Υπενθυμίσεις"
        case .turkish: return "Hatırlatmalar"
        case .russian: return "Напоминания"
        case .indonesian: return "Pengingat"
        case .thai: return "การแจ้งเตือน"
        case .vietnamese: return "Nhắc trước"
        }
    }

    static var anniversaryRemindFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "2주 전에 휴가를 챙기라고, 당일 아침에는 오늘이라고 알려 드려요. 그날 휴가가 이미 있거나 원래 쉬는 날이면 2주 전 알림은 건너뛰어요."
        case .english: return "You get a reminder two weeks ahead to book time off, and another on the morning of the day. The two‑week reminder is skipped if you're already off that day."
        case .japanese: return "2週間前に休みを取るよう、当日の朝には今日だとお知らせします。その日がすでに休みなら2週間前のお知らせは省きます。"
        case .chinese: return "提前两周提醒你安排休假，当天早上再提醒一次。如果那天已经休假或本来就休息，就不会发两周前的提醒。"
        case .german: return "Zwei Wochen vorher erinnern wir dich daran, Urlaub zu nehmen, und am Morgen des Tages noch einmal. Bist du an dem Tag schon frei, entfällt die erste Erinnerung."
        case .french: return "Un rappel deux semaines avant pour poser un congé, et un autre le matin même. Le premier est ignoré si vous êtes déjà en repos ce jour-là."
        case .spanish: return "Te avisamos dos semanas antes para que pidas el día y otra vez esa misma mañana. Si ya libras ese día, no hay aviso previo."
        case .italian: return "Ti avvisiamo due settimane prima per chiedere ferie e di nuovo la mattina stessa. Se quel giorno sei già libero, il primo avviso salta."
        case .portuguese: return "Avisamos duas semanas antes para você pedir folga e de novo na manhã do dia. Se você já estiver de folga, o primeiro aviso não é enviado."
        case .chineseTraditional: return "提前兩週提醒你安排請假，當天早上再提醒一次。如果那天已經請假或本來就放假，就不會發兩週前的提醒。"
        case .dutch: return "Twee weken van tevoren een herinnering om vrij te vragen, en nog een op de ochtend zelf. Ben je die dag al vrij, dan vervalt de eerste."
        case .swedish: return "En påminnelse två veckor innan om att ta ledigt, och en till på morgonen samma dag. Är du redan ledig den dagen hoppas den första över."
        case .norwegian: return "En påminnelse to uker før om å ta fri, og en til samme morgen. Har du allerede fri den dagen, hoppes den første over."
        case .danish: return "En påmindelse to uger før om at tage fri, og en til samme morgen. Har du allerede fri den dag, springes den første over."
        case .finnish: return "Muistutus kaksi viikkoa ennen vapaan pyytämisestä ja toinen päivän aamuna. Jos olet jo vapaalla, ensimmäinen jää pois."
        case .polish: return "Przypomnienie dwa tygodnie wcześniej o wzięciu wolnego i drugie rano tego dnia. Jeśli już masz wolne, pierwszego nie będzie."
        case .czech: return "Připomínka dva týdny předem, ať si vezmeš volno, a další ráno v ten den. Pokud už máš volno, první se vynechá."
        case .greek: return "Υπενθύμιση δύο εβδομάδες πριν για να πάρεις άδεια και άλλη μία το πρωί της ημέρας. Αν έχεις ήδη ρεπό, η πρώτη παραλείπεται."
        case .turkish: return "İki hafta önce izin alman için, o günün sabahı da bugün olduğunu hatırlatırız. O gün zaten izinliysen ilk hatırlatma gelmez."
        case .russian: return "Напомним за две недели, чтобы взять выходной, и ещё раз утром в этот день. Если в этот день вы уже не работаете, первое напоминание не придёт."
        case .indonesian: return "Pengingat dua minggu sebelumnya untuk mengambil cuti, dan sekali lagi pada pagi harinya. Jika hari itu sudah libur, pengingat pertama dilewati."
        case .thai: return "แจ้งเตือนล่วงหน้าสองสัปดาห์ให้ลา และอีกครั้งในเช้าวันนั้น ถ้าวันนั้นหยุดอยู่แล้วจะไม่แจ้งเตือนล่วงหน้า"
        case .vietnamese: return "Nhắc trước hai tuần để bạn xin nghỉ, và nhắc lại vào sáng hôm đó. Nếu hôm đó bạn đã nghỉ thì bỏ qua lời nhắc trước."
        }
    }

    static var upcomingAnniversariesTitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "다가오는 가족 기념일"
        case .english: return "Upcoming Family Occasions"
        case .japanese: return "もうすぐの家族の記念日"
        case .chinese: return "即将到来的家庭纪念日"
        case .german: return "Bald: Familientage"
        case .french: return "Dates de famille à venir"
        case .spanish: return "Próximas fechas familiares"
        case .italian: return "Prossime ricorrenze di famiglia"
        case .portuguese: return "Próximas datas da família"
        case .chineseTraditional: return "即將到來的家庭紀念日"
        case .dutch: return "Binnenkort: familiedagen"
        case .swedish: return "Kommande familjedagar"
        case .norwegian: return "Kommende merkedager"
        case .danish: return "Kommende mærkedage"
        case .finnish: return "Tulevat perheen merkkipäivät"
        case .polish: return "Nadchodzące rodzinne święta"
        case .czech: return "Blížící se rodinná výročí"
        case .greek: return "Επερχόμενες οικογενειακές γιορτές"
        case .turkish: return "Yaklaşan aile günleri"
        case .russian: return "Ближайшие семейные даты"
        case .indonesian: return "Hari penting keluarga mendatang"
        case .thai: return "วันสำคัญของครอบครัวที่ใกล้เข้ามา"
        case .vietnamese: return "Ngày kỷ niệm gia đình sắp tới"
        }
    }

    static var anniversaryLeaveReady: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "휴가 있음"
        case .english: return "Off booked"
        case .japanese: return "休み済み"
        case .chinese: return "已请假"
        case .german: return "Frei geplant"
        case .french: return "Congé posé"
        case .spanish: return "Día pedido"
        case .italian: return "Ferie prese"
        case .portuguese: return "Folga marcada"
        case .chineseTraditional: return "已請假"
        case .dutch: return "Vrij gepland"
        case .swedish: return "Ledig bokad"
        case .norwegian: return "Fri planlagt"
        case .danish: return "Fri planlagt"
        case .finnish: return "Vapaa sovittu"
        case .polish: return "Wolne zaplanowane"
        case .czech: return "Volno naplánováno"
        case .greek: return "Άδεια κλεισμένη"
        case .turkish: return "İzin alındı"
        case .russian: return "Выходной есть"
        case .indonesian: return "Sudah cuti"
        case .thai: return "ลาแล้ว"
        case .vietnamese: return "Đã xin nghỉ"
        }
    }

    static var anniversaryAlreadyOff: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "쉬는 날"
        case .english: return "Day off"
        case .japanese: return "休日"
        case .chinese: return "休息日"
        case .german: return "Frei"
        case .french: return "Repos"
        case .spanish: return "Libre"
        case .italian: return "Libero"
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
        case .thai: return "วันหยุด"
        case .vietnamese: return "Ngày nghỉ"
        }
    }

    static var anniversaryTakeLeave: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "휴가 내기"
        case .english: return "Take Leave"
        case .japanese: return "休みを取る"
        case .chinese: return "请假"
        case .german: return "Urlaub nehmen"
        case .french: return "Poser congé"
        case .spanish: return "Pedir día"
        case .italian: return "Chiedi ferie"
        case .portuguese: return "Pedir folga"
        case .chineseTraditional: return "請假"
        case .dutch: return "Vrij vragen"
        case .swedish: return "Ta ledigt"
        case .norwegian: return "Ta fri"
        case .danish: return "Tag fri"
        case .finnish: return "Pyydä vapaa"
        case .polish: return "Weź wolne"
        case .czech: return "Vzít volno"
        case .greek: return "Πάρε άδεια"
        case .turkish: return "İzin al"
        case .russian: return "Взять отгул"
        case .indonesian: return "Ambil cuti"
        case .thai: return "ลางาน"
        case .vietnamese: return "Xin nghỉ"
        }
    }

    static func anniversaryKindName(_ kind: AnniversaryKind) -> String {
        let lang = LanguageManager.shared.currentLanguage
        switch kind {
        case .birthday:
            switch lang {
            case .korean: return "생일"
            case .english: return "Birthday"
            case .japanese: return "誕生日"
            case .chinese: return "生日"
            case .german: return "Geburtstag"
            case .french: return "Anniversaire"
            case .spanish: return "Cumpleaños"
            case .italian: return "Compleanno"
            case .portuguese: return "Aniversário"
            case .chineseTraditional: return "生日"
            case .dutch: return "Verjaardag"
            case .swedish: return "Födelsedag"
            case .norwegian: return "Bursdag"
            case .danish: return "Fødselsdag"
            case .finnish: return "Syntymäpäivä"
            case .polish: return "Urodziny"
            case .czech: return "Narozeniny"
            case .greek: return "Γενέθλια"
            case .turkish: return "Doğum günü"
            case .russian: return "День рождения"
            case .indonesian: return "Ulang tahun"
            case .thai: return "วันเกิด"
            case .vietnamese: return "Sinh nhật"
            }
        case .wedding:
            switch lang {
            case .korean: return "결혼기념일"
            case .english: return "Wedding anniversary"
            case .japanese: return "結婚記念日"
            case .chinese: return "结婚纪念日"
            case .german: return "Hochzeitstag"
            case .french: return "Anniversaire de mariage"
            case .spanish: return "Aniversario de boda"
            case .italian: return "Anniversario di matrimonio"
            case .portuguese: return "Aniversário de casamento"
            case .chineseTraditional: return "結婚紀念日"
            case .dutch: return "Trouwdag"
            case .swedish: return "Bröllopsdag"
            case .norwegian: return "Bryllupsdag"
            case .danish: return "Bryllupsdag"
            case .finnish: return "Hääpäivä"
            case .polish: return "Rocznica ślubu"
            case .czech: return "Výročí svatby"
            case .greek: return "Επέτειος γάμου"
            case .turkish: return "Evlilik yıl dönümü"
            case .russian: return "Годовщина свадьбы"
            case .indonesian: return "Hari pernikahan"
            case .thai: return "วันครบรอบแต่งงาน"
            case .vietnamese: return "Kỷ niệm ngày cưới"
            }
        case .memorial:
            switch lang {
            case .korean: return "기일"
            case .english: return "Remembrance day"
            case .japanese: return "命日"
            case .chinese: return "忌日"
            case .german: return "Todestag"
            case .french: return "Jour de mémoire"
            case .spanish: return "Aniversario luctuoso"
            case .italian: return "Anniversario della scomparsa"
            case .portuguese: return "Data de falecimento"
            case .chineseTraditional: return "忌日"
            case .dutch: return "Sterfdag"
            case .swedish: return "Minnesdag"
            case .norwegian: return "Minnedag"
            case .danish: return "Mindedag"
            case .finnish: return "Muistopäivä"
            case .polish: return "Rocznica śmierci"
            case .czech: return "Výročí úmrtí"
            case .greek: return "Μνημόσυνο"
            case .turkish: return "Anma günü"
            case .russian: return "День памяти"
            case .indonesian: return "Hari peringatan"
            case .thai: return "วันรำลึก"
            case .vietnamese: return "Ngày giỗ"
            }
        case .other:
            switch lang {
            case .korean: return "기념일"
            case .english: return "Special day"
            case .japanese: return "記念日"
            case .chinese: return "纪念日"
            case .german: return "Besonderer Tag"
            case .french: return "Jour spécial"
            case .spanish: return "Día especial"
            case .italian: return "Giorno speciale"
            case .portuguese: return "Dia especial"
            case .chineseTraditional: return "紀念日"
            case .dutch: return "Speciale dag"
            case .swedish: return "Högtidsdag"
            case .norwegian: return "Merkedag"
            case .danish: return "Mærkedag"
            case .finnish: return "Merkkipäivä"
            case .polish: return "Ważny dzień"
            case .czech: return "Významný den"
            case .greek: return "Ξεχωριστή μέρα"
            case .turkish: return "Özel gün"
            case .russian: return "Памятная дата"
            case .indonesian: return "Hari spesial"
            case .thai: return "วันสำคัญ"
            case .vietnamese: return "Ngày kỷ niệm"
            }
        }
    }

    static func anniversaryOrdinal(_ kind: AnniversaryKind, _ n: Int) -> String {
        let i: Int
        switch kind { case .birthday: i = 0; case .wedding: i = 1; case .memorial: i = 2; case .other: i = 3 }
        let texts: [String]
        switch LanguageManager.shared.currentLanguage {
        case .korean: texts = ["\(n)번째 생일", "\(n)주년", "\(n)주기", "\(n)주년"]
        case .english: texts = ["Turns \(n)", "\(n) years married", "\(n) years", "\(n) years"]
        case .japanese: texts = ["\(n)歳", "\(n)周年", "没後\(n)年", "\(n)周年"]
        case .chinese: texts = ["\(n)岁生日", "\(n)周年", "\(n)周年", "\(n)周年"]
        case .german: texts = ["wird \(n)", "\(n). Hochzeitstag", "\(n). Todestag", "\(n). Jahrestag"]
        case .french: texts = ["\(n) ans", "\(n) ans de mariage", "\(n) ans", "\(n) ans"]
        case .spanish: texts = ["Cumple \(n)", "\(n) años de casados", "\(n) años", "\(n) años"]
        case .italian: texts = ["Compie \(n) anni", "\(n) anni di matrimonio", "\(n) anni", "\(n) anni"]
        case .portuguese: texts = ["Faz \(n) anos", "\(n) anos de casados", "\(n) anos", "\(n) anos"]
        case .chineseTraditional: texts = ["\(n)歲生日", "\(n)週年", "\(n)週年", "\(n)週年"]
        case .dutch: texts = ["Wordt \(n)", "\(n) jaar getrouwd", "\(n) jaar", "\(n) jaar"]
        case .swedish: texts = ["Fyller \(n)", "\(n) år som gifta", "\(n) år", "\(n) år"]
        case .norwegian: texts = ["Fyller \(n)", "\(n) år som gift", "\(n) år", "\(n) år"]
        case .danish: texts = ["Fylder \(n)", "\(n) år som gift", "\(n) år", "\(n) år"]
        case .finnish: texts = ["Täyttää \(n)", "\(n) vuotta naimisissa", "\(n) vuotta", "\(n) vuotta"]
        case .polish: texts = ["\(n). urodziny", "\(n). rocznica ślubu", "\(n). rocznica", "\(n). rocznica"]
        case .czech: texts = ["\(n). narozeniny", "\(n). výročí svatby", "\(n). výročí", "\(n). výročí"]
        case .greek: texts = ["Κλείνει τα \(n)", "\(n) χρόνια γάμου", "\(n) χρόνια", "\(n) χρόνια"]
        case .turkish: texts = ["\(n) yaşına giriyor", "\(n). evlilik yıl dönümü", "\(n). yıl", "\(n). yıl"]
        case .russian: texts = ["Исполняется \(n)", "\(n)-я годовщина свадьбы", "\(n)-я годовщина", "\(n)-я годовщина"]
        case .indonesian: texts = ["Ulang tahun ke-\(n)", "Tahun ke-\(n) menikah", "Tahun ke-\(n)", "Tahun ke-\(n)"]
        case .thai: texts = ["อายุครบ \(n) ปี", "แต่งงานครบ \(n) ปี", "ครบ \(n) ปี", "ครบรอบ \(n) ปี"]
        case .vietnamese: texts = ["Tròn \(n) tuổi", "\(n) năm ngày cưới", "Giỗ lần thứ \(n)", "\(n) năm"]
        }
        return texts[i]
    }

    static func anniversaryTodayBody(_ kind: AnniversaryKind, ordinal: Int?) -> String {
        let i: Int
        switch kind { case .birthday: i = 0; case .wedding: i = 1; case .memorial: i = 2; case .other: i = 3 }
        let texts: [String]
        switch LanguageManager.shared.currentLanguage {
        case .korean: texts = ["축하 인사를 전해 보세요", "함께한 시간을 축하해요", "가족과 함께 기억해요", "가족과 함께 보내세요"]
        case .english: texts = ["Send your best wishes", "Celebrate your time together", "Remember them together as a family", "Spend it with your family"]
        case .japanese: texts = ["お祝いの言葉を伝えましょう", "一緒に過ごした時間をお祝いしましょう", "家族で一緒に偲びましょう", "家族と一緒に過ごしましょう"]
        case .chinese: texts = ["送上你的祝福吧", "庆祝你们一起走过的时光", "和家人一起缅怀", "和家人一起度过吧"]
        case .german: texts = ["Schick deine Glückwünsche", "Feiert eure gemeinsame Zeit", "Gedenkt gemeinsam als Familie", "Verbring den Tag mit deiner Familie"]
        case .french: texts = ["Envoyez vos vœux", "Célébrez votre temps ensemble", "Souvenez-vous ensemble, en famille", "Passez la journée en famille"]
        case .spanish: texts = ["Envía tus felicitaciones", "Celebrad el tiempo juntos", "Recordadlo juntos en familia", "Pásalo con tu familia"]
        case .italian: texts = ["Manda i tuoi auguri", "Festeggiate il tempo insieme", "Ricordatelo insieme in famiglia", "Passalo con la tua famiglia"]
        case .portuguese: texts = ["Mande seus parabéns", "Celebrem o tempo juntos", "Lembrem juntos, em família", "Passe o dia com a família"]
        case .chineseTraditional: texts = ["送上你的祝福吧", "慶祝你們一起走過的時光", "和家人一起緬懷", "和家人一起度過吧"]
        case .dutch: texts = ["Stuur je felicitaties", "Vier jullie tijd samen", "Sta er samen als familie bij stil", "Breng de dag door met je familie"]
        case .swedish: texts = ["Skicka en hälsning", "Fira er tid tillsammans", "Minns tillsammans som familj", "Tillbringa dagen med familjen"]
        case .norwegian: texts = ["Send en hilsen", "Feir tiden dere har hatt sammen", "Minnes sammen som familie", "Tilbring dagen med familien"]
        case .danish: texts = ["Send en hilsen", "Fejr jeres tid sammen", "Mindes sammen som familie", "Tilbring dagen med familien"]
        case .finnish: texts = ["Lähetä onnittelut", "Juhlikaa yhteistä aikaanne", "Muistakaa yhdessä perheenä", "Vietä päivä perheen kanssa"]
        case .polish: texts = ["Złóż życzenia", "Świętujcie wspólny czas", "Wspominajcie razem, w rodzinie", "Spędź ten dzień z rodziną"]
        case .czech: texts = ["Pošli přání", "Oslavte společný čas", "Vzpomeňte společně jako rodina", "Stráv den s rodinou"]
        case .greek: texts = ["Στείλε τις ευχές σου", "Γιορτάστε τον χρόνο σας μαζί", "Θυμηθείτε μαζί ως οικογένεια", "Πέρνα τη μέρα με την οικογένεια"]
        case .turkish: texts = ["Tebrik etmeyi unutma", "Birlikte geçen zamanı kutlayın", "Ailece birlikte anın", "Günü ailenle geçir"]
        case .russian: texts = ["Поздравьте", "Отпразднуйте время, проведённое вместе", "Вспомните вместе всей семьёй", "Проведите день с семьёй"]
        case .indonesian: texts = ["Sampaikan ucapan selamat", "Rayakan waktu bersama", "Kenang bersama keluarga", "Habiskan hari bersama keluarga"]
        case .thai: texts = ["อย่าลืมส่งคำอวยพร", "ฉลองเวลาที่อยู่ด้วยกัน", "รำลึกถึงพร้อมกันกับครอบครัว", "ใช้เวลากับครอบครัว"]
        case .vietnamese: texts = ["Gửi lời chúc mừng nhé", "Mừng quãng thời gian bên nhau", "Cùng gia đình tưởng nhớ", "Dành thời gian bên gia đình"]
        }
        guard let ordinal else { return texts[i] }
        return "\(anniversaryOrdinal(kind, ordinal)) · \(texts[i])"
    }

    static func lunarDateLabel(month: Int, day: Int, isLeap: Bool) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "음력 \(isLeap ? "윤" : "")\(month)월 \(day)일"
        case .english: return "Lunar \(month)/\(day)\(isLeap ? " (leap month)" : "")"
        case .japanese: return "旧暦\(isLeap ? "閏" : "")\(month)月\(day)日"
        case .chinese: return "农历\(isLeap ? "闰" : "")\(month)月\(day)日"
        case .german: return "Mondkalender: \(day).\(month).\(isLeap ? " (Schaltmonat)" : "")"
        case .french: return "Lunaire : \(day)/\(month)\(isLeap ? " (mois intercalaire)" : "")"
        case .spanish: return "Lunar: \(day)/\(month)\(isLeap ? " (mes intercalar)" : "")"
        case .italian: return "Lunare: \(day)/\(month)\(isLeap ? " (mese intercalare)" : "")"
        case .portuguese: return "Lunar: \(day)/\(month)\(isLeap ? " (mês intercalar)" : "")"
        case .chineseTraditional: return "農曆\(isLeap ? "閏" : "")\(month)月\(day)日"
        case .dutch: return "Maankalender: \(day)-\(month)\(isLeap ? " (schrikkelmaand)" : "")"
        case .swedish: return "Månkalender: \(day)/\(month)\(isLeap ? " (skottmånad)" : "")"
        case .norwegian: return "Månekalender: \(day).\(month).\(isLeap ? " (skuddmåned)" : "")"
        case .danish: return "Månekalender: \(day)/\(month)\(isLeap ? " (skudmåned)" : "")"
        case .finnish: return "Kuukalenteri: \(day).\(month).\(isLeap ? " (karkauskuu)" : "")"
        case .polish: return "Kalendarz księżycowy: \(day).\(month)\(isLeap ? " (miesiąc przestępny)" : "")"
        case .czech: return "Lunární kalendář: \(day). \(month).\(isLeap ? " (přestupný měsíc)" : "")"
        case .greek: return "Σεληνιακό: \(day)/\(month)\(isLeap ? " (εμβόλιμος μήνας)" : "")"
        case .turkish: return "Ay takvimi: \(day)/\(month)\(isLeap ? " (artık ay)" : "")"
        case .russian: return "По лунному: \(day).\(month)\(isLeap ? " (високосный месяц)" : "")"
        case .indonesian: return "Kalender lunar: \(day)/\(month)\(isLeap ? " (bulan kabisat)" : "")"
        case .thai: return "จันทรคติ \(day)/\(month)\(isLeap ? " (อธิกมาส)" : "")"
        case .vietnamese: return "Âm lịch \(day)/\(month)\(isLeap ? " (nhuận)" : "")"
        }
    }

    static func anniversaryLeaveTitle(_ name: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\(name)에 함께 쉬기"
        case .english: return "Be there for \(name)"
        case .japanese: return "\(name)に合わせて休む"
        case .chinese: return "\(name)陪伴家人"
        case .german: return "Frei für: \(name)"
        case .french: return "Libre pour : \(name)"
        case .spanish: return "Libre para: \(name)"
        case .italian: return "Libero per: \(name)"
        case .portuguese: return "Folga para: \(name)"
        case .chineseTraditional: return "\(name)陪伴家人"
        case .dutch: return "Vrij voor: \(name)"
        case .swedish: return "Ledig för: \(name)"
        case .norwegian: return "Fri til: \(name)"
        case .danish: return "Fri til: \(name)"
        case .finnish: return "Vapaata: \(name)"
        case .polish: return "Wolne na: \(name)"
        case .czech: return "Volno na: \(name)"
        case .greek: return "Ρεπό για: \(name)"
        case .turkish: return "\(name) için izin"
        case .russian: return "Выходной: \(name)"
        case .indonesian: return "Libur untuk \(name)"
        case .thai: return "หยุดวัน \(name)"
        case .vietnamese: return "Nghỉ dịp \(name)"
        }
    }

    static func anniversaryLeaveDesc(_ name: String, leaveDays l: Int, totalDays t: Int) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "연차 \(l)일로 \(t)일 연휴를 만들어, \(name)에 가족과 함께할 수 있어요."
        case .english: return "Use \(l) leave day\(l == 1 ? "" : "s") for \(t) days off and spend \(name) with your family."
        case .japanese: return "有給\(l)日で\(t)連休に。\(name)を家族と過ごせます。"
        case .chinese: return "用\(l)天年假连休\(t)天，和家人一起过\(name)。"
        case .german: return "Mit \(l) Urlaubstag\(l == 1 ? "" : "en") hast du \(t) Tage frei und verbringst den Tag mit der Familie."
        case .french: return "Avec \(l) jour\(l == 1 ? "" : "s") de congé, \(t) jours de repos pour être en famille ce jour-là."
        case .spanish: return "Con \(l) día\(l == 1 ? "" : "s") de vacaciones tienes \(t) días libres para estar en familia ese día."
        case .italian: return "Con \(l) giorn\(l == 1 ? "o" : "i") di ferie hai \(t) giorni liberi per stare in famiglia quel giorno."
        case .portuguese: return "Com \(l) dia\(l == 1 ? "" : "s") de folga você tem \(t) dias livres para estar com a família nesse dia."
        case .chineseTraditional: return "用\(l)天特休連休\(t)天，和家人一起過\(name)。"
        case .dutch: return "Met \(l) vrije dag\(l == 1 ? "" : "en") ben je \(t) dagen vrij om die dag bij je familie te zijn."
        case .swedish: return "Med \(l) semesterdag\(l == 1 ? "" : "ar") blir det \(t) lediga dagar med familjen."
        case .norwegian: return "Med \(l) feriedag\(l == 1 ? "" : "er") får du \(t) fridager med familien."
        case .danish: return "Med \(l) feriedag\(l == 1 ? "" : "e") får du \(t) fridage med familien."
        case .finnish: return "\(l) lomapäivällä saat \(t) vapaapäivää ja ehdit olla perheen kanssa sinä päivänä."
        case .polish: return "Za \(l) dz. urlopu masz \(t) dni wolnego i spędzasz ten dzień z rodziną."
        case .czech: return "Za \(l) d. dovolené máš \(t) dní volna a ten den strávíš s rodinou."
        case .greek: return "Με \(l) ημέρ\(l == 1 ? "α" : "ες") άδειας έχεις \(t) μέρες ρεπό για να είσαι με την οικογένεια."
        case .turkish: return "\(l) gün izinle \(t) gün tatil yapıp o günü ailenle geçirebilirsin."
        case .russian: return "\(l) дн. отпуска — и \(t) дн. отдыха, чтобы провести этот день с семьёй."
        case .indonesian: return "Dengan \(l) hari cuti, kamu libur \(t) hari dan bisa bersama keluarga di hari itu."
        case .thai: return "ลา \(l) วัน ได้หยุด \(t) วันติดกัน อยู่กับครอบครัวในวันนั้นได้"
        case .vietnamese: return "Nghỉ phép \(l) ngày để có \(t) ngày nghỉ liền, ở bên gia đình dịp \(name)."
        }
    }

    static func anniversaryLeadTitle(_ title: String, days: Int) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\(title)까지 \(days)일 남았어요"
        case .english: return "\(days) days until \(title)"
        case .japanese: return "\(title)まであと\(days)日"
        case .chinese: return "距离\(title)还有\(days)天"
        case .german: return "Noch \(days) Tage: \(title)"
        case .french: return "Plus que \(days) jours : \(title)"
        case .spanish: return "Faltan \(days) días: \(title)"
        case .italian: return "Mancano \(days) giorni: \(title)"
        case .portuguese: return "Faltam \(days) dias: \(title)"
        case .chineseTraditional: return "距離\(title)還有\(days)天"
        case .dutch: return "Nog \(days) dagen: \(title)"
        case .swedish: return "\(days) dagar kvar: \(title)"
        case .norwegian: return "\(days) dager igjen: \(title)"
        case .danish: return "\(days) dage til: \(title)"
        case .finnish: return "\(days) päivää: \(title)"
        case .polish: return "Za \(days) dni: \(title)"
        case .czech: return "Za \(days) dní: \(title)"
        case .greek: return "Σε \(days) μέρες: \(title)"
        case .turkish: return "\(title) için \(days) gün kaldı"
        case .russian: return "Через \(days) дней: \(title)"
        case .indonesian: return "\(days) hari lagi: \(title)"
        case .thai: return "อีก \(days) วัน: \(title)"
        case .vietnamese: return "Còn \(days) ngày: \(title)"
        }
    }

    static func anniversaryLeadBody(_ date: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\(date)이에요. 지금 휴가를 내 두면 가족과 함께할 수 있어요."
        case .english: return "It's on \(date). Book time off now so you can be with your family."
        case .japanese: return "\(date)です。今のうちに休みを取っておけば家族と過ごせます。"
        case .chinese: return "就在\(date)。现在请好假，就能陪伴家人。"
        case .german: return "Am \(date). Nimm jetzt Urlaub, dann hast du Zeit für die Familie."
        case .french: return "C’est le \(date). Posez un congé maintenant pour être en famille."
        case .spanish: return "Es el \(date). Pide el día ahora para estar con tu familia."
        case .italian: return "È il \(date). Chiedi ferie ora per stare con la tua famiglia."
        case .portuguese: return "É em \(date). Peça folga agora para estar com a família."
        case .chineseTraditional: return "就在\(date)。現在請好假，就能陪伴家人。"
        case .dutch: return "Op \(date). Vraag nu vrij, dan kun je bij je familie zijn."
        case .swedish: return "Den \(date). Ta ledigt nu så kan du vara med familjen."
        case .norwegian: return "\(date). Ta fri nå, så kan du være med familien."
        case .danish: return "Den \(date). Tag fri nu, så du kan være sammen med familien."
        case .finnish: return "\(date). Pyydä vapaa nyt, niin ehdit olla perheen kanssa."
        case .polish: return "To \(date). Weź wolne już teraz, żeby być z rodziną."
        case .czech: return "Je to \(date). Vezmi si volno už teď a buď s rodinou."
        case .greek: return "Είναι στις \(date). Πάρε άδεια τώρα για να είσαι με την οικογένεια."
        case .turkish: return "Tarih: \(date). Şimdiden izin al, ailenle birlikte ol."
        case .russian: return "Это \(date). Возьмите выходной заранее, чтобы побыть с семьёй."
        case .indonesian: return "Tanggal \(date). Ambil cuti sekarang agar bisa bersama keluarga."
        case .thai: return "ตรงกับ \(date) ลาไว้ตอนนี้จะได้อยู่กับครอบครัว"
        case .vietnamese: return "Vào \(date). Xin nghỉ ngay để ở bên gia đình nhé."
        }
    }

    static func anniversaryTodayTitle(_ title: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "오늘은 \(title)"
        case .english: return "Today: \(title)"
        case .japanese: return "今日は\(title)"
        case .chinese: return "今天是\(title)"
        case .german: return "Heute: \(title)"
        case .french: return "Aujourd’hui : \(title)"
        case .spanish: return "Hoy: \(title)"
        case .italian: return "Oggi: \(title)"
        case .portuguese: return "Hoje: \(title)"
        case .chineseTraditional: return "今天是\(title)"
        case .dutch: return "Vandaag: \(title)"
        case .swedish: return "I dag: \(title)"
        case .norwegian: return "I dag: \(title)"
        case .danish: return "I dag: \(title)"
        case .finnish: return "Tänään: \(title)"
        case .polish: return "Dziś: \(title)"
        case .czech: return "Dnes: \(title)"
        case .greek: return "Σήμερα: \(title)"
        case .turkish: return "Bugün: \(title)"
        case .russian: return "Сегодня: \(title)"
        case .indonesian: return "Hari ini: \(title)"
        case .thai: return "วันนี้: \(title)"
        case .vietnamese: return "Hôm nay: \(title)"
        }
    }

    /// 관계 빠른 입력 — 그 언어권에서 흔히 부르는 말
    static var anniversaryRelationPresets: [String] {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return ["엄마", "아빠", "배우자", "아이", "할머니", "할아버지", "장인어른", "장모님", "시아버지", "시어머니"]
        case .english: return ["Mom", "Dad", "Partner", "Child", "Grandma", "Grandpa"]
        case .japanese: return ["母", "父", "配偶者", "子ども", "祖母", "祖父", "義父", "義母"]
        case .chinese: return ["妈妈", "爸爸", "爱人", "孩子", "奶奶", "爷爷", "外婆", "外公"]
        case .german: return ["Mama", "Papa", "Partner", "Kind", "Oma", "Opa"]
        case .french: return ["Maman", "Papa", "Conjoint", "Enfant", "Mamie", "Papi"]
        case .spanish: return ["Mamá", "Papá", "Pareja", "Hijo", "Abuela", "Abuelo"]
        case .italian: return ["Mamma", "Papà", "Partner", "Figlio", "Nonna", "Nonno"]
        case .portuguese: return ["Mãe", "Pai", "Cônjuge", "Filho", "Avó", "Avô"]
        case .chineseTraditional: return ["媽媽", "爸爸", "另一半", "孩子", "奶奶", "爺爺", "外婆", "外公"]
        case .dutch: return ["Mama", "Papa", "Partner", "Kind", "Oma", "Opa"]
        case .swedish: return ["Mamma", "Pappa", "Partner", "Barn", "Mormor", "Morfar", "Farmor", "Farfar"]
        case .norwegian: return ["Mamma", "Pappa", "Partner", "Barn", "Mormor", "Morfar", "Farmor", "Farfar"]
        case .danish: return ["Mor", "Far", "Partner", "Barn", "Mormor", "Morfar", "Farmor", "Farfar"]
        case .finnish: return ["Äiti", "Isä", "Puoliso", "Lapsi", "Mummi", "Ukki"]
        case .polish: return ["Mama", "Tata", "Partner", "Dziecko", "Babcia", "Dziadek"]
        case .czech: return ["Máma", "Táta", "Partner", "Dítě", "Babička", "Děda"]
        case .greek: return ["Μαμά", "Μπαμπάς", "Σύντροφος", "Παιδί", "Γιαγιά", "Παππούς"]
        case .turkish: return ["Annem", "Babam", "Eşim", "Çocuğum", "Anneannem", "Babaannem", "Dedem"]
        case .russian: return ["Мама", "Папа", "Супруг(а)", "Ребёнок", "Бабушка", "Дедушка"]
        case .indonesian: return ["Ibu", "Ayah", "Pasangan", "Anak", "Nenek", "Kakek"]
        case .thai: return ["แม่", "พ่อ", "คู่ชีวิต", "ลูก", "ยาย", "ตา", "ย่า", "ปู่"]
        case .vietnamese: return ["Mẹ", "Bố", "Vợ/chồng", "Con", "Bà", "Ông"]
        }
    }
}
