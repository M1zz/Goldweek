//
//  Strings+Monetization.swift
//  Goldweek
//
//  2.4.0 유료화 정리 — 연간 구독·평생 구매 고르기, 구독 고지, 새로 Pro가 된 기능 문구.
//  무엇을 왜 Pro로 두는지는 docs/MONETIZATION.md.
//

import Foundation

extension Strings {
    private static var moneyLang: AppLanguage { LanguageManager.shared.currentLanguage }

    /// 요금제 카드 — 연간 구독
    static var planYearly: String {
        switch moneyLang {
        case .korean: return "연간"
        case .english: return "Yearly"
        case .swedish: return "Årsvis"
        case .norwegian: return "Årlig"
        case .danish: return "Årligt"
        case .finnish: return "Vuosittain"
        case .polish: return "Rocznie"
        case .czech: return "Ročně"
        case .greek: return "Ετήσια"
        case .turkish: return "Yıllık"
        case .russian: return "На год"
        case .indonesian: return "Tahunan"
        case .thai: return "รายปี"
        case .vietnamese: return "Theo năm"
        case .dutch: return "Per jaar"
        case .japanese: return "年額"
        case .chinese: return "按年"
        case .german: return "Jährlich"
        case .french: return "Annuel"
        case .spanish: return "Anual"
        case .italian: return "Annuale"
        case .portuguese: return "Anual"
        case .chineseTraditional: return "按年"
        }
    }

    /// 요금제 카드 — 평생 구매
    static var planLifetime: String {
        switch moneyLang {
        case .korean: return "평생"
        case .english: return "Lifetime"
        case .swedish: return "Livstid"
        case .norwegian: return "Livstid"
        case .danish: return "Livstid"
        case .finnish: return "Elinikäinen"
        case .polish: return "Na zawsze"
        case .czech: return "Navždy"
        case .greek: return "Δια βίου"
        case .turkish: return "Ömür boyu"
        case .russian: return "Навсегда"
        case .indonesian: return "Selamanya"
        case .thai: return "ตลอดชีพ"
        case .vietnamese: return "Trọn đời"
        case .dutch: return "Levenslang"
        case .japanese: return "買い切り"
        case .chinese: return "终身"
        case .german: return "Lebenslang"
        case .french: return "À vie"
        case .spanish: return "De por vida"
        case .italian: return "A vita"
        case .portuguese: return "Vitalício"
        case .chineseTraditional: return "終身"
        }
    }

    /// 연간 가격 — "연 ₩X"
    static func yearlyPriceLabel(_ price: String) -> String {
        switch moneyLang {
        case .korean: return "연 \(price)"
        case .english: return "\(price)/year"
        case .swedish: return "\(price)/år"
        case .norwegian: return "\(price)/år"
        case .danish: return "\(price)/år"
        case .finnish: return "\(price)/vuosi"
        case .polish: return "\(price)/rok"
        case .czech: return "\(price)/rok"
        case .greek: return "\(price)/έτος"
        case .turkish: return "Yıllık \(price)"
        case .russian: return "\(price) в год"
        case .indonesian: return "\(price)/tahun"
        case .thai: return "\(price)/ปี"
        case .vietnamese: return "\(price)/năm"
        case .dutch: return "\(price) per jaar"
        case .japanese: return "年額 \(price)"
        case .chinese: return "每年 \(price)"
        case .german: return "\(price)/Jahr"
        case .french: return "\(price)/an"
        case .spanish: return "\(price)/año"
        case .italian: return "\(price)/anno"
        case .portuguese: return "\(price)/ano"
        case .chineseTraditional: return "每年 \(price)"
        }
    }

    /// 연간 가격을 달로 나눈 값 — "한 달 ₩X꼴"
    static func perMonthHint(_ price: String) -> String {
        switch moneyLang {
        case .korean: return "한 달 \(price)꼴"
        case .english: return "Just \(price) a month"
        case .swedish: return "Bara \(price) i månaden"
        case .norwegian: return "Bare \(price) i måneden"
        case .danish: return "Kun \(price) om måneden"
        case .finnish: return "Vain \(price) kuussa"
        case .polish: return "Tylko \(price) miesięcznie"
        case .czech: return "Jen \(price) měsíčně"
        case .greek: return "Μόνο \(price) τον μήνα"
        case .turkish: return "Ayda yalnızca \(price)"
        case .russian: return "Всего \(price) в месяц"
        case .indonesian: return "Hanya \(price) per bulan"
        case .thai: return "เฉลี่ยเดือนละ \(price)"
        case .vietnamese: return "Chỉ khoảng \(price) mỗi tháng"
        case .dutch: return "Slechts \(price) per maand"
        case .japanese: return "月あたり約\(price)"
        case .chinese: return "每月约 \(price)"
        case .german: return "Nur \(price) im Monat"
        case .french: return "Seulement \(price) par mois"
        case .spanish: return "Solo \(price) al mes"
        case .italian: return "Solo \(price) al mese"
        case .portuguese: return "Só \(price) por mês"
        case .chineseTraditional: return "每月約 \(price)"
        }
    }

    /// 구매 버튼
    static var startPro: String {
        switch moneyLang {
        case .korean: return "Pro 시작하기"
        case .english: return "Start Pro"
        case .swedish: return "Starta Pro"
        case .norwegian: return "Start Pro"
        case .danish: return "Start Pro"
        case .finnish: return "Aloita Pro"
        case .polish: return "Włącz Pro"
        case .czech: return "Začít s Pro"
        case .greek: return "Ξεκινήστε το Pro"
        case .turkish: return "Pro'yu başlat"
        case .russian: return "Перейти на Pro"
        case .indonesian: return "Mulai Pro"
        case .thai: return "เริ่มใช้ Pro"
        case .vietnamese: return "Bắt đầu dùng Pro"
        case .dutch: return "Start Pro"
        case .japanese: return "Proをはじめる"
        case .chinese: return "开始使用 Pro"
        case .german: return "Pro starten"
        case .french: return "Passer à Pro"
        case .spanish: return "Empezar con Pro"
        case .italian: return "Inizia con Pro"
        case .portuguese: return "Começar o Pro"
        case .chineseTraditional: return "開始使用 Pro"
        }
    }

