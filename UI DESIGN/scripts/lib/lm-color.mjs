// OKLab/OKLCH helpers for LaunchMotion themes. No dependencies.

export function parseColor(str) {
  str = str.trim();
  let m = str.match(/^#([0-9a-f]{3,8})$/i);
  if (m) {
    let h = m[1];
    if (h.length === 3 || h.length === 4) h = [...h].map((c) => c + c).join('');
    if (h.length !== 6 && h.length !== 8) return null;
    const n = (i) => parseInt(h.slice(i, i + 2), 16);
    return { r: n(0), g: n(2), b: n(4), a: h.length === 8 ? n(6) / 255 : 1 };
  }
  m = str.match(/^rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+%?)\s*)?\)$/i);
  if (m) {
    const a = m[4] === undefined ? 1 : m[4].endsWith('%') ? parseFloat(m[4]) / 100 : parseFloat(m[4]);
    return { r: +m[1], g: +m[2], b: +m[3], a };
  }
  return null;
}

const toLin = (c) => { c /= 255; return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4; };
const fromLin = (c) => 255 * (c <= 0.0031308 ? 12.92 * c : 1.055 * c ** (1 / 2.4) - 0.055);

export function rgbToOklab({ r, g, b }) {
  const [R, G, B] = [toLin(r), toLin(g), toLin(b)];
  const l = Math.cbrt(0.4122214708 * R + 0.5363325363 * G + 0.0514459929 * B);
  const m = Math.cbrt(0.2119034982 * R + 0.6806995451 * G + 0.1073969566 * B);
  const s = Math.cbrt(0.0883024619 * R + 0.2817188376 * G + 0.6299787005 * B);
  return {
    L: 0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s,
    a: 1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s,
    b: 0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s,
  };
}

export function oklabToRgb({ L, a, b }) {
  const l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3;
  const m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3;
  const s = (L - 0.0894841775 * a - 1.291485548 * b) ** 3;
  return {
    r: fromLin(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s),
    g: fromLin(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s),
    b: fromLin(-0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s),
  };
}

export const toLch = ({ L, a, b }) => ({ L, C: Math.hypot(a, b), H: ((Math.atan2(b, a) * 180) / Math.PI + 360) % 360 });
export const fromLch = ({ L, C, H }) => ({ L, a: C * Math.cos((H * Math.PI) / 180), b: C * Math.sin((H * Math.PI) / 180) });

const inGamut = ({ r, g, b }) => [r, g, b].every((v) => v >= -0.5 && v <= 255.5);

/** Largest chroma that stays in sRGB at this lightness and hue. */
export function maxChroma(L, H) {
  let lo = 0, hi = 0.4;
  for (let i = 0; i < 24; i += 1) {
    const mid = (lo + hi) / 2;
    if (inGamut(oklabToRgb(fromLch({ L, C: mid, H })))) lo = mid; else hi = mid;
  }
  return lo;
}

export function format({ r, g, b }, a = 1) {
  const c = (v) => Math.max(0, Math.min(255, Math.round(v)));
  if (a >= 0.999) return '#' + [r, g, b].map((v) => c(v).toString(16).padStart(2, '0')).join('').toUpperCase();
  return `rgba(${c(r)},${c(g)},${c(b)},${+a.toFixed(3)})`;
}

export const mixLab = (p, q, t) => ({ L: p.L + (q.L - p.L) * t, a: p.a + (q.a - p.a) * t, b: p.b + (q.b - p.b) * t });

export function luminance({ r, g, b }) {
  const [R, G, B] = [toLin(r), toLin(g), toLin(b)];
  return 0.2126 * R + 0.7152 * G + 0.0722 * B;
}
