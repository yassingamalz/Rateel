// U1.L2 — أعضاء النطق (Organs of Articulation)
// Photo-driven lesson in the same emerald manuscript style.
// Core visual = a mid-sagittal head cross-section: a drag-and-drop <image-slot>
// (user drops a licensed render) over a hand-built emerald/gold duotone head
// placeholder so airflow + leader lines + organ glows always align.
// Engine globals from animations.jsx: Stage, Sprite, useTime, useSprite, clamp, Easing.

const FONTS = { naskh: "'Amiri', serif", kufi: "'Reem Kufi', sans-serif" };
const AMIRI = FONTS.naskh;
const KUFI  = FONTS.kufi;

const THEMES = {
  emerald: {
    dark: true,
    bg: "radial-gradient(circle at 50% 34%, #1f4037 0%, #163129 52%, #0b1c17 100%)",
    ink: "#f3ead4", gold: "#daa520", gold2: "#ffd700", glow: "#ffe355",
    green: "#95d5b2", lgold: "#dfc298", terra: "#dfc298", geoInk: "#5e9b86",
    plate1: "#1d463b", plate2: "#0c2019", cavity: "#0a1f1a",
  },
  manuscript: {
    dark: false,
    bg: "radial-gradient(circle at 50% 40%, #f8efd8 0%, #f1e4c5 58%, #ead9b4 100%)",
    ink: "#173f37", gold: "#b3893f", gold2: "#d8b25e", glow: "#d8b25e",
    green: "#3f6f54", lgold: "#a07a36", terra: "#a14a30", geoInk: "#173f37",
    plate1: "#efe2c4", plate2: "#e2d2ad", cavity: "#d8c79e",
  },
  royal: {
    dark: true,
    bg: "radial-gradient(circle at 50% 40%, #3a2c6e 0%, #281f54 58%, #1c1542 100%)",
    ink: "#f3ead4", gold: "#d8b65c", gold2: "#f0d385", glow: "#f0d385",
    green: "#9fc7b4", lgold: "#e3cf9a", terra: "#dd8fa6", geoInk: "#9486c9",
    plate1: "#332a63", plate2: "#1e1748", cavity: "#181140",
  },
};

const TH = React.createContext({ ...THEMES.emerald, heroFont: AMIRI, motif: "girih", grade: 70 });
const useTH = () => React.useContext(TH);

const C = (v, mn, mx) => Math.max(mn, Math.min(mx, v));
function win(lt, a, b, f = 0.45) {
  if (lt <= a || lt >= b) return 0;
  return C(Math.min((lt - a) / f, (b - lt) / f, 1), 0, 1);
}
function starPoints(cx, cy, R, r, points = 8) {
  const arr = [];
  for (let i = 0; i < points * 2; i++) {
    const ang = (Math.PI / points) * i - Math.PI / 2;
    const rad = i % 2 === 0 ? R : r;
    arr.push((cx + rad * Math.cos(ang)).toFixed(2) + "," + (cy + rad * Math.sin(ang)).toFixed(2));
  }
  return arr.join(" ");
}

// ── head-stage geometry (canvas coords) ──────────────────────────
const BOX = { x: 408, y: 100, w: 460, h: 520 };           // image box
const L2C = (lx, ly) => [BOX.x + lx, BOX.y + ly];          // local(460x520) → canvas
const ORG = {                                              // organ canvas points
  larynx:  L2C(258, 432), throat: L2C(254, 360), tongue: L2C(188, 318),
  palate:  L2C(182, 270), teeth:  L2C(112, 300), lips:   L2C(90, 320),
  nasal:   L2C(126, 176), lungs:  L2C(300, 506),
};

