# stoatchat-chart — Claude guidance

## Commit messages

Use this format for every commit on this repo:

```
<gitmoji> (<version>): <message>
```

- `<gitmoji>`: a single gitmoji emoji that fits the change (see https://gitmoji.dev).
  - `:sparkles:` ✨ for new features
  - `:bug:` 🐛 for bug fixes
  - `:wrench:` 🔧 for config/tooling
  - `:arrow_up:` ⬆️ for dependency bumps
  - `:fire:` 🔥 for removals
  - `:memo:` 📝 for docs
  - `:recycle:` ♻️ for refactors
- `<version>`: the `charts/stoatchat/Chart.yaml` `version` value the commit lands at (the chart version, not `appVersion`). Bump it in the same commit when the change is user-visible.
- `<message>`: short imperative summary (≤72 chars total line length when reasonable).

### Examples

```
✨ (0.2.0): Default storage backend to RustFS
🔥 (0.2.0): Drop MinIO subchart and bitnamilegacy image
⬆️ (0.2.1): Bump rabbitmq subchart to groundhog2k 2.3.0
🔧 (0.2.2): Wire LiveKit ServiceLB pool selector
🐛 (0.2.3): Fix ingress path for /january proxy
```

### Notes

- One logical change per commit.
- Bump `charts/stoatchat/Chart.yaml: version` for any change that affects rendered manifests, defaults, or dependencies. Pure docs/CI changes can keep the version.
- Don't include a `Co-Authored-By` trailer unless the user asks for it.
