# CMD+RVL

**Open-source tools from CMD+RVL that help agents answer hard data questions without hand-waving.**

CMD+RVL is broader than this toolset. We build systems, pipelines, and intelligence layers for reasoning over changing data. The repositories here are the open-source CLI layer we publish for questions like:

- What changed?
- Are these two datasets even comparable?
- Did this output violate a rule?
- How good is this result against a gold set?
- Should we proceed, escalate, or block?

These tools are designed for agent workflows, but they are also useful directly from the terminal. Same inputs, same answer. If the answer would be untrustworthy, the tool refuses and tells you what is missing.

### What this feels like with an agent

Without tools, an agent often says:

- "I think these files are probably comparable."
- "It looks like only a few things changed."
- "This output seems mostly fine."

With CMD+RVL, the same workflow becomes:

- `shape` says whether the files are actually comparable
- `rvl` says exactly what materially changed
- `verify` says whether declared rules passed or failed
- `benchmark` says how good the result is against ground truth
- `assess` says whether to proceed, escalate, or block

Two concrete examples:

**Example 1: quarterly holdings review**

An agent receives two CSVs and a question: "Did anything important change?"

- `shape` confirms the files are comparable
- `rvl` reports that only 3 of 847 rows changed, with one new position and a net notional increase
- `pack` can seal that evidence so the result can be reviewed or shared later

Instead of a vague summary, you get a small, checkable evidence trail.

**Example 2: extraction quality check**

An agent produces a candidate dataset from filings and needs to know whether it is safe to use.

- `verify` checks declared constraints like missing IDs, duplicates, and broken references
- `benchmark` checks the candidate against a gold set and emits quality signals
- `assess` turns that bundle into a deterministic decision

Instead of "looks good to me," you get an explicit PASS / FAIL / quality / decision chain.

### Start Here

Most first-time users do not need the full stack. They usually start with these:

| Question | Tool | What it gives you |
|------|------|-------------------|
| Can these two files be compared at all? | **[shape](https://github.com/cmdrvl/shape)** | A clear compatibility verdict before you diff anything |
| What materially changed? | **[rvl](https://github.com/cmdrvl/rvl)** | The smallest numeric delta set that explains the change |
| Did the output break declared rules? | **[verify](https://github.com/cmdrvl/verify)** | Deterministic PASS / FAIL over portable constraints |
| How good is this result versus ground truth? | **[benchmark](https://github.com/cmdrvl/benchmark)** | Accuracy, coverage, and policy-facing quality signals |
| What should we do with this evidence? | **[assess](https://github.com/cmdrvl/assess)** | Deterministic PROCEED / ESCALATE / BLOCK decisions |

### Quick start

What changed between two quarterly reports?

```bash
# Step 1: ask whether they are comparable
shape q3/positions.csv q4/positions.csv --json > shape.report.json

# Step 2: ask what materially changed
rvl q3/positions.csv q4/positions.csv --json > rvl.report.json

# Step 3: lock and seal the evidence if it matters
vacuum q3/ q4/ | hashbytes | lock --dataset-id quarterly > quarterly.lock.json
pack seal quarterly.lock.json shape.report.json rvl.report.json --output evidence/quarterly/
```

---

## Why agents like this

Every shipped CMD+RVL tool follows the same behavioral rules:

1. **Deterministic** — same bytes in, same answer out
2. **Refusal-aware** — if the tool cannot make a trustworthy claim, it refuses explicitly
3. **Machine-readable** — JSON output, `--describe`, and `--schema` for agent integration
4. **Composable** — outputs from one tool can feed the next without glue code

That means an agent can inspect a tool, run it, and trust that the result is stable enough to use in a real evidence pipeline.

---

## Shipped Tools

You do not need to learn all of these at once. The top of the list is the most approachable; the bottom is more like infrastructure and evidence plumbing.

| Tool | What it does | Install |
|------|-------------|---------|
| **[shape](https://github.com/cmdrvl/shape)** | Checks whether two datasets are structurally comparable before you diff them | `brew install cmdrvl/tap/shape` |
| **[rvl](https://github.com/cmdrvl/rvl)** | Finds the material numeric differences that explain what changed | `brew install cmdrvl/tap/rvl` |
| **[verify](https://github.com/cmdrvl/verify)** | Checks declared rules and constraints over files or relations | `brew install cmdrvl/tap/verify` |
| **[benchmark](https://github.com/cmdrvl/benchmark)** | Scores candidate outputs against a gold set | `brew install cmdrvl/tap/cmdrvl-benchmark` |
| **[assess](https://github.com/cmdrvl/assess)** | Turns evidence into a deterministic PROCEED / ESCALATE / BLOCK classification | `brew install cmdrvl/tap/assess` |
| **[canon](https://github.com/cmdrvl/canon)** | Resolves entity identifiers deterministically with auditability | `brew install cmdrvl/tap/canon` |
| **[veil](https://github.com/cmdrvl/veil)** | Prevents raw sensitive file reads from entering an agent's context while allowing authorized subprocess workflows | `brew install cmdrvl/tap/veil` |
| **[airlock](https://github.com/cmdrvl/airlock)** | Proves what crossed the model boundary with boundary-attestation manifests and provenance maps | `brew install cmdrvl/tap/airlock` |
| **[vacuum](https://github.com/cmdrvl/vacuum)** | Enumerates artifacts in scope, emits a deterministic sorted JSONL manifest with size, mtime, and MIME type | `brew install cmdrvl/tap/vacuum` |
| **[hash](https://github.com/cmdrvl/hash)** | Streaming content hashing — adds SHA-256 or BLAKE3 byte identity to every artifact in a manifest. The installed binary is `hashbytes`. | `brew install cmdrvl/tap/hash` |
| **[fingerprint](https://github.com/cmdrvl/fingerprint)** | Template recognition — tests artifacts against versioned assertion-based definitions and produces content hashes | `brew install cmdrvl/tap/fingerprint` |
| **[profile](https://github.com/cmdrvl/profile)** | Column-scoping configs for report tools — draft/freeze lifecycle, deterministic key suggestion, schema linting | `brew install cmdrvl/tap/profile` |
| **[lock](https://github.com/cmdrvl/lock)** | Dataset lockfiles — like Cargo.lock for data. Self-hashed, tamper-evident, with `lock verify` for integrity checks | `brew install cmdrvl/tap/lock` |
| **[pack](https://github.com/cmdrvl/pack)** | Evidence sealing — bundles lockfiles, reports, and tool outputs into one immutable, content-addressed evidence pack | `brew install cmdrvl/tap/pack` |

All shipped tools also record a local witness receipt so runs can be traced later.

**Typical pipeline:** `shape` → `rvl` / `verify` / `benchmark` → `assess` → `pack`

If you need stronger provenance around inputs, add `vacuum`, `hashbytes`, and `lock` before the analysis step.

### Deferred / Future

| Tool | What it does |
|------|-------------|
| **[compare](https://github.com/cmdrvl/compare)** | Exhaustive raw diff capability, currently deferred as a standalone core tool |

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

## For Agent Builders

These tools were built to be called by agents. A model can:

- inspect a tool with `--describe`
- fetch its JSON Schema with `--schema`
- run it safely in an evidence pipeline
- handle explicit refusals instead of guessing

Two reference prompts help agents learn the ecosystem:

- **[Agent Operator Guide](./AGENT_PROMPT.md)** — workflows, refusal recovery, schema discovery, and the full tool map
- **[System Prompt](./SYSTEM_PROMPT.md)** — compact drop-in for agent context windows (~30 lines)

## Install

Most people start here:

```bash
brew install cmdrvl/tap/shape
brew install cmdrvl/tap/rvl
brew install cmdrvl/tap/verify
brew install cmdrvl/tap/cmdrvl-benchmark
brew install cmdrvl/tap/assess
brew install cmdrvl/tap/veil
brew install cmdrvl/tap/airlock
```

Full tap:

```bash
brew install cmdrvl/tap/vacuum
brew install cmdrvl/tap/hash   # provides the `hashbytes` binary
brew install cmdrvl/tap/fingerprint
brew install cmdrvl/tap/profile
brew install cmdrvl/tap/lock
brew install cmdrvl/tap/shape
brew install cmdrvl/tap/rvl
brew install cmdrvl/tap/verify
brew install cmdrvl/tap/cmdrvl-benchmark
brew install cmdrvl/tap/assess
brew install cmdrvl/tap/veil
brew install cmdrvl/tap/airlock
brew install cmdrvl/tap/canon
brew install cmdrvl/tap/pack
```

## Links

- [cmdrvl.com](https://cmdrvl.com)
- [signals.cmdrvl.com](https://signals.cmdrvl.com)
- [dealcharts.org](https://dealcharts.org)
- [@cmdrvl](https://x.com/cmdrvl) on X
