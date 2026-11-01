//
//  Strings+Monetization.swift
//  Goldweek
//
//  2.4.0 유료화 정리 — 연간 구독·평생 구매 고르기, 구독 고지, 새로 Pro가 된 기능 문구.
//  무료 한도 미리 알림 · 응원(팁) · 선물 행 문구.
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

// MARK: - 칸 (무료 · 플러스 · 프로)

extension Strings {
    /// 칸 이름
    static func trimName(_ tier: ProTier) -> String {
        switch tier {
        case .free: return pick([.korean: "무료", .english: "Free", .japanese: "無料", .chinese: "免费版", .german: "Gratis", .french: "Gratuit", .spanish: "Gratis", .italian: "Gratis", .portuguese: "Grátis", .chineseTraditional: "免費版", .dutch: "Gratis", .swedish: "Gratis", .norwegian: "Gratis", .danish: "Gratis", .finnish: "Ilmainen", .polish: "Darmowy", .czech: "Zdarma", .greek: "Δωρεάν", .turkish: "Ücretsiz", .russian: "Бесплатно", .indonesian: "Gratis", .thai: "ฟรี", .vietnamese: "Miễn phí"])
        case .plus: return pick([.korean: "플러스", .english: "Plus", .japanese: "プラス", .chinese: "Plus", .german: "Plus", .french: "Plus", .spanish: "Plus", .italian: "Plus", .portuguese: "Plus", .chineseTraditional: "Plus", .dutch: "Plus", .swedish: "Plus", .norwegian: "Plus", .danish: "Plus", .finnish: "Plus", .polish: "Plus", .czech: "Plus", .greek: "Plus", .turkish: "Plus", .russian: "Plus", .indonesian: "Plus", .thai: "Plus", .vietnamese: "Plus"])
        case .pro: return pick([.korean: "프로", .english: "Pro", .japanese: "プロ", .chinese: "Pro", .german: "Pro", .french: "Pro", .spanish: "Pro", .italian: "Pro", .portuguese: "Pro", .chineseTraditional: "Pro", .dutch: "Pro", .swedish: "Pro", .norwegian: "Pro", .danish: "Pro", .finnish: "Pro", .polish: "Pro", .czech: "Pro", .greek: "Pro", .turkish: "Pro", .russian: "Pro", .indonesian: "Pro", .thai: "Pro", .vietnamese: "Pro"])
        }
    }

