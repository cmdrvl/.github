# CMD+RVL

**Infrastructure for proving what changed in financial data.**

CMD+RVL builds deterministic tooling, event pipelines, and intelligence layers so that every data change is traceable, every conclusion is reproducible, and every gap is surfaced — not buried.

The open-source CLI tools below are the protocol layer: composable, deterministic Rust binaries that anyone can run. Same bytes in, same answer out, every time. When a confident answer isn't possible, the tool refuses and tells you exactly what to fix.

### Quick start — what changed between two quarterly reports?

```bash
# What's in each quarterly report?
vacuum q3/ q4/ | hash | lock save --name quarterly

# What actually changed?
rvl q3/positions.csv q4/positions.csv
# → 3 of 847 rows changed, net +$2.1M notional, 1 new position

# Seal the evidence
pack create --lock quarterly.lock --include q3/ q4/
# → pack-a7f3b2.pack (content-addressed, tamper-evident)
```

---

## How the tools work

Every CMD+RVL tool follows four rules:

1. **Structured output** — emits JSON with a `version` field (e.g., `rvl.v0`), an `outcome` (domain result), and a `refusal` (when it can't operate)
2. **Self-description** — `--describe` emits a machine-readable operator manifest; `--schema` emits the output JSON Schema
3. **Witness** — appends a content-addressed, hash-chained record to `~/.cmdrvl/witness.jsonl` on every invocation
4. **Determinism** — same inputs, same output, every time. No randomness, no side effects, no network calls in the truth path

Tools that follow the protocol compose automatically: `assess` scores any tool's output via policy rules. `pack` seals any tool's output into tamper-evident evidence. The witness ledger records any tool's invocation. No central coordinator — the protocol is the coordinator.

---

## Reference Implementation

Composable Rust CLIs. Each tool does one thing. Agents decide what to run — these tools decide what is true.

### Shipped

| Tool | What it does | Install |
|------|-------------|---------|
| **[vacuum](https://github.com/cmdrvl/vacuum)** | Enumerates artifacts in scope, emits a deterministic sorted JSONL manifest with size, mtime, and MIME type | `brew install cmdrvl/tap/vacuum` |
| **[hash](https://github.com/cmdrvl/hash)** | Streaming content hashing — adds SHA-256 or BLAKE3 byte identity to every artifact in a manifest | `brew install cmdrvl/tap/hash` |
| **[fingerprint](https://github.com/cmdrvl/fingerprint)** | Template recognition — tests artifacts against versioned assertion-based definitions and produces content hashes | `brew install cmdrvl/tap/fingerprint` |
| **[profile](https://github.com/cmdrvl/profile)** | Column-scoping configs for report tools — draft/freeze lifecycle, deterministic key suggestion, schema linting | `brew install cmdrvl/tap/profile` |
| **[lock](https://github.com/cmdrvl/lock)** | Dataset lockfiles — like Cargo.lock for data. Self-hashed, tamper-evident, with `lock verify` for integrity checks | `brew install cmdrvl/tap/lock` |
| **[shape](https://github.com/cmdrvl/shape)** | Structural comparability gate — can these two datasets be compared at all? | `brew install cmdrvl/tap/shape` |
| **[rvl](https://github.com/cmdrvl/rvl)** | Reveals the smallest set of numeric changes that explain what actually changed between two datasets | `brew install cmdrvl/tap/rvl` |
| **[canon](https://github.com/cmdrvl/canon)** | Deterministic entity resolution — resolves identifiers against versioned registries with full audit trail | `brew install cmdrvl/tap/canon` |
| **[pack](https://github.com/cmdrvl/pack)** | Evidence sealing — bundles lockfiles, reports, and tool outputs into one immutable, content-addressed evidence pack | `brew install cmdrvl/tap/pack` |

All nine tools record to the witness ledger — every invocation is content-addressed, hash-chained, and auditable.

**Typical pipeline:** `vacuum` (what's there?) → `hash` (prove identity) → `fingerprint` (recognize templates) → `lock` (pin inputs) → `shape` (are these comparable?) → `rvl` (what changed?) → `pack` (seal the evidence)

### In Development

| Tool | What it does |
|------|-------------|
| **[verify](https://github.com/cmdrvl/verify)** | Invariant checks — single-artifact rules (JSON) and cross-artifact constraints (SQL via DuckDB) |
| **[benchmark](https://github.com/cmdrvl/benchmark)** | Extraction accuracy scoring — checks (entity, field, value) assertions against candidate datasets |
| **[compare](https://github.com/cmdrvl/compare)** | Exhaustive cell-by-cell diff without materiality compression |
| **[assess](https://github.com/cmdrvl/assess)** | Decision framing — PROCEED / ESCALATE / BLOCK against declared policy |

### SEC EDGAR & Financial Data

| Tool | What it does |
|------|-------------|
| **[cmdrvl-xew](https://github.com/cmdrvl/cmdrvl-xew)** | Detects enforcement-fragile XBRL patterns in SEC filings, produces reproducible Evidence Packs |
| **[edgar-change-interpreter](https://github.com/cmdrvl/edgar-change-interpreter)** | Claude skill for identifying material changes and silent risks in SEC filings |
| **[edgar-fabric-ingest](https://github.com/cmdrvl/edgar-fabric-ingest)** | Reference implementation for ingesting EDGAR disclosures into an append-only event store |

### Developer Tools

| Tool | What it does |
|------|-------------|
| **[regret](https://github.com/cmdrvl/regret)** | Mines git history for high-precision regret signals — reverts, linked fixes, patch-id matches |
| **[twinning](https://github.com/cmdrvl/twinning)** | In-memory database twin that speaks the real wire protocol — fast testing without a real database |

## Agent Integration

These tools are built for agent orchestration. Two reference prompts help agents learn the protocol:

- **[Agent Operator Guide](./AGENT_PROMPT.md)** — workflows, refusal recovery, schema discovery, and the full tool map
- **[System Prompt](./SYSTEM_PROMPT.md)** — compact drop-in for agent context windows (~30 lines)

Every shipped tool supports `<tool> --describe` for machine-readable self-discovery and `<tool> --schema` for runtime JSON Schema output.

## Install

```bash
brew install cmdrvl/tap/vacuum
brew install cmdrvl/tap/hash
brew install cmdrvl/tap/fingerprint
brew install cmdrvl/tap/profile
brew install cmdrvl/tap/lock
brew install cmdrvl/tap/shape
brew install cmdrvl/tap/rvl
brew install cmdrvl/tap/canon
brew install cmdrvl/tap/pack
```

## Links

- [cmdrvl.com](https://cmdrvl.com)
- [signals.cmdrvl.com](https://signals.cmdrvl.com)
- [dealcharts.org](https://dealcharts.org)
- [@cmdrvl](https://x.com/cmdrvl) on X
