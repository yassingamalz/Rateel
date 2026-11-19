// U1.L2 — أعضاء النطق (Organs of Articulation) — PHOTO VERSION
// Uses the three supplied emerald/gold illustrations as the real visuals:
//   assets/lips.png       → title backdrop (breath flowing from lips)
//   assets/head.png       → labeled organ-tour centerpiece (anatomical cross-section)
//   assets/head-glow.png  → luminous finale (transparent gold head, breath exiting)
// Engine globals from animations.jsx: Stage, Sprite, useTime, useSprite, clamp, Easing.

const FONTS = { naskh: "'Amiri', serif", kufi: "'Reem Kufi', sans-serif" };
const AMIRI = FONTS.naskh;
const KUFI  = FONTS.kufi;

// fixed emerald stage bg — tuned to blend with head.png's dark-green edges
const BG = "radial-gradient(circle at 50% 36%, #173026 0%, #102219 52%, #08160f 100%)";

// accent palettes recolor the OVERLAY graphics (lines, glows, text) — photos stay fixed
const ACCENTS = {
  gold:  { gold: "#daa520", gold2: "#ffd700", glow: "#ffe355", lgold: "#e3c79a", green: "#95d5b2", ink: "#f6ecd2" },
  amber: { gold: "#e0821e", gold2: "#ffb347", glow: "#ffd089", lgold: "#ecca9c", green: "#a6cf9f", ink: "#fceede" },
  ivory: { gold: "#c2ab78", gold2: "#f3ead4", glow: "#fff6dc", lgold: "#e9dec2", green: "#a9d6bf", ink: "#fbf6e8" },
};

const TH = React.createContext({ ...ACCENTS.gold, heroFont: AMIRI, motif: "girih" });
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

// ── organ anchor points on head.png (full-bleed 1280×720, 16:9 exact) ──
const N = (nx, ny) => [Math.round(nx * 1280), Math.round(ny * 720)];
const ORG = {
  nasal:  N(0.515, 0.175),  // الخيشوم / nasopharynx (top sinus)
  palate: N(0.400, 0.380),  // الحنك الأعلى (roof of mouth)
  teeth:  N(0.378, 0.452),  // الأسنان
  lips:   N(0.292, 0.435),  // الشفتان (front of mouth)
  tongue: N(0.452, 0.560),  // اللسان
  throat: N(0.532, 0.610),  // الحلق (pharynx)
  larynx: N(0.508, 0.785),  // الحنجرة
  lungs:  N(0.500, 0.985),  // الرئتان (below frame)
};

// ── text components ──────────────────────────────────────────────
function Word({ text, x, y, size = 80, color, font, weight = 400, delay = 0, hold = null, scaleIn = false, glow = null, anchor = "center" }) {
  const th = useTH();
  const { localTime, duration } = window.useSprite();
  color = color || th.ink; font = font || th.heroFont;
  const b = hold != null ? hold : duration - 0.05;
  const op = win(localTime, delay, b, 0.45);
  const t = C((localTime - delay) / 0.5, 0, 1);
  const ty = (1 - window.Easing.easeOutCubic(t)) * 18;
  const sc = scaleIn ? (0.6 + 0.4 * window.Easing.easeOutBack(t)) : 1;
  const tx = anchor === "center" ? "-50%" : anchor === "right" ? "-100%" : "0";
  return (
    <div style={{
      position: "absolute", left: x, top: y, transform: `translate(${tx}, calc(-50% + ${ty}px)) scale(${sc})`,
      opacity: op, color, fontFamily: font, fontWeight: weight, fontSize: size, lineHeight: 1.25,
      direction: "rtl", whiteSpace: "nowrap", textAlign: anchor, willChange: "transform, opacity",
      textShadow: glow ? `0 0 ${glow}px ${th.glow}, 0 0 ${glow * 2}px ${th.gold}99, 0 2px 18px #000a` : "0 2px 14px #000a",
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
      textShadow: "0 1px 10px #000b",
    }}>{text}</div>
  );
}