// ── duotone head illustration (data-URI placeholder) ─────────────
function buildHeadSVG(th) {
  const svg = `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 460 520'>
  <defs>
    <linearGradient id='plate' x1='0' y1='0' x2='0' y2='1'>
      <stop offset='0' stop-color='${th.plate1}'/><stop offset='1' stop-color='${th.plate2}'/>
    </linearGradient>
    <radialGradient id='hg' cx='40%' cy='42%' r='70%'>
      <stop offset='0' stop-color='${th.plate1}'/><stop offset='1' stop-color='${th.plate2}'/>
    </radialGradient>
  </defs>
  <rect x='5' y='5' width='450' height='510' rx='22' fill='url(#plate)' stroke='${th.gold}' stroke-opacity='.4' stroke-width='1.5'/>
  <g fill='none' stroke='${th.gold}' stroke-width='2.4' stroke-linejoin='round' stroke-linecap='round'>
    <path d='M252,40 C150,40 78,104 78,188 C78,206 60,212 54,228 C49,241 72,246 70,258
             C84,262 75,275 90,281 C100,287 80,299 96,307 C104,321 126,333 152,339
             C190,349 214,347 228,367 C236,385 250,385 262,373 L300,373 L300,512 L372,512
             L372,470 C372,300 432,266 418,182 C410,94 360,40 252,40 Z' fill='url(#hg)'/>
  </g>
  <g fill='none' stroke='${th.lgold}' stroke-width='1.5' stroke-opacity='.85' stroke-linecap='round'>
    <path d='M96,150 C118,144 152,150 160,178 C154,192 150,202 138,208 C120,212 100,206 96,196' fill='${th.cavity}' fill-opacity='.55'/>
    <path d='M114,168 C124,168 134,170 140,178 M112,184 C124,184 134,186 142,192' stroke-opacity='.6'/>
    <path d='M104,288 C150,264 212,264 252,280' />
    <path d='M122,338 C166,308 218,308 252,324 C242,352 168,358 122,342 Z' fill='${th.gold}' fill-opacity='.18'/>
    <path d='M252,280 C268,332 268,402 258,454' />
    <ellipse cx='264' cy='452' rx='17' ry='22' fill='${th.gold}' fill-opacity='.16'/>
    <path d='M251,468 L300,514 M278,462 L322,514' stroke-opacity='.7'/>
    <path d='M214,360 C226,352 236,352 244,360' stroke-opacity='.6'/>
  </g>
  <g fill='${th.cavity}' fill-opacity='.5'><path d='M92,288 C120,300 120,322 96,336 C88,322 86,302 92,288 Z'/></g>
</svg>`;
  return "data:image/svg+xml;utf8," + encodeURIComponent(svg);
}

// ── reusable text ────────────────────────────────────────────────
function Word({ text, x, y, size = 80, color, font, weight = 400, delay = 0, hold = null, scaleIn = false, glow = null, lineHeight = 1.25, anchor = "center" }) {
  const th = useTH();
  const { localTime, duration } = window.useSprite();
  color = color || th.ink; font = font || th.heroFont;
  const b = hold != null ? hold : duration - 0.05;
  const op = win(localTime, delay, b, 0.45);
  const t = C((localTime - delay) / 0.5, 0, 1);
  const ease = window.Easing.easeOutBack(t);
  const ty = (1 - window.Easing.easeOutCubic(t)) * 18;
  const sc = scaleIn ? (0.6 + 0.4 * ease) : 1;
  const tx = anchor === "center" ? "-50%" : anchor === "right" ? "-100%" : "0";
  return (
    <div style={{
      position: "absolute", left: x, top: y,
      transform: `translate(${tx}, calc(-50% + ${ty}px)) scale(${sc})`,
      opacity: op, color, fontFamily: font, fontWeight: weight, fontSize: size, lineHeight,
      direction: "rtl", whiteSpace: "nowrap", textAlign: anchor, willChange: "transform, opacity",
      textShadow: glow ? `0 0 ${glow}px ${th.glow}, 0 0 ${glow * 2}px ${th.gold}88` : "none",
    }}>{text}</div>
  );
}
function Label({ text, x, y, size = 26, color, weight = 500, delay = 0, hold = null, align = "center", opacityMul = 1 }) {
  const th = useTH();
  const { localTime, duration } = window.useSprite();
  color = color || th.gold;
  const b = hold != null ? hold : duration - 0.05;
  const op = win(localTime, delay, b, 0.45) * opacityMul;
  const t = C((localTime - delay) / 0.5, 0, 1);
  const ty = (1 - window.Easing.easeOutCubic(t)) * 12;
  const tx = align === "center" ? "-50%" : align === "right" ? "-100%" : "0";
  return (
    <div style={{
      position: "absolute", left: x, top: y, transform: `translate(${tx}, calc(-50% + ${ty}px))`,
      opacity: op, color, fontFamily: KUFI, fontWeight: weight, fontSize: size,
      direction: "rtl", whiteSpace: "nowrap", textAlign: align, willChange: "transform, opacity",
    }}>{text}</div>
  );
}

