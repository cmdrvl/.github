# Epistemic Spine — Agent Operator Guide

You have access to the **epistemic spine**: a set of composable, deterministic Rust CLI tools that establish what can be known, compared, and trusted about data artifacts. These tools produce truth. You decide what to run — they decide what is true.

Every tool is MIT-licensed, open source, and runs locally with no network dependency.

## The tools

Nine shipped tools. Each does one thing. They compose via Unix pipes (stream tools) or file arguments (report tools).

### Stream pipeline (JSONL in → JSONL out)

```
vacuum → hash → fingerprint → lock
```

| Tool | What it does | Key flags |
|------|-------------|-----------|
| **vacuum** | Scans directories, emits sorted JSONL manifest (path, size, mtime, mime) | `vacuum <DIR>...` `--include` `--exclude` |
| **hash** | Adds SHA-256 or BLAKE3 byte identity to each record | `--algorithm blake3` |
| **fingerprint** | Tests each artifact against template definitions, produces content hashes | `--fp <ID>` (repeatable, first match wins) `--list` `--diagnose`. YAML definitions in `~/.fingerprint/definitions/` run directly without compilation (override with `FINGERPRINT_DEFINITIONS`). |
| **lock** | Pins the stream into a self-hashed, tamper-evident lockfile | `--dataset-id` `--as-of` `--note` |

Stream tools read JSONL from stdin, enrich each record, emit to stdout. Pipe them:

```bash
vacuum /data/delivery/ | hash | fingerprint --fp csv.v0 | lock --dataset-id "q4" > q4.lock.json
```

### Report tools (files in → JSON or human text out)

| Tool | What it does | Key flags |
|------|-------------|-----------|
| **shape** | Structural comparability gate — can two CSVs be compared? | `shape old.csv new.csv --key loan_id --json` |
| **rvl** | Material change detector — which cells explain the difference? | `rvl old.csv new.csv --key loan_id --json` |
| **canon** | Entity resolution against versioned registries | `canon data.csv --registry reg/ --column id` |

Report tools default to human-readable output. Add `--json` for structured output.

### Lifecycle tools

| Tool | What it does | Key flags |
|------|-------------|-----------|
| **profile** | Column-scoping configs for report tools (draft → frozen lifecycle) | `profile draft init data.csv` `profile freeze` `profile suggest-key` |
| **pack** | Evidence sealing — bundles lockfiles and reports into content-addressed packs | `pack seal *.json --note "..." --output dir/` |

### Not yet shipped

| Tool | What it will do |
|------|----------------|
| **verify** | Invariant checks against declared rules (PASS / FAIL) |
| **compare** | Exhaustive cell-by-cell diff (all changes, no compression) |
| **assess** | Decision framing — PROCEED / PROCEED_WITH_RISK / ESCALATE / BLOCK via versioned policy |

---

## Universal conventions

### Exit codes (every tool)

| Code | Meaning |
|------|---------|
| `0` | Positive / clean (no change, compatible, pass, all matched) |
| `1` | Domain-negative (change detected, incompatible, fail, partial) |
| `2` | Refusal — tool cannot operate, with structured reason |

### Refusals are not errors

A refusal means the tool is being honest: it cannot produce a confident answer. Every refusal includes:

```json
{
  "code": "E_NEED_KEY",
  "message": "Row counts differ; key alignment required",
  "detail": { "suggested_key": "loan_id" },
  "next_command": "rvl old.csv new.csv --key loan_id --json"
}
```

- `code` — stable machine identifier (`E_UPPERCASE`)
- `detail` — structured context you can inspect
- `next_command` — literal shell command to retry (when mechanical recovery is possible)

**Mechanical recovery:** If `next_command` is present, execute it directly. No reasoning needed.

**Judgment recovery:** If `next_command` is null, the refusal requires you to interpret `detail` and decide. Example: `E_MISSINGNESS` on a column — you decide whether to exclude it via a profile edit.

### Self-discovery (every tool)

```bash
<tool> --describe    # Prints operator.json — full contract: args, options, exit codes, refusals
<tool> --schema      # Prints JSON Schema for structured output
<tool> --version     # Prints "<tool> <semver>"
```

Run `--describe` on any tool to learn its interface without reading docs. The refusals section tells you every failure mode and what to do about each one.

### Witness ledger

Every tool appends a ~300-byte record to `~/.epistemic/witness.jsonl` — content-addressed, hash-chained. This happens automatically. You can query it:

```bash
<tool> witness query --since 2026-01-01 --json
<tool> witness last --json
```

Suppress with `--no-witness` when benchmarking.

---

## Common workflows

### 1. Lock a data delivery

```bash
vacuum /data/2026-02/ | hash | lock --dataset-id "feb-delivery" --as-of "2026-02-28" > feb.lock.json
```

You now have a tamper-evident snapshot of every file — path, size, hash, tool versions. Verify later with `lock verify feb.lock.json`.

### 2. Identify document types in a corpus

```bash
vacuum /dataroom/ | hash | fingerprint --fp argus-model.v1 --fp csv.v0 --fp xlsx.v0 > fp.jsonl
```

Each record now has `fingerprint.matched`, `fingerprint.assertions`, and `fingerprint.content_hash`. Filter matched vs unmatched:

```bash
jq 'select(.fingerprint.matched == true)' fp.jsonl    # Recognized
jq 'select(.fingerprint.matched == false)' fp.jsonl   # Unknown
```

### 2b. Author and test a custom fingerprint (no compilation required)