    /// 자동 갱신 구독 고지 — App Store 심사 필수 문구. 구매 버튼 바로 아래에 둔다.
    static var subscriptionDisclosure: String {
        switch moneyLang {
        case .korean: return "연간 구독은 기간이 끝나기 24시간 전까지 끄지 않으면 같은 가격으로 자동 갱신돼요. 결제는 Apple 계정으로 청구되고, 설정 > Apple 계정 > 구독에서 언제든 끌 수 있어요. 평생 구매는 한 번만 결제해요."
        case .english: return "The yearly plan renews automatically at the same price unless you turn it off at least 24 hours before the period ends. Payment is charged to your Apple Account. Manage or cancel anytime in Settings > Apple Account > Subscriptions. Lifetime is a single payment."
        case .swedish: return "Årsplanen förnyas automatiskt till samma pris om du inte stänger av den minst 24 timmar innan perioden tar slut. Betalningen dras från ditt Apple-konto. Hantera eller avsluta när som helst i Inställningar > Apple-konto > Prenumerationer. Livstid är en engångsbetalning."
        case .norwegian: return "Årsabonnementet fornyes automatisk til samme pris med mindre du slår det av minst 24 timer før perioden er over. Beløpet belastes Apple-kontoen din. Administrer eller avslutt når som helst i Innstillinger > Apple-konto > Abonnementer. Livstid betales én gang."
        case .danish: return "Årsabonnementet fornyes automatisk til samme pris, medmindre du slår det fra mindst 24 timer før perioden udløber. Betalingen trækkes fra din Apple-konto. Administrer eller opsig når som helst under Indstillinger > Apple-konto > Abonnementer. Livstid betales én gang."
        case .finnish: return "Vuositilaus uusiutuu automaattisesti samaan hintaan, ellei sitä peru viimeistään 24 tuntia ennen kauden päättymistä. Maksu veloitetaan Apple-tililtäsi. Voit hallita tai perua tilauksen milloin tahansa: Asetukset > Apple-tili > Tilaukset. Elinikäinen maksetaan kerran."
        case .polish: return "Plan roczny odnawia się automatycznie w tej samej cenie, chyba że wyłączysz go co najmniej 24 godziny przed końcem okresu. Opłata zostanie pobrana z konta Apple. Zarządzaj subskrypcją lub anuluj ją w dowolnej chwili w Ustawienia > Konto Apple > Subskrypcje. Plan na zawsze to jednorazowa płatność."
        case .czech: return "Roční předplatné se automaticky obnoví za stejnou cenu, pokud ho nevypnete nejpozději 24 hodin před koncem období. Platba se strhne z vašeho účtu Apple. Spravovat nebo zrušit ho můžete kdykoli v Nastavení > Účet Apple > Předplatné. Možnost Navždy zaplatíte jen jednou."
        case .greek: return "Το ετήσιο πρόγραμμα ανανεώνεται αυτόματα στην ίδια τιμή, εκτός αν το απενεργοποιήσετε τουλάχιστον 24 ώρες πριν λήξει η περίοδος. Η χρέωση γίνεται στον λογαριασμό Apple σας. Διαχειριστείτε ή ακυρώστε το όποτε θέλετε στις Ρυθμίσεις > Λογαριασμός Apple > Συνδρομές. Το Δια βίου πληρώνεται μία φορά."
        case .turkish: return "Yıllık plan, dönem bitmeden en az 24 saat önce kapatmazsanız aynı fiyatla otomatik olarak yenilenir. Ödeme Apple Hesabınızdan alınır. Ayarlar > Apple Hesabı > Abonelikler bölümünden dilediğiniz zaman yönetebilir veya iptal edebilirsiniz. Ömür boyu seçeneği tek seferlik ödemedir."
        case .russian: return "Годовая подписка продлевается автоматически по той же цене, если не отключить её как минимум за 24 часа до конца периода. Оплата списывается с вашего аккаунта Apple. Управлять подпиской или отменить её можно в любой момент: Настройки > Аккаунт Apple > Подписки. Вариант «Навсегда» оплачивается один раз."
        case .indonesian: return "Paket tahunan diperpanjang otomatis dengan harga yang sama kecuali Anda mematikannya paling lambat 24 jam sebelum periode berakhir. Pembayaran ditagihkan ke Akun Apple Anda. Kelola atau batalkan kapan saja di Pengaturan > Akun Apple > Langganan. Paket Selamanya cukup dibayar sekali."
        case .thai: return "แผนรายปีจะต่ออายุอัตโนมัติในราคาเดิม เว้นแต่คุณจะปิดก่อนสิ้นสุดรอบอย่างน้อย 24 ชั่วโมง ระบบจะเรียกเก็บเงินจากบัญชี Apple ของคุณ จัดการหรือยกเลิกได้ทุกเมื่อที่ การตั้งค่า > บัญชี Apple > การสมัครรับ ส่วนแบบตลอดชีพจ่ายครั้งเดียว"
        case .vietnamese: return "Gói năm tự động gia hạn với cùng mức giá trừ khi bạn tắt ít nhất 24 giờ trước khi kỳ hạn kết thúc. Tiền được trừ vào Tài khoản Apple của bạn. Bạn có thể quản lý hoặc hủy bất cứ lúc nào trong Cài đặt > Tài khoản Apple > Đăng ký. Gói trọn đời chỉ trả một lần."
        case .dutch: return "Het jaarabonnement wordt automatisch verlengd tegen dezelfde prijs, tenzij je het minstens 24 uur voor het einde van de periode uitzet. De betaling gaat via je Apple-account. Beheer of zeg op wanneer je wilt via Instellingen > Apple-account > Abonnementen. Levenslang betaal je één keer."
        case .japanese: return "年額プランは、期間終了の24時間前までに解約しない限り同じ料金で自動更新されます。お支払いはAppleアカウントに請求されます。設定 > Appleアカウント > サブスクリプション からいつでも管理・解約できます。買い切りは一度のお支払いです。"
        case .chinese: return "年度订阅会以相同价格自动续订，除非你在本期结束前至少 24 小时关闭。费用将从你的 Apple 账户扣除。你可以随时在“设置 > Apple 账户 > 订阅”中管理或取消。终身版只需付款一次。"
        case .german: return "Das Jahresabo verlängert sich automatisch zum gleichen Preis, wenn du es nicht spätestens 24 Stunden vor Ablauf kündigst. Die Zahlung erfolgt über deinen Apple Account. Verwalten oder kündigen kannst du jederzeit unter Einstellungen > Apple Account > Abonnements. Lebenslang zahlst du nur einmal."
        case .french: return "L’abonnement annuel se renouvelle automatiquement au même prix, sauf si vous le désactivez au moins 24 heures avant la fin de la période. Le paiement est débité de votre compte Apple. Gérez-le ou résiliez-le à tout moment dans Réglages > Compte Apple > Abonnements. L’option À vie se paie une seule fois."
        case .spanish: return "El plan anual se renueva automáticamente al mismo precio, salvo que lo desactives al menos 24 horas antes de que termine el periodo. El cobro se hace en tu cuenta de Apple. Puedes gestionarlo o cancelarlo cuando quieras en Ajustes > Cuenta de Apple > Suscripciones. De por vida se paga una sola vez."
        case .italian: return "Il piano annuale si rinnova automaticamente allo stesso prezzo, a meno che tu non lo disattivi almeno 24 ore prima della fine del periodo. Il pagamento viene addebitato sul tuo Account Apple. Puoi gestirlo o annullarlo quando vuoi in Impostazioni > Account Apple > Abbonamenti. A vita si paga una volta sola."
        case .portuguese: return "O plano anual é renovado automaticamente pelo mesmo preço, a menos que você o desative pelo menos 24 horas antes do fim do período. A cobrança é feita na sua Conta Apple. Gerencie ou cancele quando quiser em Ajustes > Conta Apple > Assinaturas. O Vitalício é pago uma única vez."
        case .chineseTraditional: return "年度訂閱會以相同價格自動續訂，除非你在本期結束前至少 24 小時關閉。費用將從你的 Apple 帳號扣款。你可以隨時在「設定 > Apple 帳號 > 訂閱項目」中管理或取消。終身版只需付款一次。"
        }
    }

    /// 설정 — 구독 관리 버튼
    static var manageSubscription: String {
        switch moneyLang {
        case .korean: return "구독 관리"
        case .english: return "Manage Subscription"
        case .swedish: return "Hantera prenumeration"
        case .norwegian: return "Administrer abonnement"
        case .danish: return "Administrer abonnement"
        case .finnish: return "Hallitse tilausta"
        case .polish: return "Zarządzaj subskrypcją"
        case .czech: return "Spravovat předplatné"
        case .greek: return "Διαχείριση συνδρομής"
        case .turkish: return "Aboneliği yönet"
        case .russian: return "Управлять подпиской"
        case .indonesian: return "Kelola langganan"
        case .thai: return "จัดการการสมัครรับ"
        case .vietnamese: return "Quản lý đăng ký"
        case .dutch: return "Abonnement beheren"
        case .japanese: return "サブスクリプションを管理"
        case .chinese: return "管理订阅"
        case .german: return "Abo verwalten"
        case .french: return "Gérer l’abonnement"
        case .spanish: return "Gestionar suscripción"
        case .italian: return "Gestisci abbonamento"
        case .portuguese: return "Gerenciar assinatura"
        case .chineseTraditional: return "管理訂閱"
        }
    }

    /// 설정 — 연간 구독 중 (date는 이미 현지 형식으로 만든 날짜)
    static func yearlyPlanUntil(_ date: String) -> String {
        switch moneyLang {
        case .korean: return "연간 구독 · \(date)까지"
        case .english: return "Yearly plan · through \(date)"
        case .swedish: return "Årsplan · t.o.m. \(date)"
        case .norwegian: return "Årsabonnement · t.o.m. \(date)"
        case .danish: return "Årsabonnement · t.o.m. \(date)"
        case .finnish: return "Vuositilaus · \(date) asti"
        case .polish: return "Plan roczny · do \(date)"
        case .czech: return "Roční předplatné · do \(date)"
        case .greek: return "Ετήσιο πρόγραμμα · έως \(date)"
        case .turkish: return "Yıllık plan · \(date) tarihine kadar"
        case .russian: return "Годовая подписка · до \(date)"
        case .indonesian: return "Paket tahunan · sampai \(date)"
        case .thai: return "แผนรายปี · ถึง \(date)"
        case .vietnamese: return "Gói năm · đến \(date)"
        case .dutch: return "Jaarabonnement · t/m \(date)"
        case .japanese: return "年額プラン・\(date)まで"
        case .chinese: return "年度订阅 · 至 \(date)"
        case .german: return "Jahresabo · bis \(date)"
        case .french: return "Abonnement annuel · jusqu’au \(date)"
        case .spanish: return "Plan anual · hasta el \(date)"
        case .italian: return "Piano annuale · fino al \(date)"
        case .portuguese: return "Plano anual · até \(date)"
        case .chineseTraditional: return "年度訂閱 · 至 \(date)"
        }
    }

    /// 온보딩 Pro 화면 부제 — 예전 "한 번 결제로 영구히"는 구독이 생겨 맞지 않는다
    static var proOnboardingPitch: String {
        switch moneyLang {
        case .korean: return "남은 연차로 가장 길게 쉬는 방법을 앱이 찾아 드려요"
        case .english: return "Let the app find the longest breaks your days off can buy"
        case .swedish: return "Låt appen hitta de längsta ledigheterna dina dagar räcker till"
        case .norwegian: return "La appen finne de lengste friperiodene dagene dine gir"
        case .danish: return "Lad appen finde de længste pauser, dine fridage rækker til"
        case .finnish: return "Sovellus etsii pisimmät vapaat, jotka lomapäivilläsi saa"
        case .polish: return "Aplikacja znajdzie najdłuższy wypoczynek z Twoich dni urlopu"
        case .czech: return "Aplikace najde nejdelší volno, které vám dny dovolené dají"
        case .greek: return "Η εφαρμογή βρίσκει τις πιο μεγάλες διακοπές με τις μέρες άδειάς σας"
        case .turkish: return "İzin günlerinle en uzun tatili uygulama bulsun"
        case .russian: return "Приложение найдёт самый длинный отдых из ваших дней отпуска"
        case .indonesian: return "Biar aplikasi yang mencari libur terpanjang dari sisa cutimu"
        case .thai: return "ให้แอปหาช่วงพักที่ยาวที่สุดจากวันลาที่คุณมี"
        case .vietnamese: return "Để ứng dụng tìm kỳ nghỉ dài nhất từ số ngày phép của bạn"
        case .dutch: return "Laat de app de langste vakanties vinden met je vrije dagen"
        case .japanese: return "残りの休暇でいちばん長く休める方法をアプリが見つけます"
        case .chinese: return "让 App 用你剩下的年假拼出最长的假期"
        case .german: return "Die App findet die längsten Auszeiten für deine Urlaubstage"
        case .french: return "L’app trouve les plus longues pauses avec vos jours de congé"
        case .spanish: return "La app encuentra los descansos más largos con tus días libres"
        case .italian: return "L’app trova le pause più lunghe con i tuoi giorni di ferie"
        case .portuguese: return "O app encontra as pausas mais longas com seus dias de folga"
        case .chineseTraditional: return "讓 App 用你剩下的特休湊出最長的假期"
        }
    }

