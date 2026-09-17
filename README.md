# Meet AIRO: your first conversation — Lab Guide

A foundational lab guide for **Meet AIRO: your first conversation**, served
via GitHub Pages from the `docs/` folder (branch `main`, folder `/docs`).

## Lab

| Lab | Tier | Time |
|---|---|---|
| [Meet AIRO: your first conversation](docs/index.html) | Foundational | 15 minutes |

## Structure

- `docs/` — the published surface: a single self-contained lab page (Pages
  source)
- Every commit is checked by the publish guard workflow
  (`.github/workflows/publish-guard.yml`); the same checks run locally as a
  pre-push hook — enable once per clone with:

```
git config core.hooksPath .githooks
```

## Contributing

Content is authored and reviewed elsewhere; this repo holds only pressed,
vetted output. Do not edit the lab HTML in place — changes land as a fresh
press of the whole file.
