// Shared scene builder for LaunchMotion create scripts: theme, font, text slots and media.
import fs from 'node:fs';
import path from 'node:path';
import { applyMedia, applyTheme, FONTS, THEME_NAMES } from './lm-theme.mjs';

export function parseArgs(argv) {
  const o = { out: null, effect: null, list: null, values: {}, media: {}, theme: null, accent: null, font: null };
  const pair = (p) => { const eq = p.indexOf('='); return eq > 0 ? [p.slice(0, eq), p.slice(eq + 1)] : null; };
  for (let i = 0; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === '--effect') o.effect = argv[++i];
    else if (a === '--out' || a === '--output') o.out = path.resolve(argv[++i]);
    else if (a === '--data') Object.assign(o.values, JSON.parse(fs.readFileSync(path.resolve(argv[++i]), 'utf8')));
    else if (a === '--set') { const p = pair(argv[++i] || ''); if (p) o.values[p[0]] = p[1]; }
    else if (a === '--media') { const p = pair(argv[++i] || ''); if (p) o.media[p[0]] = p[1]; }
    else if (a === '--theme') o.theme = argv[++i];
    else if (a === '--accent') o.accent = argv[++i];
    else if (a === '--font') o.font = argv[++i];
    else if (a === '--list') o.list = argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[++i] : '';
    else if (a === '--help' || a === '-h') o.help = true;
  }
  return o;
}

export const USAGE = `Options:
  --out <dir>               project folder to create
  --theme blue|mono|orange  color theme (default blue)
  --accent "#RRGGBB"        brand color theme instead of a preset
  --font smiley|inter|<file> display font for headlines (default Smiley Sans; .woff2/.woff/.ttf/.otf)
  --set key=value           text slot (repeat); wrap one phrase in [[ ]] to keep its highlight
  --data content.json       object of slot values
  --media name=path[,path]  replace a picture/footage slot with your own file(s) or a folder`;

const safeName = (p) => path.basename(p).replace(/[^A-Za-z0-9._-]/g, '-');

function copyUserFile(local, outDir) {
  const rel = `assets/user/${safeName(local)}`;
  fs.mkdirSync(path.join(outDir, 'assets', 'user'), { recursive: true });
  fs.copyFileSync(local, path.join(outDir, rel));
  return rel;
}

function resolveFont(choice, outDir, smileySource) {
  if (!choice || choice === 'smiley' || choice === 'smiley-sans') {
    const dst = path.join(outDir, 'assets', FONTS.smiley.file);
    if (!fs.existsSync(dst)) { fs.mkdirSync(path.dirname(dst), { recursive: true }); fs.copyFileSync(smileySource, dst); }
    return FONTS.smiley;
  }
  if (choice === 'inter') return FONTS.inter;
  const local = path.resolve(choice);
  if (!fs.existsSync(local)) throw new Error(`--font: "${choice}" is not smiley, inter or an existing font file.`);
  const ext = path.extname(local).toLowerCase();
  if (!['.woff2', '.woff', '.ttf', '.otf'].includes(ext)) throw new Error('--font: use a .woff2, .woff, .ttf or .otf file.');
  fs.mkdirSync(path.join(outDir, 'assets'), { recursive: true });
  fs.copyFileSync(local, path.join(outDir, 'assets', `user-font${ext}`));
  return { family: 'LM Display', file: `user-font${ext}`, relax: true };
}

function mediaFiles(value, outDir) {
  const parts = String(value).split(',').map((s) => s.trim()).filter(Boolean);
  const files = [];
  for (const p of parts) {
    const local = path.resolve(p);
    if (!fs.existsSync(local)) throw new Error(`--media: file not found: ${p}`);
    if (fs.statSync(local).isDirectory()) {
      for (const f of fs.readdirSync(local).sort()) {
        if (/\.(png|jpe?g|webp|avif|gif|svg|mp4|webm|mov)$/i.test(f)) files.push(copyUserFile(path.join(local, f), outDir));
      }
    } else files.push(copyUserFile(local, outDir));
  }
  return files;
}