    /// Pro 기능 — 내 규칙대로 (연간 한도·넘겨 쓰기·학교 달력)
    static var proFeatureRulesTitle: String {
        switch moneyLang {
        case .korean: return "내 회사·학교 규칙 그대로"
        case .english: return "Your workplace rules, built in"
        case .swedish: return "Din arbetsplats regler, inbyggda"
        case .norwegian: return "Arbeidsplassens regler, innebygd"
        case .danish: return "Din arbejdsplads' regler, indbygget"
        case .finnish: return "Työpaikkasi säännöt mukana"
        case .polish: return "Zasady Twojej pracy w aplikacji"
        case .czech: return "Pravidla vaší práce přímo v aplikaci"
        case .greek: return "Οι κανόνες της δουλειάς σας, ενσωματωμένοι"
        case .turkish: return "İş yerinin kuralları hazır"
        case .russian: return "Правила вашей работы — прямо в приложении"
        case .indonesian: return "Aturan kantor atau sekolahmu, sudah ada"
        case .thai: return "ตั้งตามกฎของที่ทำงานคุณ"
        case .vietnamese: return "Đúng quy định nơi bạn làm việc"
        case .dutch: return "De regels van je werk, ingebouwd"
        case .japanese: return "職場や学校のルールそのままに"
        case .chinese: return "按你单位的规定来"
        case .german: return "Die Regeln deiner Arbeit, eingebaut"
        case .french: return "Les règles de votre travail, intégrées"
        case .spanish: return "Las reglas de tu trabajo, integradas"
        case .italian: return "Le regole del tuo lavoro, già dentro"
        case .portuguese: return "As regras do seu trabalho, embutidas"
        case .chineseTraditional: return "照你單位的規定來"
        }
    }

    static var proFeatureRulesDesc: String {
        switch moneyLang {
        case .korean: return "휴가 종류별 연간 한도와 넘겨 쓰기, 학교 달력 사진으로 방학 한 번에 넣기"
        case .english: return "Yearly allowances and carry-over per leave type, plus school calendars from a photo"
        case .swedish: return "Årskvoter och överföring per ledighetstyp, och skolkalendrar från ett foto"
        case .norwegian: return "Årlige kvoter og overføring per fraværstype, og skolekalendere fra et bilde"
        case .danish: return "Årlige kvoter og overførsel pr. fraværstype samt skolekalendere fra et foto"
        case .finnish: return "Vuosikiintiöt ja siirrot poissaolotyypeittäin sekä koulun kalenteri kuvasta"
        case .polish: return "Roczne limity i przenoszenie dla każdego rodzaju urlopu oraz szkolny kalendarz ze zdjęcia"
        case .czech: return "Roční limity a převod podle druhu volna a školní kalendář z fotky"
        case .greek: return "Ετήσια όρια και μεταφορά ανά είδος άδειας, και σχολικό ημερολόγιο από φωτογραφία"
        case .turkish: return "İzin türüne göre yıllık hak ve devir, fotoğraftan okul takvimi"
        case .russian: return "Годовые лимиты и перенос по видам отпуска, школьный календарь по фото"
        case .indonesian: return "Jatah tahunan dan sisa yang terbawa per jenis cuti, plus kalender sekolah dari foto"
        case .thai: return "โควตารายปีและยกยอดแยกตามประเภทการลา พร้อมนำเข้าปฏิทินโรงเรียนจากรูปภาพ"
        case .vietnamese: return "Hạn mức năm và chuyển phép theo từng loại nghỉ, cùng lịch trường học từ ảnh chụp"
        case .dutch: return "Jaartegoed en overdracht per verloftype, plus schoolkalenders vanaf een foto"
        case .japanese: return "休暇の種類ごとの年間上限と繰り越し、写真から学校カレンダーの取り込み"
        case .chinese: return "按假期类型设年度额度和结转，拍照导入学校校历"
        case .german: return "Jahreskontingente und Übertrag je Abwesenheitsart, dazu Schulkalender per Foto"
        case .french: return "Quotas annuels et report par type d’absence, et calendrier scolaire depuis une photo"
        case .spanish: return "Cupos anuales y arrastre por tipo de ausencia, y calendario escolar desde una foto"
        case .italian: return "Monte ore annuale e riporto per tipo di assenza, e calendario scolastico da una foto"
        case .portuguese: return "Cotas anuais e saldo transferido por tipo de folga, e calendário escolar por foto"
        case .chineseTraditional: return "依假別設定年度額度與遞延，拍照匯入學校行事曆"
        }
    }

    /// 페이월 비교표 — 휴가 종류별 연간 한도
    static var paywallAllowanceFeature: String {
        switch moneyLang {
        case .korean: return "종류별 연간 한도·넘겨 쓰기"
        case .english: return "Allowances & carry-over"
        case .swedish: return "Kvoter och överföring"
        case .norwegian: return "Kvoter og overføring"
        case .danish: return "Kvoter og overførsel"
        case .finnish: return "Kiintiöt ja siirrot"
        case .polish: return "Limity i przenoszenie"
        case .czech: return "Limity a převod"
        case .greek: return "Όρια και μεταφορά"
        case .turkish: return "Haklar ve devir"
        case .russian: return "Лимиты и перенос"
        case .indonesian: return "Jatah dan sisa terbawa"
        case .thai: return "โควตาและการยกยอด"
        case .vietnamese: return "Hạn mức và chuyển phép"
        case .dutch: return "Tegoed en overdracht"
        case .japanese: return "種類別の上限と繰り越し"
        case .chinese: return "按类型额度与结转"
        case .german: return "Kontingente und Übertrag"
        case .french: return "Quotas et report"
        case .spanish: return "Cupos y arrastre"
        case .italian: return "Monte ore e riporto"
        case .portuguese: return "Cotas e saldo transferido"
        case .chineseTraditional: return "依假別額度與遞延"
        }
    }

    /// 휴가 종류 편집 — 무료 사용자에게 한도 토글 아래 안내
    static var allowanceProFooter: String {
        switch moneyLang {
        case .korean: return "연간 한도와 넘겨 쓰기는 Pro에서 쓸 수 있어요. 종류를 만들고 기록하는 건 무료예요."
        case .english: return "Yearly allowances and carry-over are part of Pro. Creating and logging leave types stays free."
        case .swedish: return "Årskvoter och överföring ingår i Pro. Att skapa och logga ledighetstyper är fortfarande gratis."
        case .norwegian: return "Årlige kvoter og overføring er en del av Pro. Å lage og føre fraværstyper er fortsatt gratis."
        case .danish: return "Årlige kvoter og overførsel er en del af Pro. Det er stadig gratis at oprette og registrere fraværstyper."
        case .finnish: return "Vuosikiintiöt ja siirrot kuuluvat Pro-versioon. Poissaolotyyppien luominen ja kirjaaminen on edelleen ilmaista."
        case .polish: return "Roczne limity i przenoszenie są w Pro. Tworzenie i zapisywanie rodzajów urlopu pozostaje bezpłatne."
        case .czech: return "Roční limity a převod jsou součástí Pro. Vytvářet a zapisovat druhy volna můžete dál zdarma."
        case .greek: return "Τα ετήσια όρια και η μεταφορά είναι μέρος του Pro. Η δημιουργία και καταγραφή ειδών άδειας παραμένει δωρεάν."
        case .turkish: return "Yıllık haklar ve devir Pro'ya dahildir. İzin türü oluşturmak ve kaydetmek ücretsiz kalır."
        case .russian: return "Годовые лимиты и перенос доступны в Pro. Создавать виды отпуска и вести записи можно бесплатно."
        case .indonesian: return "Jatah tahunan dan sisa terbawa ada di Pro. Membuat dan mencatat jenis cuti tetap gratis."
        case .thai: return "โควตารายปีและการยกยอดอยู่ใน Pro ส่วนการสร้างและบันทึกประเภทการลายังใช้ได้ฟรี"
        case .vietnamese: return "Hạn mức năm và chuyển phép có trong Pro. Tạo và ghi lại các loại nghỉ vẫn miễn phí."
        case .dutch: return "Jaartegoed en overdracht horen bij Pro. Verloftypes maken en bijhouden blijft gratis."
        case .japanese: return "年間上限と繰り越しはProの機能です。種類を作って記録するのは無料のままです。"
        case .chinese: return "年度额度和结转属于 Pro 功能。创建和记录假期类型仍然免费。"
        case .german: return "Jahreskontingente und Übertrag gehören zu Pro. Abwesenheitsarten anlegen und eintragen bleibt kostenlos."
        case .french: return "Les quotas annuels et le report font partie de Pro. Créer et noter des types d’absence reste gratuit."
        case .spanish: return "Los cupos anuales y el arrastre son parte de Pro. Crear y registrar tipos de ausencia sigue siendo gratis."
        case .italian: return "Il monte ore annuale e il riporto fanno parte di Pro. Creare e registrare i tipi di assenza resta gratis."
        case .portuguese: return "Cotas anuais e saldo transferido fazem parte do Pro. Criar e registrar tipos de folga continua grátis."
        case .chineseTraditional: return "年度額度與遞延屬於 Pro 功能。建立和記錄假別仍然免費。"
        }
    }

