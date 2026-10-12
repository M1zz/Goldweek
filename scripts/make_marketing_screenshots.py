#!/usr/bin/env python3
"""Goldweek App Store 마케팅 스크린샷 — 12개 언어 × (iPhone 5장 + iPad 4장), 같은 구성·같은 디자인.

원본: docs/screenshots/raw/<로케일>/01-home.png …  (scripts/take_screenshots.sh 가 찍는다)
제출본: docs/screenshots/marketing/<로케일>/01-….png  (DeployBar 가 이 폴더를 올린다)

  01 홈(쉴 때)          hero-bleed
  02 추천 연휴          left-text
  03 캘린더             text-bottom
  04 41개국 공휴일       flags-many (화면 대신 국기 그리드)
  05 설정(국가·언어)     flat-rotate

iPad: 원본 docs/screenshots/raw/ipad/<로케일>/ → 제출본 marketing/<로케일>/1x-ipad-….png (2064×2752)
  (DeployBar 는 픽셀 크기로 기기를 가린다 — 같은 폴더에 둬도 iPhone 자리와 섞이지 않는다)

사용법: python3 scripts/make_marketing_screenshots.py [--ipad] [로케일...]
"""
import pathlib, subprocess, sys, tempfile, time

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = ROOT / "docs" / "screenshots" / "raw"
OUT = ROOT / "docs" / "screenshots" / "marketing"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
W, H = 1242, 2688   # App Store 6.5" 제출 규격
# 사용자가 쓰는 Chrome 과 프로필이 겹치면 헤드리스가 멈춘다 — 따로 쓴다
PROFILE = tempfile.mkdtemp(prefix="goldweek-chrome-")

# 지원 국가 — 앱의 Country 순서와 같게, 모든 언어에서 같은 순서
FLAGS = ["🇰🇷", "🇺🇸", "🇯🇵", "🇨🇳", "🇩🇪", "🇫🇷", "🇬🇧", "🇨🇦", "🇦🇺", "🇪🇸", "🇮🇹", "🇧🇷", "🇹🇼", "🇭🇰"]
# 지금 지원하는 41개 나라 전부 (Country 순서, 직접 입력 제외)
ALL_FLAGS = FLAGS + ["🇦🇪", "🇸🇦", "🇶🇦", "🇵🇪", "🇳🇱", "🇧🇪", "🇦🇹", "🇨🇭", "🇮🇪", "🇵🇹", "🇸🇪", "🇳🇴", "🇩🇰", "🇫🇮",
                     "🇵🇱", "🇨🇿", "🇬🇷", "🇹🇷", "🇪🇬", "🇿🇦", "🇲🇽", "🇦🇷", "🇨🇱", "🇨🇴", "🇳🇿", "🇷🇺", "🇮🇩"]

# (원본 파일, 레이아웃) — 5장 구성은 모든 언어에서 같다
SLIDES = [
    ("01-home.png", "hero-bleed"),
    ("02-recommend.png", "left-text"),
    ("03-calendar.png", "text-bottom"),
    (None, "flags"),
    ("04-settings.png", "flat-rotate"),
]

