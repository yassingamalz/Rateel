// U3.L1 — صفات الحروف: الصفات ذات الضدّ (overview)
// Same manuscript engine/style as the Noon Mushaddadah lesson.
// Mounts via <x-import component="App" theme script motif>.
// Engine globals from animations.jsx: Stage, Sprite, useTime, useSprite, clamp, Easing.

const FONTS = { naskh: "'Amiri', serif", kufi: "'Reem Kufi', sans-serif" };
const AMIRI = FONTS.naskh;
const KUFI  = FONTS.kufi;

// ── theme palettes — each reshapes mood across every scene ───────
const THEMES = {
  emerald: { // brief tokens: emerald → near-black, gold, light-green text, light-gold
    dark: true,
    bg: "radial-gradient(circle at 50% 34%, #1f4037 0%, #163129 52%, #0b1c17 100%)",
    ink:  "#f3ead4",  // hero letters (cream)
    gold: "#daa520", gold2: "#ffd700", glow: "#ffe355",
    green: "#95d5b2", lgold: "#dfc298", terra: "#dfc298",
    geoInk: "#5e9b86",
  },
  manuscript: {
    dark: false,
    bg: "radial-gradient(circle at 50% 40%, #f8efd8 0%, #f1e4c5 58%, #ead9b4 100%)",
    ink:  "#173f37",
    gold: "#b3893f", gold2: "#d8b25e", glow: "#d8b25e",
    green: "#3f6f54", lgold: "#a07a36", terra: "#a14a30",
    geoInk: "#173f37",
  },
  royal: {
    dark: true,
    bg: "radial-gradient(circle at 50% 40%, #3a2c6e 0%, #281f54 58%, #1c1542 100%)",
    ink:  "#f3ead4",
    gold: "#d8b65c", gold2: "#f0d385", glow: "#f0d385",
    green: "#9fc7b4", lgold: "#e3cf9a", terra: "#dd8fa6",
    geoInk: "#9486c9",
  },
};

const TH = React.createContext({ ...THEMES.emerald, heroFont: AMIRI, motif: "girih" });
const useTH = () => React.useContext(TH);

// ── helpers ──────────────────────────────────────────────────────
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

// ── arabic word (hero/script) ────────────────────────────────────
function Word({ text, x, y, size = 80, color, font, weight = 400,
                delay = 0, hold = null, scaleIn = false, glow = null, lineHeight = 1.25 }) {
  const th = useTH();
  const { localTime, duration } = window.useSprite();
  color = color || th.ink;
  font = font || th.heroFont;
  const b = hold != null ? hold : duration - 0.05;
  const op = win(localTime, delay, b, 0.45);
  const t = C((localTime - delay) / 0.5, 0, 1);
  const ease = window.Easing.easeOutBack(t);
  const ty = (1 - window.Easing.easeOutCubic(t)) * 18;
  const sc = scaleIn ? (0.6 + 0.4 * ease) : 1;
  return (
    <div style={{
      position: "absolute", left: x, top: y,
      transform: `translate(-50%, calc(-50% + ${ty}px)) scale(${sc})`,
      opacity: op, color, fontFamily: font, fontWeight: weight,
      fontSize: size, lineHeight, direction: "rtl", whiteSpace: "nowrap",
      textAlign: "center", willChange: "transform, opacity",
      textShadow: glow ? `0 0 ${glow}px ${th.glow}, 0 0 ${glow * 2}px ${th.gold}88` : "none",
    }}>{text}</div>
  );
}

// ── UI label (always Reem Kufi) ──────────────────────────────────
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
      position: "absolute", left: x, top: y,
      transform: `translate(${tx}, calc(-50% + ${ty}px))`,
      opacity: op, color, fontFamily: KUFI, fontWeight: weight,
      fontSize: size, direction: "rtl", whiteSpace: "nowrap",
      textAlign: align, willChange: "transform, opacity",
    }}>{text}</div>
  );
}

