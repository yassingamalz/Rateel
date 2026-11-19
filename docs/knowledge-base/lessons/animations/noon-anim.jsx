// Noon Mushaddadah / Ghunnah — animated Tajweed lesson (Arabic only)
// Mounts inside a DC via <x-import component="App" theme script motif>.
// Uses animations.jsx engine globals (Stage, Sprite, useTime, useSprite, clamp).

const FONTS = { naskh: "'Amiri', serif", kufi: "'Reem Kufi', sans-serif" };
const AMIRI = FONTS.naskh;
const KUFI  = FONTS.kufi;

// ── theme palettes — each reshapes mood across every scene ───────
const THEMES = {
  manuscript: {
    dark: false,
    bg: "radial-gradient(circle at 50% 40%, #f8efd8 0%, #f1e4c5 58%, #ead9b4 100%)",
    ink: "#173f37", gold: "#b3893f", gold2: "#d8b25e", terra: "#a14a30",
    geoInk: "#173f37",
  },
  midnight: {
    dark: true,
    bg: "radial-gradient(circle at 50% 38%, #11403c 0%, #0b2b2a 58%, #06201f 100%)",
    ink: "#f1e7cd", gold: "#e2bd62", gold2: "#f2d488", terra: "#e3935f",
    geoInk: "#7fb3a4",
  },
  royal: {
    dark: true,
    bg: "radial-gradient(circle at 50% 40%, #3a2c6e 0%, #281f54 58%, #1c1542 100%)",
    ink: "#f3ead4", gold: "#d8b65c", gold2: "#f0d385", terra: "#dd8fa6",
    geoInk: "#9486c9",
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
  const og = th.dark ? 0.18 : 0.10;   // star opacity
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
  // motif === "minimal" → no center medallion

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

function HumWaves({ x, y, t, count = 3, max = 170, color }) {
  const th = useTH();
  color = color || th.gold;
  const items = [];
  for (let i = 0; i < count; i++) {
    const phase = ((t * 0.6 + i / count) % 1);
    const r = 40 + phase * max;
    const op = (1 - phase) * 0.5;
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

// ── scenes ───────────────────────────────────────────────────────
function SceneTitle() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const lineW = window.clamp((localTime - 2.0) / 0.7, 0, 1) * 360;
  return (
    <>
      <Label text="أَحْكَامُ التَّجْوِيد" x={640} y={196} size={28} delay={0.2} />
      <Word text="النُّونُ المُشَدَّدَة" x={640} y={326} size={104} weight={700} font={KUFI} delay={0.6} scaleIn />
      <div style={{ position: "absolute", left: 640, top: 398, width: lineW, height: 2, marginLeft: -lineW / 2, background: th.gold, opacity: 0.8 }} />
      <Word text="بَابُ الغُنَّة" x={640} y={470} size={56} color={th.terra} weight={700} delay={2.4} />
    </>
  );
}

function SceneShaddah() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const shaddaPulse = 1 + 0.25 * Math.max(0, Math.sin((localTime - 1.6) * 4)) * (localTime > 1.4 && localTime < 3 ? 1 : 0);
  return (
    <>
      <Label text="مَا الشَّدَّة؟" x={640} y={150} size={32} delay={0.2} hold={4.0} />
      <Word text="ن" x={640} y={350} size={200} delay={0.4} hold={4.0} />
      <div style={{
        position: "absolute", left: 640, top: 350,
        transform: `translate(-50%,-50%) scale(${shaddaPulse})`,
        opacity: win(localTime, 1.5, 4.0, 0.4), fontFamily: th.heroFont, fontSize: 200,
        color: th.ink, direction: "rtl", textShadow: `0 0 18px ${th.gold2}`,
      }}>نّ</div>
      <Label text="الشَّدَّة" x={760} y={232} size={30} color={th.terra} delay={2.0} hold={4.0} />

      <Label text="الشَّدَّةُ حَرْفَان" x={640} y={158} size={32} delay={4.4} />
      <Word text="نْ" x={832} y={356} size={168} delay={4.7} />
      <Label text="نُونٌ سَاكِنَة" x={832} y={490} size={30} color={th.ink} weight={600} delay={5.1} />
      <Word text="+" x={640} y={350} size={84} color={th.gold} font={KUFI} delay={5.0} />
      <Word text="نَ" x={448} y={356} size={168} color={th.terra} delay={4.9} />
      <Label text="نُونٌ مُتَحَرِّكَة" x={448} y={490} size={30} color={th.terra} weight={600} delay={5.3} />
      <Label text="سَاكِنٌ  ثُمَّ  مُتَحَرِّك" x={640} y={584} size={28} delay={5.8} />
    </>
  );
}

function SceneRule() {
  const th = useTH();
  const { localTime } = window.useSprite();
  return (
    <>
      <HumWaves x={640} y={300} t={localTime} count={3} max={150} />
      <div style={{ opacity: win(localTime, 0.3, 9.0, 0.5) }}>
        <Word text="نّ" x={640} y={300} size={170} delay={0.3} glow={20} />
      </div>
      <Label text="الغُنَّة: صَوْتٌ يَخْرُجُ مِنَ الخَيْشُوم" x={640} y={452} size={28} delay={1.4} />
      <Word text="تَجِبُ الغُنَّة" x={640} y={534} size={60} weight={700} delay={3.0} hold={9.2} />
      <Word text="بِمِقْدَارِ حَرَكَتَيْن" x={640} y={596} size={48} color={th.terra} weight={700} delay={4.6} />
    </>
  );
}

function SceneCount() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const cStart = 2.0, cEnd = 6.0;
  const p = window.clamp((localTime - cStart) / (cEnd - cStart), 0, 1);
  const beat = p < 0.5 ? "١" : "٢";
  const beatPulse = 1 + 0.18 * Math.abs(Math.sin(p * Math.PI * 2));
  const trackW = 520;
  return (
    <>
      <Label text="كَلِمَة:  الجَنَّة" x={640} y={152} size={32} delay={0.2} />
      <div style={{ opacity: localTime > cStart && localTime < cEnd ? 1 : 0 }}>
        <HumWaves x={640} y={300} t={localTime} count={3} max={130} color={th.gold2} />
      </div>
      <Word text="نّ" x={640} y={300} size={200} delay={0.5} glow={localTime > cStart ? 24 : 0} />
      <div style={{
        position: "absolute", left: 1010, top: 300,
        transform: `translate(-50%,-50%) scale(${beatPulse})`,
        opacity: localTime > cStart - 0.1 && localTime < cEnd + 0.3 ? 1 : 0,
        fontFamily: th.heroFont, fontSize: 150, fontWeight: 700, color: th.terra, direction: "rtl",
      }}>{beat}</div>
      <Label text="عُدَّ:" x={1010} y={196} size={28} delay={cStart - 0.1} hold={cEnd + 0.3} />
      <div style={{
        position: "absolute", left: 640 - trackW / 2, top: 470, width: trackW, height: 16,
        background: th.dark ? "rgba(255,255,255,.10)" : "rgba(23,63,55,.12)", borderRadius: 9,
        border: `1px solid ${th.gold}`, opacity: win(localTime, 1.4, 9.4, 0.4), overflow: "hidden",
      }}>
        <div style={{ width: `${p * 100}%`, height: "100%", background: `linear-gradient(90deg, ${th.gold}, ${th.gold2})`, borderRadius: 9 }} />
      </div>
      <div style={{
        position: "absolute", left: 640, top: 462, width: 2, height: 32, marginLeft: -1,
        background: th.ink, opacity: win(localTime, 1.4, 9.4, 0.4) * 0.4,
      }} />
      <Label text="غُنَّة بِمِقْدَارِ حَرَكَتَيْن" x={640} y={552} size={42} color={th.ink} weight={600} delay={1.7} />
    </>
  );
}

function SceneRecap() {
  const th = useTH();
  const { localTime } = window.useSprite();
  const lw = win(localTime, 1.8, 5, 0.6) * 520;
  return (
    <>
      <Label text="أَمْثِلَة" x={640} y={150} size={32} delay={0.1} />
      <Word text="إِنَّ"    x={968} y={310} size={96} delay={0.5} />
      <Word text="الجَنَّة" x={640} y={310} size={96} delay={0.9} />
      <Word text="النَّاس"  x={312} y={310} size={96} delay={1.3} />
      <div style={{ position: "absolute", left: 640, top: 410, width: lw, marginLeft: -lw / 2, height: 2, background: th.gold, opacity: 0.7 }} />
      <Word text="نّ  ←  غُنَّة  ←  حَرَكَتَان" x={640} y={500} size={56} color={th.terra} weight={700} delay={2.2} />
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
      <Stage width={1280} height={720} duration={40} background={theme.bg} persistKey="noonanim">
        <GeoBackground />
        <Sprite start={0}    end={6.4}>{() => <SceneTitle />}</Sprite>
        <Sprite start={6.5}  end={16.2}>{() => <SceneShaddah />}</Sprite>
        <Sprite start={16.3} end={25.6}>{() => <SceneRule />}</Sprite>
        <Sprite start={25.7} end={35.2}>{() => <SceneCount />}</Sprite>
        <Sprite start={35.3} end={40}>{() => <SceneRecap />}</Sprite>
      </Stage>
    </TH.Provider>
  );
}

window.App = App;
module.exports = { App };