# 언어마다 (헤드라인, 서브카피) × 5 — 직역이 아니라 그 언어로 다시 쓴 문구
COPY = {
    "ko": [
        ("언제 쉬어야<br>할까?", "마지막 휴가와 다음 휴가로 쉴 때를 알려 드려요"),
        ("최소 연차로<br>최대 연휴", "공휴일과 주말을 엮은 조합을 추천해요"),
        ("한눈에 보는<br>휴가 달력", "날짜를 눌러 바로 등록하고 고쳐요"),
        ("41개 나라<br>공휴일", "지역마다 다른 공휴일도 골라 맞춰요"),
        ("내 나라,<br>내 언어로", "21개 언어로 쓸 수 있어요"),
    ],
    "en": [
        ("When should you<br>take a break?", "Your last break, your next one, and when to rest"),
        ("Fewest days off,<br>longest break", "Holidays and weekends, combined for you"),
        ("Your time off<br>at a glance", "Tap any date to add or edit leave"),
        ("Holidays for<br>41 countries", "Pick your state or region where it matters"),
        ("Your country,<br>your language", "Available in 21 languages"),
    ],
    "ja": [
        ("いつ休むのが<br>いい？", "前回と次の休みから、休みどきをお知らせ"),
        ("最少の有給で<br>最長の連休", "祝日と週末を組み合わせて提案します"),
        ("休みがひと目で<br>わかるカレンダー", "日付をタップしてすぐ登録・編集"),
        ("41か国・地域の<br>祝日に対応", "地域で異なる祝日も選べます"),
        ("あなたの国、<br>あなたの言語で", "21言語に対応しています"),
    ],
    "zh-Hans": [
        ("什么时候<br>该休息了？", "看看上次休假和下次休假，提醒你该歇歇了"),
        ("最少年假<br>拼出最长假期", "把节假日和周末串起来推荐给你"),
        ("休假安排<br>一目了然", "点一下日期即可登记或修改"),
        ("41 个国家和地区<br>的节假日", "还会标出调休补班日"),
        ("你的国家<br>你的语言", "支持 21 种语言"),
    ],
    "zh-Hant": [
        ("什麼時候<br>該休息了？", "看看上次和下次休假，提醒你該休息了"),
        ("最少特休<br>排出最長連假", "串起國定假日和週末推薦給你"),
        ("休假安排<br>一目了然", "點一下日期就能登記或修改"),
        ("41 個國家與地區<br>的假日", "各地不同的假日也能選擇"),
        ("你的國家<br>你的語言", "支援 21 種語言"),
    ],
    "de": [
        ("Wann brauchst du<br>eine Pause?", "Letzter Urlaub, nächster Urlaub und wann es Zeit wird"),
        ("Wenig Urlaub,<br>lange frei", "Feiertage und Wochenenden clever verbunden"),
        ("Dein Urlaub<br>auf einen Blick", "Tippe auf ein Datum zum Eintragen"),
        ("Feiertage in<br>41 Ländern", "Auch je nach Bundesland"),
        ("Dein Land,<br>deine Sprache", "In 21 Sprachen verfügbar"),
    ],
    "fr": [
        ("Quand faut-il<br>souffler ?", "Dernier congé, prochain congé : on vous dit quand"),
        ("Moins de congés,<br>plus de repos", "Fériés et week-ends combinés pour vous"),
        ("Vos congés<br>en un coup d'œil", "Touchez une date pour poser un congé"),
        ("Les fériés<br>de 41 pays", "Chacun avec ses propres règles"),
        ("Votre pays,<br>votre langue", "Disponible en 21 langues"),
    ],
    "es": [
        ("¿Cuándo deberías<br>descansar?", "Tu último descanso, el próximo y cuándo parar"),
        ("Menos días,<br>puentes más largos", "Festivos y fines de semana, combinados"),
        ("Tus vacaciones<br>de un vistazo", "Toca una fecha para añadir o editar"),
        ("Festivos de<br>41 países", "También por comunidad autónoma"),
        ("Tu país,<br>tu idioma", "Disponible en 21 idiomas"),
    ],
    "it": [
        ("Quando dovresti<br>fermarti?", "Ultima pausa, prossima pausa e quando staccare"),
        ("Meno ferie,<br>ponti più lunghi", "Festivi e weekend combinati per te"),
        ("Le tue ferie<br>a colpo d'occhio", "Tocca una data per aggiungere o modificare"),
        ("Festività di<br>41 Paesi", "Ognuno con le sue regole"),
        ("Il tuo Paese,<br>la tua lingua", "Disponibile in 21 lingue"),
    ],
    "ru": [
        ("Когда пора<br>отдохнуть?", "Прошлый отпуск, следующий и подсказка, когда отдыхать"),
        ("Меньше отпуска,<br>больше отдыха", "Праздники и выходные складываются в длинный отдых"),
        ("Весь отпуск<br>на одном экране", "Нажмите на дату, чтобы добавить или изменить"),
        ("Праздники<br>41 страны", "С переносами выходных по постановлению"),
        ("Ваша страна,<br>ваш язык", "21 язык интерфейса"),
    ],
    "id": [
        ("Kapan waktunya<br>istirahat?", "Libur terakhir, libur berikutnya, dan kapan harus rehat"),
        ("Cuti sedikit,<br>libur panjang", "Tanggal merah dan akhir pekan dirangkai untukmu"),
        ("Semua cutimu<br>dalam satu layar", "Ketuk tanggal untuk mencatat atau mengubah cuti"),
        ("Hari libur<br>41 negara", "Termasuk cuti bersama sesuai SKB"),
        ("Negaramu,<br>bahasamu", "Tersedia dalam 21 bahasa"),
    ],
    "pt-BR": [
        ("Quando você<br>deve descansar?", "Sua última folga, a próxima e a hora de parar"),
        ("Menos dias,<br>feriadões maiores", "Feriados e fins de semana combinados"),
        ("Suas férias<br>num piscar de olhos", "Toque numa data para lançar ou editar"),
        ("Feriados de<br>41 países", "Cada um com suas regras"),
        ("Seu país,<br>seu idioma", "Disponível em 21 idiomas"),
    ],
    "nl": [
        ("Wanneer neem jij<br>weer vrij?", "Vorige vakantie, de volgende en het beste moment"),
        ("Minder verlof,<br>langer vrij", "Feestdagen en weekenden slim voor je gecombineerd"),
        ("Al je verlof<br>in één oogopslag", "Tik een datum aan om verlof toe te voegen"),
        ("Feestdagen in<br>41 landen", "Van Koningsdag tot Hemelvaart, per land en regio"),
        ("Jouw land,<br>jouw taal", "Beschikbaar in 21 talen"),
    ],
    "sv": [
        ("När ska du<br>ta ledigt?", "Senaste ledigheten, nästa och när du behöver vila"),
        ("Färre dagar,<br>längre ledighet", "Helgdagar och helger kombineras åt dig"),
        ("Din ledighet<br>i överblick", "Tryck på ett datum för att lägga till eller ändra"),
        ("Helgdagar i<br>41 länder", "Röda dagar för varje land och region"),
        ("Ditt land,<br>ditt språk", "Finns på 21 språk"),
    ],
    "nb": [
        ("Når skal du<br>ta fri?", "Forrige ferie, den neste og når du bør hvile"),
        ("Færre dager,<br>lengre ferie", "Helligdager og helger satt sammen for deg"),
        ("Oversikt over<br>all ferien", "Trykk på en dato for å legge inn eller endre"),
        ("Helligdager i<br>41 land", "Røde dager for hvert land og hver region"),
        ("Ditt land,<br>ditt språk", "Tilgjengelig på 21 språk"),
    ],
    "da": [
        ("Hvornår skal du<br>holde fri?", "Seneste ferie, næste ferie og tid til en pause"),
        ("Færre feriedage,<br>længere fri", "Helligdage og weekender lagt sammen for dig"),
        ("Hele ferien<br>på ét blik", "Tryk på en dato for at tilføje eller rette ferie"),
        ("Helligdage<br>i 41 lande", "Med danske navne, fra påske til juleaften"),
        ("Dit land,<br>dit sprog", "Fås på 21 sprog"),
    ],
    "fi": [
        ("Milloin pitäisit<br>lomaa?", "Edellinen loma, seuraava ja milloin levätä"),
        ("Vähin lomapäivin<br>pisin vapaa", "Pyhäpäivät ja viikonloput yhdistettyinä puolestasi"),
        ("Lomat yhdellä<br>silmäyksellä", "Napauta päivää lisätäksesi tai muokataksesi lomaa"),
        ("Pyhäpäivät<br>41 maasta", "Virallisin nimin loppiaisesta juhannukseen"),
        ("Sinun maasi,<br>sinun kielesi", "Saatavilla 21 kielellä"),
    ],
    "pl": [
        ("Kiedy wziąć<br>wolne?", "Ostatni urlop, następny i kiedy odpocząć"),
        ("Mniej urlopu,<br>dłuższe wolne", "Święta i weekendy połączone za Ciebie"),
        ("Urlop<br>w jednym miejscu", "Stuknij datę, by dodać lub zmienić urlop"),
        ("Święta<br>w 41 krajach", "Z polskimi nazwami, od majówki po Wigilię"),
        ("Twój kraj,<br>Twój język", "Dostępne w 21 językach"),
    ],
    "cs": [
        ("Kdy si<br>dát volno?", "Poslední volno, to příští a kdy si odpočinout"),
        ("Méně dovolené,<br>delší volno", "Svátky a víkendy spojíme za tebe"),
        ("Dovolená<br>na první pohled", "Klepnutím na datum přidáš nebo upravíš volno"),
        ("Svátky<br>41 zemí", "České svátky pod oficiálními názvy"),
        ("Tvoje země,<br>tvůj jazyk", "K dispozici ve 21 jazycích"),
    ],
    "el": [
        ("Πότε να πάρεις<br>ρεπό;", "Το τελευταίο, το επόμενο και πότε να ξεκουραστείς"),
        ("Λιγότερη άδεια,<br>μεγαλύτερο ρεπό", "Ενώνουμε αργίες και Σαββατοκύριακα για σένα"),
        ("Οι άδειές σου<br>με μια ματιά", "Πάτα μια ημερομηνία για προσθήκη ή αλλαγή"),
        ("Αργίες για<br>41 χώρες", "Με το ορθόδοξο Πάσχα και τις κινητές γιορτές"),
        ("Η χώρα σου,<br>η γλώσσα σου", "Διαθέσιμο σε 21 γλώσσες"),
    ],
    "tr": [
        ("Ne zaman<br>izin almalı?", "Son tatilin, sıradaki tatilin ve dinlenme zamanın"),
        ("En az izinle<br>en uzun tatil", "Resmî tatil ve hafta sonları senin için birleşir"),
        ("İzinlerin<br>tek bakışta", "İzin eklemek ya da düzenlemek için tarihe dokun"),
        ("41 ülkenin<br>resmî tatilleri", "Ramazan ve Kurban Bayramı dahil"),
        ("Senin ülken,<br>senin dilin", "21 dilde kullanılabilir"),
    ],
}