/**
 * Theme the scene and fill text and media. Returns { html, warnings, theme }.
 * scene = { mode, config (scene.json), defaults ({ slots, limits }) }.
 */
export function buildScene(html, scene, opts, outDir, smileySource) {
  const warnings = [];
  const config = scene.config || {};
  const mediaDefs = config.media || [];
  const dropped = new Set(config.dropSlots || []);
  if (opts.theme && !THEME_NAMES.includes(opts.theme)) throw new Error(`--theme must be one of ${THEME_NAMES.join(', ')}.`);
  const font = resolveFont(opts.font, outDir, smileySource);
  const themed = applyTheme(html, { theme: opts.theme || 'blue', accent: opts.accent || null, mode: scene.mode, config, font });
  html = themed.html;

  const media = { ...opts.media };
  const escapeRe = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const domValues = {};
  for (let [key, value] of Object.entries(opts.values)) {
    value = String(value);
    if (mediaDefs.some((m) => m.name === key)) { media[key] = value; continue; }
    if (dropped.has(key)) warnings.push(`"${key}" is hidden in the current look; its text will not show.`);
    const limit = scene.defaults?.limits?.[key];
    const local = path.resolve(value);
    if (value.length < 1024 && fs.existsSync(local) && fs.statSync(local).isFile()) value = copyUserFile(local, outDir);
    else if (limit && value.replace(/\[\[|\]\]/g, '').length > limit) warnings.push(`"${key}" is ${value.length} characters; the layout is designed for ${limit}.`);
    if (html.includes(`data-slot="${key}"`)) { domValues[key] = value; continue; }
    const re = new RegExp(`(\\b${escapeRe(key)}\\s*:\\s*)(['"\`])((?:\\\\.|(?!\\2).)*)\\2`);
    if (re.test(html)) { html = html.replace(re, (m, a, q) => `${a}${q}${value.replace(/\\/g, '\\\\').replace(new RegExp(q, 'g'), '\\' + q)}${q}`); continue; }
    warnings.push(`Unknown slot "${key}" was ignored.`);
  }
  if (Object.keys(domValues).length) {
    // Runs after the slot elements exist and before the timeline script reads them.
    // A value may mark one highlighted phrase with [[ ]]; it takes the style of the slot's first inner element.
    const inject = `<script>(function(){var v=${JSON.stringify(domValues).replace(/</g, '\\u003c')};
Object.keys(v).forEach(function(k){document.querySelectorAll('[data-slot="'+k+'"]').forEach(function(el){var val=v[k];
if(/^(IMG|VIDEO|SOURCE|IMAGE)$/i.test(el.tagName)){el.setAttribute(el.tagName.toLowerCase()==='image'?'href':'src',val);return;}
var hi=el.firstElementChild,m=val.match(/^([\\s\\S]*?)\\[\\[([\\s\\S]*?)\\]\\]([\\s\\S]*)$/);
if(m&&hi){var s=hi.cloneNode(false);s.textContent=m[2];el.textContent='';el.append(m[1],s,m[3]);}else{el.textContent=val.replace(/\\[\\[|\\]\\]/g,'');}});});})();</script>\n`;
    const re = /<script(?![^>]*\bsrc=)[^>]*>/g;
    re.lastIndex = html.indexOf('<body');
    const m = re.exec(html);
    const at = m ? m.index : html.lastIndexOf('</body>');
    html = html.slice(0, at) + inject + html.slice(at);
  }

  const mediaValues = {};
  for (const [name, value] of Object.entries(media)) {
    if (!mediaDefs.some((m) => m.name === name)) { warnings.push(`Unknown media slot "${name}" was ignored.`); continue; }
    mediaValues[name] = mediaFiles(value, outDir);
  }
  if (Object.keys(mediaValues).length) html = applyMedia(html, mediaDefs, mediaValues, font);
  return { html, warnings, theme: themed.theme, accent: themed.accent };
}