// ── geometric frame (over the photos) ────────────────────────────
function GeoFrame() {
  const time = window.useTime();
  const th = useTH();
  const W = 1280, H = 720;
  const rot = time * 4;
  const breath = 1 + 0.025 * Math.sin(time * 0.6);
  const cx = W / 2, cy = H / 2;
  let medallion = null;
  if (th.motif === "girih") {
    medallion = (
      <g transform={`translate(${cx} ${cy}) rotate(${rot}) scale(${breath}) translate(${-cx} ${-cy})`} opacity="0.06">
        <polygon points={starPoints(cx, cy, 332, 152)} fill="none" stroke={th.gold} strokeWidth="2" />
      </g>
    );
  } else if (th.motif === "arabesque") {
    medallion = (
      <g transform={`translate(${cx} ${cy}) scale(${breath}) translate(${-cx} ${-cy})`} opacity="0.06">
        {[330, 262, 194].map((r, i) => <circle key={i} cx={cx} cy={cy} r={r} fill="none" stroke={th.gold} strokeWidth={i === 0 ? 2 : 1.2} />)}
      </g>
    );
  }
  return (
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`} style={{ position: "absolute", inset: 0, pointerEvents: "none" }}>
      {medallion}
      <rect x="38" y="38" width={W - 76} height={H - 76} fill="none" stroke={th.gold} strokeWidth="2.5" opacity="0.5" />
      <rect x="48" y="48" width={W - 96} height={H - 96} fill="none" stroke={th.gold} strokeWidth="1" opacity="0.4" />
      {[[43, 43], [W - 43, 43], [43, H - 43], [W - 43, H - 43]].map(([x, y], i) => <polygon key={i} points={starPoints(x, y, 16, 7)} fill={th.gold} opacity="0.55" />)}
    </svg>
  );
}

// ── photo layers (cross-fade + subtle ken-burns) ─────────────────
function ImageLayer() {
  const t = window.useTime();
  const layer = (src, op, scale, ox = "50%", oy = "50%", extra = {}) => (
    op <= 0.001 ? null : (
      <img src={src} alt="" style={{
        position: "absolute", inset: 0, width: "100%", height: "100%",
        objectFit: "cover", objectPosition: `${ox} ${oy}`, opacity: op,
        transform: `scale(${scale})`, transformOrigin: "50% 45%",
        willChange: "transform, opacity", ...extra,
      }} />
    )
  );
  // lips (title): 0 → 5.0
  let lipsOp = 0;
  if (t < 4.4) lipsOp = 0.9;
  else if (t < 5.2) lipsOp = 0.9 * (1 - C((t - 4.4) / 0.8, 0, 1));
  const lipsSc = 1.06 + 0.05 * C(t / 5, 0, 1);
  // head (airflow+tour+equation): 4.2 → 36.4
  let headOp = 0;
  if (t > 4.2 && t < 5.2) headOp = C((t - 4.2) / 1.0, 0, 1);
  else if (t >= 5.2 && t < 35.4) headOp = 1;
  else if (t >= 35.4 && t < 36.4) headOp = 1 - C((t - 35.4) / 1.0, 0, 1);
  const headSc = 1.06 - 0.05 * C((t - 4.2) / 32, 0, 1);
  // glow head (close): 35.6 → end
  let glowOp = 0;
  if (t > 35.6 && t < 36.6) glowOp = C((t - 35.6) / 1.0, 0, 1);
  else if (t >= 36.6) glowOp = 1;
  const glowSc = 1.0 + 0.05 * C((t - 35.6) / 6, 0, 1);

  return (
    <div style={{ position: "absolute", inset: 0 }}>
      {layer("assets/lips.jpg", lipsOp, lipsSc, "55%", "50%")}
      {layer("assets/head.jpg", headOp, headSc, "50%", "50%")}
      {layer("assets/head-glow-sm.png", glowOp, glowSc, "50%", "46%")}
      {/* vignette for text legibility */}
      <div style={{ position: "absolute", inset: 0, pointerEvents: "none",
        background: "radial-gradient(120% 90% at 50% 42%, transparent 52%, #08160fcc 100%)" }} />
    </div>
  );
}

// ── airflow thread on head.png ───────────────────────────────────
const AF = [ORG.lungs, ORG.larynx, ORG.throat, N(0.515, 0.40), N(0.46, 0.36), ORG.teeth, ORG.lips, N(0.17, 0.45)];
function polyLen(pts) { let L = 0; const seg = [0]; for (let i = 1; i < pts.length; i++) { L += Math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1]); seg.push(L); } return { L, seg }; }
function pointAt(pts, frac) {
  const { L, seg } = polyLen(pts); const d = frac * L;
  for (let i = 1; i < pts.length; i++) { if (d <= seg[i]) { const tt = (d - seg[i - 1]) / (seg[i] - seg[i - 1] || 1); return [pts[i - 1][0] + (pts[i][0] - pts[i - 1][0]) * tt, pts[i - 1][1] + (pts[i][1] - pts[i - 1][1]) * tt]; } }
  return pts[pts.length - 1];
}
function AirflowLayer() {
  const th = useTH();
  const t = window.useTime();
  const { L } = polyLen(AF);
  const draw = C((t - 4.9) / 4.2, 0, 1);
  let op = 0;
  if (t > 4.8 && t < 12.3) op = 1;
  else if (t >= 12.3 && t < 35.4) op = 0.42;
  else if (t >= 35.4) op = 0;
  if (op <= 0) return null;
  const d = "M" + AF.map((p) => p.join(",")).join(" L");
  const head = pointAt(AF, draw);
  const showHead = t > 4.9 && t < 9.4;
  return (
    <svg width="1280" height="720" style={{ position: "absolute", inset: 0, pointerEvents: "none", opacity: op }}>
      <path d={d} fill="none" stroke={th.gold} strokeWidth="6" strokeLinecap="round" strokeLinejoin="round"
        strokeDasharray={L} strokeDashoffset={L * (1 - draw)} opacity="0.4" style={{ filter: `drop-shadow(0 0 7px ${th.glow})` }} />
      <path d={d} fill="none" stroke={th.glow} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"
        strokeDasharray={L} strokeDashoffset={L * (1 - draw)} />
      {showHead && <circle cx={head[0]} cy={head[1]} r="9" fill="#fff" style={{ filter: `drop-shadow(0 0 12px ${th.glow})` }} />}
    </svg>
  );
}

// ─────────────────────────────────────────────────────────────────
// SCENE 1 — Title (over lips.png)
function SceneTitle() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const lineW = C((localTime - 1.9) / 0.7, 0, 1) * 380;
  return (
    <>
      <Word text="أَعْضَاءُ النُّطْق" x={640} y={300} size={110} color={th.gold2} weight={700} font={KUFI} delay={0.5} scaleIn glow={30} />
      <div style={{ position: "absolute", left: 640, top: 376, width: lineW, height: 2, marginLeft: -lineW / 2, background: th.gold, opacity: 0.9, boxShadow: `0 0 12px ${th.glow}` }} />
      <Label text="كَيْفَ تَتَكَوَّنُ الحُرُوف؟" x={640} y={436} size={34} color={th.lgold} delay={2.2} />
    </>
  );
}

// SCENE 2 — Airflow (over head.png)
function SceneAir() {
  const th = useTH();
  return (
    <>
      <Label text="مَسَارُ الهَوَاء" x={640} y={92} size={32} color={th.gold2} delay={0.2} />
      <Label text="الرِّئَتَان" x={ORG.lungs[0] + 150} y={690} size={26} color={th.green} weight={600} delay={0.9} align="left" />
      <Label text="يَخْرُجُ مِنَ الفَم" x={150} y={300} size={28} color={th.gold2} weight={600} delay={5.4} align="center" />
      <Word text="هَوَاءٌ يَصْعَدُ مِنَ الرِّئَتَيْن فَتُشَكِّلُهُ الأَعْضَاء" x={640} y={662} size={30} color={th.lgold} font={KUFI} delay={2.4} />
    </>
  );
}

// SCENE 3 — Organ tour (over head.png)
const ORGANS = [
  { key: "lips",   name: "الشَّفَتَان",       sub: "البَاءُ وَالمِيمُ وَالوَاو",      lx: 150,  ly: 250, align: "center" },
  { key: "teeth",  name: "الأَسْنَان",        sub: "تَشْتَرِكُ فِي عِدَّةِ حُرُوف",   lx: 150,  ly: 410, align: "center" },
  { key: "tongue", name: "اللِّسَان",          sub: "أَهَمُّ الأَعْضَاء",             lx: 175,  ly: 560, align: "center" },
  { key: "palate", name: "الحَنَكُ الأَعْلَى", sub: "اللَّهَاةُ وَالغَارُ وَاللِّثَة", lx: 360,  ly: 110, align: "center" },
  { key: "nasal",  name: "الخَيْشُوم",         sub: "مَخْرَجُ الغُنَّة",              lx: 720,  ly: 92,  align: "center" },
  { key: "throat", name: "الحَلْق",            sub: "أَقْصَى · وَسَط · أَدْنَى",      lx: 1130, ly: 360, align: "right" },
  { key: "larynx", name: "الحَنْجَرَة",        sub: "فِيهَا الأَوْتَارُ الصَّوْتِيَّة", lx: 1130, ly: 560, align: "right" },
];
const STAG = 2.35;
function OrganLabel({ org, idx }) {
  const th = useTH();
  const { localTime } = window.useSprite();
  const t0 = 0.7 + idx * STAG;
  const appeared = localTime > t0;
  const isNew = localTime < t0 + STAG;
  const op = appeared ? (isNew ? 1 : 0.42) : 0;
  const e = window.Easing.easeOutCubic(C((localTime - t0) / 0.5, 0, 1));
  const [ox, oy] = ORG[org.key];
  const ax = org.lx, ay = org.ly;
  const glowA = appeared ? (isNew ? 1 : 0.3) : 0;
  const pulse = isNew ? (1 + 0.3 * Math.max(0, Math.sin((localTime - t0 - 0.3) * 5)) * (localTime < t0 + 1 ? 1 : 0)) : 1;
  const tx = org.align === "right" ? "-100%" : org.align === "left" ? "0" : "-50%";
  return (
    <>
      {/* organ glow on the photo */}
      <div style={{ position: "absolute", left: ox, top: oy, width: 130, height: 130, marginLeft: -65, marginTop: -65,
        borderRadius: "50%", background: `radial-gradient(circle, ${th.glow}d9 0%, ${th.gold}55 38%, transparent 70%)`,
        opacity: glowA * e, transform: `scale(${pulse})`, mixBlendMode: "screen", pointerEvents: "none" }} />
      <svg width="1280" height="720" style={{ position: "absolute", inset: 0, pointerEvents: "none", opacity: op * e }}>
        <line x1={ox} y1={oy} x2={ax} y2={ay} stroke={th.gold2} strokeWidth="1.8" strokeDasharray="3 5" opacity="0.9"
          style={{ filter: `drop-shadow(0 0 3px ${th.glow})` }} />
        <circle cx={ox} cy={oy} r="5.5" fill="#fff" style={{ filter: `drop-shadow(0 0 7px ${th.glow})` }} />
        <circle cx={ax} cy={ay} r="3" fill={th.gold2} />
      </svg>
      <div style={{ position: "absolute", left: ax, top: ay - 4, transform: `translate(${tx}, -100%)`,
        opacity: op * e, direction: "rtl", textAlign: org.align, whiteSpace: "nowrap", willChange: "opacity" }}>
        <div style={{ fontFamily: th.heroFont, fontSize: 40, fontWeight: 700, color: th.gold2, textShadow: `0 0 12px ${th.glow}88, 0 2px 12px #000b` }}>{org.name}</div>
        <div style={{ fontFamily: KUFI, fontSize: 18, color: th.lgold, marginTop: 2, textShadow: "0 1px 8px #000c" }}>{org.sub}</div>
      </div>
    </>
  );
}
function SceneTour() {
  const th = useTH();
  return (
    <>
      <Label text="جَوْلَةُ الأَعْضَاء" x={640} y={60} size={28} color={th.gold} delay={0.1} hold={999} opacityMul={0.85} />
      {ORGANS.map((o, i) => <OrganLabel key={o.key} org={o} idx={i} />)}
    </>
  );
}