BRAND = "#0066FF"
BASE_CSS = f"""
* {{ margin:0; padding:0; box-sizing:border-box; }}
html,body {{ width:{W}px; height:{H}px; overflow:hidden; }}
body {{ background:linear-gradient(180deg,#EEF4FF 0%,#F7FAFF 55%,#EFFAF4 100%);
  font-family:-apple-system,"Apple SD Gothic Neo","Hiragino Sans","PingFang SC","PingFang TC",sans-serif;
  position:relative; }}
.headline {{ font-size:104px; font-weight:800; color:#121A2B; letter-spacing:-2px; line-height:1.18; }}
.sub {{ font-size:46px; font-weight:500; color:#5E6B80; letter-spacing:-0.5px; line-height:1.35; }}
.bar {{ width:120px; height:14px; border-radius:7px; background:linear-gradient(90deg,{BRAND},#00C471); }}
.phone {{ background:#14161B; border-radius:112px; border:3px solid #3A3D45; padding:24px;
  box-shadow:50px 80px 110px rgba(10,40,100,.22),16px 26px 46px rgba(10,40,100,.14); }}
.phone img {{ width:100%; display:block; border-radius:90px; }}
"""

LAYOUTS = {
    "hero-bleed": """
.text { text-align:center; padding:250px 80px 0; } .bar { margin:0 auto 56px; }
.sub { margin-top:44px; }
.wrap { display:flex; justify-content:center; margin-top:120px; }
.phone { width:960px; }
""",
    "left-text": """
.text { text-align:left; padding:250px 90px 0 100px; } .bar { margin:0 0 56px; }
.sub { margin-top:44px; }
.wrap { perspective:2600px; perspective-origin:30% 30%; position:absolute; left:290px; top:1010px; }
.phone { width:820px; transform:rotateY(16deg) rotateX(2deg); }
""",
    "text-bottom": """
.wrap { perspective:2800px; perspective-origin:50% 40%; display:flex; justify-content:center; margin-top:150px; }
.phone { width:840px; transform:rotateY(-10deg) rotateX(2deg); }
.text { text-align:center; padding:110px 80px 0; } .bar { margin:0 auto 48px; }
.sub { margin-top:40px; }
""",
    "flat-rotate": """
.text { text-align:center; padding:250px 80px 0; } .bar { margin:0 auto 56px; }
.sub { margin-top:44px; }
.wrap { position:absolute; left:120px; top:1030px; }
.phone { width:980px; transform:rotate(-6deg); }
""",
    "flags": """
body { background:linear-gradient(160deg,#0B57E3 0%,#0A7BD8 50%,#05A86A 100%); }
.headline { color:#fff; } .sub { color:rgba(255,255,255,.82); }
.bar { background:#fff; opacity:.9; }
.text { text-align:center; padding:250px 80px 0; } .bar { margin:0 auto 56px; }
.sub { margin-top:44px; }
.grid { display:grid; grid-template-columns:repeat(4,200px); gap:56px 64px; justify-content:center; margin-top:170px; }
.grid div { width:200px; height:200px; border-radius:50%; background:rgba(255,255,255,.16);
  display:flex; align-items:center; justify-content:center; font-size:128px;
  box-shadow:0 18px 40px rgba(0,0,0,.18); border:3px solid rgba(255,255,255,.35); }
.grid div:nth-child(13) { grid-column:2; }
""",
    # 41개 국기 — 6열로 촘촘히
    "flags-many": """
body { background:linear-gradient(160deg,#0B57E3 0%,#0A7BD8 50%,#05A86A 100%); }
.headline { color:#fff; } .sub { color:rgba(255,255,255,.82); }
.bar { background:#fff; opacity:.9; }
.text { text-align:center; padding:250px 80px 0; } .bar { margin:0 auto 56px; }
.sub { margin-top:44px; }
.grid { display:grid; grid-template-columns:repeat(6,136px); gap:34px 34px; justify-content:center; margin-top:130px; }
.grid div { width:136px; height:136px; border-radius:50%; background:rgba(255,255,255,.16);
  display:flex; align-items:center; justify-content:center; font-size:86px;
  box-shadow:0 12px 28px rgba(0,0,0,.18); border:3px solid rgba(255,255,255,.35); }
""",
}

