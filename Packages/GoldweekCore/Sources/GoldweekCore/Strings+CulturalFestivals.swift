//
//  Strings+CulturalFestivals.swift
//  Goldweek
//
//  문화별 명절 — 설정 문구
//

import Foundation

extension Strings {
    public static var culturalFestivalsTitle: String {
        pick([.korean: "문화별 명절", .english: "Cultural Festivals", .japanese: "文化・宗教の祝祭日", .chinese: "民族与宗教节日", .german: "Kulturelle Feste", .french: "Fêtes culturelles", .spanish: "Fiestas culturales", .italian: "Feste culturali", .portuguese: "Festas culturais", .chineseTraditional: "民族與宗教節日", .dutch: "Culturele feestdagen", .swedish: "Kulturella högtider", .norwegian: "Kulturelle høytider", .danish: "Kulturelle højtider", .finnish: "Kulttuurien juhlapäivät", .polish: "Święta kulturowe", .czech: "Kulturní svátky", .greek: "Πολιτιστικές γιορτές", .turkish: "Kültürel bayramlar", .russian: "Культурные праздники", .indonesian: "Hari raya budaya", .thai: "เทศกาลตามวัฒนธรรม", .vietnamese: "Lễ hội văn hóa"])
    }

    public static var culturalFestivalsFooter: String {
        pick([.korean: "켠 명절은 쉬는 날로 세고 추천도 그날에 맞춰요. 이슬람 명절은 달을 보고 정해 하루 다를 수 있어요. 하루만 빼려면 공휴일 관리에서 숨기세요.",
              .english: "Festivals you turn on count as days off, and suggestions plan around them. Islamic dates follow the moon and may shift by a day. To skip one day, hide it in Manage Holidays.",
              .japanese: "オンにした祝祭日は休みとして数え、おすすめもその日に合わせます。イスラムの祝祭日は月を見て決まるため、1日ずれることがあります。1日だけ外すには祝日の管理で非表示にしてください。",
              .chinese: "开启的节日会算作休息日，推荐也会围绕这些日子安排。伊斯兰节日按月相确定，可能相差一天。若只想去掉某一天，请在假日管理中隐藏。",
              .german: "Eingeschaltete Feste zählen als freie Tage, und Vorschläge planen um sie herum. Islamische Feste richten sich nach dem Mond und können sich um einen Tag verschieben. Einzelne Tage blendest du unter „Feiertage verwalten“ aus.",
              .french: "Les fêtes activées comptent comme jours de repos et les suggestions s’organisent autour. Les fêtes musulmanes suivent la lune et peuvent varier d’un jour. Pour retirer un seul jour, masquez-le dans Gérer les jours fériés.",
              .spanish: "Las fiestas que actives cuentan como días libres y las sugerencias se organizan en torno a ellas. Las fiestas islámicas siguen la luna y pueden variar un día. Para quitar un solo día, ocúltalo en Gestionar festivos.",
              .italian: "Le feste attivate contano come giorni liberi e i suggerimenti si organizzano intorno a esse. Le feste islamiche seguono la luna e possono spostarsi di un giorno. Per togliere un solo giorno, nascondilo in Gestisci festività.",
              .portuguese: "As festas que você ativar contam como dias de folga, e as sugestões se organizam em torno delas. As datas islâmicas seguem a lua e podem mudar um dia. Para tirar só um dia, oculte-o em Gerenciar feriados.",
              .chineseTraditional: "開啟的節日會算作休息日，推薦也會配合這些日子安排。伊斯蘭節日依月相決定，可能相差一天。若只想拿掉某一天，請在假日管理中隱藏。",
              .dutch: "Feestdagen die je aanzet tellen als vrije dagen, en suggesties plannen eromheen. Islamitische feestdagen volgen de maan en kunnen een dag verschuiven. Wil je één dag overslaan, verberg die dan bij Feestdagen beheren.",
              .swedish: "Högtider du slår på räknas som lediga dagar, och förslagen planeras runt dem. Islamiska högtider följer månen och kan flyttas en dag. Vill du hoppa över en dag döljer du den under Hantera helgdagar.",
              .norwegian: "Høytider du slår på teller som fridager, og forslagene planlegges rundt dem. Islamske høytider følger månen og kan flytte seg en dag. Vil du hoppe over én dag, skjuler du den under Administrer helligdager.",
              .danish: "Højtider, du slår til, tæller som fridage, og forslagene planlægges omkring dem. Islamiske højtider følger månen og kan flytte sig en dag. Vil du springe en enkelt dag over, skjuler du den under Administrer helligdage.",
              .finnish: "Päälle kytketyt juhlat lasketaan vapaapäiviksi, ja ehdotukset suunnitellaan niiden ympärille. Islamilaiset juhlat seuraavat kuuta ja voivat siirtyä päivällä. Yksittäisen päivän voit piilottaa kohdassa Hallitse pyhäpäiviä.",
              .polish: "Włączone święta liczą się jako dni wolne, a propozycje są do nich dopasowane. Święta muzułmańskie zależą od księżyca i mogą przesunąć się o dzień. Aby pominąć jeden dzień, ukryj go w Zarządzaniu świętami.",
              .czech: "Zapnuté svátky se počítají jako volné dny a návrhy se plánují kolem nich. Islámské svátky se řídí měsícem a mohou se posunout o den. Jednotlivý den skryjete ve Správě svátků.",
              .greek: "Οι γιορτές που ενεργοποιείτε μετρούν ως ρεπό και οι προτάσεις οργανώνονται γύρω τους. Οι ισλαμικές γιορτές ακολουθούν τη σελήνη και μπορεί να διαφέρουν μία ημέρα. Για να αφαιρέσετε μία μέρα, κρύψτε την στη Διαχείριση αργιών.",
              .turkish: "Açtığın bayramlar izin günü sayılır ve öneriler bunlara göre yapılır. İslami bayramlar aya göre belirlenir ve bir gün kayabilir. Tek bir günü çıkarmak için Tatilleri yönet bölümünde gizle.",
              .russian: "Включённые праздники считаются выходными, и подсказки строятся вокруг них. Исламские праздники зависят от луны и могут сдвинуться на день. Чтобы убрать один день, скройте его в разделе «Управление праздниками».",
              .indonesian: "Hari raya yang kamu aktifkan dihitung sebagai hari libur, dan saran disusun di sekitarnya. Hari raya Islam mengikuti bulan dan bisa bergeser sehari. Untuk melewatkan satu hari, sembunyikan di Kelola hari libur.",
              .thai: "เทศกาลที่เปิดไว้จะนับเป็นวันหยุด และคำแนะนำจะวางแผนรอบวันนั้น วันสำคัญของศาสนาอิสลามกำหนดตามดวงจันทร์จึงอาจคลาดได้หนึ่งวัน หากต้องการตัดออกเพียงวันเดียว ให้ซ่อนในจัดการวันหยุด",
              .vietnamese: "Các lễ bạn bật sẽ được tính là ngày nghỉ, và gợi ý sẽ xếp quanh những ngày đó. Lễ Hồi giáo theo mặt trăng nên có thể lệch một ngày. Muốn bỏ một ngày, hãy ẩn ngày đó trong Quản lý ngày lễ."])
    }

