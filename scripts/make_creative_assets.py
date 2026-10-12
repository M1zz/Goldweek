#!/usr/bin/env python3
"""Goldweek App Store 크리에이티브 자산(제품 페이지 헤더 · 검색 결과): HTML → 헤드리스 Chrome.

사용법: python3 scripts/make_creative_assets.py [언어 ...]     (없으면 전부, 언어는 앱 코드: en, de, nb …)

자리
  docs/screenshots/creative/<스토어 로케일>/header.png   3840x1646  제품 페이지 맨 위
  docs/screenshots/creative/<스토어 로케일>/search.png   3840x2560  검색 결과 (없으면 스크린샷이 대신 보인다)

기기 화면: docs/screenshots/raw/<언어>/01-home · 02-recommend · 03-calendar (scripts/take_screenshots.sh 가 찍는다)

⚠️ 안전 영역 밖은 기기에 따라 잘린다. 글은 **반드시** 안전 영역 안에 둔다(배경 · 기기 그림은 넘쳐도 된다).
   수치는 Apple 공식 PSD 템플릿에서 잰 값이다(https://developer.apple.com/app-store/asset-best-practices/).
⚠️ 가격 · 할인 · 주소(URL) · 수상 · 다른 플랫폼 이름은 넣지 않는다(Apple 가이드).
"""
import subprocess, sys, pathlib, tempfile, time

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = ROOT / "docs" / "screenshots" / "raw"
OUT = ROOT / "docs" / "screenshots" / "creative"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
# 사용자가 쓰는 Chrome 과 프로필이 겹치면 헤드리스가 멈춘다 — 따로 쓴다
PROFILE = tempfile.mkdtemp(prefix="goldweek-creative-chrome-")

# 앱 언어 코드(raw · marketing 폴더 이름) → App Store Connect 로케일 (--storetext 로 확인한 것)
STORE = {"en": "en-US", "de": "de-DE", "es": "es-ES", "fr": "fr-FR", "nl": "nl-NL", "nb": "no"}

# (가로, 세로, 안전 영역 left, top, right, bottom)
SPEC = {
    "header": (3840, 1646, (1097, 493, 2743, 1154)),
    "search": (3840, 2560, (836, 765, 3004, 1795)),
}

# 헤더: 처음 온 사람에게 **한 가지 약속** — 부제와 같은 생각: 연차는 조금, 연휴는 길게.
# ⚠️ 기계번역하지 않는다. 각 언어에서 짧게 읽히는 말로 따로 썼다. 말투는 그 언어 스크린샷과 맞춘다.
HEADER = {
    "ko":      ("황금연휴 플래너", "연차는 조금만,<br>연휴는 길게"),
    "en":      ("PTO planner", "Take fewer days off.<br>Get longer breaks."),
    "de":      ("Brückentage", "Weniger Urlaub,<br>länger frei"),
    "es":      ("Puentes y vacaciones", "Pide menos días,<br>descansa más"),
    "fr":      ("Congés et ponts", "Posez moins,<br>partez plus longtemps"),
    "it":      ("Ferie e ponti", "Meno permessi,<br>ponti più lunghi"),
    "ja":      ("連休プランナー", "少ない有給で、<br>長い連休を"),
    "pt-BR":   ("Feriadões e férias", "Menos dias de folga,<br>feriadões maiores"),
    "zh-Hans": ("连休规划", "少请几天假，<br>多休好几天"),
    "zh-Hant": ("連假規劃", "少請幾天特休，<br>多放好幾天"),
    "ru":      ("Планер отпуска", "Меньше дней отпуска,<br>больше отдыха"),
    "id":      ("Perencana cuti", "Cuti sedikit,<br>libur panjang"),
    "nl":      ("Verlofplanner", "Minder verlof,<br>langer vrij"),
    "sv":      ("Semesterplanerare", "Färre semesterdagar,<br>längre ledigt"),
    "nb":      ("Ferieplanlegger", "Færre feriedager,<br>lengre fri"),
    "da":      ("Ferieplanlægger", "Færre feriedage,<br>længere fri"),
    "fi":      ("Lomasuunnittelija", "Vähemmän lomapäiviä,<br>pidempi vapaa"),
    "pl":      ("Planer urlopu", "Mniej dni urlopu,<br>dłuższe wolne"),
    "cs":      ("Plánovač dovolené", "Méně dní dovolené,<br>delší volno"),
    "el":      ("Πλάνο άδειας", "Λιγότερη άδεια,<br>περισσότερη ξεκούραση"),
    "tr":      ("İzin planlayıcı", "Daha az izin,<br>daha uzun tatil"),
}

