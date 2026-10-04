#!/usr/bin/env python3
"""Goldweek App Store 마케팅 스크린샷 — 10개 언어 × 5장, 같은 구성·같은 디자인.

원본: docs/screenshots/raw/<로케일>/01-home.png …  (scripts/take_screenshots.sh 가 찍는다)
제출본: docs/screenshots/marketing/<로케일>/01-….png  (DeployBar 가 이 폴더를 올린다)

  01 홈(쉴 때)          hero-bleed
  02 추천 연휴          left-text
  03 캘린더             text-bottom
  04 14개국 공휴일       flags (화면 대신 국기 그리드)
  05 설정(국가·언어)     flat-rotate

사용법: python3 scripts/make_marketing_screenshots.py [로케일...]
"""
import pathlib, subprocess, sys, tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = ROOT / "docs" / "screenshots" / "raw"
OUT = ROOT / "docs" / "screenshots" / "marketing"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
W, H = 1242, 2688   # App Store 6.5" 제출 규격

# 지원 국가 — 앱의 Country 순서와 같게, 모든 언어에서 같은 순서
FLAGS = ["🇰🇷", "🇺🇸", "🇯🇵", "🇨🇳", "🇩🇪", "🇫🇷", "🇬🇧", "🇨🇦", "🇦🇺", "🇪🇸", "🇮🇹", "🇧🇷", "🇹🇼", "🇭🇰"]

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
        ("14개 나라<br>공휴일", "지역마다 다른 공휴일도 골라 맞춰요"),
        ("내 나라,<br>내 언어로", "10개 언어로 쓸 수 있어요"),
    ],
    "en": [
        ("When should you<br>take a break?", "Your last break, your next one, and when to rest"),
        ("Fewest days off,<br>longest break", "Holidays and weekends, combined for you"),
        ("Your time off<br>at a glance", "Tap any date to add or edit leave"),
        ("Holidays for<br>14 countries", "Pick your state or region where it matters"),
        ("Your country,<br>your language", "Available in 10 languages"),
    ],
    "ja": [
        ("いつ休むのが<br>いい？", "前回と次の休みから、休みどきをお知らせ"),
        ("最少の有給で<br>最長の連休", "祝日と週末を組み合わせて提案します"),
        ("休みがひと目で<br>わかるカレンダー", "日付をタップしてすぐ登録・編集"),
        ("14か国・地域の<br>祝日に対応", "地域で異なる祝日も選べます"),
        ("あなたの国、<br>あなたの言語で", "10言語に対応しています"),
    ],
    "zh-Hans": [
        ("什么时候<br>该休息了？", "看看上次休假和下次休假，提醒你该歇歇了"),
        ("最少年假<br>拼出最长假期", "把节假日和周末串起来推荐给你"),
        ("休假安排<br>一目了然", "点一下日期即可登记或修改"),
        ("14 个国家和地区<br>的节假日", "还会标出调休补班日"),
        ("你的国家<br>你的语言", "支持 10 种语言"),
    ],
    "zh-Hant": [
        ("什麼時候<br>該休息了？", "看看上次和下次休假，提醒你該休息了"),
        ("最少特休<br>排出最長連假", "串起國定假日和週末推薦給你"),
        ("休假安排<br>一目了然", "點一下日期就能登記或修改"),
        ("14 個國家與地區<br>的假日", "各地不同的假日也能選擇"),
        ("你的國家<br>你的語言", "支援 10 種語言"),
    ],
    "de": [
        ("Wann brauchst du<br>eine Pause?", "Letzter Urlaub, nächster Urlaub und wann es Zeit wird"),
        ("Wenig Urlaub,<br>lange frei", "Feiertage und Wochenenden clever verbunden"),
        ("Dein Urlaub<br>auf einen Blick", "Tippe auf ein Datum zum Eintragen"),
        ("Feiertage in<br>14 Ländern", "Auch je nach Bundesland"),
        ("Dein Land,<br>deine Sprache", "In 10 Sprachen verfügbar"),
    ],
    "fr": [
        ("Quand faut-il<br>souffler ?", "Dernier congé, prochain congé : on vous dit quand"),
        ("Moins de congés,<br>plus de repos", "Fériés et week-ends combinés pour vous"),
        ("Vos congés<br>en un coup d'œil", "Touchez une date pour poser un congé"),
        ("Les fériés<br>de 14 pays", "Chacun avec ses propres règles"),
        ("Votre pays,<br>votre langue", "Disponible en 10 langues"),
    ],
    "es": [
        ("¿Cuándo deberías<br>descansar?", "Tu último descanso, el próximo y cuándo parar"),
        ("Menos días,<br>puentes más largos", "Festivos y fines de semana, combinados"),
        ("Tus vacaciones<br>de un vistazo", "Toca una fecha para añadir o editar"),
        ("Festivos de<br>14 países", "También por comunidad autónoma"),
        ("Tu país,<br>tu idioma", "Disponible en 10 idiomas"),
    ],
    "it": [
        ("Quando dovresti<br>fermarti?", "Ultima pausa, prossima pausa e quando staccare"),
        ("Meno ferie,<br>ponti più lunghi", "Festivi e weekend combinati per te"),
        ("Le tue ferie<br>a colpo d'occhio", "Tocca una data per aggiungere o modificare"),
        ("Festività di<br>14 Paesi", "Ognuno con le sue regole"),
        ("Il tuo Paese,<br>la tua lingua", "Disponibile in 10 lingue"),
    ],
    "pt-BR": [
        ("Quando você<br>deve descansar?", "Sua última folga, a próxima e a hora de parar"),
        ("Menos dias,<br>feriadões maiores", "Feriados e fins de semana combinados"),
        ("Suas férias<br>num piscar de olhos", "Toque numa data para lançar ou editar"),
        ("Feriados de<br>14 países", "Cada um com suas regras"),
        ("Seu país,<br>seu idioma", "Disponível em 10 idiomas"),
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
}