    /// 칸 한 줄 설명
    static func trimTagline(_ tier: ProTier) -> String {
        switch tier {
        case .free: return pick([.korean: "연차를 놓치지 않고, 올해 가장 긴 연휴를 찾아보세요.", .english: "Never lose a leave day, and find this year’s longest breaks.", .japanese: "休暇を無駄にせず、今年いちばん長い連休を見つけましょう。", .chinese: "不错过任何年假，找到今年最长的假期。", .german: "Verliere keinen Urlaubstag und finde die längsten Pausen des Jahres.", .french: "Ne perdez aucun jour de congé et trouvez les plus longues pauses de l’année.", .spanish: "No pierdas ningún día de permiso y encuentra los descansos más largos del año.", .italian: "Non perdere giorni di ferie e trova le pause più lunghe dell’anno.", .portuguese: "Não perca nenhum dia de folga e encontre as pausas mais longas do ano.", .chineseTraditional: "不錯過任何年假，找到今年最長的假期。", .dutch: "Verlies geen vrije dag en vind de langste pauzes van dit jaar.", .swedish: "Missa ingen ledig dag och hitta årets längsta ledigheter.", .norwegian: "Ikke mist en eneste feriedag, og finn årets lengste ferier.", .danish: "Mist ikke en eneste feriedag, og find årets længste ferier.", .finnish: "Älä menetä yhtään vapaapäivää ja löydä vuoden pisimmät lomat.", .polish: "Nie trać dni urlopu i znajdź najdłuższe przerwy w tym roku.", .czech: "Nepřijdeš o žádný den volna a najdeš nejdelší volno v roce.", .greek: "Μη χάνεις καμία μέρα άδειας και βρες τα μεγαλύτερα διαλείμματα της χρονιάς.", .turkish: "İzin günlerini kaçırma, bu yılın en uzun tatillerini bul.", .russian: "Не теряйте дни отпуска и находите самые длинные перерывы года.", .indonesian: "Jangan lewatkan hari cuti dan temukan libur terpanjang tahun ini.", .thai: "ไม่พลาดวันลา และค้นหาวันหยุดยาวที่สุดของปีนี้", .vietnamese: "Không bỏ lỡ ngày phép nào và tìm kỳ nghỉ dài nhất năm nay."])
        case .plus: return pick([.korean: "추천을 마음껏 넣고, 작년과 내년까지 짜 보세요.", .english: "Add every suggestion you like and plan last year and next year too.", .japanese: "おすすめを好きなだけ追加して、去年と来年の分も計画しましょう。", .chinese: "随意添加推荐，还能查看去年并规划明年。", .german: "Füge beliebig viele Vorschläge hinzu und plane auch letztes und nächstes Jahr.", .french: "Ajoutez autant de suggestions que vous voulez, pour l’an dernier et l’an prochain aussi.", .spanish: "Añade todas las sugerencias que quieras y planifica también el año pasado y el próximo.", .italian: "Aggiungi tutti i suggerimenti che vuoi e pianifica anche l’anno scorso e il prossimo.", .portuguese: "Adicione quantas sugestões quiser e planeje também o ano passado e o próximo.", .chineseTraditional: "隨意加入推薦，還能查看去年並規劃明年。", .dutch: "Voeg zoveel suggesties toe als je wilt en plan ook vorig en volgend jaar.", .swedish: "Lägg till alla förslag du vill och planera även förra och nästa år.", .norwegian: "Legg til alle forslagene du vil, og planlegg også i fjor og neste år.", .danish: "Tilføj alle de forslag, du vil, og planlæg også sidste og næste år.", .finnish: "Lisää ehdotuksia vapaasti ja suunnittele myös viime ja ensi vuosi.", .polish: "Dodawaj dowolnie sugestie i planuj także zeszły i przyszły rok.", .czech: "Přidávej návrhy podle libosti a plánuj i minulý a příští rok.", .greek: "Πρόσθεσε όσες προτάσεις θέλεις και σχεδίασε και την περσινή και την επόμενη χρονιά.", .turkish: "İstediğin kadar öneri ekle, geçen ve gelecek yılı da planla.", .russian: "Добавляйте сколько угодно рекомендаций и планируйте также прошлый и следующий год.", .indonesian: "Tambahkan saran sesukamu dan rencanakan juga tahun lalu dan tahun depan.", .thai: "เพิ่มคำแนะนำได้ตามใจ และวางแผนทั้งปีที่แล้วและปีหน้า", .vietnamese: "Thêm gợi ý tùy thích và lên kế hoạch cả năm ngoái lẫn năm sau."])
        case .pro: return pick([.korean: "복잡한 휴가 규칙도, 가족과 함께 쉬는 날도 알아서.", .english: "Complex leave rules and days off with family, handled for you.", .japanese: "複雑な休暇ルールも、家族と休む日もおまかせ。", .chinese: "复杂的休假规则和家人共同的休息日，都交给它。", .german: "Komplexe Urlaubsregeln und freie Tage mit der Familie, automatisch geregelt.", .french: "Règles de congés complexes et jours en famille, tout est géré.", .spanish: "Reglas de permisos complejas y días libres en familia, resueltos por ti.", .italian: "Regole complesse e giorni liberi in famiglia, ci pensa l’app.", .portuguese: "Regras complexas de folga e dias livres em família, tudo resolvido.", .chineseTraditional: "複雜的休假規則和家人共同的休息日，都交給它。", .dutch: "Ingewikkelde verlofregels en vrije dagen met het gezin, geregeld voor jou.", .swedish: "Krångliga ledighetsregler och lediga dagar med familjen, ordnat åt dig.", .norwegian: "Kompliserte ferieregler og fridager med familien, ordnet for deg.", .danish: "Komplicerede ferieregler og fridage med familien, klaret for dig.", .finnish: "Monimutkaiset lomasäännöt ja perheen yhteiset vapaat hoituvat puolestasi.", .polish: "Złożone zasady urlopów i wolne dni z rodziną załatwione za Ciebie.", .czech: "Složitá pravidla volna i dny s rodinou vyřešené za tebe.", .greek: "Σύνθετοι κανόνες αδειών και ρεπό με την οικογένεια, χωρίς κόπο.", .turkish: "Karmaşık izin kuralları ve aileyle izin günleri senin için halledilir.", .russian: "Сложные правила отпусков и выходные с семьёй — всё под контролем.", .indonesian: "Aturan cuti yang rumit dan hari libur bersama keluarga, semua beres.", .thai: "กฎการลาที่ซับซ้อนและวันหยุดกับครอบครัว จัดการให้เอง", .vietnamese: "Quy tắc nghỉ phức tạp và ngày nghỉ cùng gia đình, đã có ứng dụng lo."])
        }
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


    /// 이미 쓰고 있는 트림 이하
    static var trimIncluded: String {
        switch LanguageManager.shared.currentLanguage {
        case .korean: return "지금 쓰는 요금제에 들어 있어요"
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

// MARK: - 함께 쉬기 (프로)

extension Strings {
    /// 함께 쉬기 이름
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
        pick([.korean: "프로에서 쓸 수 있어요", .english: "Available with Pro", .japanese: "プロで使えます", .chinese: "Pro 可用", .german: "Mit Pro verfügbar", .french: "Disponible avec Pro", .spanish: "Disponible con Pro", .italian: "Disponibile con Pro", .portuguese: "Disponível no Pro", .chineseTraditional: "Pro 可用", .dutch: "Beschikbaar met Pro", .swedish: "Ingår i Pro", .norwegian: "Tilgjengelig med Pro", .danish: "Tilgængelig med Pro", .finnish: "Kuuluu Pro-versioon", .polish: "Dostępne w Pro", .czech: "K dispozici v Pro", .greek: "Διαθέσιμο με Pro", .turkish: "Pro ile kullanılabilir", .russian: "Доступно в Pro", .indonesian: "Tersedia di Pro", .thai: "ใช้ได้กับ Pro", .vietnamese: "Có trong gói Pro"])
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

// MARK: - 무료 한도 미리 알림 · 응원(팁) · 선물

extension Strings {
    /// 추천 목록 위 — 무료로 넣을 수 있는 칸이 거의 끝났다(`RecommendationGate`). `n` 은 지금 남은 무료 칸 수.
    static func freeRecommendationNotice(remaining n: Int) -> String {
        pick([.korean: "무료로 넣을 수 있는 추천이 \(n)개 남았어요", .english: "Free suggestions left to add: \(n)", .japanese: "無料で追加できるおすすめは残り\(n)件です", .chinese: "还可免费添加的推荐：\(n)", .german: "Noch kostenlos hinzufügbare Vorschläge: \(n)", .french: "Suggestions gratuites restantes : \(n)", .spanish: "Sugerencias gratis restantes: \(n)", .italian: "Suggerimenti gratuiti rimasti: \(n)", .portuguese: "Sugestões grátis restantes: \(n)", .chineseTraditional: "還可免費加入的推薦：\(n)", .dutch: "Gratis suggesties over: \(n)", .swedish: "Gratisförslag kvar: \(n)", .norwegian: "Gratis forslag igjen: \(n)", .danish: "Gratis forslag tilbage: \(n)", .finnish: "Ilmaisia ehdotuksia jäljellä: \(n)", .polish: "Pozostałe darmowe sugestie: \(n)", .czech: "Zbývající návrhy zdarma: \(n)", .greek: "Δωρεάν προτάσεις που απομένουν: \(n)", .turkish: "Kalan ücretsiz öneri: \(n)", .russian: "Осталось бесплатных рекомендаций: \(n)", .indonesian: "Sisa saran gratis: \(n)", .thai: "คำแนะนำฟรีที่เหลือ: \(n)", .vietnamese: "Gợi ý miễn phí còn lại: \(n)"])
    }

    /// 팁 부탁 카드의 숫자 한 줄 — 올해 추천으로 세운 휴가 계획 수(`ProBenefits.recommendedPlanCount`)
    static func tipAskPlans(_ n: Int) -> String {
        pick([.korean: "올해 Goldweek 추천으로 휴가 계획을 \(n)개 세웠어요", .english: "You’ve planned \(n) breaks with Goldweek’s recommendations this year", .japanese: "今年はGoldweekのおすすめで休みを\(n)回計画しました", .chinese: "今年你已用 Goldweek 的推荐规划了 \(n) 次休假", .german: "Du hast dieses Jahr \(n) Auszeiten mit Goldweek-Empfehlungen geplant", .french: "Cette année, vous avez planifié \(n) congés grâce aux recommandations de Goldweek", .spanish: "Este año has planificado \(n) descansos con las recomendaciones de Goldweek", .italian: "Quest’anno hai pianificato \(n) pause con i suggerimenti di Goldweek", .portuguese: "Este ano você planejou \(n) folgas com as sugestões do Goldweek", .chineseTraditional: "今年你已用 Goldweek 的推薦規劃了 \(n) 次休假", .dutch: "Je hebt dit jaar \(n) keer vrij gepland met aanbevelingen van Goldweek", .swedish: "Du har planerat \(n) ledigheter med Goldweeks förslag i år", .norwegian: "Du har planlagt fri \(n) ganger med Goldweeks anbefalinger i år", .danish: "Du har planlagt fri \(n) gange med Goldweeks anbefalinger i år", .finnish: "Olet suunnitellut tänä vuonna \(n) lomaa Goldweekin ehdotuksilla", .polish: "Urlopy zaplanowane w tym roku z rekomendacji Goldweek: \(n)", .czech: "Volna naplánovaná letos podle doporučení Goldweeku: \(n)", .greek: "Άδειες που οργάνωσες φέτος με τις προτάσεις του Goldweek: \(n)", .turkish: "Bu yıl Goldweek önerileriyle \(n) izin planladın", .russian: "Отпусков по рекомендациям Goldweek в этом году: \(n)", .indonesian: "Tahun ini kamu sudah merencanakan \(n) cuti dari rekomendasi Goldweek", .thai: "ปีนี้คุณวางแผนวันหยุดจากคำแนะนำของ Goldweek ไปแล้ว \(n) ครั้ง", .vietnamese: "Năm nay bạn đã lên \(n) kỳ nghỉ nhờ gợi ý của Goldweek"])
    }

    /// 팁 부탁 카드의 숫자 한 줄 — 지금까지 적어 둔 휴가 기록 수
    static func tipAskLeaves(_ n: Int) -> String {
        pick([.korean: "Goldweek로 휴가를 \(n)번 챙겼어요", .english: "You’ve tracked \(n) time-off entries in Goldweek", .japanese: "Goldweekで休みを\(n)件記録しました", .chinese: "你已在 Goldweek 记录了 \(n) 次休假", .german: "Du hast \(n) Urlaube in Goldweek festgehalten", .french: "Vous avez noté \(n) congés dans Goldweek", .spanish: "Has anotado \(n) vacaciones en Goldweek", .italian: "Hai registrato \(n) periodi di ferie in Goldweek", .portuguese: "Você já registrou \(n) folgas no Goldweek", .chineseTraditional: "你已在 Goldweek 記錄了 \(n) 次休假", .dutch: "Je hebt \(n) keer verlof bijgehouden in Goldweek", .swedish: "Du har fört in \(n) ledigheter i Goldweek", .norwegian: "Du har registrert fri \(n) ganger i Goldweek", .danish: "Du har registreret fri \(n) gange i Goldweek", .finnish: "Olet kirjannut Goldweekiin \(n) lomaa", .polish: "Urlopy zapisane w Goldweek: \(n)", .czech: "Volna zapsaná v Goldweeku: \(n)", .greek: "Άδειες που κατέγραψες στο Goldweek: \(n)", .turkish: "Goldweek’e \(n) izin kaydettin", .russian: "Отпусков записано в Goldweek: \(n)", .indonesian: "Kamu sudah mencatat \(n) cuti di Goldweek", .thai: "คุณบันทึกวันลาใน Goldweek ไปแล้ว \(n) ครั้ง", .vietnamese: "Bạn đã ghi \(n) lần nghỉ phép trong Goldweek"])
    }

    /// 설정 — 선물 · 응원 섹션 머리
    static var giftAndTipSection: String {
        pick([.korean: "선물과 응원", .english: "Gifts & Support", .japanese: "ギフトと応援", .chinese: "礼物与支持", .german: "Geschenke & Unterstützung", .french: "Cadeaux et soutien", .spanish: "Regalos y apoyo", .italian: "Regali e sostegno", .portuguese: "Presentes e apoio", .chineseTraditional: "禮物與支持", .dutch: "Cadeaus en steun", .swedish: "Gåvor och stöd", .norwegian: "Gaver og støtte", .danish: "Gaver og støtte", .finnish: "Lahjat ja tuki", .polish: "Prezenty i wsparcie", .czech: "Dárky a podpora", .greek: "Δώρα και στήριξη", .turkish: "Hediyeler ve destek", .russian: "Подарки и поддержка", .indonesian: "Hadiah dan dukungan", .thai: "ของขวัญและการสนับสนุน", .vietnamese: "Quà tặng và ủng hộ"])
    }

    // ⚠️ 아래 넷은 LeeoKit 카탈로그(`LeeoTipText` · `LeeoGiftText`)의 번역을 그대로 옮긴 것이다.
    //    LeeoKit 문구는 **기기 언어**를 따라서, 앱 언어만 바꾼 사람에게 설정 행이 다른 말로 남는다(지원 섹션 주석 참고).

    /// 설정 — 팁 화면으로 (`LeeoTipText.entry`)
    static var tipEntry: String {
        pick([.korean: "개발자 응원하기", .english: "Support the Developer", .japanese: "開発者を応援する", .chinese: "支持开发者", .german: "Entwickler unterstützen", .french: "Soutenir le développeur", .spanish: "Apoya al desarrollador", .italian: "Sostieni lo sviluppatore", .portuguese: "Apoie o desenvolvedor", .chineseTraditional: "支持開發者", .dutch: "Steun de ontwikkelaar", .swedish: "Stöd utvecklaren", .norwegian: "Støtt utvikleren", .danish: "Støt udvikleren", .finnish: "Tue kehittäjää", .polish: "Wesprzyj twórcę", .czech: "Podpořit vývojáře", .greek: "Στήριξε τον δημιουργό", .turkish: "Geliştiriciyi Destekleyin", .russian: "Поддержать разработчика", .indonesian: "Dukung Pengembang", .thai: "สนับสนุนผู้พัฒนา", .vietnamese: "Ủng hộ nhà phát triển"])
    }

    /// 설정 — 팁 행 아래 한 줄 (`LeeoTipText.entrySubtitle`)
    static var tipEntrySubtitle: String {
        pick([.korean: "기능은 그대로, 앱을 더 다듬는 데 쓰여요", .english: "Nothing changes in the app, it helps polish it further", .japanese: "機能はそのまま、アプリをさらに磨くために使われます", .chinese: "功能不变，用来把 App 做得更好", .german: "Die App bleibt gleich, es hilft beim Weiterentwickeln", .french: "Rien ne change dans l'app, cela aide à la peaufiner", .spanish: "No cambia nada en la app, ayuda a pulirla más", .italian: "L'app non cambia, aiuta a migliorarla ancora", .portuguese: "Nada muda no app, ajuda a deixá-lo ainda melhor", .chineseTraditional: "功能不變，用來把 App 做得更好", .dutch: "Er verandert niets in de app, het helpt om hem verder te verbeteren", .swedish: "Inget ändras i appen, det hjälper till att förbättra den", .norwegian: "Ingenting endres i appen, det hjelper til å gjøre den bedre", .danish: "Intet ændres i appen, det hjælper med at gøre den bedre", .finnish: "Sovellus pysyy samana, tuki auttaa hiomaan sitä", .polish: "Funkcje się nie zmieniają, to pomaga dalej dopracowywać aplikację", .czech: "V aplikaci se nic nemění, pomůže to ji dál vylepšovat", .greek: "Τίποτα δεν αλλάζει στην εφαρμογή, βοηθά να γίνει ακόμα καλύτερη", .turkish: "Uygulamada hiçbir şey değişmez, daha da iyileştirmeye yarar", .russian: "Функции не меняются, деньги идут на доработку приложения", .indonesian: "Fitur tetap sama, dipakai untuk menyempurnakan app", .thai: "ฟีเจอร์เหมือนเดิม ใช้เพื่อปรับแอปให้ดียิ่งขึ้น", .vietnamese: "Tính năng giữ nguyên, dùng để hoàn thiện ứng dụng hơn"])
    }

    /// 설정 — 선물 보내기 (`LeeoGiftText.sendEntry`)
    static var giftSendEntry: String {
        pick([.korean: "Pro 선물하기", .english: "Gift Pro", .japanese: "Proをプレゼント", .chinese: "赠送 Pro", .german: "Pro verschenken", .french: "Offrir Pro", .spanish: "Regalar Pro", .italian: "Regala Pro", .portuguese: "Presentear Pro", .chineseTraditional: "贈送 Pro", .dutch: "Pro cadeau geven", .swedish: "Ge bort Pro", .norwegian: "Gi bort Pro", .danish: "Giv Pro i gave", .finnish: "Anna Pro lahjaksi", .polish: "Podaruj Pro", .czech: "Darovat Pro", .greek: "Δώρο Pro", .turkish: "Pro hediye et", .russian: "Подарить Pro", .indonesian: "Hadiahkan Pro", .thai: "มอบ Pro เป็นของขวัญ", .vietnamese: "Tặng Pro"])
    }

    /// 설정 — 받은 선물 코드 넣기 (`LeeoGiftText.redeemEntry`)
    static var giftRedeemEntry: String {
        pick([.korean: "선물 코드 입력", .english: "Redeem Gift Code", .japanese: "ギフトコードを入力", .chinese: "输入礼品码", .german: "Geschenkcode eingeben", .french: "Saisir un code cadeau", .spanish: "Canjear código de regalo", .italian: "Riscatta codice regalo", .portuguese: "Resgatar código de presente", .chineseTraditional: "輸入禮物碼", .dutch: "Cadeaucode invoeren", .swedish: "Lös in presentkod", .norwegian: "Løs inn gavekode", .danish: "Indløs gavekode", .finnish: "Lunasta lahjakoodi", .polish: "Wpisz kod prezentu", .czech: "Zadat dárkový kód", .greek: "Εξαργύρωση κωδικού δώρου", .turkish: "Hediye kodu gir", .russian: "Ввести код подарка", .indonesian: "Tukarkan Kode Hadiah", .thai: "ใส่รหัสของขวัญ", .vietnamese: "Nhập mã quà tặng"])
    }
}

// MARK: - 세 칸 페이월 (2.4.2)

extension Strings {
    /// 페이월 머리말
    static var paywallLadderTitle: String {
        "Goldweek \(trimName(.plus)) · \(trimName(.pro))"
    }

    /// 페이월 머리말 아래 한 줄. 유료 칸마다 연 구독과 평생이 있다.
    static var paywallLadderSubtitle: String {
        pick([.korean: "쉬는 습관은 무료. 계획과 자동화는 연 구독이나 평생으로", .english: "Resting well is free. Planning and automation, yearly or for life.", .japanese: "休む習慣は無料。計画と自動化は年額か買い切りで", .chinese: "好好休息免费。规划与自动化可按年订阅或终身购买", .german: "Gute Pausen sind kostenlos. Planung und Automatik jährlich oder für immer.", .french: "Bien se reposer est gratuit. Planification et automatisation à l’année ou à vie.", .spanish: "Descansar bien es gratis. Planificación y automatización, al año o para siempre.", .italian: "Riposare bene è gratis. Pianificazione e automazione, all’anno o per sempre.", .portuguese: "Descansar bem é grátis. Planejamento e automação, por ano ou para sempre.", .chineseTraditional: "好好休息免費。規劃與自動化可按年訂閱或終身購買", .dutch: "Goed rusten is gratis. Plannen en automatiseren per jaar of voor altijd.", .swedish: "Bra vila är gratis. Planering och automatik per år eller för alltid.", .norwegian: "God hvile er gratis. Planlegging og automatikk per år eller for alltid.", .danish: "God hvile er gratis. Planlægning og automatik pr. år eller for altid.", .finnish: "Hyvä lepo on ilmaista. Suunnittelu ja automaatio vuosittain tai ikuisesti.", .polish: "Dobry odpoczynek jest za darmo. Planowanie i automatyzacja na rok lub na zawsze.", .czech: "Dobrý odpočinek je zdarma. Plánování a automatizace na rok nebo navždy.", .greek: "Η καλή ξεκούραση είναι δωρεάν. Σχεδιασμός και αυτοματισμός ετήσια ή για πάντα.", .turkish: "İyi dinlenmek ücretsiz. Planlama ve otomasyon yıllık ya da ömür boyu.", .russian: "Хороший отдых бесплатно. Планирование и автоматизация на год или навсегда.", .indonesian: "Istirahat yang baik itu gratis. Perencanaan dan otomatisasi per tahun atau selamanya.", .thai: "การพักผ่อนที่ดีใช้ได้ฟรี การวางแผนและระบบอัตโนมัติเลือกแบบรายปีหรือตลอดชีพ", .vietnamese: "Nghỉ ngơi tốt là miễn phí. Lập kế hoạch và tự động hóa theo năm hoặc trọn đời."])
    }

    /// 무료 칸: 휴가 기록과 남은 연차
    static var freeFeatTracking: String {
        pick([.korean: "휴가 기록과 남은 연차", .english: "Log time off and see what’s left", .japanese: "休暇の記録と残りの有給", .chinese: "记录休假，查看剩余年假", .german: "Urlaub eintragen, Resturlaub sehen", .french: "Notez vos congés et voyez le solde", .spanish: "Registra tus días libres y lo que te queda", .italian: "Registra le ferie e vedi quelle rimaste", .portuguese: "Registre folgas e veja o saldo", .chineseTraditional: "記錄休假，查看剩餘特休", .dutch: "Verlof bijhouden en je saldo zien", .swedish: "Logga ledighet och se vad som är kvar", .norwegian: "Før fridager og se hva som er igjen", .danish: "Registrér fridage og se, hvad der er tilbage", .finnish: "Kirjaa lomat ja näe, paljonko on jäljellä", .polish: "Zapisuj urlop i sprawdzaj, ile zostało", .czech: "Zapisuj dovolenou a sleduj, kolik zbývá", .greek: "Κατέγραψε άδειες και δες το υπόλοιπο", .turkish: "İzinlerini kaydet, kalanı gör", .russian: "Учёт отпусков и оставшихся дней", .indonesian: "Catat cuti dan lihat sisanya", .thai: "บันทึกวันลาและดูวันลาที่เหลือ", .vietnamese: "Ghi ngày nghỉ và xem số ngày còn lại"])
    }

    /// 무료 칸: 나라별 공휴일, 내 공휴일과 방학
    static var freeFeatHolidays: String {
        pick([.korean: "나라별 공휴일, 내 공휴일과 방학", .english: "Public holidays, your own days off and school breaks", .japanese: "国ごとの祝日、自分の休日や長期休み", .chinese: "各国公共假日，以及自定义假日和假期", .german: "Feiertage deines Landes, eigene freie Tage und Ferien", .french: "Jours fériés du pays, vos propres jours et vacances", .spanish: "Festivos de tu país, tus propios días y vacaciones escolares", .italian: "Festività del paese, giorni personali e vacanze", .portuguese: "Feriados do país, seus próprios dias e férias escolares", .chineseTraditional: "各國國定假日，以及自訂假日和假期", .dutch: "Feestdagen per land, eigen vrije dagen en vakanties", .swedish: "Helgdagar i ditt land, egna lediga dagar och lov", .norwegian: "Helligdager i landet ditt, egne fridager og ferier", .danish: "Helligdage i dit land, egne fridage og ferier", .finnish: "Maasi pyhäpäivät, omat vapaapäivät ja lomat", .polish: "Święta w twoim kraju, własne dni wolne i ferie", .czech: "Svátky tvé země, vlastní volna a prázdniny", .greek: "Αργίες της χώρας σου, δικές σου μέρες και διακοπές", .turkish: "Ülkenin resmi tatilleri, kendi izin günlerin ve okul tatilleri", .russian: "Праздники вашей страны, свои выходные и каникулы", .indonesian: "Hari libur nasional, hari libur sendiri, dan libur sekolah", .thai: "วันหยุดของแต่ละประเทศ วันหยุดของคุณเองและปิดเทอม", .vietnamese: "Ngày lễ theo quốc gia, ngày nghỉ riêng và kỳ nghỉ học"])
    }

    // MARK: - 페이월 비교표 · 주 / 월 구독

    static var compareTitle: String { pick([.korean: "칸별로 비교하기", .english: "Compare plans", .japanese: "プランを比較", .chinese: "比较方案", .german: "Pläne vergleichen", .french: "Comparer les offres", .spanish: "Comparar planes", .italian: "Confronta i piani", .portuguese: "Comparar planos", .chineseTraditional: "比較方案", .dutch: "Abonnementen vergelijken", .swedish: "Jämför planer", .norwegian: "Sammenlign planer", .danish: "Sammenlign planer", .finnish: "Vertaile tasoja", .polish: "Porównaj plany", .czech: "Porovnat plány", .greek: "Σύγκριση προγραμμάτων", .turkish: "Planları karşılaştır", .russian: "Сравнить планы", .indonesian: "Bandingkan paket", .thai: "เปรียบเทียบแผน", .vietnamese: "So sánh các gói"]) }
    static var compareRecommendations: String { pick([.korean: "올해 추천 일정에 넣기", .english: "Add this year’s suggestions", .japanese: "今年のおすすめを追加", .chinese: "添加今年的推荐", .german: "Vorschläge dieses Jahres hinzufügen", .french: "Ajouter les suggestions de l’année", .spanish: "Añadir sugerencias de este año", .italian: "Aggiungi i suggerimenti dell’anno", .portuguese: "Adicionar sugestões deste ano", .chineseTraditional: "加入今年的推薦", .dutch: "Suggesties van dit jaar toevoegen", .swedish: "Lägg till årets förslag", .norwegian: "Legg til årets forslag", .danish: "Tilføj årets forslag", .finnish: "Lisää tämän vuoden ehdotukset", .polish: "Dodaj sugestie na ten rok", .czech: "Přidat letošní návrhy", .greek: "Προσθήκη προτάσεων της χρονιάς", .turkish: "Bu yılın önerilerini ekle", .russian: "Добавить рекомендации этого года", .indonesian: "Tambahkan saran tahun ini", .thai: "เพิ่มคำแนะนำของปีนี้", .vietnamese: "Thêm gợi ý năm nay"]) }
    static var compareUnlimited: String { pick([.korean: "무제한", .english: "Unlimited", .japanese: "無制限", .chinese: "无限", .german: "Unbegrenzt", .french: "Illimité", .spanish: "Sin límite", .italian: "Illimitati", .portuguese: "Ilimitado", .chineseTraditional: "無限", .dutch: "Onbeperkt", .swedish: "Obegränsat", .norwegian: "Ubegrenset", .danish: "Ubegrænset", .finnish: "Rajaton", .polish: "Bez limitu", .czech: "Neomezeně", .greek: "Απεριόριστα", .turkish: "Sınırsız", .russian: "Без лимита", .indonesian: "Tanpa batas", .thai: "ไม่จำกัด", .vietnamese: "Không giới hạn"]) }
    static var shortPlansTitle: String { pick([.korean: "주간 · 월간으로 보기", .english: "See weekly and monthly", .japanese: "週額・月額を見る", .chinese: "查看按周和按月", .german: "Wöchentlich und monatlich ansehen", .french: "Voir à la semaine et au mois", .spanish: "Ver semanal y mensual", .italian: "Vedi settimanale e mensile", .portuguese: "Ver semanal e mensal", .chineseTraditional: "查看按週和按月", .dutch: "Bekijk per week en per maand", .swedish: "Visa vecko- och månadsvis", .norwegian: "Se ukentlig og månedlig", .danish: "Se ugentligt og månedligt", .finnish: "Näytä viikoittain ja kuukausittain", .polish: "Zobacz tygodniowo i miesięcznie", .czech: "Zobrazit týdně a měsíčně", .greek: "Δες εβδομαδιαία και μηνιαία", .turkish: "Haftalık ve aylık gör", .russian: "Смотреть на неделю и месяц", .indonesian: "Lihat mingguan dan bulanan", .thai: "ดูแบบรายสัปดาห์และรายเดือน", .vietnamese: "Xem theo tuần và theo tháng"]) }
    static func shortPlanWeekly(_ price: String) -> String { pick([.korean: "주간 \(price)", .english: "Weekly \(price)", .japanese: "週額 \(price)", .chinese: "按周 \(price)", .german: "Wöchentlich \(price)", .french: "À la semaine \(price)", .spanish: "Semanal \(price)", .italian: "Settimanale \(price)", .portuguese: "Semanal \(price)", .chineseTraditional: "按週 \(price)", .dutch: "Per week \(price)", .swedish: "Veckovis \(price)", .norwegian: "Ukentlig \(price)", .danish: "Ugentligt \(price)", .finnish: "Viikoittain \(price)", .polish: "Tygodniowo \(price)", .czech: "Týdně \(price)", .greek: "Εβδομαδιαία \(price)", .turkish: "Haftalık \(price)", .russian: "На неделю \(price)", .indonesian: "Mingguan \(price)", .thai: "รายสัปดาห์ \(price)", .vietnamese: "Theo tuần \(price)"]) }
    static func shortPlanMonthly(_ price: String) -> String { pick([.korean: "월간 \(price)", .english: "Monthly \(price)", .japanese: "月額 \(price)", .chinese: "按月 \(price)", .german: "Monatlich \(price)", .french: "Au mois \(price)", .spanish: "Mensual \(price)", .italian: "Mensile \(price)", .portuguese: "Mensal \(price)", .chineseTraditional: "按月 \(price)", .dutch: "Per maand \(price)", .swedish: "Månadsvis \(price)", .norwegian: "Månedlig \(price)", .danish: "Månedligt \(price)", .finnish: "Kuukausittain \(price)", .polish: "Miesięcznie \(price)", .czech: "Měsíčně \(price)", .greek: "Μηνιαία \(price)", .turkish: "Aylık \(price)", .russian: "На месяц \(price)", .indonesian: "Bulanan \(price)", .thai: "รายเดือน \(price)", .vietnamese: "Theo tháng \(price)"]) }
    static var shortPlansDisclosure: String { pick([.korean: "주간 · 월간 구독도 기간이 끝나기 24시간 전까지 끄지 않으면 같은 가격으로 자동 갱신돼요.", .english: "Weekly and monthly plans also renew automatically at the same price unless turned off at least 24 hours before the period ends.", .japanese: "週額・月額も、期間終了の24時間前までに解約しない限り同じ価格で自動更新されます。", .chinese: "按周和按月订阅同样会以相同价格自动续订，除非在周期结束前至少24小时关闭。", .german: "Wöchentliche und monatliche Abos verlängern sich ebenfalls automatisch zum selben Preis, sofern sie nicht mindestens 24 Stunden vor Ablauf beendet werden.", .french: "Les formules à la semaine et au mois se renouvellent aussi automatiquement au même prix, sauf résiliation au moins 24 heures avant la fin de la période.", .spanish: "Los planes semanales y mensuales también se renuevan automáticamente al mismo precio si no los cancelas al menos 24 horas antes de que termine el periodo.", .italian: "Anche i piani settimanali e mensili si rinnovano automaticamente allo stesso prezzo se non li disattivi almeno 24 ore prima della scadenza.", .portuguese: "Os planos semanais e mensais também renovam automaticamente pelo mesmo preço, a menos que sejam desativados pelo menos 24 horas antes do fim do período.", .chineseTraditional: "按週和按月訂閱同樣會以相同價格自動續訂，除非在週期結束前至少24小時關閉。", .dutch: "Week- en maandabonnementen worden ook automatisch tegen dezelfde prijs verlengd, tenzij je ze minstens 24 uur voor het einde van de periode stopzet.", .swedish: "Vecko- och månadsplaner förnyas också automatiskt till samma pris om du inte stänger av dem minst 24 timmar innan perioden tar slut.", .norwegian: "Ukes- og månedsplaner fornyes også automatisk til samme pris med mindre du slår dem av minst 24 timer før perioden er over.", .danish: "Uge- og månedsplaner fornyes også automatisk til samme pris, medmindre du slår dem fra mindst 24 timer før periodens udløb.", .finnish: "Viikko- ja kuukausitilaukset uusiutuvat myös automaattisesti samaan hintaan, ellei niitä peruta vähintään 24 tuntia ennen jakson loppua.", .polish: "Plany tygodniowe i miesięczne także odnawiają się automatycznie w tej samej cenie, chyba że wyłączysz je co najmniej 24 godziny przed końcem okresu.", .czech: "Týdenní a měsíční plány se také automaticky obnovují za stejnou cenu, pokud je nevypneš alespoň 24 hodin před koncem období.", .greek: "Τα εβδομαδιαία και μηνιαία προγράμματα ανανεώνονται επίσης αυτόματα στην ίδια τιμή, εκτός αν τα απενεργοποιήσεις τουλάχιστον 24 ώρες πριν από τη λήξη.", .turkish: "Haftalık ve aylık planlar da dönem bitmeden en az 24 saat önce kapatılmazsa aynı fiyattan otomatik yenilenir.", .russian: "Недельные и месячные планы также продлеваются автоматически по той же цене, если не отключить их минимум за 24 часа до конца периода.", .indonesian: "Paket mingguan dan bulanan juga diperpanjang otomatis dengan harga yang sama kecuali dimatikan setidaknya 24 jam sebelum periode berakhir.", .thai: "แผนรายสัปดาห์และรายเดือนจะต่ออายุอัตโนมัติในราคาเดิมเช่นกัน เว้นแต่จะปิดอย่างน้อย 24 ชั่วโมงก่อนสิ้นสุดรอบ", .vietnamese: "Gói theo tuần và theo tháng cũng tự động gia hạn với cùng mức giá trừ khi tắt ít nhất 24 giờ trước khi hết kỳ."]) }

    /// 평생 가격이 오르기 전까지 페이월에 서는 한 줄 (`LeeoLadderSchedule`). 가격은 App Store 값이 칸에 보이니 적지 않는다.
    static func lifetimeDealNotice(_ date: String) -> String {
        pick([.korean: "\(date)부터 평생 가격이 올라요. 지금 사면 이 가격으로 평생이에요.", .english: "Lifetime prices go up on \(date). Buy now and keep this price for life.", .japanese: "\(date)から買い切り価格が上がります。今なら、この価格でずっと使えます。", .chinese: "永久版将于 \(date) 涨价。现在购买，以此价格永久使用。", .german: "Am \(date) steigen die Preise für Lebenslang. Jetzt kaufen und für immer zu diesem Preis nutzen.", .french: "Les prix à vie augmentent le \(date). Achetez maintenant à ce prix, pour toujours.", .spanish: "Los precios de por vida suben el \(date). Compra ahora y quédate con este precio para siempre.", .italian: "I prezzi a vita aumentano il \(date). Acquista ora a questo prezzo, per sempre.", .portuguese: "Os preços vitalícios sobem em \(date). Compre agora por este preço, para sempre.", .chineseTraditional: "永久版將於 \(date) 漲價。現在購買，以此價格永久使用。", .dutch: "Op \(date) gaan de levenslange prijzen omhoog. Koop nu en houd deze prijs voor altijd.", .swedish: "Livstidspriserna höjs den \(date). Köp nu till det här priset, för alltid.", .norwegian: "Livstidsprisene øker \(date). Kjøp nå til denne prisen, for alltid.", .danish: "Livstidspriserne stiger den \(date). Køb nu til denne pris, for altid.", .finnish: "Elinikäiset hinnat nousevat \(date). Osta nyt tällä hinnalla, lopullisesti.", .polish: "Ceny dożywotnie rosną \(date). Kup teraz w tej cenie, na zawsze.", .czech: "Doživotní ceny se zvýší \(date). Kup teď za tuto cenu, navždy.", .greek: "Οι τιμές εφ’ όρου ζωής αυξάνονται στις \(date). Αγόρασε τώρα σε αυτή την τιμή, για πάντα.", .turkish: "Ömür boyu fiyatlar \(date) tarihinde artıyor. Şimdi al, bu fiyatla sonsuza dek kullan.", .russian: "Цены на покупку навсегда вырастут \(date). Купите сейчас по этой цене — навсегда.", .indonesian: "Harga seumur hidup naik pada \(date). Beli sekarang dengan harga ini, selamanya.", .thai: "ราคาตลอดชีพจะขึ้นวันที่ \(date) ซื้อตอนนี้ในราคานี้ ใช้ได้ตลอดไป", .vietnamese: "Giá trọn đời sẽ tăng vào \(date). Mua ngay với giá này, dùng mãi mãi."])
    }

    /// 프로 칸: App Store 에서 프로 평생에 가족 공유가 켜져 있을 때만 선다.
    static var proLifetimeFamilySharing: String { pick([.korean: "프로 평생은 한 번 사면 가족 공유로 6명까지 함께 써요.", .english: "Buy Pro Lifetime once and share it with up to 6 people through Family Sharing.", .japanese: "プロ買い切りは一度の購入で、ファミリー共有により最大6人で使えます。", .chinese: "专业永久版只需购买一次，可通过家人共享最多 6 人使用。", .german: "Pro Lebenslang einmal kaufen und per Familienfreigabe mit bis zu 6 Personen nutzen.", .french: "Achetez Pro à vie une fois et partagez-le jusqu’à 6 personnes avec le partage familial.", .spanish: "Compra Pro de por vida una vez y compártelo con hasta 6 personas en En familia.", .italian: "Acquista Pro a vita una volta e usalo in fino a 6 persone con In famiglia.", .portuguese: "Compre o Pro vitalício uma vez e use com até 6 pessoas pelo Compartilhamento Familiar.", .chineseTraditional: "專業永久版只需購買一次，可透過家人共享最多 6 人使用。", .dutch: "Koop Pro levenslang één keer en deel het met maximaal 6 personen via Delen met gezin.", .swedish: "Köp Pro livstid en gång och dela med upp till 6 personer via Familjedelning.", .norwegian: "Kjøp Pro livstid én gang og del med opptil 6 personer via Familiedeling.", .danish: "Køb Pro livstid én gang, og del med op til 6 personer via Familiedeling.", .finnish: "Osta Pro elinikäinen kerran ja jaa se enintään 6 henkilölle perhejaolla.", .polish: "Kup Pro dożywotnio raz i korzystaj w maksymalnie 6 osób dzięki Chmurze rodzinnej.", .czech: "Kup Pro navždy jednou a sdílej ho až s 6 lidmi přes Rodinné sdílení.", .greek: "Αγόρασε το Pro εφ’ όρου ζωής μία φορά και μοιράσου το με έως 6 άτομα μέσω της Οικογενειακής κοινής χρήσης.", .turkish: "Pro ömür boyunu bir kez al, Aile Paylaşımı ile en fazla 6 kişi kullansın.", .russian: "Купите Pro навсегда один раз и пользуйтесь вшестером через Семейный доступ.", .indonesian: "Beli Pro Seumur Hidup sekali dan gunakan hingga 6 orang lewat Berbagi Keluarga.", .thai: "ซื้อโปรตลอดชีพครั้งเดียว ใช้ร่วมกันได้สูงสุด 6 คนผ่านการแชร์กันในครอบครัว", .vietnamese: "Mua Pro trọn đời một lần, dùng chung tối đa 6 người qua Chia sẻ trong gia đình."]) }

    /// 무료 칸: 올해 추천 전부 보기, n개까지 넣기 (`ProManager.freeRecommendationAddLimit`)
    static func freeFeatRecommendations(_ n: Int) -> String {
        pick([.korean: "올해 추천 전부 보기, \(n)개까지 넣기", .english: "See all of this year’s suggestions, add up to \(n)", .japanese: "今年のおすすめをすべて表示、\(n)件まで登録", .chinese: "查看今年全部推荐，最多添加 \(n) 个", .german: "Alle Vorschläge für dieses Jahr, bis zu \(n) übernehmen", .french: "Toutes les suggestions de l’année, jusqu’à \(n) à ajouter", .spanish: "Todas las sugerencias del año, añade hasta \(n)", .italian: "Tutti i suggerimenti dell’anno, aggiungine fino a \(n)", .portuguese: "Todas as sugestões do ano, adicione até \(n)", .chineseTraditional: "查看今年全部推薦，最多新增 \(n) 個", .dutch: "Alle voorstellen van dit jaar, tot \(n) toevoegen", .swedish: "Alla förslag för i år, lägg till upp till \(n)", .norwegian: "Alle forslag for i år, legg til opptil \(n)", .danish: "Alle forslag for i år, tilføj op til \(n)", .finnish: "Kaikki tämän vuoden ehdotukset, lisää enintään \(n)", .polish: "Wszystkie propozycje na ten rok, dodaj do \(n)", .czech: "Všechny letošní návrhy, přidej až \(n)", .greek: "Όλες οι φετινές προτάσεις, πρόσθεσε έως \(n)", .turkish: "Bu yılın tüm önerileri, en fazla \(n) tane ekle", .russian: "Все рекомендации на этот год, добавить можно до \(n)", .indonesian: "Semua saran tahun ini, tambahkan hingga \(n)", .thai: "ดูคำแนะนำทั้งหมดของปีนี้ เพิ่มได้สูงสุด \(n) รายการ", .vietnamese: "Xem mọi gợi ý năm nay, thêm tối đa \(n)"])
    }

    /// 무료 칸: 쉬는 간격 안내, 알림, 위젯
    static var freeFeatRest: String {
        pick([.korean: "쉬는 간격 안내, 알림, 위젯", .english: "Rest reminders, alerts and widgets", .japanese: "休むタイミングの案内、通知、ウィジェット", .chinese: "休息间隔提醒、通知和小组件", .german: "Pausenhinweise, Mitteilungen und Widgets", .french: "Rappels de repos, notifications et widgets", .spanish: "Avisos de descanso, notificaciones y widgets", .italian: "Promemoria di riposo, notifiche e widget", .portuguese: "Lembretes de descanso, notificações e widgets", .chineseTraditional: "休息間隔提醒、通知和小工具", .dutch: "Rusttips, meldingen en widgets", .swedish: "Vilopåminnelser, notiser och widgetar", .norwegian: "Påminnelser om hvile, varsler og widgeter", .danish: "Påmindelser om pauser, notifikationer og widgets", .finnish: "Lepomuistutukset, ilmoitukset ja widgetit", .polish: "Przypomnienia o odpoczynku, powiadomienia i widżety", .czech: "Připomínky odpočinku, oznámení a widgety", .greek: "Υπενθυμίσεις ξεκούρασης, ειδοποιήσεις και widget", .turkish: "Dinlenme hatırlatmaları, bildirimler ve widget’lar", .russian: "Напоминания об отдыхе, уведомления и виджеты", .indonesian: "Pengingat istirahat, notifikasi, dan widget", .thai: "เตือนให้พัก การแจ้งเตือน และวิดเจ็ต", .vietnamese: "Nhắc nghỉ ngơi, thông báo và tiện ích"])
    }

    /// 무료 칸: iCloud 백업, 가족과 일정 보기 공유 (같이 계획하기는 프로)
    static var freeFeatBackupShare: String {
        pick([.korean: "iCloud 백업, 가족과 일정 공유", .english: "iCloud backup and sharing schedules with family", .japanese: "iCloudバックアップ、家族と予定を共有", .chinese: "iCloud 备份，与家人共享日程", .german: "iCloud-Backup und Pläne mit der Familie teilen", .french: "Sauvegarde iCloud et planning partagé en famille", .spanish: "Copia en iCloud y calendario compartido con la familia", .italian: "Backup su iCloud e programmi condivisi in famiglia", .portuguese: "Backup no iCloud e agenda compartilhada com a família", .chineseTraditional: "iCloud 備份，與家人共享行程", .dutch: "iCloud-back-up en planning delen met je gezin", .swedish: "iCloud-säkerhetskopia och delat schema med familjen", .norwegian: "iCloud-sikkerhetskopi og delt timeplan med familien", .danish: "iCloud-backup og delt plan med familien", .finnish: "iCloud-varmuuskopio ja aikataulun jakaminen perheelle", .polish: "Kopia w iCloud i plan udostępniany rodzinie", .czech: "Záloha na iCloud a sdílení plánu s rodinou", .greek: "Αντίγραφο στο iCloud και κοινό πρόγραμμα με την οικογένεια", .turkish: "iCloud yedeği ve aileyle takvim paylaşımı", .russian: "Резервная копия в iCloud и общий график с семьёй", .indonesian: "Cadangan iCloud dan berbagi jadwal dengan keluarga", .thai: "สำรองข้อมูล iCloud และแชร์ตารางกับครอบครัว", .vietnamese: "Sao lưu iCloud và chia sẻ lịch với gia đình"])
    }

    /// 설정: 구독 중일 때만 서는 줄. 누르면 구독 졸업(프로 평생) 화면이 뜬다.
    /// `LeeoLadderText.switchToLifetimeEntry` 의 번역을 그대로 옮겼다. LeeoKit 문구는 기기 언어를 따르므로 앱 언어로 다시 적는다.
    static var switchToLifetimeEntry: String {
        pick([.korean: "평생으로 바꾸기", .english: "Switch to Lifetime", .japanese: "買い切りに切り替える", .chinese: "改为永久版", .german: "Zu Lebenslang wechseln", .french: "Passer à l’achat à vie", .spanish: "Cambiar a la versión de por vida", .italian: "Passa alla versione a vita", .portuguese: "Mudar para o vitalício", .chineseTraditional: "改為永久版", .dutch: "Overstappen op levenslang", .swedish: "Byt till livstid", .norwegian: "Bytt til livstid", .danish: "Skift til livstid", .finnish: "Vaihda elinikäiseen", .polish: "Przejdź na dostęp dożywotni", .czech: "Přejít na doživotní verzi", .greek: "Μετάβαση σε εφ’ όρου ζωής", .turkish: "Ömür boyu sürüme geç", .russian: "Перейти на покупку навсегда", .indonesian: "Beralih ke Seumur Hidup", .thai: "เปลี่ยนเป็นตลอดชีพ", .vietnamese: "Chuyển sang trọn đời"])
    }
}