    public static func culturalFestivalName(_ festival: CulturalFestival) -> String {
        switch festival {
        case .islamic:
            return pick([.korean: "이슬람", .english: "Islamic", .japanese: "イスラム", .chinese: "伊斯兰", .german: "Islamisch", .french: "Musulmanes", .spanish: "Islámicas", .italian: "Islamiche", .portuguese: "Islâmicas", .chineseTraditional: "伊斯蘭", .dutch: "Islamitisch", .swedish: "Islamiska", .norwegian: "Islamske", .danish: "Islamiske", .finnish: "Islamilaiset", .polish: "Muzułmańskie", .czech: "Islámské", .greek: "Ισλαμικές", .turkish: "İslami", .russian: "Исламские", .indonesian: "Islam", .thai: "อิสลาม", .vietnamese: "Hồi giáo"])
        case .jewish:
            return pick([.korean: "유대교", .english: "Jewish", .japanese: "ユダヤ教", .chinese: "犹太教", .german: "Jüdisch", .french: "Juives", .spanish: "Judías", .italian: "Ebraiche", .portuguese: "Judaicas", .chineseTraditional: "猶太教", .dutch: "Joods", .swedish: "Judiska", .norwegian: "Jødiske", .danish: "Jødiske", .finnish: "Juutalaiset", .polish: "Żydowskie", .czech: "Židovské", .greek: "Εβραϊκές", .turkish: "Yahudi", .russian: "Еврейские", .indonesian: "Yahudi", .thai: "ยิว", .vietnamese: "Do Thái"])
        case .hindu:
            return pick([.korean: "힌두교", .english: "Hindu", .japanese: "ヒンドゥー教", .chinese: "印度教", .german: "Hinduistisch", .french: "Hindoues", .spanish: "Hindúes", .italian: "Indù", .portuguese: "Hindus", .chineseTraditional: "印度教", .dutch: "Hindoeïstisch", .swedish: "Hinduiska", .norwegian: "Hinduistiske", .danish: "Hinduistiske", .finnish: "Hindulaiset", .polish: "Hinduistyczne", .czech: "Hinduistické", .greek: "Ινδουιστικές", .turkish: "Hindu", .russian: "Индуистские", .indonesian: "Hindu", .thai: "ฮินดู", .vietnamese: "Hindu giáo"])
        case .lunar:
            return pick([.korean: "음력 명절", .english: "Lunar", .japanese: "旧暦の節句", .chinese: "农历节日", .german: "Mondkalender", .french: "Lunaires", .spanish: "Lunares", .italian: "Lunari", .portuguese: "Lunares", .chineseTraditional: "農曆節日", .dutch: "Maankalender", .swedish: "Månkalender", .norwegian: "Månekalender", .danish: "Månekalender", .finnish: "Kuukalenteri", .polish: "Księżycowe", .czech: "Lunární", .greek: "Σεληνιακές", .turkish: "Ay takvimi", .russian: "Лунные", .indonesian: "Imlek", .thai: "จันทรคติ", .vietnamese: "Âm lịch"])
        }
    }

