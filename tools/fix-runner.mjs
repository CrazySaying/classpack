// Apply surgical text fixes to classpack pack JSONs, with expected-count assertions.
// Usage: node fix-runner.mjs <baseDir> <fixesJson>
import fs from "node:fs";
import path from "node:path";

const [baseDir, fixesFile] = process.argv.slice(2);
if (!baseDir || !fixesFile) {
  console.error("usage: node fix-runner.mjs <baseDir> <fixesJson>");
  process.exit(1);
}
const fixes = JSON.parse(fs.readFileSync(fixesFile, "utf8"));
const report = [];
for (const fx of fixes) {
  const dir = fx.glob ? path.join(baseDir, ...fx.glob.split("/")) : baseDir;
  const walk = (d) =>
    fs.readdirSync(d, { withFileTypes: true }).flatMap((e) => {
      const p = path.join(d, e.name);
      return e.isDirectory() ? walk(p) : e.isFile() && e.name.endsWith(".json") ? [p] : [];
    });
  const files = walk(dir);
  let total = 0, touched = 0;
  const bad = [];
  for (const f of files) {
    const t = fs.readFileSync(f, "utf8");
    const ms = t.match(new RegExp(fx.find, "g"));
    if (!ms || ms.length === 0) continue;
    total += ms.length; touched++;
    const out = t.replace(new RegExp(fx.find, "g"), fx.replace.replace(/\$/g, "$$$$"));
    fs.writeFileSync(f, out, "utf8");
    try { JSON.parse(fs.readFileSync(f, "utf8")); } catch (e) { bad.push(`JSON INVALID: ${f} :: ${e.message}`); }
  }
  const status = total === fx.expect ? "OK" : `MISMATCH expect=${fx.expect}`;
  report.push(`${fx.name.padEnd(32)} files=${String(touched).padStart(2)} count=${String(total).padStart(2)}  ${status}`);
  for (const b of bad) report.push("  " + b);
}
console.log(report.join("\n"));