    /// 2.4.0 전에 설치한 무료 사용자 — 새로 Pro가 된 기능을 계속 쓴다는 안내
    static var legacyFeaturesNote: String {
        switch moneyLang {
        case .korean: return "먼저 써 주셔서 고마워요. 학교 달력 가져오기와 종류별 연간 한도는 계속 무료로 쓸 수 있어요."
        case .english: return "Thanks for being an early user. School calendar import and yearly allowances stay free for you."
        case .swedish: return "Tack för att du var med tidigt. Import av skolkalender och årskvoter förblir gratis för dig."
        case .norwegian: return "Takk for at du var med tidlig. Import av skolekalender og årlige kvoter forblir gratis for deg."
        case .danish: return "Tak, fordi du var med fra starten. Import af skolekalender og årlige kvoter forbliver gratis for dig."
        case .finnish: return "Kiitos, että olit mukana alusta asti. Koulukalenterin tuonti ja vuosikiintiöt pysyvät sinulle ilmaisina."
        case .polish: return "Dziękujemy, że jesteś z nami od początku. Import kalendarza szkolnego i roczne limity pozostają dla Ciebie bezpłatne."
        case .czech: return "Díky, že jste s námi od začátku. Import školního kalendáře a roční limity vám zůstávají zdarma."
        case .greek: return "Ευχαριστούμε που είστε μαζί μας από νωρίς. Η εισαγωγή σχολικού ημερολογίου και τα ετήσια όρια μένουν δωρεάν για εσάς."
        case .turkish: return "Bizi erkenden kullandığın için teşekkürler. Okul takvimi aktarma ve yıllık haklar senin için ücretsiz kalıyor."
        case .russian: return "Спасибо, что вы с нами с самого начала. Импорт школьного календаря и годовые лимиты останутся для вас бесплатными."
        case .indonesian: return "Terima kasih sudah memakai sejak awal. Impor kalender sekolah dan jatah tahunan tetap gratis untukmu."
        case .thai: return "ขอบคุณที่ใช้กันมาตั้งแต่แรก การนำเข้าปฏิทินโรงเรียนและโควตารายปียังใช้ได้ฟรีสำหรับคุณ"
        case .vietnamese: return "Cảm ơn bạn đã dùng từ sớm. Nhập lịch trường học và hạn mức năm vẫn miễn phí cho bạn."
        case .dutch: return "Bedankt dat je er vroeg bij was. Schoolkalender importeren en jaartegoed blijven voor jou gratis."
        case .japanese: return "早くから使ってくださりありがとうございます。学校カレンダーの取り込みと年間上限は引き続き無料です。"
        case .chinese: return "感谢你一直以来的使用。导入学校校历和年度额度对你继续免费。"
        case .german: return "Danke, dass du von Anfang an dabei bist. Schulkalender-Import und Jahreskontingente bleiben für dich kostenlos."
        case .french: return "Merci d’être là depuis le début. L’import du calendrier scolaire et les quotas annuels restent gratuits pour vous."
        case .spanish: return "Gracias por estar desde el principio. Importar el calendario escolar y los cupos anuales siguen siendo gratis para ti."
        case .italian: return "Grazie per essere con noi dall’inizio. L’importazione del calendario scolastico e il monte ore annuale restano gratis per te."
        case .portuguese: return "Obrigado por estar com a gente desde o começo. Importar o calendário escolar e as cotas anuais continuam grátis para você."
        case .chineseTraditional: return "感謝你一路以來的使用。匯入學校行事曆與年度額度對你繼續免費。"
        }
    }
}

// MARK: - 트림 (플러스 · 프로 · 패밀리)

