# CMD+RVL

**Open-source CLI tools that give agents facts instead of guesses about data.**

CMD+RVL builds systems for reasoning over changing data. These repos are the open-source layer: small, deterministic tools that check whether two files can even be compared, say exactly what changed, check rules, score quality, and decide proceed/escalate/block — each one backed by a declared, versioned artifact (a rule set, a registry, a schema) instead of logic buried in code.

## Give this to your agent

The fastest way to understand these tools is to hand them to your coding agent. Paste [`SYSTEM_PROMPT.md`](./SYSTEM_PROMPT.md) into its context, or point it at [`AGENT_PROMPT.md`](./AGENT_PROMPT.md) for the full guide. Every tool also answers `--describe` and `--schema` directly, so an agent can explore on its own from there.

Use these in conjunction with our [MCP servers](https://cmdrvl.com/mcp-servers/) — the tools verify and seal what your agent already has locally, the MCP servers give it public and licensed data to check against.

## What changes

Without these tools, an agent guesses:

- "I think these files are probably comparable."
- "It looks like only a few things changed."
- "This output seems mostly fine."

With them, it gets answers:

- `shape` — are these two files actually comparable?
- `rvl` — what materially changed, and by how much?
- `verify` — did this pass the declared rules?
- `benchmark` — how good is this against a gold set?
- `assess` — proceed, escalate, or block?

Example: an agent gets two quarterly CSVs and needs to know if anything important changed. `shape` confirms they're comparable, `rvl` reports 3 of 847 rows changed with one new position, and `pack` can seal that as evidence to review or share later. Instead of a vague summary, you get a small, checkable trail.

## Tools

| Tool | What it does |
|------|-------------|
| **[shape](https://github.com/cmdrvl/shape)** | Checks whether two datasets are structurally comparable before you diff them |
| **[rvl](https://github.com/cmdrvl/rvl)** | Finds the material numeric differences that explain what changed |
| **[verify](https://github.com/cmdrvl/verify)** | Checks declared rules and constraints over files or relations |
| **[benchmark](https://github.com/cmdrvl/benchmark)** | Scores candidate outputs against a gold set |
| **[assess](https://github.com/cmdrvl/assess)** | Turns evidence into a deterministic proceed / escalate / block call |
| **[canon](https://github.com/cmdrvl/canon)** | Resolves entity identifiers against versioned registries |
| **[veil](https://github.com/cmdrvl/veil)** | Keeps raw sensitive files out of an agent's context while still allowing authorized subprocess workflows |
| **[airlock](https://github.com/cmdrvl/airlock)** | Proves what did and didn't cross into a model's context |
| **[vacuum](https://github.com/cmdrvl/vacuum)** | Enumerates files into a deterministic manifest |
| **[hash](https://github.com/cmdrvl/hash)** | Adds SHA-256/BLAKE3 content identity to a manifest (installs as `hashbytes`) |
| **[fingerprint](https://github.com/cmdrvl/fingerprint)** | Matches files against versioned template definitions |
| **[profile](https://github.com/cmdrvl/profile)** | Defines and freezes a column-scoping config for the tools above |
| **[lock](https://github.com/cmdrvl/lock)** | Pins a dataset into a self-hashed, tamper-evident lockfile |
| **[pack](https://github.com/cmdrvl/pack)** | Bundles lockfiles and reports into one sealed, content-addressed evidence pack |

Typical pipeline: `shape` → `rvl` / `verify` / `benchmark` → `assess` → `pack`. Add `vacuum` → `hashbytes` → `lock` first for stronger provenance on the inputs.

<details>
<summary>More repos: SEC/EDGAR tools, developer tools, deferred</summary>

**SEC EDGAR & financial data**

| Tool | What it does |
|------|-------------|
| **[cmdrvl-xew](https://github.com/cmdrvl/cmdrvl-xew)** | Detects enforcement-fragile XBRL patterns in SEC filings |
| **[edgar-change-interpreter](https://github.com/cmdrvl/edgar-change-interpreter)** | Claude skill for spotting material changes in SEC filings |
| **[edgar-fabric-ingest](https://github.com/cmdrvl/edgar-fabric-ingest)** | Reference implementation for ingesting EDGAR disclosures into an event store |

**Developer tools**

| Tool | What it does |
|------|-------------|
| **[regret](https://github.com/cmdrvl/regret)** | Mines git history for high-precision regret signals — reverts, linked fixes, patch-id matches |
| **[twinning](https://github.com/cmdrvl/twinning)** | In-memory database twin that speaks the real wire protocol |

**Deferred**

| Tool | What it does |
|------|-------------|
| **[compare](https://github.com/cmdrvl/compare)** | Exhaustive raw diff capability, currently deferred |

</details>

## Install

```bash
brew install cmdrvl/tap/{shape,rvl,verify,benchmark,assess,veil,airlock}
```

Full set:

```bash
brew install cmdrvl/tap/{vacuum,hash,fingerprint,profile,lock,shape,rvl,verify,benchmark,assess,canon,pack,veil,airlock}
```

(`cmdrvl/tap/hash` provides the `hashbytes` binary; `cmdrvl/tap/benchmark` installs as `cmdrvl-benchmark`.)

## Links

- [cmdrvl.com](https://cmdrvl.com)
- [MCP servers](https://cmdrvl.com/mcp-servers/)
- [signals.cmdrvl.com](https://signals.cmdrvl.com)
- [dealcharts.org](https://dealcharts.org)
- [@cmdrvl](https://x.com/cmdrvl) on X
