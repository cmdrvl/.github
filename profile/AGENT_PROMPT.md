# CMD+RVL — Agent Operator Guide

You are operating **CMD+RVL**: a unified, deterministic, local-first Rust system that establishes what can be known, compared, simulated, and proven about data — without leaking raw sensitive bytes into your context window.

These tools produce verifiable facts. You drive the control loop — they decide what is true.

Every tool is MIT-licensed, open source, and runs locally with no network dependency.

---

## Mental Model: One Tower, Two Orthogonal Planes

Do not treat these tools as 15 disconnected CLIs. Operate them as **one linked abstraction tower** cut by **two orthogonal planes**:

```text
  ORTHOGONAL PLANE A — BOUNDARY & EXPOSURE (public < derived < protected)
    Ingress: veil    (blocks direct raw reads; OS sandbox + broker + --explicit flag guard)
    Egress:  airlock (proves/gates what crosses to models; signed manifests + wire proxy)

  VERTICAL EPISTEMIC TOWER (each layer links downward by content hash + receipt)
    L0–L1  Identity & Scope    vacuum · s3-to-vacuum · hashbytes · lock
    L2     Type & Lens         fingerprint · profile (draft -> frozen)
    L4     Comparability/Diff  shape (gate) · rvl (minimal numeric explanation)
    L5     Closure & Rules     verify · canon (exact lookup / entity / geo) · decoding
    L6     Decision            benchmark · assess (PROCEED | RISK | ESCALATE | BLOCK)
    L7–L8  Seal & Accrete      pack · witness ledger · versioned registries & champions
    L10    Agent Control       --robot-triage · --describe · capabilities · cmdrvl orient

  ORTHOGONAL PLANE B — COUNTERFACTUAL SIMULATION
    twinning (ephemeral Postgres/REST/warehouse twins, ms reset, embedded verify)
```

### The Agent Control Loop

```text
orient → scope & type (L1–L2) → [twin dry-run] → gate & diff (L4) → verify & resolve (L5) → decide (L6) → seal & accrete (L7–L8)
```

1. **Orient before acting:** Inspect installed contracts and boundary posture with read-only discovery before running data commands. Never guess flags from memory.
2. **Protect your context budget:** Keep default redaction on; read bounded summaries and `blake3:` / `sha256:` refs rather than raw files or huge JSON dumps; iterate on deltas, not full re-reads.
3. **Simulate before mutating:** When iterating on extractors, migrations, or SQL queries, run against `twinning` (ephemeral local twin + embedded `verify`) until clean before touching real targets.
4. **Promote, don't leave prose:** Turn resolved discoveries into durable deterministic artifacts — frozen `profile`s, `fingerprint` YAML definitions, `verify` rule sets, versioned `canon` registries, and sealed `pack`s — so future agents pay zero tokens to re-learn them.

---

## Tool Catalog by Layer

### L1–L2: Provenance, Typing & Lenses (Stream: JSONL in → JSONL out)

```bash
vacuum /data/delivery/ | hashbytes | fingerprint --fp csv.v0 | lock --dataset-id "q4" > q4.lock.json
```

| Tool | Role | Key command |
|------|------|-------------|
| **vacuum** | Scans directories into sorted `vacuum.v0` JSONL manifests | `vacuum <DIR>... --include --exclude` |
| **s3-to-vacuum** | Converts an S3 prefix listing into `vacuum.v0` JSONL | `s3-to-vacuum s3://bucket/prefix/` |
| **hashbytes** | Enriches stream with SHA-256 or BLAKE3 byte identity | `hashbytes --algorithm blake3` |
| **fingerprint** | Tests artifacts against versioned template assertions (YAML in `~/.fingerprint/definitions/` runs directly without compile) | `fingerprint --fp <ID> --diagnose` / `--list` |
| **lock** | Pins manifest + tool versions into a self-hashed lockfile | `lock --dataset-id "q4" --as-of "2026-02-28"` |
| **profile** | Column-scoping lenses (`draft` scratchpad → immutable `frozen` lens) | `profile draft init data.csv` / `profile freeze` / `profile suggest-key` |

### L4–L5: Comparability, Diff, Constraints & Identity

| Tool | Role | Key command |
|------|------|-------------|
| **shape** | Structural comparability gate — **always run before `rvl`** | `shape old.csv new.csv --key loan_id --json` |
| **rvl** | Minimal material numeric change explanation (redacted by default) | `rvl old.csv new.csv --key loan_id --json` |
| **verify** | Deterministic constraint evaluation with machine witnesses | `verify data.csv --rules rules.yaml --json` / `verify run constraints.verify.json --bind name=path` |
| **canon** | Identity compiler: exact registry lookup (`canon <INPUT>`) + deterministic `canon entity` / `canon geo` workbenches | `canon positions.csv --registry reg/ --column cusip --json` |
| **decoding** | Deterministic resolution of conflicting claims into canonical outputs | `decoding --describe` |

