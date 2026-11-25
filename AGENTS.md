# AGENTS.md — cmdrvl/.github

Inherits the shared CMD+RVL rules in the monorepo root `AGENTS.md`. This file adds what is specific to this repository.

## What you are editing

Everything under `profile/` is public. `profile/README.md` is the front page of github.com/cmdrvl, and the two prompt files are what outside agents are told to paste into their own sessions. A wrong command here is copied into other people's workflows.

## Rules

- **Verify before you write.** Every command, flag, binary name and install line must match the live tool or the tap. Run the tool's `--describe` or `capabilities --json` rather than copying from another document, and run `ruby profile/check-homebrew-references.rb` before every commit.
- **Do not overclaim.** Do not describe a tool as zero-retention safe, deterministic or offline-verifiable beyond what its own documentation currently states. When a tool has a known gap, say so.
- **No internal identifiers in public text.** No bead IDs, internal repo codenames or private paths.
- **Keep the prompts consistent.** A change to a command in one prompt usually applies to the other prompt and to `profile/README.md`.
- **No process artifacts.** Do not add trackers, plan indexes, ledgers or a `docs/` tree to this repository. It is a front door, not a project.
- **Branch and commits.** Work on `main`. Stage only the files you changed with `git add <paths>`.
