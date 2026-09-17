# Meet AIRO — Lab Guides

Lab guides for the AIRO training course, served via GitHub Pages from the
`docs/` folder (branch `main`, folder `/docs`).

## Labs

| Lab | Tier | Time |
|---|---|---|
| [Visit Playgrounds](docs/airo-0-visit-playgrounds.html) | Orientation | 10 minutes |
| [Meet AIRO: your first conversation](docs/airo-1-meet-airo.html) | Foundational | 15 minutes |
| [You just got here: using AIRO to inherit a project](docs/airo-2-inherit-project.html) | Foundational | 45 minutes |

The course hub ([docs/index.html](docs/index.html)) links to all three.

## Structure

- `docs/` — the published surface: the course hub plus one self-contained
  page per lab (Pages source)
- Every commit is checked by the publish guard workflow
  (`.github/workflows/publish-guard.yml`); the same checks run locally as a
  pre-push hook — enable once per clone with:

```
git config core.hooksPath .githooks
```

## Contributing

Content is authored and reviewed elsewhere; this repo holds only pressed,
vetted output. Do not edit lab HTML in place — changes land as a fresh press
of the whole bundle.
