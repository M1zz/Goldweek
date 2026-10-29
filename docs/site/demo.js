// 골드위크 웹 체험: 연차를 며칠 쓸지 고르면, 그 일수로 가장 길게 쉬는 연휴를 보여 준다.
// 연휴 목록은 앱의 RecommendationEngine 이 그 언어 나라의 공휴일(HolidayService)로 낸 결과를 그대로 옮긴 것이다.
// d 는 하루씩 L(연차) · H(공휴일) · W(주말), 색은 앱의 추천 카드와 같다.
(() => {
  const root = document.getElementById("demo");
  if (!root) return;
  const T = JSON.parse(root.dataset.text);
  const lang = document.documentElement.lang;
  const fill = (s, n) => s.replace("{n}", n);
  const esc = s => s.replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);

  const day = s => { const [y, m, d] = s.split("-").map(Number); return new Date(y, m - 1, d); };
  const today = new Date(); today.setHours(0, 0, 0, 0);
  const leaveOf = r => [...r.d].filter(c => c === "L").length;
  const yearAhead = new Date(today); yearAhead.setFullYear(today.getFullYear() + 1);
  const recs = T.recs.filter(r => day(r.s) >= today && day(r.s) < yearAhead);   // 앞으로 1년
  const budgets = [1, 2, 3, 4].filter(n => recs.some(r => leaveOf(r) === n));
  if (!budgets.length) { root.closest("section").hidden = true; return; }
  let pick = budgets[0];

  const md = new Intl.DateTimeFormat(lang, { year: "numeric", month: "short", day: "numeric" });
  const range = (a, b) => md.formatRange ? md.formatRange(a, b) : `${md.format(a)} – ${md.format(b)}`;
  const KIND = { L: "leave", H: "holiday", W: "weekend" };

  function best(n) {
    const seen = new Set();
    return recs.filter(r => leaveOf(r) === n)
      .sort((a, b) => b.d.length - a.d.length || day(a.s) - day(b.s))
      .filter(r => !seen.has(r.s + r.d) && seen.add(r.s + r.d))
      .slice(0, 3);
  }

  function card(r) {
    const start = day(r.s), end = new Date(start); end.setDate(end.getDate() + r.d.length - 1);
    const cells = [...r.d].map((c, i) => {
      const d = new Date(start); d.setDate(d.getDate() + i);
      return `<li class="gw-day ${KIND[c]}"><small>${esc(T.weekdays[d.getDay()])}</small><span>${d.getDate()}</span></li>`;
    }).join("");
    return `<article class="gw-rec">
      <h3>${esc(r.t)}</h3>
      <p class="muted small">${esc(range(start, end))}</p>
      <ol class="gw-days" aria-label="${esc(range(start, end))}">${cells}</ol>
      <p class="gw-sum"><span>${esc(fill(T.leave, leaveOf(r)))}</span><span aria-hidden="true">→</span><b>${esc(fill(T.rest, r.d.length))}</b></p>
    </article>`;
  }

  function render(focus) {
    root.innerHTML = `
      <div class="gw-ask">
        <p class="gw-q" id="gw-q">${esc(T.ask)}</p>
        <div class="gw-chips" role="radiogroup" aria-labelledby="gw-q">${budgets.map(n =>
          `<button type="button" class="chip" role="radio" aria-checked="${n === pick}" data-n="${n}">${esc(fill(T.leave, n))}</button>`).join("")}</div>
        <p class="muted small">${esc(T.based)}</p>
      </div>
      <div class="gw-list" aria-live="polite">${best(pick).map(card).join("")}</div>
      <ul class="gw-legend muted small">${["leave", "holiday", "weekend"].map((k, i) =>
        `<li class="${k}">${esc(T.legend[i + 1])}</li>`).join("")}</ul>
      <p class="muted small demo-note">${esc(T.note)}</p>`;
    if (focus) root.querySelector(`[data-n="${pick}"]`).focus();
  }

  root.addEventListener("click", e => {
    const b = e.target.closest("[data-n]");
    if (!b) return;
    pick = +b.dataset.n;
    render(true);
  });
  root.addEventListener("keydown", e => {
    if (!e.target.dataset.n || !["ArrowRight", "ArrowLeft"].includes(e.key)) return;
    const i = budgets.indexOf(pick) + (e.key === "ArrowRight" ? 1 : -1);
    if (i < 0 || i >= budgets.length) return;
    pick = budgets[i]; e.preventDefault(); render(true);
  });

  render();
})();