# 검색 결과: 스크린샷 1장(홈 · "언제 쉬어야 할까?")과 **같은 이야기**. 눈썹글은 그 나라 사람이 검색창에 치는 말.
SEARCH = {
    "ko":      ("연차 관리", "언제 쉬어야<br>할까?", "지난 휴가와 다음 휴가로 쉴 때를 알려 드려요"),
    "en":      ("PTO tracker", "When should you<br>take a break?", "Your last break, your next one, and when to rest"),
    "de":      ("Urlaubsplaner", "Wann brauchst du<br>eine Pause?", "Letzter Urlaub, nächster Urlaub und wann es Zeit wird"),
    "es":      ("Calendario de vacaciones", "¿Cuándo deberías<br>descansar?", "Tu último descanso, el próximo y cuándo parar"),
    "fr":      ("Planning des congés", "Quand faut-il<br>souffler&nbsp;?", "Dernier congé, prochain congé&nbsp;: on vous dit quand"),
    "it":      ("Calendario ferie", "Quando dovresti<br>fermarti?", "Ultima pausa, prossima pausa e quando staccare"),
    "ja":      ("有給管理", "いつ休むのが<br>いい？", "前回と次の休みから、休みどきをお知らせ"),
    "pt-BR":   ("Calendário de feriados", "Quando você<br>deve descansar?", "Sua última folga, a próxima e a hora de parar"),
    "zh-Hans": ("年假管理", "什么时候<br>该休息了？", "看看上次和下次休假，提醒你该歇歇了"),
    "zh-Hant": ("特休管理", "什麼時候<br>該休息了？", "看看上次和下次休假，提醒你該休息了"),
    "ru":      ("Календарь отпусков", "Когда пора<br>отдохнуть?", "Прошлый отпуск, следующий и подсказка, когда отдыхать"),
    "id":      ("Kalender cuti", "Kapan waktunya<br>istirahat?", "Libur terakhir, libur berikutnya, dan kapan harus rehat"),
    "nl":      ("Vakantieplanner", "Wanneer neem jij<br>weer vrij?", "Je vorige vakantie, de volgende en het beste moment"),
    "sv":      ("Klämdagar", "När ska du<br>ta ledigt?", "Senaste ledigheten, nästa och när du behöver vila"),
    "nb":      ("Inneklemte dager", "Når skal du<br>ta fri?", "Forrige ferie, den neste og når du bør hvile"),
    "da":      ("Klemmedage", "Hvornår skal du<br>holde fri?", "Seneste ferie, næste ferie og tid til en pause"),
    "fi":      ("Lomakalenteri", "Milloin pitäisit<br>lomaa?", "Edellinen loma, seuraava ja milloin levätä"),
    "pl":      ("Kalendarz urlopów", "Kiedy wziąć<br>wolne?", "Ostatni urlop, następny i kiedy odpocząć"),
    "cs":      ("Kalendář dovolené", "Kdy si<br>dát volno?", "Poslední volno, to příští a kdy si odpočinout"),
    "el":      ("Ημερολόγιο αργιών", "Πότε να πάρεις<br>ρεπό;", "Το τελευταίο, το επόμενο και πότε να ξεκουραστείς"),
    "tr":      ("Yıllık izin", "Ne zaman<br>izin almalı?", "Son tatilin, sıradaki tatilin ve dinlenme zamanın"),
}

BRAND = "#0066FF"
# ⚠️ 바탕 · 글자색 · 막대는 마케팅 스크린샷(make_marketing_screenshots.py)과 같다.
BASE_CSS = """
* { margin:0; padding:0; box-sizing:border-box; }
html,body { width:%(W)dpx; height:%(H)dpx; overflow:hidden; }
body { background:linear-gradient(180deg,#EEF4FF 0%%,#F7FAFF 55%%,#EFFAF4 100%%); position:relative;
  font-family:-apple-system,"Apple SD Gothic Neo","Hiragino Sans","PingFang SC","PingFang TC",sans-serif; }
.glow { position:absolute; border-radius:50%%; filter:blur(160px); pointer-events:none; }
.text { position:absolute; display:flex; flex-direction:column; justify-content:center; }
.bar { width:180px; height:20px; border-radius:10px; background:linear-gradient(90deg,#0066FF,#00C471); }
.eyebrow { font-weight:700; color:#0066FF; letter-spacing:-0.01em; line-height:1.15; }
.headline { font-weight:800; color:#121A2B; letter-spacing:-0.03em; line-height:1.14; text-wrap:balance; }
.sub { font-weight:500; color:#5E6B80; letter-spacing:-0.01em; line-height:1.35; text-wrap:balance; }
:lang(ja) .headline, :lang(zh) .headline { letter-spacing:0; }
:lang(ko) .headline, :lang(ko) .sub, :lang(ko) .eyebrow { word-break:keep-all; }
.phone { position:absolute; background:#14161B; border:5px solid #3A3D45; padding:40px; border-radius:190px;
  box-shadow:60px 90px 140px rgba(10,40,100,.22), 18px 30px 60px rgba(10,40,100,.14); }
.phone img { width:100%%; display:block; border-radius:152px; }
/* 앱의 날짜 동그라미(주말 파랑 · 공휴일 빨강 · 연차 초록)를 장식으로 흩는다 */
.day { position:absolute; border-radius:50%%; display:flex; align-items:center; justify-content:center;
  color:#fff; font-weight:700; font-family:-apple-system,"Helvetica Neue",sans-serif;
  box-shadow:0 20px 50px rgba(10,40,100,.16); }
"""
# 헤드리스 Chrome 은 -apple-system 을 못 찾아 다음 글꼴(한글)로 그린다 — 그 글꼴엔 그리스 문자·체코 악센트가 없다.
CJK = {"ko", "ja", "zh-Hans", "zh-Hant"}
LATIN_FONT = 'body { font-family:"Helvetica Neue",-apple-system,sans-serif; }'