TEXT = '<div class="text"><div class="bar"></div><div class="headline">{h}</div><div class="sub">{s}</div></div>'
PHONE = '<div class="wrap"><div class="phone"><img src="{img}"></div></div>'
PAGE = '<!doctype html><html><head><meta charset="utf-8"><style>{css}</style></head><body>{body}</body></html>'


def render(locale):
    out_dir = OUT / locale
    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("*.png"):
        old.unlink()
    for i, ((src, layout), (h, s)) in enumerate(zip(SLIDES, COPY[locale]), start=1):
        text = TEXT.format(h=h, s=s)
        if layout == "flags":
            body = text + '<div class="grid">' + "".join(f"<div>{f}</div>" for f in FLAGS) + "</div>"
            name = "countries"
        else:
            img = RAW / locale / src
            if not img.exists():
                sys.exit(f"원본 없음: {img} — scripts/take_screenshots.sh 먼저")
            phone = PHONE.format(img=img.as_uri())
            body = phone + text if layout == "text-bottom" else text + phone
            name = src[3:-4]
        html = PAGE.format(css=BASE_CSS + LAYOUTS[layout], body=body)
        with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False, encoding="utf-8") as f:
            f.write(html)
        png = out_dir / f"{i:02d}-{name}.png"
        subprocess.run([CHROME, "--headless=new", f"--screenshot={png}", f"--window-size={W},{H}",
                        "--force-device-scale-factor=1", "--hide-scrollbars", "--disable-gpu",
                        "--allow-file-access-from-files", pathlib.Path(f.name).as_uri()],
                       check=True, capture_output=True)
        pathlib.Path(f.name).unlink()
        print(f"  ✓ {png.relative_to(ROOT)}")


if __name__ == "__main__":
    for loc in (sys.argv[1:] or list(COPY)):
        render(loc)