// SCENE 4 — Air + organ = letter (over head.png, letter emerges from mouth)
function SceneEquation() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const grow = C((localTime - 2.2) / 0.7, 0, 1);
  const fly = window.Easing.easeInOutCubic(C((localTime - 3.4) / 1.1, 0, 1));
  const [lx, ly] = ORG.lips;
  const mx = lx + (640 - lx) * fly, my = ly + (392 - ly) * fly;
  const msize = 64 + 120 * grow + 36 * fly;
  return (
    <>
      <Label text="هَوَاء" x={500} y={140} size={44} color={th.green} weight={700} delay={0.2} hold={999} />
      <div style={{ position: "absolute", left: 640, top: 140, transform: "translate(-50%,-50%)", color: th.gold, fontFamily: KUFI, fontSize: 42, opacity: win(localTime, 0.5, 999, 0.4), textShadow: "0 1px 10px #000" }}>+</div>
      <Label text="عُضْو" x={780} y={140} size={44} color={th.gold2} weight={700} delay={0.6} hold={999} />
      <div style={{ position: "absolute", left: 640, top: 210, transform: "translate(-50%,-50%)", color: th.gold, fontFamily: KUFI, fontSize: 42, opacity: win(localTime, 1.4, 999, 0.4), textShadow: "0 1px 10px #000" }}>=</div>
      <div style={{ position: "absolute", left: mx, top: my, transform: "translate(-50%,-50%)", color: th.gold2,
        fontFamily: th.heroFont, fontSize: msize, fontWeight: 700, opacity: win(localTime, 2.2, 999, 0.4),
        textShadow: `0 0 ${20 + 16 * fly}px ${th.glow}, 0 0 ${40 * fly}px ${th.gold}, 0 2px 18px #000` }}>مْ</div>
      <Word text="هَوَاءٌ يَمُرّ … وَعُضْوٌ يُشَكِّلُهُ … فَيَنْتُجُ حَرْف" x={640} y={636} size={30} color={th.lgold} font={KUFI} delay={4.6} />
    </>
  );
}

