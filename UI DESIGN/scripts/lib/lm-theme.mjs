// LaunchMotion theme engine: display font, color theme and glass materials for one scene.
// applyTheme(html, options) returns the themed HTML; it never touches timings.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { format, fromLch, luminance, maxChroma, mixLab, oklabToRgb, parseColor, rgbToOklab, toLch } from './lm-color.mjs';
function hslHue(hex) { const c = parseColor(hex); const r = c.r / 255, g = c.g / 255, b = c.b / 255; const mx = Math.max(r, g, b), mn = Math.min(r, g, b), d = mx - mn; if (!d) return 0; const h = mx === r ? ((g - b) / d) % 6 : mx === g ? (b - r) / d + 2 : (r - g) / d + 4; return (h * 60 + 360) % 360; }

// Same math as the CSS filters Chrome applies in sRGB: hue-rotate(deg) saturate(1.05), or grayscale(1) contrast(1.06).
function filterHex(hex, mono, deg) {
  const c = parseColor(hex); let [r, g, b] = [c.r / 255, c.g / 255, c.b / 255];
  const mul = (m) => [m[0] * r + m[1] * g + m[2] * b, m[3] * r + m[4] * g + m[5] * b, m[6] * r + m[7] * g + m[8] * b];
  if (mono) {
    const y = 0.2126 * r + 0.7152 * g + 0.0722 * b; [r, g, b] = [y, y, y].map((v) => (v - 0.5) * 1.06 + 0.5);
  } else {
    const a = (deg * Math.PI) / 180, cs = Math.cos(a), sn = Math.sin(a);
    [r, g, b] = mul([0.213 + cs * 0.787 - sn * 0.213, 0.715 - cs * 0.715 - sn * 0.715, 0.072 - cs * 0.072 + sn * 0.928,
      0.213 - cs * 0.213 + sn * 0.143, 0.715 + cs * 0.285 + sn * 0.140, 0.072 - cs * 0.072 - sn * 0.283,
      0.213 - cs * 0.213 - sn * 0.787, 0.715 - cs * 0.715 + sn * 0.715, 0.072 + cs * 0.928 + sn * 0.072]).map((v) => Math.min(1, Math.max(0, v)));
    const s = 1.05;
    [r, g, b] = mul([0.213 + 0.787 * s, 0.715 - 0.715 * s, 0.072 - 0.072 * s, 0.213 - 0.213 * s, 0.715 + 0.285 * s, 0.072 - 0.072 * s, 0.213 - 0.213 * s, 0.715 - 0.715 * s, 0.072 + 0.928 * s]);
  }
  return format({ r: Math.min(1, Math.max(0, r)) * 255, g: Math.min(1, Math.max(0, g)) * 255, b: Math.min(1, Math.max(0, b)) * 255 }, c.a);
}

const HERE = path.dirname(fileURLToPath(import.meta.url));
export const THEMES = JSON.parse(fs.readFileSync(path.join(HERE, 'lm-themes.json'), 'utf8'));
export const THEME_NAMES = Object.keys(THEMES.themes);
const DISPLAY_MIN_PX = 32;

export const FONTS = {
  smiley: { family: 'Smiley Sans', file: 'smiley-sans.woff2', relax: true },
  inter: { family: null, file: null, relax: false },
};