### L6–L7: Scoring, Policy Decisions & Sealing

| Tool | Role | Key command |
|------|------|-------------|
| **benchmark** | Gold-set scoring against frozen assertions | `benchmark normalized.csv --assertions gold.jsonl --key id --json` |
| **assess** | Deterministic `PROCEED` / `PROCEED_WITH_RISK` / `ESCALATE` / `BLOCK` verdict over evidence artifacts | `assess shape.json rvl.json verify.json --policy policy.yaml --json` |
| **pack** | Seals lockfiles, reports, and manifests into content-addressed, offline-verifiable bundles | `pack seal *.json --note "..." --output evidence/` / `pack verify` |

### Orthogonal Plane A: Privacy & Model-Boundary Enforcement

| Tool | Role | Key command |
|------|------|-------------|
| **veil** | Host-side ingress read guard: blocks raw sensitive file reads & raw-dump flags, steers to authorized metadata-safe spine tools | `veil --robot-triage` / `veil operator --json` / `veil doctor health --json` |
| **airlock** | Model-boundary egress proof: assembles provenance-mapped prompts and emits verifiable boundary manifests (`BOUNDARY_FAILED < RAW_DOCUMENT_ABSENT < STRICT_TELEMETRY_ONLY`) | `airlock assemble ...` / `airlock verify ...` / `airlock explain --manifest ...` |

### Orthogonal Plane B: Counterfactual Simulation

| Tool | Role | Key command |
|------|------|-------------|
| **twinning** | Wire-compatible ephemeral Postgres/REST database twin with ms reset, snapshot overlays, and embedded `verify` | `twinning --robot-triage` / `twinning postgres --schema schema.sql` |

---

## Universal Agent Contracts

### 1. Exit Code Trinity (Every Tool)

| Code | Meaning | Agent Action |
|------|---------|--------------|
| `0` | Clean / positive (compatible, no change, pass, all matched) | Proceed to next layer |
| `1` | Domain-negative (incompatible, change detected, fail, partial) | Inspect structured JSON findings; do not skip gates (e.g., do not run `rvl` if `shape` exited `1`) |
| `2` | **Refusal** (not a crash — the tool refuses to guess) | Execute `next_command` directly if non-null; otherwise use `detail` to adjust inputs/profile |

### 2. Refusals Teach Recovery

Every exit-`2` refusal emits a structured envelope:

```json
{
  "code": "E_NEED_KEY",
  "message": "Row counts differ; key alignment required",
  "detail": { "suggested_key": "loan_id" },
  "next_command": "rvl old.csv new.csv --key loan_id --json"
}
```

- **Mechanical recovery (`next_command != null`):** Run it directly. No guessing.
- **Judgment recovery (`next_command == null`):** Inspect `detail` and refine scope (e.g., exclude high-missingness columns via `profile` or add a missing upstream stage).

### 3. Read-Only Self-Discovery (Zero Guesswork)

Before operating any unfamiliar installed binary, query its read-only machine contract:

```bash
<tool> --robot-triage       # Fastest single-call health + capabilities + recommendations
<tool> capabilities --json  # Stable command, flag, and side-effect contract
<tool> robot-docs guide     # Compact agent quick reference
<tool> --describe           # operator.v0 manifest (args, exit codes, refusals, pipeline position)
<tool> --schema             # Output JSON Schema
<tool> doctor health --json # Read-only installation/posture check (never run --fix without approval)
```

Prefer the installed binary's `--describe` / `--robot-triage` output over memory when flags or refusal codes differ by version.

### 4. Zero-Retention & Redaction Discipline

- `shape` and `rvl` redact identifying metadata and raw values **by default**. Keep that default for triage, logs, and shared artifacts.
- Pass `--explicit` only when authorized (`shape --explicit` exposes column/key metadata; `rvl --explicit` exposes raw values). Under `veil`, raw-dump flags on protected files are blocked by policy.
- `shape` supports `--profile` and `--profile-id` (its `--lock`, `--max-rows`, and `--max-bytes` flags are reserved in v0 and do not gate runtime behavior yet). `rvl` supports `--profile` and `--profile-id`, and does not accept `--lock`.
- If `veil` blocks a direct read, run `veil operator --json` and use an authorized metadata-safe spine tool instead of attempting shell workarounds.

### 5. Canonical State Root & Witness Ledger

- Canonical state root: `~/.cmdrvl`
- Shared hash-chained witness ledger: `~/.cmdrvl/state/witness/witness.jsonl` (override with `EPISTEMIC_WITNESS`; suppress in benchmarks with `--no-witness`). Legacy `~/.epistemic/witness.jsonl` is migration input only.
- Frozen profiles: `~/.cmdrvl/config/profile/profiles/`
- Query witness history with `<tool> witness query --since 2026-01-01 --json` or `<tool> witness last --json`.

