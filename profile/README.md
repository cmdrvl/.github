# CMD+RVL

**Deterministic Rust infrastructure for agentic data workflows.**

*The model sits at the boundaries. The middle is deterministic, local, and offline-verifiable.*

AI coding agents are great at orchestration and terrible at silent math, schema drift, and data boundaries. CMD+RVL gives agents **exact, checkable facts instead of guesses**: small, local, MIT-licensed Rust CLIs backed by versioned artifacts (profiles, rules, registries, snapshots, lockfiles) instead of ad-hoc logic buried in prompts or one-off scripts.

---

## What this looks like in practice

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

And when data is sensitive, **`veil`** enforces the read boundary while still letting the agent run the tools:

```text
BLOCK:  cat client_tape.csv             -> raw bytes would enter model context
BLOCK:  Read / Grep on client_tape.csv  -> raw bytes would enter model context
ALLOW:  shape / rvl / verify / pack     -> subprocess runs locally; only verdicts return
```

---

## Give this to your agent

Paste [`SYSTEM_PROMPT.md`](./SYSTEM_PROMPT.md) into your agent's context, or point it at [`AGENT_PROMPT.md`](./AGENT_PROMPT.md) for the full operator guide.

Every spine tool is built for headless agents from day one:
- **Self-describing:** `--robot-triage`, `capabilities --json`, `robot-docs guide`, `--describe`, and `--schema` expose contracts directly from the binary.
- **Refusals are handoffs, not dead ends:** when a tool cannot answer safely, it exits with a typed `E_UPPERCASE` refusal, structured `detail`, and a literal `next_command` when mechanical recovery is possible.
- **Zero-retention defaults & ambient provenance:** `shape` and `rvl` redact raw values unless `--explicit` is passed; runs record hash-chained receipts to `~/.cmdrvl/state/witness/witness.jsonl` (`--no-witness` to disable).

