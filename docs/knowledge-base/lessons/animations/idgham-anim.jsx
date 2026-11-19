// U6 — Idghām & the Two Meeting Letters — animated Tajweed lesson (Arabic only)
// Mounts inside a DC via <x-import component="App" theme script motif>.
// Uses animations.jsx engine globals (Stage, Sprite, useTime, useSprite, clamp, Easing).

const FONTS = {
  naskh: "'Amiri', serif",
  kufi: "'Reem Kufi', sans-serif",
  scheherazade: "'Scheherazade New', serif",
  ruqaa: "'Aref Ruqaa', serif",
  lateef: "'Lateef', serif",
  cairo: "'Cairo', sans-serif",
};
const AMIRI = FONTS.naskh;
const KUFI  = FONTS.kufi;

const THEMES = {
  manuscript: {
    dark: false,
    bg: "radial-gradient(circle at 50% 40%, #f8efd8 0%, #f1e4c5 58%, #ead9b4 100%)",
    ink: "#173f37", gold: "#b3893f", gold2: "#d8b25e", terra: "#a14a30",
    geoInk: "#173f37", cardFill: "rgba(179,137,63,.10)",
  },
  midnight: {
    dark: true,
    bg: "radial-gradient(circle at 50% 38%, #11403c 0%, #0b2b2a 58%, #06201f 100%)",
    ink: "#f1e7cd", gold: "#e2bd62", gold2: "#f2d488", terra: "#e3935f",
    geoInk: "#7fb3a4", cardFill: "rgba(226,189,98,.09)",
  },
  royal: {
    dark: true,
    bg: "radial-gradient(circle at 50% 40%, #3a2c6e 0%, #281f54 58%, #1c1542 100%)",
    ink: "#f3ead4", gold: "#d8b65c", gold2: "#f0d385", terra: "#dd8fa6",
    geoInk: "#9486c9", cardFill: "rgba(216,182,92,.09)",
  },
};

const TH = React.createContext({ ...THEMES.manuscript, heroFont: AMIRI, motif: "girih" });
const useTH = () => React.useContext(TH);

// ── helpers ──────────────────────────────────────────────────────
function win(lt, a, b, f = 0.45) {
  const c = (window.clamp) || ((v, mn, mx) => Math.max(mn, Math.min(mx, v)));
  if (lt <= a || lt >= b) return 0;
  return c(Math.min((lt - a) / f, (b - lt) / f, 1), 0, 1);
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
  const a = delay;
  const b = hold != null ? hold : duration - 0.05;
  const op = win(localTime, a, b, 0.45);
  const t = window.clamp((localTime - a) / 0.5, 0, 1);
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
      textShadow: glow ? `0 0 ${glow}px ${th.gold2}, 0 0 ${glow * 2}px ${th.gold}88` : "none",
    }}>{text}</div>
  );
}

// ── UI label (always Reem Kufi) ──────────────────────────────────
function Label({ text, x, y, size = 26, color, weight = 500, delay = 0, hold = null, align = "center" }) {
  const th = useTH();
  const { localTime, duration } = window.useSprite();
  color = color || th.gold;
  const b = hold != null ? hold : duration - 0.05;
  const op = win(localTime, delay, b, 0.45);
  const t = window.clamp((localTime - delay) / 0.5, 0, 1);
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

// ── geometric background — motif reshapes the backdrop ───────────
function GeoBackground() {
  const time = window.useTime();
  const th = useTH();
  const rot = time * 4;
  const breath = 1 + 0.025 * Math.sin(time * 0.6);
  const W = 1280, H = 720, cx = W / 2, cy = H / 2;
  const og = th.dark ? 0.18 : 0.10;
  const oi = th.dark ? 0.12 : 0.07;
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
      <rect x="38" y="38" width={W - 76} height={H - 76} fill="none" stroke={th.gold} strokeWidth="2.5" opacity="0.55" />
      <rect x="48" y="48" width={W - 96} height={H - 96} fill="none" stroke={th.gold} strokeWidth="1" opacity="0.45" />
      {[[43, 43], [W - 43, 43], [43, H - 43], [W - 43, H - 43]].map(([x, y], i) => (
        <polygon key={i} points={starPoints(x, y, 16, 7)} fill={th.gold} opacity="0.5" />
      ))}
    </svg>
  );
}