TEXT = '<div class="text"><div class="bar"></div><div class="headline">{h}</div><div class="sub">{s}</div></div>'
PHONE = '<div class="wrap"><div class="phone"><img src="{img}"></div></div>'
PAGE = '<!doctype html><html><head><meta charset="utf-8"><style>{css}</style></head><body>{body}</body></html>'

# 헤드리스 Chrome 은 -apple-system 을 못 찾아 다음 글꼴(한글)로 그린다 — 그 글꼴엔 그리스 문자·체코 악센트가 없다.
# 한중일이 아닌 언어는 라틴·그리스·키릴을 다 가진 Helvetica Neue 로 먼저 그린다.
CJK = {"ko", "ja", "zh-Hans", "zh-Hant"}
LATIN_FONT = 'body { font-family:"Helvetica Neue",-apple-system,sans-serif; }'


def page(locale, css, body):
    return PAGE.format(css=css + ("" if locale in CJK else LATIN_FONT), body=body)


# ── iPad 13" ─────────────────────────────────────────────
IW, IH = 2064, 2752
IPAD_SLIDES = [   # (원본, 레이아웃, COPY 의 몇 번째 문구)
    ("01-calendar.png", "ipad", 2),
    ("02-recommend.png", "ipad", 1),
    (None, "ipad-flags", 3),
    ("03-settings.png", "ipad", 4),
]

