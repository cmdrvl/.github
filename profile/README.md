# CMD+RVL

**Verifiable data. Deterministic answers. Tamper-evident proof.**

Data will commoditize. Models will commoditize. What remains scarce is knowing where every number came from — and being able to prove it. CMD+RVL builds open-source tools that verify, explain, and lock data artifacts so every conclusion traces back to source.

Same bytes in, same answer out, every time. When a confident answer isn't possible, the tool refuses and tells you exactly what to fix.

---

## Tools

Composable Rust CLIs. Each tool does one thing and emits structured JSON. Agents decide what to run — these tools decide what is true.

### Shipped

| Tool | What it does | Install |
|------|-------------|---------|
| **[rvl](https://github.com/cmdrvl/rvl)** | Reveals the smallest set of numeric changes that explain what actually changed between two datasets | `brew install cmdrvl/tap/rvl` |
| **[shape](https://github.com/cmdrvl/shape)** | Structural comparability gate — can these two datasets be compared at all? | `brew install cmdrvl/tap/shape` |
| **[lock](https://github.com/cmdrvl/lock)** | Dataset lockfiles — like Cargo.lock for data. Self-hashed, tamper-evident, with `lock verify` for integrity checks | `brew install cmdrvl/tap/lock` |
| **[pack](https://github.com/cmdrvl/pack)** | Evidence sealing — bundles lockfiles, reports, and tool outputs into one immutable, content-addressed evidence pack | `brew install cmdrvl/tap/pack` |

All four tools record to a shared append-only witness ledger (`~/.epistemic/witness.jsonl`) — every invocation is content-addressed, hash-chained, and auditable.

**Typical pipeline:** `shape` (are these comparable?) → `rvl` (what changed?) → `lock` (pin the inputs) → `pack` (seal the evidence)

### In Development

| Tool | What it does |
|------|-------------|
| **[vacuum](https://github.com/cmdrvl/vacuum)** | Enumerates artifacts in scope, emits a stable JSONL manifest |
| **[hash](https://github.com/cmdrvl/hash)** | Exact byte identity (SHA256 / BLAKE3) for dedup and immutability |
| **[fingerprint](https://github.com/cmdrvl/fingerprint)** | Template recognition — tests artifacts against versioned assertions |
| **[profile](https://github.com/cmdrvl/profile)** | Column-scoping configs for report tools |
| **[verify](https://github.com/cmdrvl/verify)** | Invariant checks against declared rules (PASS / FAIL) |
| **[compare](https://github.com/cmdrvl/compare)** | Exhaustive cell-by-cell diff without materiality compression |
| **[canon](https://github.com/cmdrvl/canon)** | Deterministic entity resolution against versioned registries |
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

## Install

```bash
brew install cmdrvl/tap/rvl
brew install cmdrvl/tap/shape
brew install cmdrvl/tap/lock
brew install cmdrvl/tap/pack
```

## Links

- [cmdrvl.com](https://cmdrvl.com)
- [signals.cmdrvl.com](https://signals.cmdrvl.com)
- [dealcharts.org](https://dealcharts.org)
- [@cmdrvl](https://x.com/cmdrvl) on X