// ── letter card ──────────────────────────────────────────────────
function Card({ x, y, letter, scale = 1, opacity = 1, color, glow = 0, terra = false }) {
  const th = useTH();
  const w = 128 * scale, h = 148 * scale;
  const c = color || (terra ? th.terra : th.ink);
  return (
    <div style={{
      position: "absolute", left: x, top: y, width: w, height: h,
      transform: "translate(-50%,-50%)", opacity,
      borderRadius: 18 * scale, border: `2px solid ${th.gold}`,
      background: th.cardFill,
      boxShadow: glow > 0
        ? `0 0 ${22 * glow}px ${th.gold2}${th.dark ? "aa" : "88"}, inset 0 0 ${14 * glow}px ${th.gold2}55`
        : `inset 0 0 10px ${th.gold}22`,
      display: "flex", alignItems: "center", justifyContent: "center",
      willChange: "transform, opacity",
    }}>
      <span style={{
        fontFamily: th.heroFont, fontSize: 86 * scale, color: c, direction: "rtl",
        lineHeight: 1, paddingBottom: 14 * scale,
        textShadow: glow > 0.4 ? `0 0 14px ${th.gold2}` : "none",
      }}>{letter}</span>
    </div>
  );
}

// ── THE FUSION — two cards merge into one shaddah'd letter ───────
function Fusion({ x = 640, y = 330, right, left, result, start = 0, hold = null, scale = 1, caption = null }) {
  const th = useTH();
  const { localTime, duration } = window.useSprite();
  const end = hold != null ? hold : duration - 0.05;
  const t = localTime - start;
  if (t < 0 || localTime > end) return null;
  const E = window.Easing;
  const fadeOutAll = win(localTime, start, end, 0.35);

  const slideIn = E.easeOutCubic(window.clamp(t / 1.0, 0, 1));      // → ±96
  const merge   = E.easeInOutQuad
    ? E.easeInOutQuad(window.clamp((t - 1.5) / 0.6, 0, 1))
    : E.easeOutCubic(window.clamp((t - 1.5) / 0.6, 0, 1));           // ±96 → 0
  const off = (320 - 224 * slideIn) * (1 - merge) * scale;
  const flare = win(t, 1.7, 2.6, 0.3);
  const fusedP = window.clamp((t - 2.0) / 0.5, 0, 1);
  const fusedS = 0.7 + 0.3 * E.easeOutBack(fusedP);
  const cardsOp = (1 - window.clamp((t - 2.0) / 0.25, 0, 1)) * fadeOutAll;
  const pulse = 1 + 0.05 * Math.sin((t - 2.5) * 3) * (t > 2.5 ? 1 : 0);

  return (
    <>
      {/* flare at the seam */}
      <div style={{
        position: "absolute", left: x, top: y, width: 340 * scale, height: 340 * scale,
        transform: "translate(-50%,-50%)", borderRadius: "50%",
        background: `radial-gradient(circle, ${th.gold2}${th.dark ? "cc" : "99"} 0%, transparent 62%)`,
        opacity: flare * fadeOutAll, pointerEvents: "none",
      }} />
      {cardsOp > 0.01 && <>
        <Card x={x + off} y={y} letter={right} scale={scale} opacity={slideIn * cardsOp} glow={merge} />
        <Card x={x - off} y={y} letter={left} scale={scale} opacity={slideIn * cardsOp} glow={merge} terra />
      </>}
      {fusedP > 0 && (
        <div style={{ position: "absolute", left: x, top: y, transform: `translate(-50%,-50%) scale(${fusedS * pulse})`, opacity: fusedP * fadeOutAll }}>
          <div style={{ position: "relative", left: "50%", top: "50%" }}>
            <Card x={0} y={0} letter={result} scale={scale * 1.12} glow={1} color={th.terra} />
          </div>
        </div>
      )}
      {caption && (
        <Label text={caption} x={x} y={y + 128 * scale} size={26 * scale} delay={start + 2.4} hold={end} />
      )}
    </>
  );
}

