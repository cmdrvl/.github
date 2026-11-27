# CMD+RVL

**Deterministic Rust verification for data, documents, and AI agents.**

AI models are strong at orchestration and weak at silent math, schema drift, byte-accurate citations, and data boundaries. CMD+RVL moves diffs, quote grounding, schema gates, PII boundaries, and evidence sealing into deterministic, offline-verifiable Rust backed by versioned artifacts (profiles, rules, registries, lockfiles, and sealed evidence packs).

It runs two ways: locally as **CLI tools** for engineers and AI agents, or directly in a **browser tab** ([`@cmdrvl/web`](https://github.com/cmdrvl/web)) with zero server and zero file uploads.

---

## What You Can Do With CMD+RVL

- **Let your team build Claude Artifacts and custom AI tools on top of approved verification.** Instead of trusting LLM-written math inside ad-hoc apps, standardize on one zero-network browser engine ([`@cmdrvl/web`](https://github.com/cmdrvl/web)). Analysts and AI can build custom views or Claude Artifacts for every workflow while every hash, quote check, and redline comes from the same auditable, `#![forbid(unsafe_code)]` Rust code.
- **Read and diff hundreds of SEC filings, contracts, or data tapes in seconds without burning LLM tokens.** [`redline`](https://github.com/cmdrvl/redline) compares two 5.5 MB 10-K filings in about half a second, strips CSS and reflow noise, and flags only real numeric and clause changes with exact original byte offsets. [`rvl`](https://github.com/cmdrvl/rvl) checks large spreadsheets or database exports and isolates the smallest set of cells explaining >=95% of unscaled numeric movement (best used on single-unit tables or columns scoped via `--profile`), while [`shape`](https://github.com/cmdrvl/shape) stops incomparable files before bad math runs.
- **Publish research and AI reports readers can verify themselves, even offline.** Ship a static page or interactive report backed by `@cmdrvl/web`: every quoted passage and number checks locally in the reader's browser, and readers can drop their own copy of the source filing into the tab to prove nothing was edited.
- **Keep raw confidential files out of agent prompts by default.** [`veil`](https://github.com/cmdrvl/veil) uses advisory, parser-based tool hooks to block coding agents from opening or printing protected paths (`Read`, `Grep`, `Bash`) while letting them run local verification tools that return only verdicts and redacted summaries (see `veil`'s published bypass matrix for hook-only boundaries). [`airlock`](https://github.com/cmdrvl/airlock) writes a locally signed Ed25519 manifest recording the exact payload bytes that crossed into a model so post-signing edits are detectable. In web mode, files never leave the user's browser tab at all.
- **Rehearse AI queries and migrations locally before touching production.** [`twinning`](https://github.com/cmdrvl/twinning) runs fast local twins of Postgres, Snowflake, REST APIs, and MCP servers with millisecond resets, embedded rule checks, and migration equivalence proofs.
- **Crowdsource your company brain without moving your data.** Every time a team member or agent cracks a messy file format, maps an entity identifier, scopes noisy columns, or writes a business check, [`fingerprint`](https://github.com/cmdrvl/fingerprint), [`canon`](https://github.com/cmdrvl/canon), [`profile`](https://github.com/cmdrvl/profile), [`verify`](https://github.com/cmdrvl/verify), and [`assess`](https://github.com/cmdrvl/assess) capture that institutional knowledge as small, versioned metadata artifacts (templates, key mappings, lenses, and rules). Your organization accumulates shared business logic while raw client and financial files stay where they already live.
- **Hand auditors a portable receipt that still verifies offline years later.** [`lock`](https://github.com/cmdrvl/lock) and [`pack`](https://github.com/cmdrvl/pack) bundle exact input hashes, rules, profiles, and verdicts into one content-addressed folder that anyone holding the pinned `pack_id` can verify offline with `pack verify` (no server, no account, no vendor lock-in).

---

## Choose Your Mode: Web (Browser) vs. CLI

Both modes run the same compiled Rust verification crates and emit the same JSON schemas (in browser mode, `lock.v0` input pinning is optional for ad-hoc drag-and-drop checks, whereas the `verify ground` CLI requires `--lock`). Pick the mode that fits where your files live.

| If you want to... | Use | How it runs |
|---|---|---|
| **Give analysts, clients, or readers zero-upload verification in a browser** (static pages, interactive research, internal tools, Claude Artifacts) | **[`@cmdrvl/web`](https://github.com/cmdrvl/web)** | Compiled serial WebAssembly in the user's browser tab. Zero server, zero upload, works offline and in Desktop/iPhone Safari with no special server headers. |
| **Give an AI coding agent or CI pipeline deterministic local tools** (tabular diffs, schema gates, PII guards, local DB twins, offline evidence packs) | **[CLI Suite (`homebrew-tap`)](https://github.com/cmdrvl/homebrew-tap)** | Fast native Rust binaries via Homebrew. Self-describing JSON contracts, typed refusals with recovery commands, and zero-retention defaults. |
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

When files are sensitive, [`veil`](https://github.com/cmdrvl/veil) acts as an advisory hook-based read guard while still letting the agent run verification tools:

```text
BLOCK:  cat client_tape.csv             -> raw bytes would enter model context
BLOCK:  Read / Grep on client_tape.csv  -> raw bytes would enter model context
ALLOW:  shape / rvl / verify / pack     -> subprocess runs locally; only verdicts return
```

---

## Engineering Guarantees

- **One `#![forbid(unsafe_code)]` Rust codebase for CLI and Web:** `@cmdrvl/web` wraps the real Rust verification crates (`verify-engine`, `redline`, `sha2`, `blake3`) in serial `wasm32-unknown-unknown` with no `SharedArrayBuffer` or COOP/COEP headers required.
- **Built for headless AI agents:** Every CLI exposes `--robot-triage`, `capabilities --json`, `robot-docs guide`, `--describe`, and `--schema`, with a uniform 3-code exit contract (`0` clean, `1` domain-negative, `2` structured `E_UPPERCASE` refusal with a literal `next_command` when mechanical recovery exists).
- **Zero-retention defaults and ambient provenance:** `shape`, `rvl`, and `redline` redact raw values and document text unless `--explicit` is passed; CLI runs record hash-chained receipts to `~/.cmdrvl/state/witness/witness.jsonl` (`--no-witness` to disable).

## Give This to Your Agent

Paste [`SYSTEM_PROMPT.md`](./SYSTEM_PROMPT.md) into your agent's system prompt, or point it at [`AGENT_PROMPT.md`](./AGENT_PROMPT.md) for the full operator guide and refusal recovery table.

---

## The Stack

### 1. Browser WebAssembly (Zero-Upload Web Mode)

Run deterministic CMD+RVL verification directly inside static websites, interactive publications, internal tools, and Claude Artifacts.

| Repo | What it does |
|------|-------------|
| **[web](https://github.com/cmdrvl/web)** | Serial `wasm32-unknown-unknown` build of CMD+RVL (`@cmdrvl/web`). **Live today:** `verify_ground_json`, `verify_ground_multi_json`, `redline_compare`, `sha256_hex`, `blake3_hex`, `engine_info`, plus a ready-to-paste Claude Artifact verifier prompt. **Actively wiring in:** `shape`, `rvl`, `boundary-detectors`, `fingerprint`, `canon`, `profile`, `assess`, and published npm + single-file inline-WASM bundles. |

### 2. Data Diffs, Document Redlines, Gates & Grading

Stop agents from diffing incomparable files, drowning in noisy deltas, losing byte offsets in filings, or conflating wrong values with missing coverage.

| Tool | What it does |
|------|-------------|
| **[shape](https://github.com/cmdrvl/shape)** | Structural comparability gate: checks schema overlap, key uniqueness, granularity, and type shifts before you diff |
| **[rvl](https://github.com/cmdrvl/rvl)** | Finds the smallest ranked set of numeric cells explaining >=95% of change, or proves nothing moved above tolerance |
| **[redline](https://github.com/cmdrvl/redline)** | Deterministic prose and HTML diff reporting exact `[start, end)` byte spans in original files, classifying `numeric_changed`, `clause_added`, `clause_removed`, and `formatting_only` (available from source and in Browser WASM via `web`) |
| **[verify](https://github.com/cmdrvl/verify)** | Evaluates declared single-table and cross-relation constraints (`verify.constraint.v1`) plus verbatim quote and numeric-scale grounding (`verify ground`) |
| **[benchmark](https://github.com/cmdrvl/benchmark)** | Scores candidate extractions against human-validated gold assertions, separating `wrong_value` (accuracy) from `missing` (coverage) |
| **[assess](https://github.com/cmdrvl/assess)** | Turns upstream evidence bundles into a deterministic `PROCEED` / `PROCEED_WITH_RISK` / `ESCALATE` / `BLOCK` verdict from versioned policy YAML |
| **[profile](https://github.com/cmdrvl/profile)** | Drafts, lints, slices preambles, suggests keys, and freezes immutable SHA-256 column-scoping configs for downstream tools |

### 3. Zero-Exfiltration Agent Boundaries

Keep raw sensitive files out of LLM prompts, and prove what crossed the model boundary.

| Tool | What it does |
|------|-------------|
| **[veil](https://github.com/cmdrvl/veil)** | Advisory, hook-based read-boundary guard that blocks direct agent reads (`Read`, `Grep`, `Bash`) of protected paths while allowing authorized metadata-safe local tools (includes a published bypass matrix) |
| **[airlock](https://github.com/cmdrvl/airlock)** | Model-boundary manifest emitter that records and locally Ed25519-signs the exact payload fragments and claim levels (`RAW_DOCUMENT_ABSENT`, `STRICT_TELEMETRY_ONLY`) sent across a model boundary |
| **[boundary-detectors](https://github.com/cmdrvl/boundary-detectors)** | Shared `#![forbid(unsafe_code)]` pure-Rust detectors (secrets, PII, tabular dumps, blobs with recursive base64/hex decode, paths, magic bytes, and one-way shingle Bloom filters) powering `veil` and `airlock` |

### 4. Wire-Protocol SDLC Twins

Rehearse agent extractors, SQL migrations, and API clients locally before touching production.

| Tool | What it does |
|------|-------------|
| **[twinning](https://github.com/cmdrvl/twinning)** | Runnable local wire-protocol twins of **Postgres (`pgwire`)**, **Snowflake (HTTP + Arrow IPC)**, **OpenAPI 3.x REST**, and **MCP (JSON-RPC 2.0)** with embedded `verify` constraints, millisecond snapshots, and `twinning proof twin-pair` migration equivalence receipts |

### 5. Identity, Provenance & Evidence Sealing

Pin inputs, recognize document templates, resolve canonical IDs, and seal tamper-evident bundles verifiable offline years later.

| Tool | What it does |
|------|-------------|
| **[canon](https://github.com/cmdrvl/canon)** | Exact deterministic identifier and entity resolution against versioned local registries, plus evidence sessions and `dbt-seed` / `search-index` / `key-crosswalk` exports |
| **[fingerprint](https://github.com/cmdrvl/fingerprint)** | Deterministic template recognition and content hashing across CSV, Excel (`.xlsx`/`.xls`), PDF, HTML, and Markdown with corpus `infer`, chained family routing, and zero-content `peek` |
| **[vacuum](https://github.com/cmdrvl/vacuum)** | Enumerates directories into a deterministic sorted JSONL manifest (ships `vacuum` and `s3-to-vacuum`) |
| **[hashbytes](https://github.com/cmdrvl/hash)** | Constant-memory, parallel SHA-256 / BLAKE3 byte identity over manifest streams (Homebrew formula: `cmdrvl-hash`) |
| **[lock](https://github.com/cmdrvl/lock)** | `Cargo.lock` for data: pins artifacts, hashes, fingerprints, and tool versions into a self-hashed JSON lockfile |
| **[pack](https://github.com/cmdrvl/pack)** | Bundles lockfiles, reports, profiles, and registries into a closed-set, content-addressed evidence pack verifiable offline (`pack verify`) |

### 6. Agent Skills, Unified CLI & Shared Libraries

| Repo | What it does |
|------|-------------|
| **[receipts](https://github.com/cmdrvl/receipts)** | One-command MIT skills for Claude Code, Codex, Gemini CLI, and Cursor wrapping `shape`, `rvl`, and `pack` into 30-second verifiable CSV receipts |
| **[cmdrvl](https://github.com/cmdrvl/cmdrvl)** | *(Early scaffolding)* Unified porcelain CLI front door (`orient`, `inspect`, `diff`, `check`, `receipt`, `twin`, `sandbox`, `doctor`, plus git-style `cmdrvl-<subcommand>` plugin dispatch) |
| **[core](https://github.com/cmdrvl/core)** | Zero-I/O Rust primitives shared across CLI and WASM builds: canonical JSON, prefixed hashes, `lock.v0` verification, refusal types, and zero-retention redaction markers |
| **[tabular](https://github.com/cmdrvl/tabular)** | Shared deterministic Rust tabular reader (`CSV`, `TSV`, `JSONL`, `Parquet`, `XLSX`) with one cell model and refusal taxonomy |
| **[evidence-protocol](https://github.com/cmdrvl/evidence-protocol)** | Public `.v0` wire contracts (`inquiry`, `grant`, `artifact`, `plan`, `receipt`, `answer`, `capability`, `control`), JSON Schemas, and fixtures |
| **[spine-rules](https://github.com/cmdrvl/spine-rules)** | Shared golden-rules test macro (`golden_rules_suite!`), composite-key conformance, `operator.v1` + `cmdrvl.doctor.v1` contracts, and `ast-grep` static checks |
| **[decoding](https://github.com/cmdrvl/decoding)** | Deterministic convergence engine that settles conflicting multi-source claims with source-ancestry deduplication and bounded escalations |

Typical CLI pipeline: `shape` -> `rvl` / `verify` / `benchmark` -> `assess` -> `pack`. Add `vacuum` -> `hashbytes` -> `fingerprint` -> `lock` upstream for full input provenance.

<details>
<summary>More repos: SEC/EDGAR, financial benchmarks, and git observability</summary>

| Repo | What it does |
|------|-------------|
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

Core verification, privacy, and twin stack:

```bash
brew install cmdrvl/tap/{shape,rvl,verify,cmdrvl-benchmark,assess,pack,veil,airlock,twinning}
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
