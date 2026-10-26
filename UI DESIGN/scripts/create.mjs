#!/usr/bin/env node
// Build an editable LaunchMotion scene with your own text, theme, font and pictures.
// Usage: node scripts/create.mjs --out ./launch-scene [--theme blue|mono|orange | --accent "#RRGGBB"]
//        [--font smiley|inter|<font file>] [--set key=value ...] [--data content.json] [--media name=path ...]
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildScene, parseArgs, USAGE } from './lib/lm-build.mjs';

const skillRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const refs = path.join(skillRoot, 'references');
const projectDir = path.join(refs, 'project');
const defaults = JSON.parse(fs.readFileSync(path.join(refs, 'defaults.json'), 'utf8'));
const sceneConfig = JSON.parse(fs.readFileSync(path.join(refs, 'scene.json'), 'utf8'));

const opts = parseArgs(process.argv.slice(2));
if (opts.help) {
  console.log(`Text slots: ${Object.keys(defaults.slots).join(', ')}`);
  console.log(`Media slots: ${(sceneConfig.media || []).filter((m) => m.selector).map((m) => m.name).join(', ') || 'none'}`);
  console.log(USAGE);
  process.exit(0);
}
const out = opts.out || path.resolve('launch-scene');
fs.rmSync(out, { recursive: true, force: true });
fs.cpSync(projectDir, out, { recursive: true });

const base = fs.readFileSync(path.join(out, 'index.html'), 'utf8');
const { html, warnings, theme, accent } = buildScene(base, { mode: defaults.mode, config: sceneConfig, defaults }, opts, out, path.join(projectDir, 'assets', 'smiley-sans.woff2'));
fs.writeFileSync(path.join(out, 'index.html'), html);

for (const w of warnings) console.warn(`warning: ${w}`);
console.log(`Created ${out} (${defaults.durationSeconds}s, ${defaults.width}x${defaults.height}, ${defaults.mode} scene, theme ${accent || theme}).`);
console.log(`Preview: npx hyperframes preview ${out}`);
console.log(`Render:  npx hyperframes render ${out} --output ${out}.mp4 --fps 30 --quality high --resolution 1080p   (4K: --resolution 4k)`);