    /// 켜면 들어가는 날 — 이름 밑에 작게
    public static func culturalFestivalExamples(_ festival: CulturalFestival) -> String {
        switch festival {
        case .islamic:
            return pick([.korean: "이드 알피트르 · 이드 알아드하", .english: "Eid al-Fitr · Eid al-Adha", .japanese: "イード・アル＝フィトル · イード・アル＝アドハー", .chinese: "开斋节 · 宰牲节", .german: "Zuckerfest · Opferfest", .french: "Aïd el-Fitr · Aïd el-Kébir", .spanish: "Eid al-Fitr · Eid al-Adha", .italian: "Eid al-Fitr · Eid al-Adha", .portuguese: "Eid al-Fitr · Eid al-Adha", .chineseTraditional: "開齋節 · 宰牲節", .dutch: "Suikerfeest · Offerfeest", .swedish: "Eid al-Fitr · Eid al-Adha", .norwegian: "Eid al-Fitr · Eid al-Adha", .danish: "Eid al-Fitr · Eid al-Adha", .finnish: "Eid al-Fitr · Eid al-Adha", .polish: "Id al-Fitr · Id al-Adha", .czech: "Íd al-Fitr · Íd al-Adhá", .greek: "Ιντ αλ-Φιτρ · Ιντ αλ-Άντχα", .turkish: "Ramazan Bayramı · Kurban Bayramı", .russian: "Ураза-байрам · Курбан-байрам", .indonesian: "Idulfitri · Iduladha", .thai: "อีดิลฟิฏริ · อีดิลอัฎฮา", .vietnamese: "Eid al-Fitr · Eid al-Adha"])
        case .jewish:
            return pick([.korean: "로시 하샤나 · 욤 키푸르 · 유월절", .english: "Rosh Hashanah · Yom Kippur · Passover", .japanese: "ロシュ・ハシャナ · ヨム・キプル · 過越祭", .chinese: "犹太新年 · 赎罪日 · 逾越节", .german: "Rosch ha-Schana · Jom Kippur · Pessach", .french: "Roch Hachana · Yom Kippour · Pessa’h", .spanish: "Rosh Hashaná · Yom Kipur · Pésaj", .italian: "Rosh haShanà · Yom Kippur · Pesach", .portuguese: "Rosh Hashaná · Yom Kipur · Pessach", .chineseTraditional: "猶太新年 · 贖罪日 · 逾越節", .dutch: "Rosj Hasjana · Jom Kipoer · Pesach", .swedish: "Rosh hashana · Jom kippur · Pesach", .norwegian: "Rosh hashana · Jom kippur · Pesach", .danish: "Rosh Hashana · Yom Kippur · Pesach", .finnish: "Roš hašana · Jom kippur · Pesah", .polish: "Rosz ha-Szana · Jom Kipur · Pesach", .czech: "Roš ha-šana · Jom kipur · Pesach", .greek: "Ρος Ασανά · Γιομ Κιπούρ · Πέσαχ", .turkish: "Roş Aşana · Yom Kipur · Pesah", .russian: "Рош ха-Шана · Йом-Кипур · Песах", .indonesian: "Rosh Hashanah · Yom Kippur · Paskah Yahudi", .thai: "รอช ฮาชานาห์ · ยมคิปปูร์ · ปัสกา", .vietnamese: "Rosh Hashanah · Yom Kippur · Lễ Vượt Qua"])
        case .hindu:
            return pick([.korean: "디왈리 · 홀리", .english: "Diwali · Holi", .japanese: "ディワリ · ホーリー", .chinese: "排灯节 · 洒红节", .german: "Diwali · Holi", .french: "Diwali · Holi", .spanish: "Diwali · Holi", .italian: "Diwali · Holi", .portuguese: "Diwali · Holi", .chineseTraditional: "排燈節 · 灑紅節", .dutch: "Divali · Holi", .swedish: "Diwali · Holi", .norwegian: "Diwali · Holi", .danish: "Diwali · Holi", .finnish: "Diwali · Holi", .polish: "Diwali · Holi", .czech: "Díválí · Holí", .greek: "Ντιβάλι · Χόλι", .turkish: "Divali · Holi", .russian: "Дивали · Холи", .indonesian: "Diwali · Holi", .thai: "ดิวาลี · โฮลี", .vietnamese: "Diwali · Holi"])
        case .lunar:
            return pick([.korean: "설날 · 추석", .english: "Lunar New Year · Mid-Autumn Festival", .japanese: "旧正月 · 中秋節", .chinese: "春节 · 中秋节", .german: "Mondneujahr · Mondfest", .french: "Nouvel An lunaire · Fête de la mi-automne", .spanish: "Año Nuevo Lunar · Festival del Medio Otoño", .italian: "Capodanno lunare · Festa di metà autunno", .portuguese: "Ano Novo Lunar · Festival do Meio do Outono", .chineseTraditional: "春節 · 中秋節", .dutch: "Maannieuwjaar · Medio-herfstfeest", .swedish: "Månnyår · Midhöstfestivalen", .norwegian: "Månenyttår · Midthøstfesten", .danish: "Månenytår · Midthøstfesten", .finnish: "Kuukalenterin uusivuosi · Keskisyksyn juhla", .polish: "Księżycowy Nowy Rok · Święto Środka Jesieni", .czech: "Lunární Nový rok · Svátek středu podzimu", .greek: "Σεληνιακό Νέο Έτος · Γιορτή του Φθινοπώρου", .turkish: "Ay Yeni Yılı · Sonbahar Ortası Festivali", .russian: "Лунный Новый год · Праздник середины осени", .indonesian: "Imlek · Festival Pertengahan Musim Gugur", .thai: "ตรุษจีน · ไหว้พระจันทร์", .vietnamese: "Tết Nguyên Đán · Tết Trung Thu"])
        }
    }
}
