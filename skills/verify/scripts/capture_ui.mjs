#!/usr/bin/env node
import { chromium } from 'playwright';
import { mkdirSync } from 'fs';
import { join } from 'path';
const args = process.argv.slice(2);
const u = args.indexOf('--url'); const o = args.indexOf('--out');
const url = u >= 0 ? args[u + 1] : 'http://localhost:3000';
const out = o >= 0 ? args[o + 1] : '.verify/ui';
mkdirSync(out, { recursive: true });
const ts = Date.now();
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
await page.goto(url, { waitUntil: 'networkidle' });
await page.screenshot({ path: join(out, `01-initial-${ts}.png`), fullPage: true });
const button = await page.$('button, [role="button"], a[href]');
if (button) { await button.click(); await page.waitForTimeout(500); await page.screenshot({ path: join(out, `02-apres-action-${ts}.png`), fullPage: true }); }
await browser.close();
console.log(`Captures produites dans ${out}`);