/** Build a light/dark theme from one brand color (hex). */
export function customTheme(hex) {
  const c = parseColor(hex);
  if (!c) throw new Error(`Not a color: ${hex}`);
  const lab = rgbToOklab(c);
  const { L, C } = toLch(lab);
  if (C < 0.03) {
    // a neutral brand color behaves like the black-and-white theme
    return L < 0.5 ? THEMES.themes.mono : { ...THEMES.themes.mono, light: { ...THEMES.themes.mono.light, ramp: THEMES.themes.mono.light.ramp.map((h, i) => (i === 5 ? format(c) : h)) } };
  }
  const white = rgbToOklab({ r: 255, g: 255, b: 255 });
  const black = rgbToOklab({ r: 0, g: 0, b: 0 });
  const hexOf = (x) => format(oklabToRgb(x));
  const ramp = [0.9, 0.76, 0.52, 0.38, 0.2].map((t) => hexOf(mixLab(lab, white, t)));
  ramp.push(format(c), hexOf(mixLab(lab, black, 0.16)), hexOf(mixLab(lab, black, 0.32)));
  // headline emphasis must stay readable on white (contrast 3:1 or more)
  let text = lab;
  const contrast = (x) => (1.05) / (luminance(oklabToRgb(x)) + 0.05);
  for (let k = 0; k < 12 && contrast(text) < 3; k += 1) text = mixLab(text, black, 0.08);
  let darkLab = lab;
  for (let k = 0; k < 12 && luminance(oklabToRgb(darkLab)) < 0.18; k += 1) darkLab = mixLab(darkLab, white, 0.1);
  const darkRamp = [...ramp];
  darkRamp[5] = hexOf(darkLab);
  const neutralLight = { hue: toLch(lab).H, chroma: 0.003 };
  const ambLight = THEMES.themes.blue.light.ambient;
  const ambDark = THEMES.themes.blue.dark.ambient;
  return {
    label: 'Custom',
    light: { ramp, accentText: hexOf(text), neutral: neutralLight, ambient: ambLight, bg: '#FAFAFA' },
    dark: { ramp: darkRamp, accentText: hexOf(mixLab(darkLab, white, 0.15)), neutral: { hue: toLch(lab).H, chroma: 0.004 }, ambient: ambDark },
  };
}

function splitDecls(body) {
  const out = []; let depth = 0, cur = '';
  for (const ch of body) {
    if (ch === '(') depth += 1; else if (ch === ')') depth -= 1;
    if (ch === ';' && depth === 0) { out.push(cur); cur = ''; } else cur += ch;
  }
  if (cur.trim()) out.push(cur);
  return out.filter((d) => d.trim());
}

/**
 * @param {string} html  scene index.html (the untouched v2 base)
 * @param {object} o
 * @param {string} [o.theme]   blue | mono | orange (ignored when accent is set)
 * @param {string} [o.accent]  brand color hex for a custom theme
 * @param {'light'|'dark'} o.mode
 * @param {object} [o.config]  the scene's scene.json
 * @param {object} [o.font]    { family, file, relax } — default Smiley Sans
 */
