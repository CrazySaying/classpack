// Read-only dump of a ClassicLevel compendium pack to JSON files.
// Usage: node dump-ldb.mjs <packDir> <outDir>
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const cliRoot = require("node:url").fileURLToPath(new URL("../../.fvttcli/node_modules/", import.meta.url));
const { ClassicLevel: Level } = require(require("node:path").join(cliRoot, "classic-level", "index.js"));
import fs from "node:fs";
import path from "node:path";

const [packDir, outDir] = process.argv.slice(2);
if (!packDir || !outDir) {
  console.error("usage: node dump-ldb.mjs <packDir> <outDir>");
  process.exit(1);
}
fs.mkdirSync(outDir, { recursive: true });
const db = new Level(packDir, { valueEncoding: "view", keyEncoding: "view", readOnly: true });
let n = 0;
for await (const [key, value] of db.iterator()) {
  const k = Buffer.from(key).toString("utf8");
  const v = JSON.parse(Buffer.from(value).toString("utf8"));
  const safe = (v.name || k).replace(/[\\/:*?"<>|]/g, "_").slice(0, 120);
  fs.writeFileSync(path.join(outDir, `${k}_${safe}.json`), JSON.stringify(v, null, 2), "utf8");
  n++;
}
console.log(`dumped ${n} documents from ${packDir}`);