extension Strings {
    /// 트림 이름 (무료는 플러스로 대신 — 화면에 쓰지 않는다)
    static func trimName(_ tier: ProTier) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let rows: [AppLanguage: String]
        switch tier {
        case .plus, .free: rows = [.korean: "플러스", .english: "Plus", .japanese: "プラス", .chinese: "Plus", .german: "Plus", .french: "Plus", .spanish: "Plus", .italian: "Plus", .portuguese: "Plus", .chineseTraditional: "Plus", .dutch: "Plus", .swedish: "Plus", .norwegian: "Plus", .danish: "Plus", .finnish: "Plus", .polish: "Plus", .czech: "Plus", .greek: "Plus", .turkish: "Plus", .russian: "Plus", .indonesian: "Plus", .thai: "Plus", .vietnamese: "Plus"]
        case .pro: rows = [.korean: "프로", .english: "Pro", .japanese: "プロ", .chinese: "Pro", .german: "Pro", .french: "Pro", .spanish: "Pro", .italian: "Pro", .portuguese: "Pro", .chineseTraditional: "Pro", .dutch: "Pro", .swedish: "Pro", .norwegian: "Pro", .danish: "Pro", .finnish: "Pro", .polish: "Pro", .czech: "Pro", .greek: "Pro", .turkish: "Pro", .russian: "Pro", .indonesian: "Pro", .thai: "Pro", .vietnamese: "Pro"]
        case .family: rows = [.korean: "패밀리", .english: "Family", .japanese: "ファミリー", .chinese: "家庭版", .german: "Familie", .french: "Famille", .spanish: "Familia", .italian: "Famiglia", .portuguese: "Família", .chineseTraditional: "家庭版", .dutch: "Gezin", .swedish: "Familj", .norwegian: "Familie", .danish: "Familie", .finnish: "Perhe", .polish: "Rodzina", .czech: "Rodina", .greek: "Οικογένεια", .turkish: "Aile", .russian: "Семья", .indonesian: "Keluarga", .thai: "ครอบครัว", .vietnamese: "Gia đình"]
        }
        return rows[lang] ?? rows[.english] ?? ""
    }

    /// 트림 한 줄 설명
    static func trimTagline(_ tier: ProTier) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let rows: [AppLanguage: String]
        switch tier {
        case .plus, .free: rows = [.korean: "연차 계획을 알아서 짜 줘요", .english: "Plans your time off for you", .japanese: "休みの計画を自動で立てます", .chinese: "自动帮你规划休假", .german: "Plant deinen Urlaub für dich", .french: "Planifie vos congés pour vous", .spanish: "Planifica tus vacaciones por ti", .italian: "Pianifica le ferie al posto tuo", .portuguese: "Planeja suas folgas por você", .chineseTraditional: "自動幫你規劃休假", .dutch: "Plant je verlof voor je", .swedish: "Planerar ledigheten åt dig", .norwegian: "Planlegger fridagene for deg", .danish: "Planlægger din ferie for dig", .finnish: "Suunnittelee lomasi puolestasi", .polish: "Planuje urlop za ciebie", .czech: "Naplánuje dovolenou za tebe", .greek: "Σχεδιάζει τις άδειές σου για σένα", .turkish: "İzinlerini senin için planlar", .russian: "Сам планирует ваш отпуск", .indonesian: "Merencanakan cutimu otomatis", .thai: "วางแผนวันลาให้คุณ", .vietnamese: "Tự lên kế hoạch nghỉ phép cho bạn"]
        case .pro: rows = [.korean: "내 직장 규칙까지 그대로", .english: "Fits your workplace rules too", .japanese: "職場のルールにもそのまま対応", .chinese: "连单位的规定也能照顾到", .german: "Passt auch zu den Regeln deines Jobs", .french: "S’adapte aussi aux règles de votre travail", .spanish: "Se adapta también a las reglas de tu trabajo", .italian: "Si adatta anche alle regole del tuo lavoro", .portuguese: "Segue também as regras do seu trabalho", .chineseTraditional: "連公司的規定也能照顧到", .dutch: "Past ook bij de regels van je werk", .swedish: "Följer även reglerna på jobbet", .norwegian: "Følger også reglene på jobben", .danish: "Følger også reglerne på jobbet", .finnish: "Taipuu myös työpaikan sääntöihin", .polish: "Uwzględnia też zasady w twojej pracy", .czech: "Zvládne i pravidla tvé práce", .greek: "Ταιριάζει και στους κανόνες της δουλειάς σου", .turkish: "İş yerinin kurallarına da uyar", .russian: "Учитывает и правила вашей работы", .indonesian: "Sesuai juga dengan aturan kantormu", .thai: "รองรับกฎของที่ทำงานคุณด้วย", .vietnamese: "Hợp cả với quy định nơi làm việc"]
        case .family: rows = [.korean: "프로를 가족 6명이 함께", .english: "Pro for up to 6 family members", .japanese: "プロを家族6人まで", .chinese: "最多6位家人共享 Pro", .german: "Pro für bis zu 6 Familienmitglieder", .french: "Pro pour 6 membres de la famille", .spanish: "Pro para hasta 6 familiares", .italian: "Pro per un massimo di 6 familiari", .portuguese: "Pro para até 6 pessoas da família", .chineseTraditional: "最多6位家人共享 Pro", .dutch: "Pro voor maximaal 6 gezinsleden", .swedish: "Pro för upp till 6 i familjen", .norwegian: "Pro for opptil 6 i familien", .danish: "Pro til op til 6 i familien", .finnish: "Pro jopa 6 perheenjäsenelle", .polish: "Pro dla maksymalnie 6 osób z rodziny", .czech: "Pro až pro 6 členů rodiny", .greek: "Pro για έως 6 μέλη της οικογένειας", .turkish: "Pro, 6 aile üyesine kadar", .russian: "Pro для 6 членов семьи", .indonesian: "Pro untuk hingga 6 anggota keluarga", .thai: "Pro สำหรับครอบครัวสูงสุด 6 คน", .vietnamese: "Pro cho tối đa 6 người trong gia đình"]
        }
        return rows[lang] ?? rows[.english] ?? ""
    }

    /// 주력 트림 표시
    static var trimPopular: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "인기"
        case .english: return "Popular"
        case .japanese: return "人気"
        case .chinese: return "最受欢迎"
        case .german: return "Beliebt"
        case .french: return "Populaire"
        case .spanish: return "Popular"
        case .italian: return "Più scelto"
        case .portuguese: return "Popular"
        case .chineseTraditional: return "最受歡迎"
        case .dutch: return "Populair"
        case .swedish: return "Populär"
        case .norwegian: return "Populær"
        case .danish: return "Populær"
        case .finnish: return "Suosituin"
        case .polish: return "Popularny"
        case .czech: return "Oblíbené"
        case .greek: return "Δημοφιλές"
        case .turkish: return "Popüler"
        case .russian: return "Популярный"
        case .indonesian: return "Populer"
        case .thai: return "ยอดนิยม"
        case .vietnamese: return "Phổ biến"
        }
    }

    /// 아래 트림 전부 포함
    static func trimEverythingIn(_ name: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\(name)의 모든 기능"
        case .english: return "Everything in \(name)"
        case .japanese: return "\(name)のすべての機能"
        case .chinese: return "\(name) 的全部功能"
        case .german: return "Alles aus \(name)"
        case .french: return "Tout \(name)"
        case .spanish: return "Todo lo de \(name)"
        case .italian: return "Tutto di \(name)"
        case .portuguese: return "Tudo do \(name)"
        case .chineseTraditional: return "\(name) 的全部功能"
        case .dutch: return "Alles van \(name)"
        case .swedish: return "Allt i \(name)"
        case .norwegian: return "Alt i \(name)"
        case .danish: return "Alt i \(name)"
        case .finnish: return "Kaikki \(name)-ominaisuudet"
        case .polish: return "Wszystko z \(name)"
        case .czech: return "Vše z \(name)"
        case .greek: return "Όλα του \(name)"
        case .turkish: return "\(name) içindeki her şey"
        case .russian: return "Всё из \(name)"
        case .indonesian: return "Semua di \(name)"
        case .thai: return "ทุกอย่างใน \(name)"
        case .vietnamese: return "Mọi tính năng của \(name)"
        }
    }

    /// 트림 기능 — 추천 무제한 등록
    static var featUnlimitedRecs: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "추천 휴가 무제한 등록"
        case .english: return "Add unlimited suggestions"
        case .japanese: return "おすすめを無制限に登録"
        case .chinese: return "无限添加推荐"
        case .german: return "Unbegrenzt Vorschläge übernehmen"
        case .french: return "Suggestions illimitées"
        case .spanish: return "Sugerencias ilimitadas"
        case .italian: return "Suggerimenti illimitati"
        case .portuguese: return "Sugestões ilimitadas"
        case .chineseTraditional: return "無限新增推薦"
        case .dutch: return "Onbeperkt voorstellen toevoegen"
        case .swedish: return "Obegränsat med förslag"
        case .norwegian: return "Ubegrenset med forslag"
        case .danish: return "Ubegrænset med forslag"
        case .finnish: return "Rajattomasti ehdotuksia"
        case .polish: return "Nielimitowane propozycje"
        case .czech: return "Neomezeně návrhů"
        case .greek: return "Απεριόριστες προτάσεις"
        case .turkish: return "Sınırsız öneri ekleme"
        case .russian: return "Без ограничения рекомендаций"
        case .indonesian: return "Saran tanpa batas"
        case .thai: return "เพิ่มคำแนะนำได้ไม่จำกัด"
        case .vietnamese: return "Thêm gợi ý không giới hạn"
        }
    }

    /// 트림 기능 — 지난해·다음 해 추천
    static var featOtherYears: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "지난해·다음 해 추천"
        case .english: return "Suggestions for last and next year"
        case .japanese: return "昨年・来年のおすすめ"
        case .chinese: return "去年和明年的推荐"
        case .german: return "Vorschläge für letztes und nächstes Jahr"
        case .french: return "Suggestions pour l’an dernier et l’an prochain"
        case .spanish: return "Sugerencias del año pasado y el próximo"
        case .italian: return "Suggerimenti per l’anno scorso e il prossimo"
        case .portuguese: return "Sugestões do ano passado e do próximo"
        case .chineseTraditional: return "去年和明年的推薦"
        case .dutch: return "Voorstellen voor vorig en volgend jaar"
        case .swedish: return "Förslag för förra och nästa år"
        case .norwegian: return "Forslag for i fjor og neste år"
        case .danish: return "Forslag for sidste og næste år"
        case .finnish: return "Ehdotukset viime ja ensi vuodelle"
        case .polish: return "Propozycje na zeszły i przyszły rok"
        case .czech: return "Návrhy na loňský a příští rok"
        case .greek: return "Προτάσεις για πέρσι και του χρόνου"
        case .turkish: return "Geçen ve gelecek yıl için öneriler"
        case .russian: return "Рекомендации на прошлый и следующий год"
        case .indonesian: return "Saran untuk tahun lalu dan tahun depan"
        case .thai: return "คำแนะนำปีที่แล้วและปีหน้า"
        case .vietnamese: return "Gợi ý cho năm ngoái và năm sau"
        }
    }

    /// 트림 기능 — 가족 공유
    static var featFamilySharing: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "가족 최대 6명이 함께 쓰기 (가족 공유)"
        case .english: return "Up to 6 family members (Family Sharing)"
        case .japanese: return "家族6人まで一緒に使える（ファミリー共有）"
        case .chinese: return "最多6位家人一起用（家人共享）"
        case .german: return "Bis zu 6 Familienmitglieder (Familienfreigabe)"
        case .french: return "Jusqu’à 6 membres (Partage familial)"
        case .spanish: return "Hasta 6 familiares (En familia)"
        case .italian: return "Fino a 6 familiari (In famiglia)"
        case .portuguese: return "Até 6 pessoas (Compartilhamento Familiar)"
        case .chineseTraditional: return "最多6位家人一起用（家人共享）"
        case .dutch: return "Tot 6 gezinsleden (Delen met gezin)"
        case .swedish: return "Upp till 6 i familjen (Familjedelning)"
        case .norwegian: return "Opptil 6 i familien (Familiedeling)"
        case .danish: return "Op til 6 i familien (Familiedeling)"
        case .finnish: return "Jopa 6 perheenjäsentä (Perhejako)"
        case .polish: return "Do 6 osób z rodziny (Chmura rodzinna)"
        case .czech: return "Až 6 členů rodiny (Rodinné sdílení)"
        case .greek: return "Έως 6 μέλη (Οικογενειακή κοινή χρήση)"
        case .turkish: return "6 aile üyesine kadar (Aile Paylaşımı)"
        case .russian: return "До 6 членов семьи (Семейный доступ)"
        case .indonesian: return "Hingga 6 anggota (Berbagi Keluarga)"
        case .thai: return "สมาชิกครอบครัวสูงสุด 6 คน (การแชร์กันในครอบครัว)"
        case .vietnamese: return "Tối đa 6 người (Chia sẻ trong gia đình)"
        }
    }

    /// 요금 카드 — 무료 체험
    static func trialThenPrice(_ days: Int, _ price: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\(days)일 무료, 이후 연 \(price)"
        case .english: return "\(days) days free, then \(price)/year"
        case .japanese: return "\(days)日間無料、その後 年額\(price)"
        case .chinese: return "免费 \(days) 天，之后每年 \(price)"
        case .german: return "\(days) Tage gratis, dann \(price)/Jahr"
        case .french: return "\(days) jours gratuits, puis \(price)/an"
        case .spanish: return "\(days) días gratis, luego \(price)/año"
        case .italian: return "\(days) giorni gratis, poi \(price)/anno"
        case .portuguese: return "\(days) dias grátis, depois \(price)/ano"
        case .chineseTraditional: return "免費 \(days) 天，之後每年 \(price)"
        case .dutch: return "\(days) dagen gratis, daarna \(price)/jaar"
        case .swedish: return "\(days) dagar gratis, sedan \(price)/år"
        case .norwegian: return "\(days) dager gratis, deretter \(price)/år"
        case .danish: return "\(days) dage gratis, derefter \(price)/år"
        case .finnish: return "\(days) päivää maksutta, sitten \(price)/vuosi"
        case .polish: return "\(days) dni za darmo, potem \(price)/rok"
        case .czech: return "\(days) dní zdarma, pak \(price)/rok"
        case .greek: return "\(days) ημέρες δωρεάν, μετά \(price)/έτος"
        case .turkish: return "\(days) gün ücretsiz, sonra yıllık \(price)"
        case .russian: return "\(days) дней бесплатно, затем \(price) в год"
        case .indonesian: return "Gratis \(days) hari, lalu \(price)/tahun"
        case .thai: return "ฟรี \(days) วัน จากนั้นปีละ \(price)"
        case .vietnamese: return "Miễn phí \(days) ngày, sau đó \(price)/năm"
        }
    }

    /// 구매 버튼 — 무료 체험
    static func startTrial(_ days: Int) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\(days)일 무료로 시작"
        case .english: return "Start \(days)-day free trial"
        case .japanese: return "\(days)日間無料で始める"
        case .chinese: return "开始 \(days) 天免费试用"
        case .german: return "\(days) Tage gratis testen"
        case .french: return "Essai gratuit de \(days) jours"
        case .spanish: return "Prueba gratis \(days) días"
        case .italian: return "Prova gratis per \(days) giorni"
        case .portuguese: return "Testar grátis por \(days) dias"
        case .chineseTraditional: return "開始 \(days) 天免費試用"
        case .dutch: return "\(days) dagen gratis proberen"
        case .swedish: return "Prova gratis i \(days) dagar"
        case .norwegian: return "Prøv gratis i \(days) dager"
        case .danish: return "Prøv gratis i \(days) dage"
        case .finnish: return "Kokeile \(days) päivää maksutta"
        case .polish: return "Wypróbuj za darmo przez \(days) dni"
        case .czech: return "Vyzkoušet \(days) dní zdarma"
        case .greek: return "Δοκίμασε δωρεάν \(days) ημέρες"
        case .turkish: return "\(days) gün ücretsiz dene"
        case .russian: return "Попробовать \(days) дней бесплатно"
        case .indonesian: return "Coba gratis \(days) hari"
        case .thai: return "ทดลองใช้ฟรี \(days) วัน"
        case .vietnamese: return "Dùng thử miễn phí \(days) ngày"
        }
    }

    /// 구매 버튼
    static func startTrim(_ name: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\(name) 시작하기"
        case .english: return "Get \(name)"
        case .japanese: return "\(name)を始める"
        case .chinese: return "开通 \(name)"
        case .german: return "\(name) holen"
        case .french: return "Passer à \(name)"
        case .spanish: return "Obtener \(name)"
        case .italian: return "Passa a \(name)"
        case .portuguese: return "Assinar \(name)"
        case .chineseTraditional: return "開通 \(name)"
        case .dutch: return "\(name) nemen"
        case .swedish: return "Skaffa \(name)"
        case .norwegian: return "Skaff \(name)"
        case .danish: return "Få \(name)"
        case .finnish: return "Hanki \(name)"
        case .polish: return "Wybierz \(name)"
        case .czech: return "Pořídit \(name)"
        case .greek: return "Απόκτησε το \(name)"
        case .turkish: return "\(name)’a geç"
        case .russian: return "Подключить \(name)"
        case .indonesian: return "Dapatkan \(name)"
        case .thai: return "รับ \(name)"
        case .vietnamese: return "Nâng cấp \(name)"
        }
    }

    /// 패밀리 카드 — 한 사람 몫
    static func familyPerPersonHint(_ price: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "6명이면 한 사람당 한 달 \(price)꼴"
        case .english: return "About \(price)/month per person for 6"
        case .japanese: return "6人なら1人あたり月\(price)ほど"
        case .chinese: return "6人共用，每人每月约 \(price)"
        case .german: return "Bei 6 Personen ca. \(price) pro Kopf/Monat"
        case .french: return "Environ \(price)/mois par personne à 6"
        case .spanish: return "Unos \(price)/mes por persona entre 6"
        case .italian: return "Circa \(price)/mese a persona in 6"
        case .portuguese: return "Cerca de \(price)/mês por pessoa para 6"
        case .chineseTraditional: return "6人共用，每人每月約 \(price)"
        case .dutch: return "Ongeveer \(price)/maand per persoon met 6"
        case .swedish: return "Cirka \(price)/månad per person för 6"
        case .norwegian: return "Omtrent \(price)/måned per person for 6"
        case .danish: return "Omkring \(price)/måned pr. person for 6"
        case .finnish: return "Noin \(price)/kk henkeä kohden kuudelle"
        case .polish: return "Ok. \(price)/mies. na osobę przy 6"
        case .czech: return "Asi \(price)/měsíc na osobu při 6"
        case .greek: return "Περίπου \(price)/μήνα ανά άτομο για 6"
        case .turkish: return "6 kişide kişi başı ayda yaklaşık \(price)"
        case .russian: return "Около \(price) в месяц на человека при 6"
        case .indonesian: return "Sekitar \(price)/bulan per orang untuk 6"
        case .thai: return "ราว \(price)/เดือนต่อคน เมื่อใช้ 6 คน"
        case .vietnamese: return "Khoảng \(price)/tháng mỗi người nếu 6 người"
        }
    }

    /// 이미 쓰고 있는 트림 이하
    static var trimIncluded: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "이용 중인 트림에 들어 있어요"
        case .english: return "Included in your plan"
        case .japanese: return "ご利用中のプランに含まれています"
        case .chinese: return "已包含在你的方案中"
        case .german: return "In deinem Abo enthalten"
        case .french: return "Inclus dans votre formule"
        case .spanish: return "Incluido en tu plan"
        case .italian: return "Incluso nel tuo piano"
        case .portuguese: return "Incluído no seu plano"
        case .chineseTraditional: return "已包含在你的方案中"
        case .dutch: return "Zit in je abonnement"
        case .swedish: return "Ingår i din plan"
        case .norwegian: return "Inkludert i planen din"
        case .danish: return "Inkluderet i dit abonnement"
        case .finnish: return "Sisältyy tilaukseesi"
        case .polish: return "W twoim planie"
        case .czech: return "Součást tvého plánu"
        case .greek: return "Περιλαμβάνεται στο πρόγραμμά σου"
        case .turkish: return "Planına dahil"
        case .russian: return "Входит в ваш план"
        case .indonesian: return "Sudah termasuk paketmu"
        case .thai: return "รวมอยู่ในแผนของคุณแล้ว"
        case .vietnamese: return "Đã có trong gói của bạn"
        }
    }

}