export function applyTheme(html, o) {
  const mode = o.mode === 'dark' ? 'dark' : 'light';
  const themeName = o.accent ? 'custom' : (o.theme || 'blue');
  const themeDef = o.accent ? customTheme(o.accent) : THEMES.themes[themeName];
  if (!themeDef) throw new Error(`Unknown theme "${themeName}". Use ${THEME_NAMES.join(', ')} or --accent <hex>.`);
  const T = themeDef[mode];
  const cfg = o.config || {};
  const font = o.font || FONTS.smiley;
  const isPresetBlue = themeName === 'blue';

  const src = THEMES.sourceRamp.map((h) => rgbToOklab(parseColor(h)));
  const order = src.map((lab, i) => ({ lab, i })).sort((p, q) => q.lab.L - p.lab.L);
  const tgt = T.ramp.map((h) => rgbToOklab(parseColor(h)));
  const tintDeg = Math.round((((hslHue(T.ramp[5]) - hslHue('#2F6BFF')) % 360) + 360) % 360);
  const tintMap = new Map((cfg.tintColors || []).map((h) => [h.toUpperCase(), isPresetBlue ? h : filterHex(h, (themeName === 'mono' || (themeName === 'custom' && toLch(rgbToOklab(parseColor(T.ramp[5]))).C < 0.03)), tintDeg)]));

  const neutralize = (lab) => {
    if (!T.neutral) return lab;
    const { L } = toLch(lab);
    const fade = Math.max(0, Math.min(1, (1 - L) / 0.06, L / 0.12));
    return fromLch({ L, C: T.neutral.chroma * fade, H: T.neutral.hue });
  };
  const classify = (lab) => {
    const { L, C, H } = toLch(lab);
    if (C < 0.004 && (L > 0.995 || L < 0.01)) return 'pure';
    const rel = C / Math.max(0.005, maxChroma(L, H));
    if (H >= 232 && H <= 292 && C >= 0.015 && (C >= 0.05 || rel >= 0.6)) return 'accent';
    if (C < 0.05) return 'neutral';
    return 'other';
  };
  const mapAccent = (lab) => {
    const L = lab.L;
    const first = order[0], last = order[order.length - 1];
    if (L >= first.lab.L) {
      const t = Math.min(1, (L - first.lab.L) / Math.max(0.001, 1 - first.lab.L));
      return mixLab(tgt[first.i], neutralize({ L, a: 0, b: 0 }), t);
    }
    if (L <= last.lab.L) {
      const t = Math.min(1, (last.lab.L - L) / Math.max(0.001, last.lab.L));
      return mixLab(tgt[last.i], neutralize({ L: L * 0.6, a: 0, b: 0 }), t);
    }
    for (let k = 0; k < order.length - 1; k += 1) {
      const p = order[k], q = order[k + 1];
      if (L <= p.lab.L && L >= q.lab.L) return mixLab(tgt[p.i], tgt[q.i], (p.lab.L - L) / Math.max(0.0001, p.lab.L - q.lab.L));
    }
    return lab;
  };
  const stats = { accent: 0, neutral: 0, other: 0, pure: 0 };
  const remap = (str) => {
    const c = parseColor(str);
    if (!c) return str;
    if (tintMap.has(str.toUpperCase())) return tintMap.get(str.toUpperCase());
    const lab = rgbToOklab(c);
    const kind = classify(lab);
    stats[kind] += 1;
    if (T.bg && kind === 'neutral' && str.toUpperCase() === '#F4F6FA') return T.bg;
    if (isPresetBlue && kind !== 'neutral') return str;
    if (kind === 'accent') return format(oklabToRgb(mapAccent(lab)), c.a);
    if (kind === 'neutral' && T.neutral) return format(oklabToRgb(neutralize(lab)), c.a);
    return str;
  };
  // Large soft glows in the accent color become neutral light: no colored washes.
  const neutralGlow = (str) => {
    const c = parseColor(str);
    if (!c || c.a >= 0.3) return null;
    if (classify(rgbToOklab(c)) !== 'accent') return null;
    return mode === 'dark' ? `rgba(255,255,255,${+(c.a * 0.5).toFixed(3)})` : `rgba(120,120,128,${+(c.a * 0.6).toFixed(3)})`;
  };
  const recolor = (text) => {
    text = text.replace(/radial-gradient\((?:[^()]|\([^()]*\))*\)/g, (g) =>
      g.replace(/rgba?\([^)]*\)|#[0-9a-fA-F]{8}\b/g, (m) => neutralGlow(m) ?? m));
    text = text.replace(/rgba?\(\s*[\d.]+\s*,\s*[\d.]+\s*,\s*[\d.]+\s*(?:,\s*[\d.]+%?\s*)?\)/gi, (m) => remap(m));
    return text.replace(/(^|[^\w&#-])#([0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3})(?![\w-])/g, (m, pre, hex, off, all) => {
      const before = all.slice(Math.max(0, off - 8), off + pre.length);
      if (/url\($|href=["']?$/i.test(before)) return m; // id references, not colors
      if (hex.length === 3 && !/[:\s,(]$/.test(before)) return m;
      return pre + remap('#' + hex);
    });
  };

  const fontize = (decls) => {
    const m = decls.match(/font-size:\s*([\d.]+)px/);
    if (!m) return decls;
    if (/font-family:\s*["']?(?:JetBrains|IBM Plex Mono|ui-monospace|monospace|Agbalumo)/i.test(decls)) return decls;
    if (+m[1] >= DISPLAY_MIN_PX) {
      if (font.relax) {
        decls = decls.replace(/letter-spacing:\s*-?[\d.]+em/g, (ls) => {
          const v = parseFloat(ls.split(':')[1]);
          return `letter-spacing: ${Math.max(v * 0.2, -0.012).toFixed(3)}em`;
        });
      }
      return `${decls.replace(/\s*;?\s*$/, '')}; font-family: var(--font-display); font-synthesis: none; `;
    }
    return `${decls.replace(/\s*;?\s*$/, '')}; font-family: var(--font-ui); `;
  };
  // Mono: words emphasised with a solid mid-blue would turn as black as body text; use the gray accent text instead.
  const emphasisToGray = (themeName === 'mono' || (themeName === 'custom' && toLch(rgbToOklab(parseColor(T.ramp[5]))).C < 0.03));
  const rootVars = {};
  for (const m of html.matchAll(/:root\s*\{([^}]*)\}/g)) for (const d of m[1].matchAll(/(--[\w-]+)\s*:\s*([^;]+)/g)) rootVars[d[1]] = d[2].trim();
  const isMidAccent = (v) => {
    const m = v.trim().match(/^var\((--[\w-]+)\)$/);
    const hex = m ? rootVars[m[1]] : v.trim();
    const c = hex && parseColor(hex);
    if (!c) return false;
    const lab = rgbToOklab(c);
    return classify(lab) === 'accent' && lab.L > 0.35 && lab.L < 0.75;
  };
  const grayEmphasis = (body) => {
    if (!emphasisToGray || /background/.test(body)) return body;
    return body.replace(/(^|;)(\s*)color:\s*([^;]+)/g, (m, a, b, v) => (isMidAccent(v) ? `${a}${b}color: var(--lm-accent-text)` : m));
  };
  const processCss = (css) => css.replace(/([^{}]+)\{([^{}]*)\}/g, (all, sel, body) => {
    if (/@font-face/.test(sel)) return all;
    // gradient-filled headline text becomes one solid accent color
    if (/background-clip:\s*text/.test(body) && /gradient\(/.test(body) && !/url\(/.test(body)) {
      body = splitDecls(body)
        .filter((d) => !/^\s*(?:-webkit-)?(?:background|background-image|background-clip|text-fill-color|-webkit-text-fill-color)\s*:/.test(d) && !/^\s*color:\s*transparent/.test(d))
        .join(';') + '; color: var(--lm-accent-text);';
    }
    return `${sel}{${fontize(grayEmphasis(body))}}`;
  });

  const glassCss = () => {
    const dark = mode === 'dark';
    const rim = dark
      ? 'linear-gradient(140deg, rgba(255,255,255,0.55), rgba(255,255,255,0.08) 38%, rgba(255,255,255,0.02) 62%, rgba(255,255,255,0.28))'
      : 'linear-gradient(140deg, rgba(255,255,255,1), rgba(255,255,255,0.35) 36%, rgba(255,255,255,0.12) 62%, rgba(255,255,255,0.85))';
    const ring = `content:''; position:absolute; inset:0; border-radius:inherit; padding:1.5px; pointer-events:none;
    -webkit-mask: linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0); -webkit-mask-composite: xor; mask-composite: exclude;`;
    const sel = (list, suffix = '') => list.map((s) => s + suffix).join(',\n');
    let out = '';
    if (cfg.glass?.length) {
      out += `${sel(cfg.glass)} {
  background: ${dark
        ? 'radial-gradient(120% 70% at 18% 0%, rgba(255,255,255,0.10), transparent 60%), linear-gradient(165deg, rgba(255,255,255,0.08), rgba(255,255,255,0.03))'
        : 'radial-gradient(120% 70% at 18% 0%, rgba(255,255,255,0.55), transparent 62%), linear-gradient(165deg, rgba(255,255,255,0.62), rgba(255,255,255,0.34))'} !important;
  -webkit-backdrop-filter: blur(26px) saturate(185%); backdrop-filter: blur(26px) saturate(185%);
  border: 0 !important;
  box-shadow: ${dark
        ? 'inset 0 1px 0 rgba(255,255,255,0.22), 0 24px 60px -24px rgba(0,0,0,0.7)'
        : 'inset 0 1px 0 rgba(255,255,255,0.95), inset 0 -1px 0 rgba(255,255,255,0.35), 0 1px 2px rgba(20,20,30,0.04), 0 14px 34px -14px rgba(20,20,30,0.18), 0 40px 80px -40px rgba(20,20,30,0.16)'} !important;
}
${sel(cfg.glass, '::after')} { ${ring} background: ${rim}; }\n`;
    }
    if (cfg.material?.length) {
      out += `${sel(cfg.material)} {
  background: ${dark ? 'rgba(28,28,30,0.72)' : 'rgba(255,255,255,0.78)'} !important;
  -webkit-backdrop-filter: blur(40px) saturate(170%); backdrop-filter: blur(40px) saturate(170%);
  border: 0 !important;
  box-shadow: ${dark
        ? 'inset 0 0 0 1px rgba(255,255,255,0.08), inset 0 1px 0 rgba(255,255,255,0.12), 0 30px 70px -30px rgba(0,0,0,0.8)'
        : 'inset 0 0 0 1px rgba(255,255,255,0.7), inset 0 1px 0 rgba(255,255,255,1), 0 1px 2px rgba(20,20,30,0.04), 0 24px 60px -28px rgba(20,20,30,0.20)'} !important;
}\n`;
    }
    if (cfg.tinted?.length) {
      out += `${sel(cfg.tinted)} {
  background: radial-gradient(120% 80% at 20% 0%, rgba(255,255,255,0.32), transparent 55%), var(--lm-accent) !important;
  color: var(--lm-on-accent) !important;
  border: 0 !important;
  box-shadow: inset 0 1px 0 rgba(255,255,255,0.45), inset 0 -1px 0 rgba(0,0,0,0.12), 0 12px 30px -12px var(--lm-accent-glow) !important;
}
${sel(cfg.tinted, '::after')} { ${ring} background: linear-gradient(140deg, rgba(255,255,255,0.75), rgba(255,255,255,0.1) 40%, rgba(255,255,255,0) 60%, rgba(255,255,255,0.4)); }
${sel(cfg.tinted, ' svg')} { stroke: var(--lm-on-accent); }\n`;
    }
    return out;
  };

  if (cfg.edits) for (const [from, to] of cfg.edits) {
    if (!html.includes(from)) throw new Error(`edit not found: ${from.slice(0, 60)}`);
    html = html.split(from).join(to);
  }

  const waitFont = font.family
    ? `(document.fonts ? document.fonts.load('48px "${font.family}"').catch(function(){}) : Promise.resolve())`
    : 'Promise.resolve()';
  // The scene script measures text in some scenes: run it only after the display face is ready.
  if (cfg.waitForFont !== false) {
    html = html.replace(/<script>([\s\S]*?)<\/script>(?=\s*<\/body>)/, (m, js) =>
      `<script>${waitFont}.then(function(){\n${js}\n});</script>`);
  }
  html = html.replace(/<style>([\s\S]*?)<\/style>/g, (m, css) => `<style>${processCss(css)}</style>`);
  html = html.replace(/style="([^"]*)"/g, (m, s) => (/font-size:\s*[\d.]+px/.test(s) ? `style="${fontize(s).trim()}"` : m));
  html = recolor(html);

  const accent = T.ramp[5];
  const onAccent = luminance(parseColor(accent)) > 0.45 ? '#111111' : '#FFFFFF';
  const glow = parseColor(accent);
  const amb = cfg.ambient?.blobs ?? [[1500, 180, 620], [260, 900, 560], [1180, 760, 420]];
  const fmt = { woff2: 'woff2', woff: 'woff', ttf: 'truetype', otf: 'opentype' }[String(font.file || '').split('.').pop().toLowerCase()];
  const fontFace = font.family ? `@font-face { font-family: "${font.family}"; src: url("assets/${font.file}")${fmt ? ` format("${fmt}")` : ''}; font-weight: 100 900; font-display: block; }\n` : '';
  const displayStack = font.family ? `"${font.family}", "Inter LM", "Noto Sans SC", sans-serif` : '"Inter LM", Inter, "Noto Sans SC", system-ui, sans-serif';
  // Brand illustrations and footage drawn in the original blue follow the theme too (never photos).
  const tintCss = (cfg.tintMedia?.length && !(isPresetBlue))
    ? `${cfg.tintMedia.join(',\n')} { filter: ${(themeName === 'mono' || (themeName === 'custom' && toLch(rgbToOklab(parseColor(accent))).C < 0.03)) ? 'grayscale(1) contrast(1.06)' : `hue-rotate(${Math.round((((hslHue(accent) - hslHue('#2F6BFF')) % 360) + 360) % 360)}deg) saturate(1.05)`} !important; }`
    : '';
  const head = `
${fontFace}:root {
  --font-display: ${displayStack};
  --font-ui: "Inter LM", Inter, "Noto Sans SC", system-ui, sans-serif;
  --font: var(--font-ui);
  ${mode === 'light' && T.bg ? `--bg: ${T.bg};` : ''}
  --lm-accent: ${accent}; --lm-on-accent: ${onAccent}; --lm-accent-text: ${T.accentText};
  --lm-accent-glow: rgba(${glow.r},${glow.g},${glow.b},0.55);
}
#lm-amb { pointer-events: none; }
#lm-amb i { position: absolute; border-radius: 50%; }
${amb.map(([x, y, r], k) => `#lm-amb i:nth-child(${k + 1}) { left: ${x - r}px; top: ${y - r}px; width: ${2 * r}px; height: ${2 * r}px; background: radial-gradient(closest-side, ${T.ambient[k % 3]} 0%, ${T.ambient[k % 3].replace(/[\d.]+\)$/, (a) => (parseFloat(a) * 0.45).toFixed(3) + ')')} 48%, transparent 100%); }`).join('\n')}
${(cfg.grid === false || (mode === 'light' && cfg.grid !== true)) ? '#grid { display: none !important; }' : ''}
${mode === 'light' && cfg.glow !== true ? '#glow { display: none !important; }' : ''}
${(cfg.hide ?? []).map((s) => `${s} { display: none !important; }`).join('\n')}
${(cfg.relative ?? []).map((s) => `${s} { position: relative; }`).join('\n')}
${tintCss}
${glassCss()}
${[...tintMap].reduce((css, [from, to]) => css.replace(new RegExp(from, 'gi'), to), cfg.css ?? '')}
`;
  html = html.replace(/<\/style>/, `${head}</style>`);
  if (font.family) {
    // Start loading the display face before any scene script measures text.
    html = html.replace(/<head>/, `<head>\n<link rel="preload" as="font" type="font/woff2" href="assets/${font.file}" crossorigin />`);
    html = html.replace(/(<script src="vendor\/gsap[^"]*"><\/script>)/, `$1\n<script>document.fonts && document.fonts.load('48px "${font.family}"');</script>`);
  }
  if (cfg.ambient !== false) {
    html = html.replace(/(<div id="main"[^>]*>)/, `$1\n  <div id="lm-amb" class="layer">${amb.map(() => '<i></i>').join('')}</div>`);
  }

  // Drift the ambient light slowly and guard text contrast on recolored surfaces.
  const tail = `<script>${waitFont}.then(function(){
var tl=(window.__timelines||{}).main; if(tl){var d=tl.duration(); document.querySelectorAll('#lm-amb i').forEach(function(el,k){tl.fromTo(el,{x:0,y:0,scale:1},{x:[90,-80,60][k%3],y:[-50,40,-70][k%3],scale:[1.08,0.94,1.1][k%3],duration:d,ease:'none'},0);});}
function lum(c){var m=c.match(/[\\d.]+/g);if(!m)return null;var a=m.length>3?+m[3]:1;if(a<0.6)return null;var f=function(v){v/=255;return v<=0.04045?v/12.92:Math.pow((v+0.055)/1.055,2.4);};return 0.2126*f(m[0])+0.7152*f(m[1])+0.0722*f(m[2]);}
function cr(a,b){var x=Math.max(a,b),y=Math.min(a,b);return (x+0.05)/(y+0.05);}
function gradLum(img){var m=img.indexOf('url(')>=0?null:img.match(/rgba?\\([^)]*\\)/g);if(!m)return null;var s=0,n=0;m.forEach(function(x){var l=lum(x);if(l!==null){s+=l;n++;}});return n?s/n:null;}
function bgOf(el){while(el&&el!==document.body){var c=getComputedStyle(el);var l=lum(c.backgroundColor);if(l!==null)return l;if(c.backgroundImage!=='none')return gradLum(c.backgroundImage);el=el.parentElement;}return null;}
document.querySelectorAll('#main *').forEach(function(el){var cs=getComputedStyle(el);var bg=lum(cs.backgroundColor);if(bg===null){var fg0=lum(cs.color);var own=[].some.call(el.childNodes,function(n){return n.nodeType===3&&n.textContent.trim();});if(own&&fg0!==null&&fg0>0.8){var p=el.parentElement;for(var k=0;k<2&&p&&p.id!=='main';k++,p=p.parentElement){var pc=getComputedStyle(p);var pl=lum(pc.backgroundColor);if(pl!==null){if(pl>0.6)el.style.color='#111111';break;}if(pc.backgroundImage!=='none')break;}}return;}var fg=lum(cs.color);if(fg!==null&&cr(fg,bg)<1.7){el.style.color=bg>0.4?'#111111':'#FFFFFF';}});
document.querySelectorAll('#main [stroke="#fff"],#main [stroke="#FFF"],#main [stroke="#FFFFFF"],#main [fill="#fff"],#main [fill="#FFFFFF"]').forEach(function(s){var b=bgOf(s.parentElement);if(b!==null&&b>0.6){if(s.getAttribute('stroke'))s.setAttribute('stroke','#111111');if(/^#f/i.test(s.getAttribute('fill')||''))s.setAttribute('fill','#111111');}});
});</script>
</body>`;
  html = html.replace(/<\/body>/, tail);
  return { html, stats, theme: themeName, accent };
}

/**
 * Swap pictures and footage: values maps a media name from scene.json to one or more
 * project-relative paths. Runs before the scene script and again right after it, so elements
 * the script creates are covered too.
 */
export function applyMedia(html, media, values, font) {
  const jobs = [];
  for (const [name, list] of Object.entries(values)) {
    const m = (media || []).find((x) => x.name === name);
    if (!m || !m.selector) continue;
    jobs.push({ s: m.selector, v: list });
  }
  if (!jobs.length) return html;
  const fn = `function(){var J=${JSON.stringify(jobs).replace(/</g, '\\u003c')};J.forEach(function(j){var els=document.querySelectorAll(j.s);for(var i=0;i<els.length;i++){var el=els[i],v=j.v[i%j.v.length];if(el.dataset.lmMedia===v)continue;el.dataset.lmMedia=v;var t=el.tagName;if(t==='IMG'||t==='VIDEO'||t==='SOURCE'){el.setAttribute('src',v);if(t==='IMG')el.removeAttribute('srcset');}else if(t.toLowerCase()==='image'){el.setAttribute('href',v);}else{el.style.backgroundImage='url("'+v+'")';}}});}`;
  const waitFont = font && font.family ? `(document.fonts ? document.fonts.load('48px "${font.family}"').catch(function(){}) : Promise.resolve())` : 'Promise.resolve()';
  const before = `<script>(${fn})();</script>\n`;
  const after = `<script>${waitFont}.then(${fn});</script>\n`;
  const re = /<script(?![^>]*\bsrc=)[^>]*>/g;
  re.lastIndex = html.indexOf('<body');
  const m = re.exec(html);
  const at = m ? m.index : html.lastIndexOf('</body>');
  html = html.slice(0, at) + before + html.slice(at);
  return html.replace(/<\/body>(?![\s\S]*<\/body>)/, `${after}</body>`);
}