IPAD_CSS = f"""
* {{ margin:0; padding:0; box-sizing:border-box; }}
html,body {{ width:{IW}px; height:{IH}px; overflow:hidden; }}
body {{ background:linear-gradient(180deg,#EEF4FF 0%,#F7FAFF 55%,#EFFAF4 100%);
  font-family:-apple-system,"Apple SD Gothic Neo","Hiragino Sans","PingFang SC","PingFang TC",sans-serif; }}
.headline {{ font-size:124px; font-weight:800; color:#121A2B; letter-spacing:-2px; line-height:1.15; }}
.sub {{ font-size:58px; font-weight:500; color:#5E6B80; line-height:1.35; margin-top:36px; }}
.bar {{ width:140px; height:16px; border-radius:8px; background:linear-gradient(90deg,{BRAND},#00C471); margin:0 auto 48px; }}
.text {{ text-align:center; padding:150px 120px 0; }}
.wrap {{ display:flex; justify-content:center; margin-top:90px; }}
.tablet {{ width:1480px; background:#14161B; border-radius:72px; border:3px solid #3A3D45; padding:30px;
  box-shadow:50px 80px 110px rgba(10,40,100,.22),16px 26px 46px rgba(10,40,100,.14); }}
.tablet img {{ width:100%; display:block; border-radius:44px; }}
"""
IPAD_FLAGS_CSS = """
body { background:linear-gradient(160deg,#0B57E3 0%,#0A7BD8 50%,#05A86A 100%); }
.headline { color:#fff; } .sub { color:rgba(255,255,255,.82); } .bar { background:#fff; opacity:.9; }
.grid { display:grid; grid-template-columns:repeat(7,190px); gap:48px 48px; justify-content:center; margin-top:170px; }
.grid div { width:190px; height:190px; border-radius:50%; background:rgba(255,255,255,.16);
  display:flex; align-items:center; justify-content:center; font-size:120px;
  box-shadow:0 14px 32px rgba(0,0,0,.18); border:3px solid rgba(255,255,255,.35); }
"""