```bash
# Learn a fingerprint from example files
fingerprint infer ./cbre-appraisals/ --format markdown --id cbre-appraisal.v1 --out cbre.fp.yaml

# Install the YAML definition for direct runtime evaluation
mkdir -p ~/.fingerprint/definitions
cp cbre.fp.yaml ~/.fingerprint/definitions/

# Test it immediately — no compile step needed
vacuum /dataroom/ | hash | fingerprint --fp cbre-appraisal.v1 --diagnose

# Iterate: edit the YAML, re-copy, re-test
# When stable, compile for production performance:
fingerprint compile cbre.fp.yaml --out fingerprint-cbre-v1/
```

### 3. Compare two datasets and explain changes

```bash
# Gate: are these structurally comparable?
shape nov.csv dec.csv --key loan_id --json > shape.json

# Explain: what actually changed?
rvl nov.csv dec.csv --key loan_id --json > rvl.json
```

If `shape` returns exit `1` (INCOMPATIBLE), do not run `rvl` — the datasets are not comparable. Read `shape.json` for why.

If `rvl` returns exit `2` (REFUSAL), read the refusal. Common case: `E_NEED_KEY` → retry with `--key`. Another: `E_MISSINGNESS` → a column is mostly null, consider excluding it with a profile.

### 4. Profile-scoped analysis (iterate, then freeze)

```bash
# Generate a draft profile from a real dataset
profile draft init tape.csv --out tape.draft.yaml

# Suggest a key column
profile suggest-key tape.csv --json

# Edit the draft: set key, remove noisy columns
# (you edit the YAML)

# Lint against the real data
profile lint tape.draft.yaml --against tape.csv

# Run rvl with the draft to see if the answer is useful
rvl old.csv new.csv --key loan_id --profile tape.draft.yaml --json

# If useful, freeze for production
profile freeze tape.draft.yaml --family csv.loan_tape.core --version 0 \
  --out profiles/csv.loan_tape.core.v0.yaml
```

Drafts are mutable scratchpads. Frozen profiles are immutable, hashed, recorded in outputs. Explore with drafts, commit with frozen.

### 5. Seal evidence

```bash
pack seal nov.lock.json dec.lock.json shape.json rvl.json \
  --note "Nov→Dec reconciliation" --output evidence/2026-02/
```

The pack is a self-hashed directory. Every member is content-addressed. Verify with `pack verify evidence/2026-02/`.

### 6. Entity resolution

```bash
canon positions.csv --registry registries/cusip-isin/ --column cusip --json
```

Exit `0` = all resolved. Exit `1` = partial (check `.unresolved[]`). Every mapping records `rule_id` and `registry.version` for audit.

---

## Refusal recovery cheat sheet

| Refusal | Tool | What to do |
|---------|------|-----------|
| `E_NEED_KEY` | rvl, shape | Retry with `--key <suggested_key>` from `detail` |
| `E_DIFFUSE` | rvl | Top contributors don't reach threshold — lower `--threshold` or scope with `--profile` |
| `E_MISSINGNESS` | rvl | Column is mostly null — edit profile to exclude it |
| `E_NO_NUMERIC` | rvl | No numeric columns found — check data or scope with `--profile` |
| `E_UNKNOWN_FP` | fingerprint | Fingerprint ID not installed — `fingerprint --list` to see available |
| `E_BAD_INPUT` | hash, fingerprint, lock | Upstream tool didn't run — check pipeline order |
| `E_COLUMN_NOT_FOUND` | canon, profile | Column name doesn't exist in input — check spelling |
| `E_INPUT_NOT_LOCKED` | shape, rvl | `--lock` was provided but input file isn't in the lockfile |
| `E_TOO_LARGE` | shape, rvl | Input exceeds `--max-rows`/`--max-bytes` — increase limit or split |
| `E_AMBIGUOUS_PROFILE` | shape, rvl | Both `--profile` and `--profile-id` given — use one |

When `next_command` is present in the refusal envelope, execute it. When it's null, apply judgment.

---

## Schema and contract discovery

Every tool carries its own contract. You never need external documentation.

```bash
# Full contract for any tool
rvl --describe | jq .

# What refusals can rvl produce and what to do about each?
rvl --describe | jq '.refusals[] | {code, action, message}'

# What does rvl's output look like?
rvl --schema | jq .

# What tools does fingerprint expect upstream?
fingerprint --describe | jq '.pipeline'

# What fingerprints are available?
fingerprint --list
```

### Output schema versions

Every structured output has a `version` field. Parse it to know the shape:

| Version | Tool | Output mode |
|---------|------|-------------|
| `vacuum.v0` | vacuum | JSONL stream |
| `hash.v0` | hash | JSONL stream |
| `fingerprint.v0` | fingerprint | JSONL stream |
| `lock.v0` | lock | JSON artifact |
| `shape.v0` | shape | JSON report (`--json`) |
| `rvl.v0` | rvl | JSON report (`--json`) |
| `canon.v0` | canon | JSON artifact |
| `pack.v0` | pack | JSON manifest |

---

## What the spine is not

The spine is the **data layer**. It establishes provenance, identity, comparability, and change. It does not:

- **Orchestrate workflows** — you decide what to run and in what order
- **Store data** — tools are stateless; they read files and emit structured output
- **Extract or parse documents** — fingerprint recognizes templates, it doesn't OCR or transform data
- **Make decisions** — tools produce deterministic facts; you (or `assess`, when shipped) interpret them
- **Require a network** — everything runs locally, no APIs, no cloud

You bring the orchestration. The spine brings the truth.

---

## Install

```bash
# All nine tools via Homebrew
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

Verify:
```bash
vacuum --version && hash --version && fingerprint --version && \
profile --version && lock --version && shape --version && \
rvl --version && canon --version && pack --version
```

## Links

- [github.com/cmdrvl](https://github.com/cmdrvl) — all repos, all MIT
- Each tool: `<tool> --describe` for the full machine-readable contract
