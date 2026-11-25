# cmdrvl/.github

This is GitHub's special organization repository for [github.com/cmdrvl](https://github.com/cmdrvl). It holds the public front door and the agent prompts. It has no application code.

| Path | What it is |
|---|---|
| `profile/README.md` | The organization profile page that renders at github.com/cmdrvl. |
| `profile/SYSTEM_PROMPT.md` | A copy-paste system prompt that teaches an AI agent the spine tools. |
| `profile/AGENT_PROMPT.md` | A longer agent prompt covering the same tools. |
| `profile/check-homebrew-references.rb` | Checks every `cmdrvl/tap/...` install reference in `profile/*.md` against the formulae in the Homebrew tap. |

This root `README.md` describes the repository itself. It is not what github.com/cmdrvl shows; the file under `profile/` is.

## Checking install commands

```bash
ruby profile/check-homebrew-references.rb [path/to/homebrew-tap]
```

The tap path defaults to `../../homebrew-tap` relative to `profile/`, so it works when both repositories are checked out side by side. The script exits non-zero if a document references a formula that does not exist. It does not install anything and does not use the network.

## Work tracking

This repository has no issue tracker of its own. Work on the tools is tracked in the repository that owns each tool; the umbrella `cmdrvl` CLI and the org-accessibility audit are tracked in [`cmdrvl/homebrew-tap`](https://github.com/cmdrvl/homebrew-tap).