def shoot(html, png, w, h):
    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False, encoding="utf-8") as f:
        f.write(html)
    # 헤드리스 Chrome 은 그림을 다 쓰고도 끝나지 않을 때가 있다 — 파일이 생기면 끝낸다
    png.unlink(missing_ok=True)
    for _ in range(3):
        proc = subprocess.Popen([CHROME, "--headless=new", f"--screenshot={png}", f"--window-size={w},{h}",
                                 "--force-device-scale-factor=1", "--hide-scrollbars", "--disable-gpu",
                                 "--allow-file-access-from-files", f"--user-data-dir={PROFILE}", pathlib.Path(f.name).as_uri()],
                                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        for _ in range(600):
            if proc.poll() is not None or (png.exists() and png.stat().st_size > 0):
                break
            time.sleep(0.5)
        time.sleep(1)   # 쓰는 중일 수 있다
        if proc.poll() is None:
            proc.kill()
            proc.wait()
        if png.exists() and png.stat().st_size > 0:
            break
    else:
        sys.exit(f"그리기 실패: {png}")
    pathlib.Path(f.name).unlink()
    print(f"  ✓ {png.relative_to(ROOT)}")


def render_ipad(locale):
    out_dir = OUT / locale
    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("*-ipad-*.png"):
        old.unlink()
    for i, (src, layout, k) in enumerate(IPAD_SLIDES, start=11):
        h, s = COPY[locale][k]
        h = h.replace("<br>", " ")   # iPad 는 폭이 넓어 한 줄로
        text = TEXT.format(h=h, s=s)
        if layout == "ipad-flags":
            body = text + '<div class="grid">' + "".join(f"<div>{f}</div>" for f in ALL_FLAGS) + "</div>"
            css, name = IPAD_CSS + IPAD_FLAGS_CSS, "countries"
        else:
            img = RAW / "ipad" / locale / src
            if not img.exists():
                sys.exit(f"원본 없음: {img} — IPAD=1 scripts/take_screenshots.sh 먼저")
            body = text + f'<div class="wrap"><div class="tablet"><img src="{img.as_uri()}"></div></div>'
            css, name = IPAD_CSS, src[3:-4]
        shoot(page(locale, css, body), out_dir / f"{i:02d}-ipad-{name}.png", IW, IH)


def render(locale):
    out_dir = OUT / locale
    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("0*.png"):
        old.unlink()
    for i, ((src, layout), (h, s)) in enumerate(zip(SLIDES, COPY[locale]), start=1):
        text = TEXT.format(h=h, s=s)
        if layout == "flags":
            layout = "flags-many"
            body = text + '<div class="grid">' + "".join(f"<div>{f}</div>" for f in ALL_FLAGS) + "</div>"
            name = "countries"
        else:
            img = RAW / locale / src
            if not img.exists():
                sys.exit(f"원본 없음: {img} — scripts/take_screenshots.sh 먼저")
            phone = PHONE.format(img=img.as_uri())
            body = phone + text if layout == "text-bottom" else text + phone
            name = src[3:-4]
        shoot(page(locale, BASE_CSS + LAYOUTS[layout], body), out_dir / f"{i:02d}-{name}.png", W, H)


if __name__ == "__main__":
    args = sys.argv[1:]
    ipad = "--ipad" in args
    locales = [a for a in args if a != "--ipad"] or list(COPY)
    for loc in locales:
        render_ipad(loc) if ipad else render(loc)