// MARK: - 패밀리 · 함께 쉬기

extension Strings {
    /// 패밀리 기능 이름
    static var togetherTitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "함께 쉬기"
        case .english: return "Time Off Together"
        case .japanese: return "みんなで休む"
        case .chinese: return "一起休假"
        case .german: return "Gemeinsam frei"
        case .french: return "Congés ensemble"
        case .spanish: return "Descansar juntos"
        case .italian: return "Riposare insieme"
        case .portuguese: return "Folgas em família"
        case .chineseTraditional: return "一起休假"
        case .dutch: return "Samen vrij"
        case .swedish: return "Ledigt tillsammans"
        case .norwegian: return "Fri sammen"
        case .danish: return "Fri sammen"
        case .finnish: return "Yhteiset vapaat"
        case .polish: return "Wolne razem"
        case .czech: return "Volno spolu"
        case .greek: return "Άδεια μαζί"
        case .turkish: return "Birlikte izin"
        case .russian: return "Отдыхаем вместе"
        case .indonesian: return "Libur bersama"
        case .thai: return "หยุดพร้อมกัน"
        case .vietnamese: return "Cùng nghỉ"
        }
    }

    /// 가족 탭 입구 설명
    static var togetherSubtitle: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "가족 모두 쉬는 날과 한 사람만 연차 내면 되는 날"
        case .english: return "Days everyone's off, and days one leave away"
        case .japanese: return "家族みんなが休める日と、1人が休みを取ればそろう日"
        case .chinese: return "全家都休息的日子，以及只需一人请假就能一起休的日子"
        case .german: return "Tage, an denen alle frei haben – oder nur einer Urlaub braucht"
        case .french: return "Les jours où tout le monde est libre, ou à un congé près"
        case .spanish: return "Días libres para todos, o a un solo día de vacaciones"
        case .italian: return "Giorni liberi per tutti, o a un solo giorno di ferie"
        case .portuguese: return "Dias de folga para todos, ou a um só dia de férias"
        case .chineseTraditional: return "全家都放假的日子，以及只需一人請假就能一起休的日子"
        case .dutch: return "Dagen dat iedereen vrij is, of één vrije dag verwijderd"
        case .swedish: return "Dagar då alla är lediga, eller bara en behöver ta ledigt"
        case .norwegian: return "Dager alle har fri, eller bare én må ta fri"
        case .danish: return "Dage hvor alle har fri, eller kun én skal tage fri"
        case .finnish: return "Päivät, jolloin kaikki ovat vapaalla – tai vain yhden tarvitsee pitää lomaa"
        case .polish: return "Dni wolne dla wszystkich lub po jednym dniu urlopu"
        case .czech: return "Dny, kdy mají volno všichni, nebo stačí den dovolené jednoho"
        case .greek: return "Μέρες που όλοι είναι ελεύθεροι, ή αρκεί άδεια ενός"
        case .turkish: return "Herkesin izinli olduğu ya da tek kişinin izin alması yeten günler"
        case .russian: return "Дни, когда все отдыхают, или нужен отгул только одному"
        case .indonesian: return "Hari semua libur, atau cukup satu orang ambil cuti"
        case .thai: return "วันที่ทุกคนหยุด หรือมีคนลาแค่คนเดียวก็หยุดพร้อมกัน"
        case .vietnamese: return "Ngày cả nhà đều nghỉ, hoặc chỉ một người cần xin phép"
        }
    }

    /// 잠겼을 때
    static var togetherLocked: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "패밀리에서 쓸 수 있어요"
        case .english: return "Available with Family"
        case .japanese: return "ファミリーで使えます"
        case .chinese: return "家庭版可用"
        case .german: return "Mit Familie verfügbar"
        case .french: return "Disponible avec Famille"
        case .spanish: return "Disponible con Familia"
        case .italian: return "Disponibile con Famiglia"
        case .portuguese: return "Disponível no Família"
        case .chineseTraditional: return "家庭版可用"
        case .dutch: return "Beschikbaar met Gezin"
        case .swedish: return "Ingår i Familj"
        case .norwegian: return "Tilgjengelig med Familie"
        case .danish: return "Tilgængelig med Familie"
        case .finnish: return "Saatavilla Perhe-tilauksella"
        case .polish: return "Dostępne w planie Rodzina"
        case .czech: return "K dispozici v plánu Rodina"
        case .greek: return "Διαθέσιμο με Οικογένεια"
        case .turkish: return "Aile ile kullanılabilir"
        case .russian: return "Доступно в тарифе «Семья»"
        case .indonesian: return "Tersedia di Keluarga"
        case .thai: return "ใช้ได้กับแผนครอบครัว"
        case .vietnamese: return "Có trong gói Gia đình"
        }
    }

    /// 나
    static var togetherMe: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "나"
        case .english: return "Me"
        case .japanese: return "自分"
        case .chinese: return "我"
        case .german: return "Ich"
        case .french: return "Moi"
        case .spanish: return "Yo"
        case .italian: return "Io"
        case .portuguese: return "Eu"
        case .chineseTraditional: return "我"
        case .dutch: return "Ik"
        case .swedish: return "Jag"
        case .norwegian: return "Meg"
        case .danish: return "Mig"
        case .finnish: return "Minä"
        case .polish: return "Ja"
        case .czech: return "Já"
        case .greek: return "Εγώ"
        case .turkish: return "Ben"
        case .russian: return "Я"
        case .indonesian: return "Saya"
        case .thai: return "ฉัน"
        case .vietnamese: return "Tôi"
        }
    }

    /// 섹션 — 다 같이 쉬는 날
    static var togetherAllOffSection: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "다 같이 쉬는 날"
        case .english: return "Everyone's off"
        case .japanese: return "みんな休みの日"
        case .chinese: return "全家都休息"
        case .german: return "Alle haben frei"
        case .french: return "Tout le monde est libre"
        case .spanish: return "Todos libres"
        case .italian: return "Tutti liberi"
        case .portuguese: return "Todos de folga"
        case .chineseTraditional: return "全家都放假"
        case .dutch: return "Iedereen vrij"
        case .swedish: return "Alla lediga"
        case .norwegian: return "Alle har fri"
        case .danish: return "Alle har fri"
        case .finnish: return "Kaikki vapaalla"
        case .polish: return "Wszyscy mają wolne"
        case .czech: return "Všichni mají volno"
        case .greek: return "Όλοι ελεύθεροι"
        case .turkish: return "Herkes izinli"
        case .russian: return "Все отдыхают"
        case .indonesian: return "Semua libur"
        case .thai: return "ทุกคนหยุด"
        case .vietnamese: return "Cả nhà cùng nghỉ"
        }
    }

    /// 섹션 — 한 사람만 연차
    static var togetherOneLeaveSection: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "한 사람만 연차 내면 다 같이 쉬어요"
        case .english: return "One person's leave away"
        case .japanese: return "1人が休みを取ればみんな休める"
        case .chinese: return "只需一人请假就能一起休"
        case .german: return "Nur einer braucht Urlaub"
        case .french: return "Un seul congé à poser"
        case .spanish: return "Solo uno pide el día"
        case .italian: return "Basta un giorno di ferie"
        case .portuguese: return "Só uma pessoa tira folga"
        case .chineseTraditional: return "只需一人請假就能一起休"
        case .dutch: return "Eén iemand neemt vrij"
        case .swedish: return "En behöver ta ledigt"
        case .norwegian: return "Én må ta fri"
        case .danish: return "Én skal tage fri"
        case .finnish: return "Yksi pitää lomaa"
        case .polish: return "Wystarczy urlop jednej osoby"
        case .czech: return "Stačí dovolená jednoho"
        case .greek: return "Αρκεί άδεια ενός"
        case .turkish: return "Tek kişi izin alsın yeter"
        case .russian: return "Нужен отгул одного"
        case .indonesian: return "Cukup satu yang cuti"
        case .thai: return "ลาแค่คนเดียวก็หยุดพร้อมกัน"
        case .vietnamese: return "Chỉ một người xin nghỉ"
        }
    }

    /// 모두 쉰다
    static var togetherEveryoneOff: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "모두 쉬어요"
        case .english: return "Everyone's off"
        case .japanese: return "みんな休み"
        case .chinese: return "全家都休息"
        case .german: return "Alle haben frei"
        case .french: return "Tout le monde est libre"
        case .spanish: return "Todos libres"
        case .italian: return "Tutti liberi"
        case .portuguese: return "Todos de folga"
        case .chineseTraditional: return "全家都放假"
        case .dutch: return "Iedereen vrij"
        case .swedish: return "Alla är lediga"
        case .norwegian: return "Alle har fri"
        case .danish: return "Alle har fri"
        case .finnish: return "Kaikki vapaalla"
        case .polish: return "Wszyscy mają wolne"
        case .czech: return "Všichni mají volno"
        case .greek: return "Όλοι ελεύθεροι"
        case .turkish: return "Herkes izinli"
        case .russian: return "Все отдыхают"
        case .indonesian: return "Semua libur"
        case .thai: return "ทุกคนหยุด"
        case .vietnamese: return "Cả nhà đều nghỉ"
        }
    }

    /// 찾은 게 없음
    static var togetherNothingFound: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "앞으로 1년 안에는 없어요"
        case .english: return "None in the next 12 months"
        case .japanese: return "今後1年はありません"
        case .chinese: return "未来一年内没有"
        case .german: return "Keine in den nächsten 12 Monaten"
        case .french: return "Aucun dans les 12 prochains mois"
        case .spanish: return "Ninguno en los próximos 12 meses"
        case .italian: return "Nessuno nei prossimi 12 mesi"
        case .portuguese: return "Nenhum nos próximos 12 meses"
        case .chineseTraditional: return "未來一年內沒有"
        case .dutch: return "Geen in de komende 12 maanden"
        case .swedish: return "Inga under de kommande 12 månaderna"
        case .norwegian: return "Ingen de neste 12 månedene"
        case .danish: return "Ingen de næste 12 måneder"
        case .finnish: return "Ei yhtään seuraavan 12 kuukauden aikana"
        case .polish: return "Brak w ciągu najbliższych 12 miesięcy"
        case .czech: return "V příštích 12 měsících nic"
        case .greek: return "Κανένα τους επόμενους 12 μήνες"
        case .turkish: return "Önümüzdeki 12 ayda yok"
        case .russian: return "В ближайшие 12 месяцев нет"
        case .indonesian: return "Tidak ada dalam 12 bulan ke depan"
        case .thai: return "ไม่มีใน 12 เดือนข้างหน้า"
        case .vietnamese: return "Không có trong 12 tháng tới"
        }
    }

    /// 연속 일수
    static func togetherDaysInRow(_ n: Int) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\(n)일"
        case .english: return "\(n) days"
        case .japanese: return "\(n)日間"
        case .chinese: return "\(n) 天"
        case .german: return "\(n) Tage"
        case .french: return "\(n) jours"
        case .spanish: return "\(n) días"
        case .italian: return "\(n) giorni"
        case .portuguese: return "\(n) dias"
        case .chineseTraditional: return "\(n) 天"
        case .dutch: return "\(n) dagen"
        case .swedish: return "\(n) dagar"
        case .norwegian: return "\(n) dager"
        case .danish: return "\(n) dage"
        case .finnish: return "\(n) pv"
        case .polish: return "\(n) dni"
        case .czech: return "\(n) dní"
        case .greek: return "\(n) ημέρες"
        case .turkish: return "\(n) gün"
        case .russian: return "\(n) дн."
        case .indonesian: return "\(n) hari"
        case .thai: return "\(n) วัน"
        case .vietnamese: return "\(n) ngày"
        }
    }

    /// 한 사람만 연차 — 설명
    static func togetherLeaveNeeded(_ name: String, _ leave: Int, _ days: Int) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\(name) 연차 \(leave)일이면 다 같이 \(days)일"
        case .english: return "\(name): \(leave) leave → \(days) days together"
        case .japanese: return "\(name)が\(leave)日休めば、みんなで\(days)日"
        case .chinese: return "\(name) 请假 \(leave) 天，全家一起休 \(days) 天"
        case .german: return "\(name): \(leave) Urlaubstag(e) → \(days) Tage gemeinsam"
        case .french: return "\(name) : \(leave) j de congé → \(days) jours ensemble"
        case .spanish: return "\(name): \(leave) día(s) → \(days) días juntos"
        case .italian: return "\(name): \(leave) g di ferie → \(days) giorni insieme"
        case .portuguese: return "\(name): \(leave) dia(s) de folga → \(days) dias juntos"
        case .chineseTraditional: return "\(name) 請假 \(leave) 天，全家一起休 \(days) 天"
        case .dutch: return "\(name): \(leave) vrije dag(en) → \(days) dagen samen"
        case .swedish: return "\(name): \(leave) dag(ar) ledigt → \(days) dagar tillsammans"
        case .norwegian: return "\(name): \(leave) dag(er) fri → \(days) dager sammen"
        case .danish: return "\(name): \(leave) dag(e) fri → \(days) dage sammen"
        case .finnish: return "\(name): \(leave) lomapv → \(days) pv yhdessä"
        case .polish: return "\(name): \(leave) dz. urlopu → \(days) dni razem"
        case .czech: return "\(name): \(leave) den/dny dovolené → \(days) dní spolu"
        case .greek: return "\(name): \(leave) ημ. άδεια → \(days) ημέρες μαζί"
        case .turkish: return "\(name): \(leave) gün izin → \(days) gün birlikte"
        case .russian: return "\(name): отгул \(leave) дн. → \(days) дн. вместе"
        case .indonesian: return "\(name) cuti \(leave) hari → libur bersama \(days) hari"
        case .thai: return "\(name) ลา \(leave) วัน → หยุดพร้อมกัน \(days) วัน"
        case .vietnamese: return "\(name) nghỉ \(leave) ngày → cả nhà nghỉ \(days) ngày"
        }
    }

    /// 기념일 — 일하는 사람
    static func togetherWorking(_ names: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "출근: \(names)"
        case .english: return "Working: \(names)"
        case .japanese: return "出勤: \(names)"
        case .chinese: return "上班：\(names)"
        case .german: return "Arbeitet: \(names)"
        case .french: return "Au travail : \(names)"
        case .spanish: return "Trabaja: \(names)"
        case .italian: return "Al lavoro: \(names)"
        case .portuguese: return "Trabalha: \(names)"
        case .chineseTraditional: return "上班：\(names)"
        case .dutch: return "Werkt: \(names)"
        case .swedish: return "Jobbar: \(names)"
        case .norwegian: return "Jobber: \(names)"
        case .danish: return "Arbejder: \(names)"
        case .finnish: return "Töissä: \(names)"
        case .polish: return "Pracuje: \(names)"
        case .czech: return "Pracuje: \(names)"
        case .greek: return "Εργάζεται: \(names)"
        case .turkish: return "Çalışıyor: \(names)"
        case .russian: return "Работает: \(names)"
        case .indonesian: return "Masuk kerja: \(names)"
        case .thai: return "ทำงาน: \(names)"
        case .vietnamese: return "Đi làm: \(names)"
        }
    }

    /// 기념일 — 공유한 사람
    static func togetherSharedBy(_ name: String) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "\(name)님이 공유"
        case .english: return "Shared by \(name)"
        case .japanese: return "\(name)さんが共有"
        case .chinese: return "\(name) 共享"
        case .german: return "Geteilt von \(name)"
        case .french: return "Partagé par \(name)"
        case .spanish: return "Compartido por \(name)"
        case .italian: return "Condiviso da \(name)"
        case .portuguese: return "Compartilhado por \(name)"
        case .chineseTraditional: return "\(name) 分享"
        case .dutch: return "Gedeeld door \(name)"
        case .swedish: return "Delad av \(name)"
        case .norwegian: return "Delt av \(name)"
        case .danish: return "Delt af \(name)"
        case .finnish: return "Jakanut \(name)"
        case .polish: return "Udostępnia \(name)"
        case .czech: return "Sdílí \(name)"
        case .greek: return "Κοινοποίηση από \(name)"
        case .turkish: return "\(name) paylaştı"
        case .russian: return "Поделился(-ась) \(name)"
        case .indonesian: return "Dibagikan \(name)"
        case .thai: return "\(name) แชร์"
        case .vietnamese: return "\(name) đã chia sẻ"
        }
    }

    /// 계산 기준
    static var togetherFooter: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "주말, 각자 나라의 공휴일, 공유한 휴가로 계산해요. 반차는 쉬는 날로 치지 않아요. 가족이 일정 공유를 켜야 보여요."
        case .english: return "Based on weekends, each person's public holidays and shared leave. Half days don't count as days off. Family members need to share their schedule."
        case .japanese: return "週末、それぞれの国の祝日、共有された休みで計算します。半休は休みに数えません。家族が予定を共有すると表示されます。"
        case .chinese: return "根据周末、各自国家的法定假日和共享的休假计算。半天假不算休息日。家人需要开启日程共享。"
        case .german: return "Berechnet aus Wochenenden, den Feiertagen jedes Landes und geteiltem Urlaub. Halbe Tage zählen nicht als frei. Familienmitglieder müssen ihren Kalender teilen."
        case .french: return "Calculé d’après les week-ends, les jours fériés de chacun et les congés partagés. Les demi-journées ne comptent pas. Chacun doit partager son planning."
        case .spanish: return "Se calcula con fines de semana, festivos de cada país y vacaciones compartidas. Los medios días no cuentan. Cada familiar debe compartir su calendario."
        case .italian: return "Calcolato su weekend, festività di ciascun paese e ferie condivise. Le mezze giornate non contano. Ogni familiare deve condividere il calendario."
        case .portuguese: return "Calculado pelos fins de semana, feriados de cada país e folgas compartilhadas. Meio período não conta. Cada familiar precisa compartilhar a agenda."
        case .chineseTraditional: return "根據週末、各自國家的國定假日和共享的休假計算。半天假不算休息日。家人需要開啟行程共享。"
        case .dutch: return "Op basis van weekenden, feestdagen per land en gedeeld verlof. Halve dagen tellen niet als vrij. Gezinsleden moeten hun planning delen."
        case .swedish: return "Räknas från helger, varje lands helgdagar och delad ledighet. Halvdagar räknas inte som lediga. Familjen behöver dela sitt schema."
        case .norwegian: return "Beregnet ut fra helger, hvert lands helligdager og delt fri. Halve dager regnes ikke som fri. Familien må dele timeplanen sin."
        case .danish: return "Beregnet ud fra weekender, hvert lands helligdage og delt fri. Halve dage tæller ikke som fri. Familien skal dele deres plan."
        case .finnish: return "Lasketaan viikonloppujen, kunkin maan pyhäpäivien ja jaettujen lomien mukaan. Puolikkaat päivät eivät ole vapaita. Perheenjäsenten pitää jakaa aikataulunsa."
        case .polish: return "Liczone z weekendów, świąt w kraju każdej osoby i udostępnionych urlopów. Pół dnia nie liczy się jako wolne. Członkowie rodziny muszą udostępnić plan."
        case .czech: return "Počítá se z víkendů, svátků každé země a sdílené dovolené. Půlden se nepočítá jako volno. Rodina musí sdílet svůj plán."
        case .greek: return "Υπολογίζεται από Σαββατοκύριακα, αργίες κάθε χώρας και κοινές άδειες. Οι μισές μέρες δεν μετρούν. Η οικογένεια πρέπει να μοιράζεται το πρόγραμμα."
        case .turkish: return "Hafta sonları, herkesin ülkesindeki resmî tatiller ve paylaşılan izinlerle hesaplanır. Yarım günler izin sayılmaz. Ailenin programını paylaşması gerekir."
        case .russian: return "Учитываются выходные, праздники страны каждого и общие отпуска. Полдня не считаются выходным. Члены семьи должны поделиться расписанием."
        case .indonesian: return "Dihitung dari akhir pekan, hari libur negara masing-masing, dan cuti yang dibagikan. Setengah hari tidak dihitung libur. Anggota keluarga perlu membagikan jadwal."
        case .thai: return "คำนวณจากวันหยุดสุดสัปดาห์ วันหยุดราชการของแต่ละประเทศ และวันลาที่แชร์ ลาครึ่งวันไม่นับเป็นวันหยุด สมาชิกครอบครัวต้องแชร์ตารางก่อน"
        case .vietnamese: return "Tính theo cuối tuần, ngày lễ của từng nước và ngày nghỉ được chia sẻ. Nghỉ nửa ngày không tính. Người nhà cần chia sẻ lịch."
        }
    }

}
