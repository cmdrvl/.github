# CMD+RVL

**Was this decision justified given what was actually available at the time?**

CMD+RVL exists to make decisions made under uncertainty inspectable, defensible, and survivable over time. Data will commoditize. Models will commoditize. What remains scarce is accountability over time.

We build open-source, deterministic CLI tools that establish what can be known, compared, and trusted about data artifacts. Same bytes in, same answer out, every time. When a confident answer isn't possible, the tool refuses and tells you exactly what to fix.

---

## Tools

Composable Rust CLIs. Each tool does one thing and emits structured JSON. Agents decide what to run — these tools decide what is true.

### Shipped

| Tool | What it does |
|------|-------------|
| **[rvl](https://github.com/cmdrvl/rvl)** | Reveals the smallest set of numeric changes that explain what actually changed between two datasets |
| **[shape](https://github.com/cmdrvl/shape)** | Structural comparability gate — can these two datasets be compared at all? |

### In Development

| Tool | What it does |
|------|-------------|
| **[vacuum](https://github.com/cmdrvl/vacuum)** | Enumerates artifacts in scope, emits a stable JSONL manifest |
| **[hash](https://github.com/cmdrvl/hash)** | Exact byte identity (SHA256 / BLAKE3) for dedup and immutability |
| **[fingerprint](https://github.com/cmdrvl/fingerprint)** | Template recognition — tests artifacts against versioned assertions |
| **[profile](https://github.com/cmdrvl/profile)** | Column-scoping configs for report tools |
| **[lock](https://github.com/cmdrvl/lock)** | Dataset lockfiles — like Cargo.lock for data |
| **[verify](https://github.com/cmdrvl/verify)** | Invariant checks against declared rules (PASS / FAIL) |
| **[compare](https://github.com/cmdrvl/compare)** | Exhaustive cell-by-cell diff without materiality compression |
| **[canon](https://github.com/cmdrvl/canon)** | Deterministic entity resolution against versioned registries |
| **[assess](https://github.com/cmdrvl/assess)** | Decision framing — PROCEED / ESCALATE / BLOCK against declared policy |
| **[pack](https://github.com/cmdrvl/pack)** | Evidence sealing — bundles everything into a content-addressed evidence pack |

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
```

## Links

- [cmdrvl.com](https://cmdrvl.com)
- [signals.cmdrvl.com](https://signals.cmdrvl.com)
- [dealcharts.org](https://dealcharts.org)
- [@cmdrvl](https://x.com/cmdrvl) on X