// SCENE 5 — Close (over head-glow.png)
function SceneClose() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const cx = 640, cy = 300;
  const gather = window.Easing.easeOutCubic(C((localTime - 0.5) / 1.2, 0, 1));
  const seeds = [[300, 180], [980, 200], [1040, 470], [620, 560], [220, 470], [180, 250], [760, 120]];
  const dots = seeds.map(([sx, sy], i) => {
    const ang = -Math.PI / 2 + (i / seeds.length) * Math.PI * 2;
    const R = 132;
    const tx = cx + R * Math.cos(ang), ty = cy + R * Math.sin(ang);
    const x = sx + (tx - sx) * gather, y = sy + (ty - sy) * gather;
    return <div key={i} style={{ position: "absolute", left: x, top: y, width: 15, height: 15, marginLeft: -7.5, marginTop: -7.5, borderRadius: "50%", background: "#fff", opacity: win(localTime, 0.3, 999, 0.4), boxShadow: `0 0 14px ${th.glow}, 0 0 26px ${th.gold}` }} />;
  });
  return (
    <>
      {dots}
      <Word text="عَرَفْنَا الآلَة … فَلْنَعْرِفِ المَخَارِج" x={640} y={500} size={50} color={th.gold2} weight={700} delay={1.6} hold={999} glow={20} />
      <Label text="الدَّرْسُ القَادِم: مَخَارِجُ الحُرُوف" x={640} y={562} size={28} color={th.lgold} delay={2.4} hold={999} />
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
  const accent = ACCENTS[String(props.accent || "gold").toLowerCase()] || ACCENTS.gold;
  const heroFont = FONTS[String(props.script || "naskh").toLowerCase()] || FONTS.naskh;
  const motif = String(props.motif || "girih").toLowerCase();
  const ctx = { ...accent, heroFont, motif };

  return (
    <TH.Provider value={ctx}>
      <Stage width={1280} height={720} duration={42} background={BG} persistKey="u1l2photo">
        <ImageLayer />
        <AirflowLayer />
        <GeoFrame />
        <Sprite start={0}    end={4.3}>{() => <SceneTitle />}</Sprite>
        <Sprite start={4.2}  end={12.3}>{() => <SceneAir />}</Sprite>
        <Sprite start={12.2} end={30.4}>{() => <SceneTour />}</Sprite>
        <Sprite start={30.3} end={35.5}>{() => <SceneEquation />}</Sprite>
        <Sprite start={35.6} end={42}>{() => <SceneClose />}</Sprite>
      </Stage>
    </TH.Provider>
  );
}

window.App = App;
module.exports = { App };