// ── geometric background — constant through whole video ──────────
function GeoBackground() {
  const time = window.useTime();
  const th = useTH();
  const rot = time * 4;
  const breath = 1 + 0.025 * Math.sin(time * 0.6);
  const W = 1280, H = 720, cx = W / 2, cy = H / 2;
  const og = th.dark ? 0.16 : 0.10;
  const oi = th.dark ? 0.11 : 0.07;
  const motif = th.motif;

  let center = null;
  if (motif === "girih") {
    center = (
      <>
        <g transform={`translate(${cx} ${cy}) rotate(${rot}) scale(${breath}) translate(${-cx} ${-cy})`} opacity={og}>
          <polygon points={starPoints(cx, cy, 300, 138)} fill="none" stroke={th.gold} strokeWidth="2" />
          <polygon points={starPoints(cx, cy, 230, 106)} fill="none" stroke={th.gold} strokeWidth="1.4" />
          <circle cx={cx} cy={cy} r="150" fill="none" stroke={th.gold} strokeWidth="1" />
        </g>
        <g transform={`translate(${cx} ${cy}) rotate(${-rot * 0.6}) translate(${-cx} ${-cy})`} opacity={oi}>
          <polygon points={starPoints(cx, cy, 168, 78)} fill="none" stroke={th.geoInk} strokeWidth="1.4" />
        </g>
      </>
    );
  } else if (motif === "arabesque") {
    const dots = [];
    for (let i = 0; i < 16; i++) {
      const ang = (Math.PI / 8) * i;
      dots.push(<circle key={i} cx={cx + 232 * Math.cos(ang)} cy={cy + 232 * Math.sin(ang)} r="7" fill="none" stroke={th.gold} strokeWidth="1.4" />);
    }
    center = (
      <>
        <g transform={`translate(${cx} ${cy}) scale(${breath}) translate(${-cx} ${-cy})`} opacity={og}>
          {[300, 246, 192, 138].map((r, i) => (
            <circle key={i} cx={cx} cy={cy} r={r} fill="none" stroke={th.gold} strokeWidth={i === 0 ? 2 : 1.2} />
          ))}
        </g>
        <g transform={`translate(${cx} ${cy}) rotate(${rot}) translate(${-cx} ${-cy})`} opacity={og}>{dots}</g>
        <g transform={`translate(${cx} ${cy}) rotate(${-rot * 0.8}) translate(${-cx} ${-cy})`} opacity={oi}>
          <circle cx={cx} cy={cy} r="96" fill="none" stroke={th.geoInk} strokeWidth="1.4" strokeDasharray="3 10" />
        </g>
      </>
    );
  }

  return (
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`} style={{ position: "absolute", inset: 0 }}>
      {center}
      <rect x="38" y="38" width={W - 76} height={H - 76} fill="none" stroke={th.gold} strokeWidth="2.5" opacity="0.5" />
      <rect x="48" y="48" width={W - 96} height={H - 96} fill="none" stroke={th.gold} strokeWidth="1" opacity="0.4" />
      {[[43, 43], [W - 43, 43], [43, H - 43], [W - 43, H - 43]].map(([x, y], i) => (
        <polygon key={i} points={starPoints(x, y, 16, 7)} fill={th.gold} opacity="0.5" />
      ))}
    </svg>
  );
}

function HumWaves({ x, y, t, count = 3, max = 170, color, op0 = 0.5 }) {
  const th = useTH();
  color = color || th.gold;
  const items = [];
  for (let i = 0; i < count; i++) {
    const phase = ((t * 0.55 + i / count) % 1);
    const r = 40 + phase * max;
    const op = (1 - phase) * op0;
    items.push(
      <div key={i} style={{
        position: "absolute", left: x, top: y, width: r * 2, height: r * 2,
        marginLeft: -r, marginTop: -r, borderRadius: "50%",
        border: `2px solid ${color}`, opacity: op,
      }} />
    );
  }
  return <>{items}</>;
}

// ─────────────────────────────────────────────────────────────────
// SCENE 1 — Title
// ─────────────────────────────────────────────────────────────────
function SceneTitle() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const lineW = C((localTime - 1.9) / 0.7, 0, 1) * 380;
  return (
    <>
      <Word text="صِفاتُ الحُروف" x={640} y={300} size={108} color={th.gold2} weight={700}
            font={KUFI} delay={0.5} scaleIn glow={26} />
      <div style={{ position: "absolute", left: 640, top: 372, width: lineW, height: 2, marginLeft: -lineW / 2,
                    background: th.gold, opacity: 0.85, boxShadow: `0 0 10px ${th.glow}` }} />
      <Label text="الجُزْءُ الأَوَّل: الصِّفاتُ ذاتُ الضِّدّ" x={640} y={430} size={34} color={th.lgold} delay={2.3} />
    </>
  );
}

// ─────────────────────────────────────────────────────────────────
// SCENE 2 — Where (makhraj) vs How (sifa)
// ─────────────────────────────────────────────────────────────────
function SceneWhereHow() {
  const th = useTH();
  const { localTime } = window.useSprite();
  // letter pulses once around t=1.0; "ayn" fades a bit after waves start (~3.4)
  const pulse = 1 + 0.08 * Math.max(0, Math.sin((localTime - 0.9) * 5)) * (localTime > 0.8 && localTime < 1.9 ? 1 : 0);
  const aynDim = localTime > 3.6 ? 0.45 : 1;          // "where" recedes
  const wavesOn = localTime > 2.2;
  return (
    <>
      <Label text="المَخْرَجُ وَالصِّفَة" x={640} y={120} size={32} color={th.gold} delay={0.2} />

      {/* sound waves = "how" / the sifa */}
      <div style={{ opacity: wavesOn ? 1 : 0 }}>
        <HumWaves x={640} y={330} t={localTime} count={3} max={150} color={th.gold2} />
      </div>

      {/* hero letter */}
      <div style={{
        position: "absolute", left: 640, top: 330, transform: `translate(-50%,-50%) scale(${pulse})`,
        opacity: win(localTime, 0.3, 999, 0.4), fontFamily: th.heroFont, fontSize: 210, fontWeight: 400,
        color: th.gold2, direction: "rtl", textShadow: `0 0 26px ${th.glow}`,
      }}>بْ</div>

      {/* RIGHT — makhraj / where (light green, recedes) */}
      <div style={{ opacity: aynDim, transition: "none" }}>
        <Label text="المَخْرَج" x={1040} y={262} size={32} color={th.green} weight={600} delay={1.4} hold={999} align="center" />
        <Label text="أَيْنَ؟" x={1040} y={312} size={40} color={th.green} weight={700} delay={1.7} hold={999} align="center" />
      </div>
      <svg width="1280" height="720" style={{ position: "absolute", inset: 0, pointerEvents: "none" }}>
        <line x1="958" y1="312" x2="740" y2="330" stroke={th.green}
              strokeWidth="2" strokeDasharray="4 6" opacity={win(localTime, 1.6, 999, 0.4) * 0.7 * aynDim} />
        <circle cx="740" cy="330" r="5" fill={th.green} opacity={win(localTime, 1.6, 999, 0.4) * 0.8 * aynDim} />
      </svg>

      {/* LEFT — sifa / how (gold, stays highlighted) */}
      <Label text="الصِّفَة" x={240} y={262} size={34} color={th.gold2} weight={700} delay={2.6} hold={999} align="center" />
      <Label text="كَيْفَ؟" x={240} y={314} size={44} color={th.gold2} weight={700} delay={2.9} hold={999} align="center" />
      <Word text="هَذَا دَرْسُنَا" x={240} y={372} size={26} color={th.lgold} font={KUFI} delay={4.4} hold={999} />
    </>
  );
}

// ─────────────────────────────────────────────────────────────────
// SCENE 3 — Two kinds of sifat
// ─────────────────────────────────────────────────────────────────
function SceneTwoTypes() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const node = { x: 640, y: 232 };
  const right = { x: 880, y: 392 };   // لها ضد (today, bright)
  const left  = { x: 400, y: 392 };   // لا ضد لها (later, dim)
  const lenR = Math.hypot(right.x - node.x, right.y - node.y);
  const lenL = Math.hypot(left.x - node.x, left.y - node.y);
  const draw = C((localTime - 1.4) / 0.9, 0, 1);
  const dimDraw = C((localTime - 1.7) / 0.9, 0, 1);
  return (
    <>
      <Word text="الصِّفاتُ نَوْعان" x={640} y={150} size={62} color={th.ink} weight={700} delay={0.3} />

      <svg width="1280" height="720" style={{ position: "absolute", inset: 0, pointerEvents: "none" }}>
        <circle cx={node.x} cy={node.y} r="7" fill={th.gold2}
                opacity={win(localTime, 0.9, 999, 0.4)} />
        <line x1={node.x} y1={node.y} x2={right.x} y2={right.y} stroke={th.gold} strokeWidth="3"
              strokeDasharray={lenR} strokeDashoffset={lenR * (1 - draw)}
              opacity={win(localTime, 1.3, 999, 0.4)} style={{ filter: `drop-shadow(0 0 5px ${th.glow})` }} />
        <line x1={node.x} y1={node.y} x2={left.x} y2={left.y} stroke={th.geoInk} strokeWidth="2"
              strokeDasharray={lenL} strokeDashoffset={lenL * (1 - dimDraw)}
              opacity={win(localTime, 1.6, 999, 0.4) * 0.55} />
      </svg>

      {/* RIGHT branch — today's topic, bright */}
      <Word text="صِفاتٌ لَهَا ضِدّ" x={right.x} y={right.y + 56} size={40} color={th.gold2} weight={700} delay={2.2} hold={999} />
      <Label text="مَوْضُوعُ اليَوْم" x={right.x} y={right.y + 102} size={24} color={th.lgold} delay={2.6} hold={999} />

      {/* LEFT branch — later, dim */}
      <div style={{ opacity: 0.5, filter: "blur(0.4px)" }}>
        <Word text="صِفاتٌ لَا ضِدَّ لَهَا" x={left.x} y={left.y + 56} size={36} color={th.green} weight={600} delay={2.5} hold={999} />
        <Label text="دُرُوسٌ قَادِمَة" x={left.x} y={left.y + 100} size={22} color={th.green} delay={2.9} hold={999} />
      </div>
    </>
  );
}

// ─────────────────────────────────────────────────────────────────
// SCENE 4 — The five opposing pairs (hero)
// ─────────────────────────────────────────────────────────────────
const PAIRS = [
  { r: "الهَمْس", l: "الجَهْر",      m: "جَرَيانُ النَّفَس · انْحِباسُه" },
  { r: "الشِّدَّة", l: "الرَّخاوَة",   m: "انْحِباسُ الصَّوْت · جَرَيانُه" },
  { r: "الاسْتِعْلاء", l: "الاسْتِفال", m: "تَفْخِيم · تَرْقِيق" },
  { r: "الإطْباق", l: "الانْفِتاح",   m: "إطْباقُ اللِّسان · انْفِتاحُه" },
  { r: "الإذْلاق", l: "الإصْمات",     m: "خِفَّةٌ وَسُرْعَة · ثِقَل" },
];

function PairRow({ pair, y, delay }) {
  const th = useTH();
  const { localTime } = window.useSprite();
  const t = C((localTime - delay) / 0.6, 0, 1);
  const e = window.Easing.easeOutBack(t);
  const dx = (1 - e) * 220;
  const arrowPulse = 1 + 0.3 * Math.max(0, Math.sin((localTime - delay - 0.55) * 7)) *
                      (localTime > delay + 0.45 && localTime < delay + 1.0 ? 1 : 0);

  const pill = (text, cx, sign, color, bright) => (
    <div style={{
      position: "absolute", left: cx, top: y,
      transform: `translate(-50%,-50%) translateX(${sign * dx}px)`,
      opacity: C(t, 0, 1),
    }}>
      <div style={{
        fontFamily: th.heroFont, fontSize: 38, fontWeight: 700, color, direction: "rtl",
        whiteSpace: "nowrap", padding: "6px 26px", borderRadius: 12,
        border: `1px solid ${bright ? th.gold2 : th.gold}`,
        background: th.dark ? "rgba(255,236,170,0.06)" : "rgba(23,63,55,0.05)",
        boxShadow: bright ? `0 0 14px ${th.gold}55` : "none",
      }}>{text}</div>
    </div>
  );

  return (
    <>
      {pill(pair.r, 838, +1, th.gold2, true)}
      {pill(pair.l, 442, -1, th.ink, false)}
      <div style={{
        position: "absolute", left: 640, top: y, transform: `translate(-50%,-50%) scale(${arrowPulse})`,
        opacity: C((t - 0.4) / 0.4, 0, 1), color: th.gold, fontFamily: KUFI, fontSize: 38, fontWeight: 700,
        textShadow: `0 0 8px ${th.glow}`,
      }}>⟷</div>
      <div style={{
        position: "absolute", left: 1130, top: y, transform: "translate(-100%,-50%)",
        opacity: C((t - 0.5) / 0.4, 0, 1) * 0.85, color: th.lgold, fontFamily: KUFI, fontSize: 17,
        direction: "rtl", whiteSpace: "nowrap", textAlign: "right",
      }}>{pair.m}</div>
    </>
  );
}

function ScenePairs() {
  const th = useTH();
  return (
    <>
      <Label text="الصِّفاتُ ذاتُ الضِّدّ — خَمْسَةُ أَزْواج" x={640} y={84} size={32} color={th.gold} delay={0.1} />
      {PAIRS.map((p, i) => (
        <PairRow key={i} pair={p} y={186 + i * 100} delay={0.9 + i * 0.55} />
      ))}
    </>
  );
}

// ─────────────────────────────────────────────────────────────────
// SCENE 5 — Close: fingerprint of sifat
// ─────────────────────────────────────────────────────────────────
function SceneClose() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const cx = 640, cy = 318, R = 120;
  const gather = C((localTime - 0.6) / 1.1, 0, 1);
  const eg = window.Easing.easeOutCubic(gather);
  const pulse = 1 + 0.06 * Math.sin(localTime * 2.2);
  const dots = [];
  for (let i = 0; i < 5; i++) {
    const ang = -Math.PI / 2 + (i / 5) * Math.PI * 2;
    const rr = R * eg + 230 * (1 - eg);
    dots.push(
      <div key={i} style={{
        position: "absolute", left: cx + rr * Math.cos(ang), top: cy + rr * Math.sin(ang),
        width: 16, height: 16, marginLeft: -8, marginTop: -8, borderRadius: "50%",
        background: th.gold2, opacity: win(localTime, 0.3, 999, 0.4),
        boxShadow: `0 0 14px ${th.glow}`,
      }} />
    );
  }
  return (
    <>
      {dots}
      <div style={{
        position: "absolute", left: cx, top: cy, transform: `translate(-50%,-50%) scale(${pulse})`,
        opacity: win(localTime, 0.5, 999, 0.4), fontFamily: th.heroFont, fontSize: 150, fontWeight: 400,
        color: th.ink, direction: "rtl", textShadow: `0 0 ${22 * eg}px ${th.glow}`,
      }}>حَرْف</div>
      <Word text="لِكُلِّ حَرْفٍ بَصْمَةٌ مِنَ الصِّفات" x={640} y={508} size={50} color={th.gold2} weight={700} delay={1.8} hold={999} />
      <Label text="الدَّرْسُ القَادِم: الهَمْسُ وَالجَهْر" x={640} y={566} size={28} color={th.lgold} delay={2.6} hold={999} />
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
  const ctx = { ...theme, heroFont, motif };

  return (
    <TH.Provider value={ctx}>
      <Stage width={1280} height={720} duration={38} background={theme.bg} persistKey="sifatanim">
        <GeoBackground />
        <Sprite start={0}    end={4.4}>{() => <SceneTitle />}</Sprite>
        <Sprite start={4.3}  end={11.3}>{() => <SceneWhereHow />}</Sprite>
        <Sprite start={11.2} end={16.4}>{() => <SceneTwoTypes />}</Sprite>
        <Sprite start={16.3} end={32.4}>{() => <ScenePairs />}</Sprite>
        <Sprite start={32.3} end={38}>{() => <SceneClose />}</Sprite>
      </Stage>
    </TH.Provider>
  );
}

window.App = App;
module.exports = { App };
