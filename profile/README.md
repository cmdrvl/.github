# CMD+RVL

**Deterministic tools for data accountability.**

Know what changed. Prove what was known. Refuse when uncertain.

---

CMD+RVL builds open-source, deterministic CLI tools that establish what can be known, compared, and trusted about data artifacts. Every tool produces the same output for the same input. When a confident answer isn't possible, the tool refuses and tells you exactly what to fix.

Agents decide what to run. These tools decide what is true.

## The Epistemic Spine

A composable Rust toolchain where each tool does one thing and emits structured JSON.

| Tool | What it does | Status |
|------|-------------|--------|
| **[rvl](https://github.com/cmdrvl/rvl)** | Reveals the smallest set of numeric changes that explain what actually changed between two datasets | Shipped |
| **[shape](https://github.com/cmdrvl/shape)** | Structural comparability gate — can these two datasets be compared at all? | Shipped |
| **[vacuum](https://github.com/cmdrvl/vacuum)** | Enumerates artifacts in scope, emits a stable JSONL manifest | Planned |
| **[hash](https://github.com/cmdrvl/hash)** | Exact byte identity (SHA256 / BLAKE3) for dedup and immutability | Planned |
| **[fingerprint](https://github.com/cmdrvl/fingerprint)** | Template recognition — tests artifacts against versioned assertions | Planned |
| **[profile](https://github.com/cmdrvl/profile)** | Column-scoping configs for report tools (draft → freeze lifecycle) | Planned |
| **[lock](https://github.com/cmdrvl/lock)** | Dataset lockfiles — like Cargo.lock for data | Planned |
| **[verify](https://github.com/cmdrvl/verify)** | Invariant checks against declared rules (PASS / FAIL) | Planned |
| **[compare](https://github.com/cmdrvl/compare)** | Exhaustive cell-by-cell diff without materiality compression | Planned |
| **[canon](https://github.com/cmdrvl/canon)** | Deterministic entity resolution against versioned registries | Planned |
| **[assess](https://github.com/cmdrvl/assess)** | Decision framing — PROCEED / ESCALATE / BLOCK against declared policy | Planned |
| **[pack](https://github.com/cmdrvl/pack)** | Evidence sealing — bundles everything into a content-addressed pack | Planned |

## Other Tools

| Tool | What it does |
|------|-------------|
| **[cmdrvl-xew](https://github.com/cmdrvl/cmdrvl-xew)** | XBRL Early Warning engine — detects enforcement-fragile patterns in SEC filings, produces reproducible Evidence Packs |
| **[regret](https://github.com/cmdrvl/regret)** | Mines git history for high-precision regret signals (reverts, linked fixes, patch-id matches) |
| **[edgar-change-interpreter](https://github.com/cmdrvl/edgar-change-interpreter)** | Claude skill for identifying material changes and silent risks in SEC filings |
| **[edgar-fabric-ingest](https://github.com/cmdrvl/edgar-fabric-ingest)** | Reference implementation for ingesting EDGAR disclosures into an append-only event store |
| **[twinning](https://github.com/cmdrvl/twinning)** | In-memory database twin that speaks the real wire protocol — fast testing without a real database |

## Install

```bash
brew install cmdrvl/tap/rvl
brew install cmdrvl/tap/shape
```

## Links

- [cmdrvl.com](https://cmdrvl.com) — Outcome & Assurance
- [signals.cmdrvl.com](https://signals.cmdrvl.com) — Discovery
- [dealcharts.org](https://dealcharts.org) — Public Evidence
- [@cmdrvl](https://x.com/cmdrvl) on X
