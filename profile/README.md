# CMD+RVL

**Deterministic Rust infrastructure for verifiable data, document, and AI agent workflows.**

One `#![forbid(unsafe_code)]` Rust verification core, two runtimes: run locally as composable **CLI tools** for engineers and AI agents, or compile to **Browser WebAssembly (`@cmdrvl/web`)** for zero-upload verification inside static webpages, internal tools, and Claude Artifacts.

AI models are strong at orchestration and weak at silent math, schema drift, byte-accurate citations, and data boundaries. CMD+RVL keeps the model at the edges while moving diffs, quote grounding, schema gates, PII boundaries, and evidence sealing into deterministic, offline-verifiable Rust backed by versioned artifacts (profiles, rules, registries, lockfiles, and sealed evidence packs).

---

## Choose Your Mode: Web (WASM) vs. CLI

Both modes execute the same compiled Rust verification code and emit the same JSON schemas. Pick the runtime that fits where the data lives.

| If you want to... | Use | How it runs |
|---|---|---|
| **Verify documents or diffs in a browser with zero file uploads** (static sites, interactive research, internal tools, Claude Artifacts) | **[`@cmdrvl/web`](https://github.com/cmdrvl/web)** | Compiled serial `wasm32-unknown-unknown` in the user's browser tab. Zero server, zero upload, works offline and in Safari with no `SharedArrayBuffer` or COOP/COEP headers. |
| **Give an AI coding agent or CI pipeline deterministic local tools** (tabular diffs, schema gates, PII guards, local DB twins, offline evidence packs) | **[CLI Suite (`homebrew-tap`)](https://github.com/cmdrvl/homebrew-tap)** | Fast native Rust binaries installed via Homebrew. Self-describing JSON contracts, typed refusals with recovery commands, and zero-retention defaults. |
| **Add 30-second verifiable CSV receipts to Claude Code, Codex, Gemini CLI, or Cursor** | **[`receipts`](https://github.com/cmdrvl/receipts)** | One-line skill installer wrapping `shape`, `rvl`, and `pack`. |
| **Connect an agent to public and licensed financial/SEC datasets** | **[`mcp-servers`](https://cmdrvl.com/mcp-servers/)** | Hosted MCP servers paired with local verification and sealing. |

---

## Why CMD+RVL Stands Out

1. **Same verified Rust code in CLI and Browser WebAssembly (`cmdrvl/web`):** Browser mode wraps the real Rust verification crates (`verify-engine`, `redline`, `sha2`, `blake3`) directly rather than a JavaScript reimplementation. A reader can open a static report, disconnect Wi-Fi, drop their own copy of a source filing into the tab, and verify every quote span, numeric scale, `lock.v0` hash, and semantic redline locally. Teams can also let LLMs or analysts generate custom HTML views or Claude Artifacts while keeping all verification inside one audited, zero-network WASM binary.
2. **Exact answers and byte-span receipts instead of LLM guesses:** [`shape`](https://github.com/cmdrvl/shape) blocks incomparable diffs before bad math runs; [`rvl`](https://github.com/cmdrvl/rvl) isolates the smallest set of numeric cells explaining >=95% of change; [`redline`](https://github.com/cmdrvl/redline) compares two 5.5 MB filings in about half a second while separating `numeric_changed` and `clause_added` from `formatting_only` and pointing at exact `[start, end)` byte ranges in the original files; [`verify`](https://github.com/cmdrvl/verify) checks declared invariants and grounds verbatim quotes + numeric scales (`verify ground`); [`pack`](https://github.com/cmdrvl/pack) seals content-addressed bundles anyone can verify offline years later (`pack verify`).
3. **Zero-retention and zero-exfiltration by default:** `shape`, `rvl`, and `redline` redact raw values and document text unless `--explicit` is passed. [`veil`](https://github.com/cmdrvl/veil) blocks AI agents from directly reading sensitive files (`Read`, `Grep`, `Bash`) while allowing authorized local tools to run and return only verdicts. [`airlock`](https://github.com/cmdrvl/airlock) emits cryptographic boundary manifests (`RAW_DOCUMENT_ABSENT`, `STRICT_TELEMETRY_ONLY`) proving what crossed into a model. In browser WASM mode, user files never leave the browser tab.
4. **Built for headless AI agents from day one:** Every CLI supports read-only self-discovery (`--robot-triage`, `capabilities --json`, `robot-docs guide`, `--describe`, `--schema`), a uniform 3-code exit contract (`0` clean, `1` domain-negative, `2` structured `E_UPPERCASE` refusal with a literal `next_command` when mechanical recovery exists), and ambient hash-chained provenance at `~/.cmdrvl/state/witness/witness.jsonl` (`--no-witness` to disable).
5. **Local wire-protocol twins before touching production:** [`twinning`](https://github.com/cmdrvl/twinning) runs ephemeral local Postgres (`pgwire`), Snowflake (HTTP + Arrow IPC), OpenAPI 3.x REST, and MCP twins with millisecond resets, embedded `verify` checks, and `twinning proof twin-pair` migration equivalence receipts.

---

## What This Looks Like in Practice

### In the Browser (`@cmdrvl/web` WASM, zero server / zero upload)

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
  Checked: 4,183 rows, 12 numeric columns (50,196 cells)
  3 cells explain 95.2% of total numeric change (threshold 95.0%):
    1. NVDA.market_value  +1842100  (123 -> 1842223)
    2. UST10Y.price       -0.37     (4.21 -> 3.84)
    3. EURUSD.fx_rate     +0.0013   (1.0842 -> 1.0855)

$ pack verify evidence/2026-q4/
pack verify: OK                             # content-addressed, verified offline
  pack_id: sha256:71cd27ee3a69cf0e...
```

When files are sensitive, [`veil`](https://github.com/cmdrvl/veil) enforces the read boundary while still letting the agent run verification tools:

```text
BLOCK:  cat client_tape.csv             -> raw bytes would enter model context
BLOCK:  Read / Grep on client_tape.csv  -> raw bytes would enter model context
ALLOW:  shape / rvl / verify / pack     -> subprocess runs locally; only verdicts return
```

---

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
| **[veil](https://github.com/cmdrvl/veil)** | Preventive read-boundary guard that blocks direct agent reads (`Read`, `Grep`, `Bash`) of sensitive files while allowing authorized metadata-safe local tools |
| **[airlock](https://github.com/cmdrvl/airlock)** | Cryptographic model-boundary attestation emitting proof manifests of the exact fragments and claim levels (`RAW_DOCUMENT_ABSENT`, `STRICT_TELEMETRY_ONLY`) that crossed into a model |
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
| **[knownby](https://github.com/cmdrvl/knownby)** | Point-in-time financial facts benchmark and citation evals |
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