---

## Core Composable Recipes

### 1. Gate → Explain → Seal (Standard Change Audit)
```bash
vacuum /data/nov/ | hashbytes | lock --dataset-id "nov" > nov.lock.json
vacuum /data/dec/ | hashbytes | lock --dataset-id "dec" > dec.lock.json
shape nov.csv dec.csv --key loan_id --json > shape.json        # must exit 0 before rvl
rvl nov.csv dec.csv --key loan_id --json > rvl.json
assess shape.json rvl.json --policy policy.yaml --json > assess.json
pack seal nov.lock.json dec.lock.json shape.json rvl.json assess.json \
  --note "Nov->Dec reconciliation" --output evidence/2026-02/
pack verify evidence/2026-02/
```

### 2. Draft → Lint → Freeze a Comparison Lens (`profile`)
```bash
profile draft init tape.csv --out tape.draft.yaml
profile suggest-key tape.csv --json
profile lint tape.draft.yaml --against tape.csv
rvl old.csv new.csv --key loan_id --profile tape.draft.yaml --json
profile freeze tape.draft.yaml --family csv.loan_tape.core --version 0 \
  --out profiles/csv.loan_tape.core.v0.yaml
```

### 3. Author & Test a Custom Fingerprint (No Compile Needed)
```bash
fingerprint infer ./samples/ --format markdown --id doc.v1 --out doc.fp.yaml
mkdir -p ~/.fingerprint/definitions && cp doc.fp.yaml ~/.fingerprint/definitions/
vacuum /dataroom/ | hashbytes | fingerprint --fp doc.v1 --diagnose
fingerprint compile doc.fp.yaml --out fingerprint-doc-v1/   # optional production compile
```

### 4. Entity Resolution (`canon`)
```bash
canon positions.csv --registry registries/cusip-isin/ --column cusip --json
```
Exit `0` = all resolved; exit `1` = partial (inspect `.unresolved[]`). Use `canon entity` / `canon geo` workbenches to compile messy local evidence into audited, versioned registries — never fuzzy-match inside production lookup.

### 5. Safe Model-Boundary Attestation (`airlock`)
```bash
airlock assemble --policy rules.yaml --input telemetry.json \
  --out prompt.json --provenance-out provenance.json
airlock verify --policy rules.yaml --prompt prompt.json --provenance provenance.json \
  --request request.json --out manifest.json --require-claim RAW_DOCUMENT_ABSENT
airlock explain --manifest manifest.json --json
```

---

## Refusal Recovery Cheat Sheet

| Refusal | Tool | Recovery |
|---------|------|----------|
| `E_NEED_KEY` | `rvl`, `shape` | Retry with `--key <suggested_key>` from `detail` |
| `E_DIFFUSE` | `rvl` | Lower `--threshold` or scope noisy columns with `--profile` |
| `E_MISSINGNESS` | `rvl` | Exclude high-null column via `profile` |
| `E_NO_NUMERIC` | `rvl` | Verify input columns or scope with `--profile` |
| `E_UNKNOWN_FP` | `fingerprint` | Run `fingerprint --list` to check installed definitions |
| `E_BAD_INPUT` | `hashbytes`, `fingerprint`, `lock` | Check upstream JSONL pipeline order |
| `E_COLUMN_NOT_FOUND` | `canon`, `profile` | Check column spelling against `shape` / `profile draft init` |
| `E_TOO_LARGE` | `shape`, `rvl` | Increase `--max-rows`/`--max-bytes` or partition input |
| `E_AMBIGUOUS_PROFILE` | `shape`, `rvl` | Pass either `--profile` or `--profile-id`, not both |

---

## Install (Homebrew)

```bash
brew install cmdrvl/tap/vacuum
brew install cmdrvl/tap/cmdrvl-hash        # installs `hashbytes`
brew install cmdrvl/tap/fingerprint
brew install cmdrvl/tap/profile
brew install cmdrvl/tap/lock
brew install cmdrvl/tap/shape
brew install cmdrvl/tap/rvl
brew install cmdrvl/tap/verify
brew install cmdrvl/tap/cmdrvl-benchmark   # installs `benchmark`
brew install cmdrvl/tap/assess
brew install cmdrvl/tap/canon
brew install cmdrvl/tap/pack
brew install cmdrvl/tap/twinning
brew install cmdrvl/tap/veil
brew install cmdrvl/tap/airlock
```

`vacuum` also installs `s3-to-vacuum`. See [github.com/cmdrvl](https://github.com/cmdrvl) and [`cmdrvl/cmdrvl`](https://github.com/cmdrvl/cmdrvl) for the unified system architecture and porcelain CLI roadmap.