Pair these local tools with our [MCP servers](https://cmdrvl.com/mcp-servers/) — the CLIs verify, resolve, and seal what your agent has locally; the MCP servers give it public and licensed data to check against.

---

## The Stack

### 1. Data Diffs, Gates & Grading
Stop agents from diffing incomparable files, drowning in noisy deltas, or conflating wrong extractions with missing coverage.

| Tool | What it does |
|------|-------------|
| **[shape](https://github.com/cmdrvl/shape)** | Structural comparability gate — checks schema overlap, key uniqueness, granularity, and type shifts before you diff |
| **[rvl](https://github.com/cmdrvl/rvl)** | Finds the smallest ranked set of numeric cells explaining ≥95% of change — or proves nothing moved above tolerance |
| **[verify](https://github.com/cmdrvl/verify)** | Evaluates declared single-table and cross-relation constraints (`verify.constraint.v1`) with row- and field-level failure localization |
| **[benchmark](https://github.com/cmdrvl/benchmark)** | Scores candidate extractions against human-validated gold assertions, separating `wrong_value` (accuracy) from `missing` (coverage) |
| **[assess](https://github.com/cmdrvl/assess)** | Turns upstream evidence bundles into a deterministic `PROCEED` / `PROCEED_WITH_RISK` / `ESCALATE` / `BLOCK` verdict from versioned policy YAML |
| **[profile](https://github.com/cmdrvl/profile)** | Drafts, lints, slices preambles, suggests keys, and freezes immutable SHA-256 column-scoping configs for downstream tools |

### 2. Zero-Exfiltration Agent Boundaries
Keep raw sensitive files out of LLM prompts — and prove what crossed the boundary.

| Tool | What it does |
|------|-------------|
| **[veil](https://github.com/cmdrvl/veil)** | Preventive read-boundary guard that blocks direct agent reads (`Read`/`Grep`/`Bash`) of sensitive files while allowing authorized spine subprocesses |
| **[airlock](https://github.com/cmdrvl/airlock)** | Cryptographic model-boundary attestation — emits proof manifests of the exact fragments and claim levels (`RAW_DOCUMENT_ABSENT`, `STRICT_TELEMETRY_ONLY`) that crossed into a model |

### 3. Wire-Protocol SDLC Twins
Rehearse agent extractors, SQL migrations, and API clients locally before touching production.

| Tool | What it does |
|------|-------------|
| **[twinning](https://github.com/cmdrvl/twinning)** | Runnable local wire-protocol twins of **Postgres (`pgwire`)**, **Snowflake (HTTP + Arrow IPC)**, **OpenAPI 3.x REST**, and **MCP (JSON-RPC 2.0)** — with embedded `verify` constraints, snapshots, and `twinning proof twin-pair` migration equivalence receipts |

### 4. Identity, Provenance & Evidence Sealing
Pin inputs, recognize document templates, resolve canonical IDs, and seal tamper-evident bundles you can verify offline years later.

| Tool | What it does |
|------|-------------|
| **[canon](https://github.com/cmdrvl/canon)** | Exact deterministic identifier and entity resolution against versioned local registries, plus evidence sessions and `dbt-seed` / `search-index` / `key-crosswalk` exports |
| **[fingerprint](https://github.com/cmdrvl/fingerprint)** | Deterministic template recognition and content hashing across CSV, Excel (`.xlsx`/`.xls`), PDF, HTML, and Markdown — with corpus `infer`, chained family routing, and zero-content `peek` |
| **[vacuum](https://github.com/cmdrvl/vacuum)** | Enumerates directories into a deterministic sorted JSONL manifest (ships `vacuum` and `s3-to-vacuum`) |
| **[hashbytes](https://github.com/cmdrvl/hash)** | Constant-memory, parallel SHA-256 / BLAKE3 byte identity over manifest streams (Homebrew formula: `cmdrvl-hash`) |
| **[lock](https://github.com/cmdrvl/lock)** | `Cargo.lock` for data — pins artifacts, hashes, fingerprints, and tool versions into a self-hashed JSON lockfile |
| **[pack](https://github.com/cmdrvl/pack)** | Bundles lockfiles, reports, profiles, and registries into a closed-set, content-addressed evidence pack verifiable offline (`pack verify`) |

### Agent Skills, Umbrella CLI & Shared Libraries

| Repo | What it does |
|------|-------------|
| **[receipts](https://github.com/cmdrvl/receipts)** | One-command MIT skills for Claude Code, Codex, Gemini CLI, and Cursor wrapping `shape` → `rvl` → `pack` into 30-second verifiable CSV receipts |
| **[cmdrvl](https://github.com/cmdrvl/cmdrvl)** | *(Early scaffolding)* Unified porcelain CLI front door (`orient`, `inspect`, `diff`, `check`, `receipt`, `twin`, `sandbox`, `doctor`, plus git-style `cmdrvl-<subcommand>` plugin dispatch) for the spine |
| **[evidence-protocol](https://github.com/cmdrvl/evidence-protocol)** | Public `.v0` wire contracts (`inquiry`, `grant`, `artifact`, `plan`, `receipt`, `answer`, `capability`, `control`), JSON Schemas, and fixtures |
| **[spine-rules](https://github.com/cmdrvl/spine-rules)** | Shared golden-rules test macro (`golden_rules_suite!`), composite-key conformance, `operator.v1` + `cmdrvl.doctor.v1` contracts, and `ast-grep` static checks |
| **[tabular](https://github.com/cmdrvl/tabular)** | Shared deterministic Rust tabular reader (`CSV`, `TSV`, `JSONL`, `Parquet`, `XLSX`) with one cell model and refusal taxonomy across spine tools |
| **[boundary-detectors](https://github.com/cmdrvl/boundary-detectors)** | Shared `#![forbid(unsafe_code)]` pure-Rust detectors (secrets, PII, tabular dumps, blobs + recursive base64/hex decode, paths, magic bytes, and one-way shingle Bloom filters) powering `veil` and `airlock` |
| **[decoding](https://github.com/cmdrvl/decoding)** | Deterministic convergence engine that settles conflicting multi-source claims with source-ancestry deduplication and bounded escalations |

Typical pipeline: `shape` → `rvl` / `verify` / `benchmark` → `assess` → `pack`. Add `vacuum` → `hashbytes` → `fingerprint` → `lock` upstream for full input provenance.

<details>
<summary>More repos: SEC/EDGAR, financial benchmarks, and git observability</summary>

| Repo | What it does |
|------|-------------|
| **[cmdrvl-xew](https://github.com/cmdrvl/cmdrvl-xew)** | Detects enforcement-fragile XBRL patterns in SEC filings and emits reproducible Evidence Packs |
| **[edgar-change-interpreter](https://github.com/cmdrvl/edgar-change-interpreter)** | Claude skill for spotting material changes, silent risks, and interpretation traps in SEC 10-K/10-Q/8-K filings |
| **[edgar-fabric-ingest](https://github.com/cmdrvl/edgar-fabric-ingest)** | TypeScript reference CLI for ingesting EDGAR disclosures into an append-only CQRS context layer |
| **[knownby](https://github.com/cmdrvl/knownby)** | Point-in-time financial facts benchmark and citation evals |
| **[regret](https://github.com/cmdrvl/regret)** | Mines git history for high-precision swarm rework signals — reverts, linked fixes, and patch-id matches |
| **[homebrew-tap](https://github.com/cmdrvl/homebrew-tap)** | Homebrew formulae and bottles for all CMD+RVL binaries |

</details>

---

## Install

### Fast path: core verification, privacy & twin stack
```bash
brew install cmdrvl/tap/{shape,rvl,verify,cmdrvl-benchmark,assess,pack,veil,airlock,twinning}
```

### Full spine via Homebrew
```bash
brew install cmdrvl/tap/{vacuum,cmdrvl-hash,fingerprint,profile,lock,shape,rvl,verify,cmdrvl-benchmark,assess,canon,pack,veil,airlock,twinning,decoding}
```
*(`cmdrvl-hash` installs `hashbytes`; `cmdrvl-benchmark` installs `benchmark`; `vacuum` installs `vacuum` and `s3-to-vacuum`; `twinning` installs `twinning` and `twinning-mcp`.)*

### One-command agent skills (Claude Code, Codex, Gemini CLI, Cursor)
```bash
curl -fsSL https://raw.githubusercontent.com/cmdrvl/receipts/main/install.sh | bash
```

---

## Links

- [cmdrvl.com](https://cmdrvl.com)
- [MCP servers](https://cmdrvl.com/mcp-servers/)
- [signals.cmdrvl.com](https://signals.cmdrvl.com)
- [dealcharts.org](https://dealcharts.org)
- [@cmdrvl](https://x.com/cmdrvl) on X