// ── THE ANTI-FUSION — cards approach, a barrier keeps them apart ─
function Block({ x = 640, y = 330, right, left, start = 0, hold = null, scale = 1, stamp = "لَا إِدْغَام", stampDy = -128, caption = null }) {
  const th = useTH();
  const { localTime, duration } = window.useSprite();
  const end = hold != null ? hold : duration - 0.05;
  const t = localTime - start;
  if (t < 0 || localTime > end) return null;
  const E = window.Easing;
  const fade = win(localTime, start, end, 0.35);

  const slideIn = E.easeOutCubic(window.clamp(t / 1.0, 0, 1));       // → ±150
  const push = Math.sin(window.clamp((t - 1.3) / 0.8, 0, 1) * Math.PI); // nudge in & bounce back
  const off = (330 - 180 * slideIn - 34 * push) * scale;
  const barrier = win(t, 1.3, end - start, 0.35);
  const stampP = window.clamp((t - 2.1) / 0.45, 0, 1);
  const stampS = 1.6 - 0.6 * E.easeOutCubic(stampP);

  return (
    <>
      <Card x={x + off} y={y} letter={right} scale={scale} opacity={slideIn * fade} />
      <Card x={x - off} y={y} letter={left} scale={scale} opacity={slideIn * fade} terra />
      {/* barrier */}
      <div style={{
        position: "absolute", left: x, top: y, width: 4, height: 170 * scale,
        transform: "translate(-50%,-50%)", borderRadius: 3,
        background: `linear-gradient(180deg, transparent, ${th.gold}, transparent)`,
        boxShadow: `0 0 16px ${th.gold2}`, opacity: barrier * fade,
      }} />
      {stampP > 0 && (
        <div style={{
          position: "absolute", left: x, top: y + stampDy * scale,
          transform: `translate(-50%,-50%) rotate(-7deg) scale(${stampS})`,
          opacity: stampP * fade, fontFamily: KUFI, fontWeight: 700,
          fontSize: 34 * scale, color: th.terra, direction: "rtl", whiteSpace: "nowrap",
          border: `3px solid ${th.terra}`, borderRadius: 10, padding: "4px 18px 8px",
        }}>{stamp}</div>
      )}
      {caption && (
        <Label text={caption} x={x} y={y + 128 * scale} size={26 * scale} delay={start + 2.2} hold={end} />
      )}
    </>
  );
}

// ── scenes ───────────────────────────────────────────────────────
function SceneTitle() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const lineW = window.clamp((localTime - 2.0) / 0.7, 0, 1) * 360;
  return (
    <>
      <Label text="أَحْكَامُ التَّجْوِيد" x={640} y={196} size={28} delay={0.2} />
      <Word text="الإِدْغَام" x={640} y={326} size={112} weight={700} font={KUFI} delay={0.6} scaleIn />
      <div style={{ position: "absolute", left: 640, top: 400, width: lineW, height: 2, marginLeft: -lineW / 2, background: th.gold, opacity: 0.8 }} />
      <Word text="الحَرْفَانِ المُلْتَقِيَان" x={640} y={472} size={54} color={th.terra} weight={700} delay={2.4} />
    </>
  );
}

function SceneDefinition() {
  const th = useTH();
  return (
    <>
      <Label text="لُغَةً: الإِدْخَال — كَإِدْخَالِ السَّيْفِ فِي غِمْدِه" x={640} y={140} size={28} delay={0.3} />
      <Label text="اصْطِلَاحًا: إِدْخَالُ حَرْفٍ سَاكِنٍ فِي مُتَحَرِّكٍ ← حَرْفٌ وَاحِدٌ مُشَدَّد" x={640} y={198} size={26} color={th.ink} weight={600} delay={1.4} />
      <Fusion x={640} y={368} right="بْ" left="بَ" result="بَّ" start={2.6} />
      <Word text="﴿ وَلْيَكْتُب بَّيْنَكُم ﴾" x={640} y={600} size={52} color={th.terra} weight={700} delay={6.6} />
    </>
  );
}

