# CMD+RVL

**Checkable financial and document analysis in deterministic Rust.**

AI models are strong at reading filings, drafting memos, and orchestrating workflows, and weak at silent math, schema drift, and byte-accurate citations. CMD+RVL moves quote grounding, filing redlines, structural gates, numeric diffs, and offline evidence sealing into small, auditable, `#![forbid(unsafe_code)]` Rust engines you can use today.

It runs two ways: directly in a **browser tab** ([`@cmdrvl/web`](https://github.com/cmdrvl/web)) with zero server and zero file uploads, or locally as **native CLI tools** ([`cmdrvl`](https://github.com/cmdrvl/cmdrvl) & [`homebrew-tap`](https://github.com/cmdrvl/homebrew-tap)) for engineers and AI agents.

---

## What You Can Do Today

- **Publish checkable memos, research, and Claude Artifacts.** Back static pages, interactive reports, or Claude Artifacts with [`@cmdrvl/web`](https://github.com/cmdrvl/web) so readers can click cited passages and figures to check them locally in their browser—or drop in their own copy of the source filing to confirm nothing was edited, even offline.
- **Redline SEC filings and contracts in under a second without burning LLM tokens.** [`redline`](https://github.com/cmdrvl/redline) compares two 5.5 MB 10-K filings in about half a second, strips CSS and reflow noise, and flags real numeric and clause changes with exact original `[start, end)` byte offsets.
- **Gate and diff financial tables and data tapes deterministically.** [`shape`](https://github.com/cmdrvl/shape) stops incomparable files before bad math runs, and [`rvl`](https://github.com/cmdrvl/rvl) isolates the smallest set of cells explaining >=95% of unscaled numeric movement (best used on single-unit tables or columns scoped via `--profile`).
- **Hand auditors a portable receipt that verifies offline years later.** [`lock`](https://github.com/cmdrvl/lock) and [`pack`](https://github.com/cmdrvl/pack) bundle exact input hashes, rules, profiles, and verdicts into one content-addressed folder that anyone holding the pinned `pack_id` can verify offline with `pack verify`—no server, no account, no vendor lock-in.

---

## Where This Fits: Mechanical Ground Truth → Semantic Reasoning

CMD+RVL separates **mechanical verification** from **semantic interpretation**:

- **This open-source library (`@cmdrvl/web` & CLI)** handles lightweight, deterministic checks you can run today with zero infrastructure—byte-accurate filing redlines, quote-span grounding, schema comparability gates, numeric delta isolation, and offline receipts. It is MIT-licensed and `#![forbid(unsafe_code)]` so any reader, client, or auditor can re-check outputs independently without trusting our servers or an LLM.
- **Our private commercial layer (*Evidence Machine*)** builds a full semantic layer on top of these primitives—aligning financial concepts across filings and periods, validating derived calculations, and encoding domain-specific regulatory and credit rulebooks using structured knowledge graphs and formal validation rules, while projecting outputs back down to receipts this open-source kernel can verify offline. Learn more at [cmdrvl.com](https://cmdrvl.com).

---

## Choose Your Mode: Web (Browser) vs. CLI

Both modes compile the same Rust verification crates and emit the same JSON schemas (in browser mode, `lock.v0` input pinning is optional for ad-hoc drag-and-drop checks, whereas the `verify ground` CLI requires `--lock`).

| If you want to... | Use | How it runs |
|---|---|---|
| **Give analysts, clients, or readers zero-upload verification in a browser** (static pages, interactive memos, internal tools, Claude Artifacts) | **[`@cmdrvl/web`](https://github.com/cmdrvl/web)** | Compiled serial WebAssembly in the user's browser tab. Zero server, zero upload, works offline and in Desktop/iPhone Safari with no special server headers. |
| **Give an AI coding agent or CI pipeline deterministic local tools** (document grounding, schema gates, tabular diffs, offline evidence packs) | **[CLI (`cmdrvl` / `homebrew-tap`)](https://github.com/cmdrvl/homebrew-tap)** | Fast native Rust binaries via Homebrew. Self-describing JSON contracts, typed refusals with recovery commands, and zero-retention defaults. |
| **Add 30-second verifiable CSV receipts to Claude Code, Codex, Gemini CLI, or Cursor** | **[`receipts`](https://github.com/cmdrvl/receipts)** | One-line skill installer wrapping `shape`, `rvl`, and `pack`. |
| **Connect an agent to public and licensed financial/SEC datasets** | **[`mcp-servers`](https://cmdrvl.com/mcp-servers/)** | Hosted MCP servers paired with local verification and sealing. |

---

## What This Looks Like in Practice

### In the Browser (`@cmdrvl/web`, zero server / zero upload)

```js
import init, { verify_ground_json, redline_compare } from "./pkg/cmdrvl_web.js";

await init();

// 1. Ground quotes, numeric scales, and optional lock.v0 hashes locally in the tab
const doc = new TextEncoder().encode("As of September 30, 2026, cash totaled $41.2 million.");
const claim = JSON.stringify({
  claim_id: "cash_q3",
  source: "q3",
  quote: "cash totaled $41.2 million",
  value: 41.2,
  scale: "millions",
  unit: "USD",
});
const ground = JSON.parse(verify_ground_json(claim, "q3", "q3.txt", doc, null));
// ground.outcome === "PASS" (1-byte source tamper fails lock.v0 deterministically)

// 2. Semantic prose/HTML redline returning exact original [start, end) byte spans
const diff = JSON.parse(redline_compare(oldFilingBytes, newFilingBytes, "html-text", false));
// Separates numeric_changed / clause_added from formatting_only; text redacted when explicit=false
```

### In the Terminal or an AI Agent Session (Native Rust CLI)

```text
$ shape nov.csv dec.csv --key loan_id
SHAPE  INCOMPATIBLE
  Types: balance: numeric -> non-numeric    # caught before a bad diff ever runs

$ rvl old.csv new.csv --key id --explicit
RVL    REAL CHANGE
  Checked: 1,003 rows, 3 numeric columns (3,009 cells)
  3 cells explain 95.2% of total numeric change (threshold 95.0%):
    1. NVDA.market_value_usd  +1.12e6  (4,250,000 -> 5,370,000)
    2. MSFT.market_value_usd  -5.1e5   (3,890,000 -> 3,380,000)
    3. AAPL.cost_basis_usd    +274000  (1,920,000 -> 2,194,000)

$ pack verify evidence/2026-q4/
pack verify: OK                             # content-addressed; compare pack_id offline
  pack_id: sha256:71cd27ee3a69cf0e...
```

---

## Engineering Design

- **One `#![forbid(unsafe_code)]` Rust core for CLI and Web:** `@cmdrvl/web` wraps the same Rust crates (`verify-engine`, `redline`, `sha2`, `blake3`) in serial `wasm32-unknown-unknown` with no `SharedArrayBuffer` or COOP/COEP headers required.
- **Built for headless AI agents:** Every CLI exposes `--robot-triage`, `capabilities --json`, `robot-docs guide`, `--describe`, and `--schema`, with a uniform 3-code exit contract (`0` clean, `1` domain-negative, `2` structured `E_UPPERCASE` refusal with a literal `next_command` when mechanical recovery exists).
- **Zero-retention defaults and ambient provenance:** `shape`, `rvl`, and `redline` redact raw values and document text unless `--explicit` is passed; CLI runs record hash-chained receipts to `~/.cmdrvl/state/witness/witness.jsonl` (`--no-witness` to disable).

## Give This to Your Agent

Paste [`SYSTEM_PROMPT.md`](./SYSTEM_PROMPT.md) into your agent's system prompt, or point it at [`AGENT_PROMPT.md`](./AGENT_PROMPT.md) for the full operator guide and refusal recovery table.

---

## Core Verification Stack

| Repo | What it does |
|------|-------------|
| **[web](https://github.com/cmdrvl/web)** | Browser WebAssembly build of CMD+RVL (`@cmdrvl/web`). **Live today:** `verify_ground_json`, `verify_ground_multi_json`, `redline_compare`, `sha256_hex`, `blake3_hex`, `engine_info`, plus a ready-to-paste Claude Artifact verifier prompt. |
| **[redline](https://github.com/cmdrvl/redline)** | Deterministic prose and HTML diff reporting exact `[start, end)` byte spans in original files, classifying `numeric_changed`, `clause_added`, `clause_removed`, and `formatting_only` (available from source and in Browser WASM via `web`) |
| **[verify](https://github.com/cmdrvl/verify)** | Evaluates declared single-table and cross-relation constraints (`verify.constraint.v1`) plus quote and numeric-scale grounding (`verify ground`) |
| **[shape](https://github.com/cmdrvl/shape)** | Structural comparability gate: checks schema overlap, key uniqueness, granularity, and type shifts before you diff |
| **[rvl](https://github.com/cmdrvl/rvl)** | Finds the smallest ranked set of numeric cells explaining >=95% of unscaled change, or proves nothing moved above tolerance |
| **[lock](https://github.com/cmdrvl/lock)** | `Cargo.lock` for data: pins artifacts, hashes, fingerprints, and tool versions into a self-hashed JSON lockfile |
| **[pack](https://github.com/cmdrvl/pack)** | Bundles lockfiles, reports, profiles, and registries into a closed-set, content-addressed evidence pack verifiable offline (`pack verify`) |
| **[receipts](https://github.com/cmdrvl/receipts)** | One-command MIT skills for Claude Code, Codex, Gemini CLI, and Cursor wrapping `shape`, `rvl`, and `pack` into 30-second verifiable CSV receipts |
| **[cmdrvl](https://github.com/cmdrvl/cmdrvl)** | *(Early scaffolding)* Unified porcelain CLI front door (`orient`, `inspect`, `diff`, `check`, `receipt`, `doctor`, plus git-style `cmdrvl-<subcommand>` plugin dispatch) |

Typical CLI pipeline: `shape` -> `rvl` / `verify` -> `pack` (add `lock` upstream for pinned input hashes).

---

## Supporting Infrastructure & Adjacent Tools

The repositories below support larger data pipelines, local agent workflows, and our commercial stack. They share the same refusal and contract model, and can be adopted independently when needed.

<details>
<summary>Data prep, provenance, and grading (profile, fingerprint, canon, assess, benchmark, vacuum, hashbytes, decoding)</summary>

| Repo | What it does |
|------|-------------|
| **[profile](https://github.com/cmdrvl/profile)** | Drafts, lints, slices preambles, suggests keys, and freezes immutable SHA-256 column-scoping configs for downstream tools |
| **[fingerprint](https://github.com/cmdrvl/fingerprint)** | Deterministic template recognition and content hashing across CSV, Excel (`.xlsx`/`.xls`), PDF, HTML, and Markdown |
| **[canon](https://github.com/cmdrvl/canon)** | Deterministic identifier and entity resolution against versioned local registries, plus evidence sessions and crosswalk exports |
| **[assess](https://github.com/cmdrvl/assess)** | Turns upstream evidence bundles into a deterministic `PROCEED` / `PROCEED_WITH_RISK` / `ESCALATE` / `BLOCK` verdict from versioned policy YAML |
| **[benchmark](https://github.com/cmdrvl/benchmark)** | Scores candidate extractions against human-validated gold assertions, separating `wrong_value` (accuracy) from `missing` (coverage) |
| **[vacuum](https://github.com/cmdrvl/vacuum)** | Enumerates directories into a deterministic sorted JSONL manifest (ships `vacuum` and `s3-to-vacuum`) |
| **[hashbytes](https://github.com/cmdrvl/hash)** | Constant-memory, parallel SHA-256 / BLAKE3 byte identity over manifest streams (Homebrew formula: `cmdrvl-hash`) |
| **[decoding](https://github.com/cmdrvl/decoding)** | Deterministic convergence engine that settles conflicting multi-source claims with source-ancestry deduplication |

</details>

<details>
<summary>Agent boundaries & local SDLC twins (veil, airlock, boundary-detectors, twinning)</summary>

| Repo | What it does |
|------|-------------|
| **[veil](https://github.com/cmdrvl/veil)** | Advisory, hook-based read-boundary guard that blocks direct agent reads (`Read`, `Grep`, `Bash`) of protected paths while allowing authorized metadata-safe local tools (includes a published bypass matrix) |
| **[airlock](https://github.com/cmdrvl/airlock)** | Model-boundary manifest emitter that records and locally Ed25519-signs the exact payload fragments and claim levels (`RAW_DOCUMENT_ABSENT`, `STRICT_TELEMETRY_ONLY`) sent across a model boundary |
| **[boundary-detectors](https://github.com/cmdrvl/boundary-detectors)** | Shared `#![forbid(unsafe_code)]` pure-Rust detectors (secrets, PII, tabular dumps, blobs, paths, magic bytes, and shingle Bloom filters) powering `veil` and `airlock` |
| **[twinning](https://github.com/cmdrvl/twinning)** | Runnable local wire-protocol twins of **Postgres (`pgwire`)**, **Snowflake (HTTP + Arrow IPC)**, **OpenAPI 3.x REST**, and **MCP (JSON-RPC 2.0)** with millisecond snapshots and migration equivalence receipts |

</details>

<details>
<summary>Shared libraries, SEC/EDGAR tools, and packaging</summary>

| Repo | What it does |
|------|-------------|
| **[core](https://github.com/cmdrvl/core)** | Zero-I/O Rust primitives shared across CLI and WASM builds: canonical JSON, prefixed hashes, `lock.v0` verification, refusal types, and zero-retention redaction markers |
| **[tabular](https://github.com/cmdrvl/tabular)** | Shared deterministic Rust tabular reader (`CSV`, `TSV`, `JSONL`, `Parquet`, `XLSX`) with one cell model and refusal taxonomy |
| **[evidence-protocol](https://github.com/cmdrvl/evidence-protocol)** | Public `.v0` wire contracts (`inquiry`, `grant`, `artifact`, `plan`, `receipt`, `answer`, `capability`, `control`), JSON Schemas, and fixtures |
| **[spine-rules](https://github.com/cmdrvl/spine-rules)** | Shared golden-rules test macro (`golden_rules_suite!`), composite-key conformance, `operator.v1` + `cmdrvl.doctor.v1` contracts, and `ast-grep` static checks |
| **[cmdrvl-xew](https://github.com/cmdrvl/cmdrvl-xew)** | Detects enforcement-fragile XBRL patterns in SEC filings and emits reproducible Evidence Packs |
| **[edgar-change-interpreter](https://github.com/cmdrvl/edgar-change-interpreter)** | Claude skill for spotting material changes, silent risks, and interpretation traps in SEC 10-K/10-Q/8-K filings |
| **[edgar-fabric-ingest](https://github.com/cmdrvl/edgar-fabric-ingest)** | TypeScript reference CLI for ingesting EDGAR disclosures into an append-only CQRS context layer |
| **[regret](https://github.com/cmdrvl/regret)** | Mines git history for high-precision swarm rework signals: reverts, linked fixes, and patch-id matches |
| **[homebrew-tap](https://github.com/cmdrvl/homebrew-tap)** | Homebrew formulae and bottles for CMD+RVL CLI binaries |

</details>

---

## Get Started

### Web Mode (Browser WebAssembly)

Build the browser WASM bundle from [`cmdrvl/web`](https://github.com/cmdrvl/web):

```bash
git clone https://github.com/cmdrvl/web.git && cd web
rustup target add wasm32-unknown-unknown
wasm-pack build --target web --release --out-dir pkg -- --features wasm
```

For an instant Claude Artifact verifier with no build step, copy [`examples/claude-artifact-prompt.md`](https://github.com/cmdrvl/web/blob/main/examples/claude-artifact-prompt.md).

### CLI Mode (Homebrew)

Core verification stack:

```bash
brew install cmdrvl/tap/{shape,rvl,verify,lock,pack}
```

Full CLI suite via Homebrew:

```bash
brew install cmdrvl/tap/{vacuum,cmdrvl-hash,fingerprint,profile,lock,shape,rvl,verify,cmdrvl-benchmark,assess,canon,pack,veil,airlock,twinning,decoding}
```

*(`cmdrvl-hash` installs `hashbytes`; `cmdrvl-benchmark` installs `benchmark`; `vacuum` installs `vacuum` and `s3-to-vacuum`; `twinning` installs `twinning` and `twinning-mcp`.)*

### One-Command Agent Skills (Claude Code, Codex, Gemini CLI, Cursor)

```bash
curl -fsSL https://raw.githubusercontent.com/cmdrvl/receipts/main/install.sh | bash
```

---

## Links

- [cmdrvl.com](https://cmdrvl.com)
- [Browser WASM (`cmdrvl/web`)](https://github.com/cmdrvl/web)
- [MCP servers](https://cmdrvl.com/mcp-servers/)
- [signals.cmdrvl.com](https://signals.cmdrvl.com)
- [dealcharts.org](https://dealcharts.org)
- [@cmdrvl](https://x.com/cmdrvl) on X