DAY_COLORS = {"b": "#3B82F6", "r": "#F0525A", "g": "#22B35E", "y": "#F5B300"}

# 글이 상자를 넘지 않을 때까지 줄인다. 잘리는 글은 없다 - 끝까지 안 맞으면 표시하고 멈춘다.
FIT_JS = """
<script>
// 문구에 적은 줄(<br>)보다 더 쪼개지면 "Rispondi / con un / tocco" 처럼 읽기가 끊긴다.
// 적은 줄 수를 지킬 때까지 줄인다.
function lines(el) {
  return Math.round(el.getBoundingClientRect().height / parseFloat(getComputedStyle(el).lineHeight));
}
function fit(box, el, max, min) {
  const want = el.querySelectorAll('br').length + 1;
  let size = max;
  el.style.fontSize = size + 'px';
  while (size > min && (box.scrollHeight > box.clientHeight + 1 || box.scrollWidth > box.clientWidth + 1 ||
         lines(el) > want)) {
    size -= 4; el.style.fontSize = size + 'px';
  }
  if (box.scrollHeight > box.clientHeight + 1 || box.scrollWidth > box.clientWidth + 1 || lines(el) > want)
    document.body.dataset.overflow = '1';
}
document.fonts.ready.then(() => {
  const box = document.querySelector('.text');
  const h = document.querySelector('.headline');
  fit(box, h, +h.dataset.max, +h.dataset.min);
  document.body.dataset.done = '1';
});
</script>
"""


def raw(lang, name):
    p = RAW / lang / name
    if not p.exists():
        raise SystemExit(f"원본 없음: {p} — scripts/take_screenshots.sh 먼저")
    return p.as_uri()


def phone(img, left, top, width, rotate=0):
    return (f'<div class="phone" style="left:{left}px;top:{top}px;width:{width}px;'
            f'transform:rotate({rotate}deg)"><img src="{img}"></div>')


def days(items):
    return "".join(f'<div class="day" style="left:{x}px;top:{y}px;width:{s}px;height:{s}px;'
                   f'font-size:{int(s * .46)}px;background:{DAY_COLORS[c]};opacity:{o}">{n}</div>'
                   for x, y, s, c, n, o in items)


def search_html(lang):
    W, H, (l, t, r, b) = SPEC["search"]
    eyebrow, headline, sub = SEARCH[lang]
    sw, sh = r - l, b - t
    col = int(sw * 0.56)
    ph_w = 1040
    ph_left = l + col + int(sw * 0.04)
    deco = days([(3300, 380, 220, "r", 3, .9), (3420, 700, 170, "g", 4, .85), (3330, 1960, 200, "b", 7, .85),
                 (420, 2180, 180, "g", 5, .7), (300, 280, 150, "b", 6, .6)])
    return f"""
<div class="glow" style="left:{ph_left - 300}px;top:500px;width:1700px;height:1700px;background:rgba(0,102,255,.14)"></div>
<div class="glow" style="left:{l - 700}px;top:{t + 300}px;width:1600px;height:1200px;background:rgba(0,196,113,.10)"></div>
{deco}
{phone(raw(lang, "01-home.png"), ph_left, t - 360, ph_w, 0)}
<div class="text" style="left:{l}px;top:{t}px;width:{col}px;height:{sh}px">
  <div class="bar" style="margin-bottom:56px"></div>
  <div class="eyebrow" style="font-size:96px">{eyebrow}</div>
  <div class="headline" data-max="230" data-min="130" style="margin-top:36px">{headline}</div>
  <div class="sub" style="font-size:80px;margin-top:52px">{sub}</div>
</div>"""


