# meet-airo

Customer-facing lab guide for "Meet AIRO: your first conversation," served
via GitHub Pages.

## Visibility contract: designed public

This repo is **designed public from its first commit**. It may sit at
Internal visibility while awaiting admin promotion, but every commit must
already meet the public bar:

- No secrets, tokens, keys, or credentials — ever, in any commit.
- No internal URLs (Okta, Confluence, Slack, private Pages domains).
- No employee GitHub usernames or internal names in content or metadata.
- Customer-facing register only. Authoring discussion happens
  elsewhere; issues are disabled here on purpose.

There is no safe way to scrub a public repo after the fact — force-pushed
commits stay reachable by SHA. If something internal lands here, treat it as
leaked: rotate any credential and involve the org admin.

## What lives here

Pressed static output only (HTML from the Gutenberg press), under `docs/` —
the GitHub Pages source folder (main branch, /docs). Source manuscripts,
decisions records, and screenshots-in-progress live in the internal
authoring repo. Do not edit the lab HTML in place — re-press and replace the
whole file. This repo receives curated snapshots only: all iteration,
discussion, and issue tracking happen in the internal authoring repo, so
nothing internal ever accumulates in this repo's history or PR threads.

## Gates

- `.github/workflows/publish-guard.yml` runs the pre-publish checks on every
  push.
- `.githooks/pre-push` runs the same checks locally
  (`git config core.hooksPath .githooks` once per clone).

## Working in this repo

Never commit or push directly to `main` after the initial publish — it is
the published surface (GitHub Pages serves `main:/docs`), so a push to main
is a deploy. Later work lands via branch + pull request; before merging,
rebase the branch onto main and run the scrubber
(`scripts/publish-checks.sh`) on the rebased result — CI repeats the same
scrub on every push and PR.
