#!/usr/bin/env node
/**
 * Executes a declared browser journey, scanning each resulting state with
 * AccessLint. It intentionally does not judge screen-reader output or apply
 * changes; those remain Codex/human review work.
 */
import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import { request } from "node:http";

const args = process.argv.slice(2);
const valueOf = (flag) => args[args.indexOf(flag) + 1];
const journeyPath = valueOf("--journey");
const outputPath = valueOf("--output") || "accessibility-journey-report.json";
if (!journeyPath || args.includes("--help")) {
  console.log("Usage: node journey-audit.mjs --journey a11y-journey.json [--output report.json]");
  process.exit(journeyPath ? 0 : 2);
}

const config = JSON.parse(readFileSync(journeyPath, "utf8"));
if (!config.baseUrl || !Array.isArray(config.journeys) || !config.journeys.length) {
  throw new Error("Journey file needs baseUrl and a non-empty journeys array.");
}

function run(command, commandArgs) {
  return execFileSync(command, commandArgs, { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] });
}
const npx = process.platform === "win32" ? "npx.cmd" : "npx";
function ensureChrome() {
  const result = JSON.parse(run(npx, ["-y", "@accesslint/chrome@latest", "ensure"]));
  if (!result.port) throw new Error("AccessLint Chrome did not return a debug port.");
  return result;
}
function getJson(port, path) {
  return new Promise((resolve, reject) => {
    const req = request({ hostname: "127.0.0.1", port, path, method: "GET" }, (res) => {
      let body = "";
      res.on("data", (chunk) => { body += chunk; });
      res.on("end", () => {
        try { resolve(JSON.parse(body)); } catch (error) { reject(error); }
      });
    });
    req.on("error", reject); req.end();
  });
}
function cdp(url) {
  const socket = new WebSocket(url);
  let nextId = 0;
  const pending = new Map();
  socket.addEventListener("message", ({ data }) => {
    const message = JSON.parse(data);
    const waiter = pending.get(message.id);
    if (waiter) { pending.delete(message.id); waiter(message); }
  });
  const ready = new Promise((resolve, reject) => {
    socket.addEventListener("open", resolve, { once: true });
    socket.addEventListener("error", reject, { once: true });
  });
  return {
    async send(method, params = {}) {
      await ready;
      const id = ++nextId;
      const response = new Promise((resolve) => pending.set(id, resolve));
      socket.send(JSON.stringify({ id, method, params }));
      const message = await response;
      if (message.error) throw new Error(`${method}: ${message.error.message}`);
      return message.result;
    },
    close: () => socket.close(),
  };
}
const absoluteUrl = (url) => new URL(url, config.baseUrl).toString();
async function executeStep(client, step) {
  if (step.url) {
    await client.send("Page.navigate", { url: absoluteUrl(step.url) });
    await new Promise((resolve) => setTimeout(resolve, step.waitMs ?? 500));
  }
  if (step.waitFor) await client.send("Runtime.evaluate", { expression: `new Promise((resolve,reject)=>{const until=Date.now()+10000;const tick=()=>document.querySelector(${JSON.stringify(step.waitFor)})?resolve(true):Date.now()>until?reject(new Error('waitFor timed out')):setTimeout(tick,50);tick()})`, awaitPromise: true });
  if (step.fill) await client.send("Runtime.evaluate", { expression: `(() => { const el=document.querySelector(${JSON.stringify(step.fill.selector)}); if (!el) throw new Error('fill target not found'); el.focus(); el.value=${JSON.stringify(step.fill.value)}; el.dispatchEvent(new InputEvent('input',{bubbles:true,inputType:'insertText',data:${JSON.stringify(step.fill.value)}})); el.dispatchEvent(new Event('change',{bubbles:true})); })()` });
  if (step.click) await client.send("Runtime.evaluate", { expression: `(() => { const el=document.querySelector(${JSON.stringify(step.click)}); if (!el) throw new Error('click target not found'); el.scrollIntoView({block:'center'}); el.click(); })()` });
  if (step.press) await client.send("Input.dispatchKeyEvent", { type: "keyDown", key: step.press, code: step.press });
  if (step.waitMs) await new Promise((resolve) => setTimeout(resolve, step.waitMs));
}
function scan(target, port) {
  try { return JSON.parse(run(npx, ["-y", "@accesslint/cli@latest", "scan", target, "--port", String(port), "--format", "json"])); }
  catch (error) { return { scanError: error.stderr || error.message }; }
}

const chrome = ensureChrome();
const pages = await getJson(chrome.port, "/json/list");
const page = pages.find((candidate) => candidate.type === "page") || pages[0];
if (!page?.webSocketDebuggerUrl) throw new Error("No inspectable Chrome page found.");
const client = cdp(page.webSocketDebuggerUrl);
await client.send("Page.enable");
const report = { generatedAt: new Date().toISOString(), baseUrl: config.baseUrl, chromePort: chrome.port, journeys: [] };
try {
  for (const journey of config.journeys) {
    const result = { name: journey.name || "Unnamed journey", steps: [] };
    for (const step of journey.steps || []) {
      const entry = { name: step.name || "Unnamed step", action: step };
      try {
        await executeStep(client, step);
        entry.url = (await client.send("Runtime.evaluate", { expression: "location.href", returnByValue: true })).result.value;
        entry.scan = scan(entry.url, chrome.port);
        entry.status = "scanned";
      } catch (error) { entry.status = "failed"; entry.error = error.message; }
      result.steps.push(entry);
    }
    report.journeys.push(result);
  }
} finally { client.close(); }
writeFileSync(outputPath, JSON.stringify(report, null, 2));
console.log(`Journey report written to ${outputPath}`);