def header_html(lang):
    W, H, (l, t, r, b) = SPEC["header"]
    eyebrow, headline = HEADER[lang]
    sw, sh = r - l, b - t
    # 연휴를 이루는 날짜처럼 보이도록 안전 영역 바깥에 흩는다(잘려도 되는 장식)
    deco = days([(80, 120, 190, "b", 6, .75), (1000, 70, 150, "r", 8, .7), (1200, 1330, 150, "g", 9, .7),
                 (2700, 80, 160, "g", 10, .7), (2520, 1340, 170, "b", 12, .7), (3640, 1180, 200, "r", 1, .75)])
    return f"""
<div class="glow" style="left:{l - 200}px;top:{t - 400}px;width:{sw + 400}px;height:{sh + 800}px;background:rgba(0,102,255,.10)"></div>
{deco}
{phone(raw(lang, "02-recommend.png"), 300, 360, 640, -9)}
{phone(raw(lang, "03-calendar.png"), 2900, 360, 640, 9)}
<div class="text" style="left:{l}px;top:{t}px;width:{sw}px;height:{sh}px;align-items:center;text-align:center">
  <div class="bar" style="margin-bottom:40px"></div>
  <div class="eyebrow" style="font-size:76px">{eyebrow}</div>
  <div class="headline" data-max="200" data-min="100" style="margin-top:22px">{headline}</div>
</div>"""


def chrome(args, done, timeout=90):
    """헤드리스 Chrome 은 일을 다 하고도 끝나지 않을 때가 있다 — done() 이 참이 되면 끝낸다."""
    with tempfile.TemporaryFile("w+", encoding="utf-8") as out:
        proc = subprocess.Popen([CHROME, "--headless=new", "--force-device-scale-factor=1", "--hide-scrollbars",
                                 "--disable-gpu", "--virtual-time-budget=3000", "--allow-file-access-from-files",
                                 f"--user-data-dir={PROFILE}", *args], stdout=out, stderr=subprocess.DEVNULL)
        text = ""
        for _ in range(timeout * 2):
            out.seek(0)
            text = out.read()
            if proc.poll() is not None or done(text):
                break
            time.sleep(0.5)
        time.sleep(1)   # 쓰는 중일 수 있다
        if proc.poll() is None:
            proc.kill()
            proc.wait()
        out.seek(0)
        return out.read()


def render(lang, kind):
    W, H, _ = SPEC[kind]
    body = search_html(lang) if kind == "search" else header_html(lang)
    css = BASE_CSS % {"W": W, "H": H} + ("" if lang in CJK else LATIN_FONT)
    page = (f'<!doctype html><html lang="{lang}"><head><meta charset="utf-8"><style>'
            f'{css}</style></head><body>{body}{FIT_JS}</body></html>')
    html_path = pathlib.Path(tempfile.gettempdir()) / f"goldweek-creative-{lang}-{kind}.html"
    html_path.write_text(page, encoding="utf-8")
    # 글이 끝까지 안 맞으면 그림을 만들지 않는다(잘린 글이 스토어에 올라가는 것보다 낫다).
    dom = chrome(["--dump-dom", f"--window-size={W},{H}", html_path.as_uri()], lambda t: "</html>" in t)
    if 'data-done="1"' not in dom:
        raise SystemExit(f"글 맞추기가 끝나지 않았다: {lang} {kind}")
    if 'data-overflow="1"' in dom:
        raise SystemExit(f"글이 안전 영역을 넘는다: {lang} {kind} - 문구를 줄일 것")
    out_dir = OUT / STORE.get(lang, lang)
    out_dir.mkdir(parents=True, exist_ok=True)
    out_png = out_dir / f"{kind}.png"
    out_png.unlink(missing_ok=True)
    # ⚠️ Chrome 은 가끔 아무것도 안 그리고 끝나거나 멈춘다. 세 번까지 한다.
    for _ in range(3):
        chrome([f"--screenshot={out_png}", f"--window-size={W},{H}", html_path.as_uri()],
               lambda t: out_png.exists() and out_png.stat().st_size > 0)
        if out_png.exists() and out_png.stat().st_size > 0:
            break
        time.sleep(1)
    else:
        raise SystemExit(f"Chrome 이 그리지 못했다: {out_png}")
    html_path.unlink(missing_ok=True)
    print(f"rendered {out_png.relative_to(ROOT)}")


if __name__ == "__main__":
    langs = sys.argv[1:] or list(SEARCH)
    for lang in langs:
        if lang not in SEARCH or lang not in HEADER:
            raise SystemExit(f"모르는 언어: {lang} (아는 것: {', '.join(SEARCH)})")
        for kind in ("header", "search"):
            render(lang, kind)