function SceneMithlayn() {
  const th = useTH();
  return (
    <>
      <Word text="١ · الحَرْفَانِ المُتَمَاثِلَان" x={640} y={128} size={44} font={KUFI} weight={700} delay={0.2} />
      <Label text="اتَّفَقَا مَخْرَجًا وَصِفَةً — الحَرْفُ نَفْسُهُ مَرَّتَيْن" x={640} y={196} size={26} delay={1.0} />
      <Fusion x={640} y={356} right="دْ" left="دَ" result="دَّ" start={1.8} scale={0.92} caption="﴿ وَقَد دَّخَلُوا ﴾ — سَكَنَ الأَوَّلُ ← وَجَبَ الإِدْغَام" />
      <Label text="فَإِنْ تَحَرَّكَ الأَوَّلُ أَوْ كَانَ حَرْفَ مَدٍّ ← لَا إِدْغَام" x={640} y={566} size={26} color={th.terra} weight={600} delay={6.4} />
      <Word text="﴿ فِي يَوْمٍ ﴾ · ﴿ يَعْلَمُ مَا ﴾" x={640} y={624} size={36} color={th.terra} delay={7.2} />
    </>
  );
}

function SceneJinsayn() {
  const th = useTH();
  const cases = ["د ← ظ", "د ← ت", "ت ← د", "ت ← ط", "ل ← ر", "ث ← ذ", "ب ← م", "ط ← ت"];
  return (
    <>
      <Word text="٢ · الحَرْفَانِ المُتَجَانِسَان" x={640} y={128} size={44} font={KUFI} weight={700} delay={0.2} />
      <Label text="اتَّفَقَا فِي المَخْرَجِ وَاخْتَلَفَا فِي بَعْضِ الصِّفَات" x={640} y={196} size={26} delay={1.0} />
      <Fusion x={640} y={344} right="دْ" left="تَ" result="تَّ" start={1.8} scale={0.86} caption="﴿ قَد تَّبَيَّنَ ﴾" />
      {cases.map((c, i) => (
        <div key={i}>
          <Label text={c} x={1090 - i * 128} y={532} size={26} color={th.ink} weight={600} delay={5.6 + i * 0.13} />
        </div>
      ))}
      <div style={{ position: "absolute", left: 640, top: 560, width: 0 }} />
      <Label text="ط ← ت: إِدْغَامٌ نَاقِص — يَبْقَى الإِطْبَاق ﴿ أَحَطتُّ ﴾ · ﴿ بَسَطتَ ﴾" x={640} y={618} size={26} color={th.terra} weight={600} delay={7.4} />
    </>
  );
}

function SceneQaribayn() {
  const th = useTH();
  return (
    <>
      <Word text="٣ · الحَرْفَانِ المُتَقَارِبَان" x={640} y={128} size={44} font={KUFI} weight={700} delay={0.2} />
      <Label text="تَقَارَبَا فِي المَخْرَجِ أَوِ الصِّفَةِ — دُونَ تَطَابُق" x={640} y={196} size={26} delay={1.0} />
      <Fusion x={640} y={344} right="قْ" left="كَ" result="كَّ" start={1.8} scale={0.86} caption="﴿ أَلَمْ نَخْلُقكُّم ﴾ · ﴿ وَقُل رَّبِّ ﴾" />
      <Label text="وَالمُخْتَلَفُ فِيهِ: ﴿ فَقَد ضَّلَّ ﴾ · ﴿ كَذَّبَت ثَّمُودُ ﴾" x={640} y={566} size={26} color={th.ink} weight={600} delay={6.2} />
      <Word text="وَحَفْصٌ يُظْهِرُهَا جَمِيعًا" x={640} y={626} size={40} color={th.terra} weight={700} delay={7.2} />
    </>
  );
}