// ── constant geometric backdrop ──────────────────────────────────
function GeoBackground() {
  const time = window.useTime();
  const th = useTH();
  const rot = time * 4;
  const breath = 1 + 0.025 * Math.sin(time * 0.6);
  const W = 1280, H = 720, cx = W / 2, cy = H / 2;
  const og = th.dark ? 0.14 : 0.10, oi = th.dark ? 0.10 : 0.07;
  let center = null;
  if (th.motif === "girih") {
    center = (
      <>
        <g transform={`translate(${cx} ${cy}) rotate(${rot}) scale(${breath}) translate(${-cx} ${-cy})`} opacity={og}>
          <polygon points={starPoints(cx, cy, 320, 148)} fill="none" stroke={th.gold} strokeWidth="2" />
          <polygon points={starPoints(cx, cy, 244, 112)} fill="none" stroke={th.gold} strokeWidth="1.4" />
        </g>
        <g transform={`translate(${cx} ${cy}) rotate(${-rot * 0.6}) translate(${-cx} ${-cy})`} opacity={oi}>
          <polygon points={starPoints(cx, cy, 176, 82)} fill="none" stroke={th.geoInk} strokeWidth="1.4" />
        </g>
      </>
    );
  } else if (th.motif === "arabesque") {
    const dots = [];
    for (let i = 0; i < 16; i++) { const a = (Math.PI / 8) * i; dots.push(<circle key={i} cx={cx + 244 * Math.cos(a)} cy={cy + 244 * Math.sin(a)} r="7" fill="none" stroke={th.gold} strokeWidth="1.4" />); }
    center = (
      <>
        <g transform={`translate(${cx} ${cy}) scale(${breath}) translate(${-cx} ${-cy})`} opacity={og}>
          {[316, 256, 196, 138].map((r, i) => <circle key={i} cx={cx} cy={cy} r={r} fill="none" stroke={th.gold} strokeWidth={i === 0 ? 2 : 1.2} />)}
        </g>
        <g transform={`translate(${cx} ${cy}) rotate(${rot}) translate(${-cx} ${-cy})`} opacity={og}>{dots}</g>
      </>
    );
  }
  return (
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`} style={{ position: "absolute", inset: 0 }}>
      {center}
      <rect x="38" y="38" width={W - 76} height={H - 76} fill="none" stroke={th.gold} strokeWidth="2.5" opacity="0.5" />
      <rect x="48" y="48" width={W - 96} height={H - 96} fill="none" stroke={th.gold} strokeWidth="1" opacity="0.4" />
      {[[43, 43], [W - 43, 43], [43, H - 43], [W - 43, H - 43]].map(([x, y], i) => <polygon key={i} points={starPoints(x, y, 16, 7)} fill={th.gold} opacity="0.5" />)}
    </svg>
  );
}

// ── head layer (image-slot + duotone grade + Ken Burns) ──────────
function HeadLayer({ headSrc }) {
  const th = useTH();
  const t = window.useTime();
  // fade: faint behind title (<4.2), clears in scene2, recedes in scene5
  let op, blur, scale;
  if (t < 4.2) { op = 0.16; blur = 6; scale = 1.05; }
  else if (t < 5.6) { const p = C((t - 4.2) / 1.4, 0, 1); op = 0.16 + 0.84 * p; blur = 6 * (1 - p); scale = 1.05 - 0.03 * p; }
  else if (t < 36.2) { op = 1; blur = 0; scale = 1.02 - 0.02 * C((t - 5.6) / 30, 0, 1); }
  else { const p = C((t - 36.2) / 1.4, 0, 1); op = 1 - 0.7 * p; blur = 0; scale = 1.0 - 0.16 * p; }

  const a = (th.grade ?? 70) / 100;
  const filter = `blur(${blur}px) brightness(${1 - 0.05 * a}) contrast(${1 + 0.06 * a}) grayscale(${a}) sepia(${a}) hue-rotate(${a * 118}deg) saturate(${1 + 0.9 * a})`;
  const slot = React.createElement("image-slot", {
    id: "u1l2-head", src: headSrc, fit: "contain",
    placeholder: "أفلِت صورةَ المقطع الجانبي للرأس",
    style: { width: BOX.w + "px", height: BOX.h + "px", display: "block" },
  });
  return (
    <div style={{ position: "absolute", left: BOX.x, top: BOX.y, width: BOX.w, height: BOX.h, opacity: op, transform: `scale(${scale})`, transformOrigin: "50% 45%", willChange: "transform, opacity" }}>
      <div style={{ position: "absolute", inset: 0, filter }}>{slot}</div>
      {/* duotone wash */}
      <div style={{ position: "absolute", inset: 0, borderRadius: 22, pointerEvents: "none",
        background: `linear-gradient(160deg, ${th.plate1}00 30%, ${th.gold}22 100%)`, mixBlendMode: "overlay", opacity: a }} />
      <div style={{ position: "absolute", inset: 0, borderRadius: 22, pointerEvents: "none", boxShadow: `inset 0 0 60px ${th.plate2}` }} />
    </div>
  );
}

// ── airflow thread (continuous across scenes) ────────────────────
const AF = [ORG.lungs, ORG.larynx, ORG.throat, [600, 420], [536, 392], [502, 396]];
function polyLen(pts) { let L = 0; const seg = [0]; for (let i = 1; i < pts.length; i++) { L += Math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1]); seg.push(L); } return { L, seg }; }
function pointAt(pts, frac) {
  const { L, seg } = polyLen(pts); const d = frac * L;
  for (let i = 1; i < pts.length; i++) { if (d <= seg[i]) { const t = (d - seg[i - 1]) / (seg[i] - seg[i - 1] || 1); return [pts[i - 1][0] + (pts[i][0] - pts[i - 1][0]) * t, pts[i - 1][1] + (pts[i][1] - pts[i - 1][1]) * t]; } }
  return pts[pts.length - 1];
}
function AirflowLayer() {
  const th = useTH();
  const t = window.useTime();
  const { L } = polyLen(AF);
  const draw = C((t - 4.7) / 4.0, 0, 1);
  let op = 0;
  if (t > 4.6 && t < 12.3) op = 1;
  else if (t >= 12.3 && t < 36.2) op = 0.5;
  else if (t >= 36.2) op = C(1 - (t - 36.2) / 1.2, 0, 1) * 0.5;
  if (op <= 0) return null;
  const d = "M" + AF.map((p) => p.join(",")).join(" L");
  const head = pointAt(AF, draw);
  const showHead = t > 4.7 && t < 9.0;
  return (
    <svg width="1280" height="720" style={{ position: "absolute", inset: 0, pointerEvents: "none", opacity: op }}>
      <path d={d} fill="none" stroke={th.gold} strokeWidth="5" strokeLinecap="round" strokeLinejoin="round"
        strokeDasharray={L} strokeDashoffset={L * (1 - draw)} opacity="0.45" style={{ filter: `drop-shadow(0 0 6px ${th.glow})` }} />
      <path d={d} fill="none" stroke={th.gold2} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"
        strokeDasharray={L} strokeDashoffset={L * (1 - draw)} />
      {showHead && <circle cx={head[0]} cy={head[1]} r="9" fill={th.glow} style={{ filter: `drop-shadow(0 0 10px ${th.glow})` }} />}
    </svg>
  );
}

// ─────────────────────────────────────────────────────────────────
// SCENE 1 — Title
function SceneTitle() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const lineW = C((localTime - 1.9) / 0.7, 0, 1) * 360;
  return (
    <>
      <Word text="أَعْضَاءُ النُّطْق" x={640} y={300} size={104} color={th.gold2} weight={700} font={KUFI} delay={0.5} scaleIn glow={26} />
      <div style={{ position: "absolute", left: 640, top: 372, width: lineW, height: 2, marginLeft: -lineW / 2, background: th.gold, opacity: 0.85, boxShadow: `0 0 10px ${th.glow}` }} />
      <Label text="كَيْفَ تَتَكَوَّنُ الحُرُوف؟" x={640} y={430} size={34} color={th.lgold} delay={2.2} />
    </>
  );
}

// SCENE 2 — Airflow
function SceneAir() {
  const th = useTH();
  return (
    <>
      <Label text="مَسَارُ الهَوَاء" x={640} y={92} size={32} color={th.gold} delay={0.2} />
      <Label text="الرِّئَتَان" x={ORG.lungs[0] + 92} y={ORG.lungs[1]} size={26} color={th.green} weight={600} delay={0.8} align="right" />
      <Label text="إِلَى الفَم" x={ORG.lips[0] - 70} y={ORG.lips[1]} size={26} color={th.gold2} weight={600} delay={5.2} align="left" />
      <Word text="هَوَاءٌ يَصْعَدُ مِنَ الرِّئَتَيْن فَتُشَكِّلُهُ الأَعْضَاء" x={640} y={662} size={30} color={th.lgold} font={KUFI} delay={2.4} />
    </>
  );
}

// SCENE 3 — Organ tour (hero)
const ORGANS = [
  { key: "larynx", name: "الحَنْجَرَة",     sub: "فِيهَا الأَوْتَارُ الصَّوْتِيَّة", side: "R", ay: 548 },
  { key: "throat", name: "الحَلْق",         sub: "أَقْصَى وَوَسَطٌ وَأَدْنَى",      side: "R", ay: 448 },
  { key: "tongue", name: "اللِّسَان",        sub: "أَهَمُّ الأَعْضَاء",             side: "L", ay: 470 },
  { key: "palate", name: "الحَنَكُ الأَعْلَى", sub: "اللَّهَاةُ وَالغَارُ وَاللِّثَة", side: "L", ay: 360 },
  { key: "teeth",  name: "الأَسْنَان",        sub: "تَشْتَرِكُ فِي عِدَّةِ حُرُوف",   side: "L", ay: 252 },
  { key: "lips",   name: "الشَّفَتَان",       sub: "البَاءُ وَالمِيمُ وَالوَاو",      side: "L", ay: 158 },
  { key: "nasal",  name: "الخَيْشُوم",        sub: "مَخْرَجُ الغُنَّة",              side: "T", ax: 640, ay: 132 },
];
const STAG = 2.3;
function OrganLabel({ org, idx }) {
  const th = useTH();
  const { localTime } = window.useSprite();
  const t0 = 0.7 + idx * STAG;
  const appeared = localTime > t0;
  const isLast = localTime < t0 + STAG;            // newest until next appears
  const op = appeared ? (isLast ? 1 : 0.55) : 0;
  const e = window.Easing.easeOutCubic(C((localTime - t0) / 0.5, 0, 1));
  const [ox, oy] = ORG[org.key];
  const ax = org.side === "R" ? 1018 : org.side === "L" ? 250 : (org.ax || 640);
  const ay = org.ay;
  const align = org.side === "R" ? "right" : org.side === "L" ? "left" : "center";
  // glow pulse on appearance
  const glowA = appeared ? (isLast ? 0.9 : 0.32) : 0;
  const pulse = isLast ? (1 + 0.25 * Math.max(0, Math.sin((localTime - t0 - 0.3) * 5)) * (localTime < t0 + 1 ? 1 : 0)) : 1;
  return (
    <>
      {/* organ glow on the image */}
      <div style={{ position: "absolute", left: ox, top: oy, width: 120, height: 120, marginLeft: -60, marginTop: -60,
        borderRadius: "50%", background: `radial-gradient(circle, ${th.glow}cc 0%, ${th.gold}55 35%, transparent 70%)`,
        opacity: glowA * e, transform: `scale(${pulse})`, mixBlendMode: "screen", pointerEvents: "none" }} />
      {/* leader line */}
      <svg width="1280" height="720" style={{ position: "absolute", inset: 0, pointerEvents: "none", opacity: op * e }}>
        <line x1={ox} y1={oy} x2={align === "right" ? ax - 8 : align === "left" ? ax + 8 : ax} y2={align === "center" ? ay + 14 : ay}
          stroke={th.gold} strokeWidth="1.6" strokeDasharray="3 5" opacity="0.85" />
        <circle cx={ox} cy={oy} r="5" fill={th.gold2} style={{ filter: `drop-shadow(0 0 6px ${th.glow})` }} />
      </svg>
      <div style={{ position: "absolute", left: ax, top: ay, transform: `translate(${align === "right" ? "-100%" : align === "center" ? "-50%" : "0"}, -50%)`,
        opacity: op * e, direction: "rtl", textAlign: align, whiteSpace: "nowrap", willChange: "opacity" }}>
        <div style={{ fontFamily: th.heroFont, fontSize: 38, fontWeight: 700, color: th.gold2 }}>{org.name}</div>
        <div style={{ fontFamily: KUFI, fontSize: 18, color: th.lgold, marginTop: 2 }}>{org.sub}</div>
      </div>
    </>
  );
}
function SceneTour() {
  const th = useTH();
  return (
    <>
      <Label text="جَوْلَةُ الأَعْضَاء" x={640} y={70} size={30} color={th.gold} delay={0.1} hold={999} opacityMul={0.9} />
      {ORGANS.map((o, i) => <OrganLabel key={o.key} org={o} idx={i} />)}
    </>
  );
}

// SCENE 4 — Air + organ = letter
function SceneEquation() {
  const th = useTH();
  const { localTime } = window.useSprite();
  // م grows at lips then flies to center-large
  const grow = C((localTime - 2.2) / 0.7, 0, 1);
  const fly = window.Easing.easeInOutCubic(C((localTime - 3.4) / 1.0, 0, 1));
  const [lx, ly] = ORG.lips;
  const mx = lx + (640 - lx) * fly, my = ly + (430 - ly) * fly;
  const msize = 70 + 110 * grow + 30 * fly;
  return (
    <>
      <div style={{ position: "absolute", left: 0, right: 0, top: 150, display: "flex", justifyContent: "center", alignItems: "center", gap: 26, direction: "rtl" }}>
        <Label text="هَوَاء" x={520} y={150} size={44} color={th.green} weight={700} delay={0.2} hold={999} />
        <div style={{ position: "absolute", left: 640, top: 150, transform: "translate(-50%,-50%)", color: th.gold, fontFamily: KUFI, fontSize: 40, opacity: win(localTime, 0.5, 999, 0.4) }}>+</div>
        <Label text="عُضْو" x={760} y={150} size={44} color={th.gold2} weight={700} delay={0.6} hold={999} />
      </div>
      <div style={{ position: "absolute", left: 640, top: 230, transform: "translate(-50%,-50%)", color: th.gold, fontFamily: KUFI, fontSize: 40, opacity: win(localTime, 1.4, 999, 0.4) }}>=</div>
      {/* the produced letter */}
      <div style={{ position: "absolute", left: mx, top: my, transform: "translate(-50%,-50%)", color: th.gold2,
        fontFamily: th.heroFont, fontSize: msize, fontWeight: 700, opacity: win(localTime, 2.2, 999, 0.4),
        textShadow: `0 0 ${18 + 14 * fly}px ${th.glow}` }}>مْ</div>
      <Word text="هَوَاءٌ يَمُرّ … وَعُضْوٌ يُشَكِّلُهُ … فَيَنْتُجُ حَرْف" x={640} y={628} size={30} color={th.lgold} font={KUFI} delay={4.6} />
    </>
  );
}

// SCENE 5 — Close
function SceneClose() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const cx = 640, cy = 318;
  const gather = window.Easing.easeOutCubic(C((localTime - 0.5) / 1.2, 0, 1));
  const keys = ["larynx", "throat", "tongue", "palate", "teeth", "lips", "nasal"];
  const dots = keys.map((k, i) => {
    const ang = -Math.PI / 2 + (i / keys.length) * Math.PI * 2;
    const R = 130;
    const tx = cx + R * Math.cos(ang), ty = cy + R * Math.sin(ang);
    const [sx, sy] = ORG[k];
    const x = sx + (tx - sx) * gather, y = sy + (ty - sy) * gather;
    return <div key={k} style={{ position: "absolute", left: x, top: y, width: 15, height: 15, marginLeft: -7.5, marginTop: -7.5, borderRadius: "50%", background: th.gold2, opacity: win(localTime, 0.3, 999, 0.4), boxShadow: `0 0 13px ${th.glow}` }} />;
  });
  return (
    <>
      {dots}
      <Word text="عَرَفْنَا الآلَة … فَلْنَعْرِفِ المَخَارِج" x={640} y={500} size={50} color={th.gold2} weight={700} delay={1.6} hold={999} />
      <Label text="الدَّرْسُ القَادِم: مَخَارِجُ الحُرُوف" x={640} y={560} size={28} color={th.lgold} delay={2.4} hold={999} />
    </>
  );
}

// ── App ──────────────────────────────────────────────────────────
function App(props) {
  props = props || {};
  const [ready, setReady] = React.useState(!!window.Stage);
  React.useEffect(() => {
    if (ready) return;
    const id = setInterval(() => { if (window.Stage) { clearInterval(id); setReady(true); } }, 30);
    return () => clearInterval(id);
  }, [ready]);
  if (!ready) return null;

  const { Stage, Sprite } = window;
  const themeKey = String(props.theme || "emerald").toLowerCase();
  const theme = THEMES[themeKey] || THEMES.emerald;
  const heroFont = FONTS[String(props.script || "naskh").toLowerCase()] || FONTS.naskh;
  const motif = String(props.motif || "girih").toLowerCase();
  const grade = props.grade != null ? Number(props.grade) : 70;
  const ctx = { ...theme, heroFont, motif, grade };
  const headSrc = React.useMemo(() => buildHeadSVG(theme), [themeKey]);

  return (
    <TH.Provider value={ctx}>
      <Stage width={1280} height={720} duration={42} background={theme.bg} persistKey="u1l2anim">
        <GeoBackground />
        <HeadLayer headSrc={headSrc} />
        <AirflowLayer />
        <Sprite start={0}    end={4.3}>{() => <SceneTitle />}</Sprite>
        <Sprite start={4.2}  end={12.3}>{() => <SceneAir />}</Sprite>
        <Sprite start={12.2} end={30.4}>{() => <SceneTour />}</Sprite>
        <Sprite start={30.3} end={36.3}>{() => <SceneEquation />}</Sprite>
        <Sprite start={36.2} end={42}>{() => <SceneClose />}</Sprite>
      </Stage>
    </TH.Provider>
  );
}

window.App = App;
module.exports = { App };