function SceneBa3idayn() {
  const th = useTH();
  return (
    <>
      <Word text="٤ · الحَرْفَانِ المُتَبَاعِدَان" x={640} y={128} size={44} font={KUFI} weight={700} delay={0.2} />
      <Label text="تَبَاعَدَا فِي المَخْرَجِ وَالصِّفَة" x={640} y={196} size={26} delay={1.0} />
      <Block x={640} y={356} right="نْ" left="ءَ" start={1.6} scale={0.92} stampDy={0} stamp="الإِظْهَارُ مُطْلَقًا" caption="﴿ مَنْ ءَامَنَ ﴾ · ﴿ أَنْعَمْتَ عَلَيْهِمْ ﴾" />
    </>
  );
}

function SceneLadder() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const states = ["مُتَمَاثِلَان", "مُتَجَانِسَان", "مُتَقَارِبَان", "مُتَبَاعِدَان"];
  const barW = 840, barX = 640 - barW / 2, barY = 356;
  const barP = window.clamp((localTime - 0.8) / 0.9, 0, 1);
  return (
    <>
      <Label text="الخَرِيطَةُ الكَامِلَة" x={640} y={140} size={30} delay={0.2} />
      <div style={{
        position: "absolute", left: barX, top: barY, width: barW * barP, height: 12,
        borderRadius: 7, background: `linear-gradient(270deg, ${th.gold2}, ${th.gold}, ${th.gold}44)`,
        boxShadow: `0 0 14px ${th.gold2}66`, opacity: win(localTime, 0.7, 99, 0.4),
      }} />
      {states.map((s, i) => {
        const x = barX + barW - (barW / 8) - i * (barW / 4); // RTL: first at right
        return (
          <div key={i}>
            <div style={{
              position: "absolute", left: x, top: barY + 6, width: 14, height: 14,
              transform: "translate(-50%,-50%)", borderRadius: "50%",
              background: th.gold2, boxShadow: `0 0 10px ${th.gold2}`,
              opacity: win(localTime, 1.6 + i * 0.35, 99, 0.3),
            }} />
            <Word text={s} x={x} y={barY - 62} size={38} weight={700} font={KUFI}
                  color={i < 3 ? th.ink : th.terra} delay={1.6 + i * 0.35} scaleIn />
          </div>
        );
      })}
      <Label text="كَامِلُ الانْدِمَاج" x={barX + barW} y={barY + 52} size={24} delay={2.0} align="right" />
      <Label text="كَامِلُ الانْفِصَال" x={barX} y={barY + 52} size={24} delay={2.2} align="left" />
      <Word text="أَشْهَرُ إِدْغَامٍ تَرَاهُ كُلَّ يَوْمٍ… فِي «الْـ»" x={640} y={548} size={42} color={th.terra} weight={700} delay={3.8} />
      <Label text="الدَّرْسُ القَادِم: لَامُ التَّعْرِيف ☾ ☀" x={640} y={620} size={28} delay={4.8} />
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
  const themeKey = String(props.theme || "manuscript").toLowerCase();
  const theme = THEMES[themeKey] || THEMES.manuscript;
  const heroFont = FONTS[String(props.script || "naskh").toLowerCase()] || FONTS.naskh;
  const motif = String(props.motif || "girih").toLowerCase();
  const ctx = { ...theme, heroFont, motif };

  return (
    <TH.Provider value={ctx}>
      <Stage width={1280} height={720} duration={60} background={theme.bg} persistKey="idghamanim">
        <GeoBackground />
        <Sprite start={0}    end={6.4}>{() => <SceneTitle />}</Sprite>
        <Sprite start={6.5}  end={15.4}>{() => <SceneDefinition />}</Sprite>
        <Sprite start={15.5} end={25.4}>{() => <SceneMithlayn />}</Sprite>
        <Sprite start={25.5} end={35.9}>{() => <SceneJinsayn />}</Sprite>
        <Sprite start={36}   end={45.9}>{() => <SceneQaribayn />}</Sprite>
        <Sprite start={46}   end={53.4}>{() => <SceneBa3idayn />}</Sprite>
        <Sprite start={53.5} end={60}>{() => <SceneLadder />}</Sprite>
      </Stage>
    </TH.Provider>
  );
}

window.App = App;
module.exports = { App };
