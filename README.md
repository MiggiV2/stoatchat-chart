# Stoatchat Helm Chart

This repository provides a custom Helm chart for deploying Stoatchat based on the upstream `self-hosted/` Docker Compose setup.

## Chart location

- `charts/stoatchat`

## What is included

- Stoatchat app components:
  - `api`, `events`, `autumn`, `january`, `gifbox`, `crond`, `pushd`, `web`
  - optional: `voice-ingress`, `livekit`
- Kubernetes Ingress routes equivalent to upstream Caddy paths:
  - `/`, `/api`, `/ws`, `/autumn`, `/january`, `/gifbox`
  - optional: `/livekit`, `/ingress`
- Config and secret wiring:
  - `Revolt.toml` via ConfigMap
  - app secrets via Secret env vars (same key names used by `secrets.env`)
  - web public URL environment values via ConfigMap
- Optional infrastructure dependencies via Helm dependencies:
  - MongoDB, Valkey, RabbitMQ, RustFS

## Design defaults

Following `GUIDE.md` recommendations, the chart defaults to **external infrastructure endpoints**, except for object storage which defaults to the bundled RustFS subchart.
You can enable bundled dependencies by toggling:

- `infrastructure.mongodb.enabled=true`
- `infrastructure.redis.enabled=true`
- `infrastructure.rabbitmq.enabled=true`
- `infrastructure.rustfs.enabled=true` (default)

Wire the S3 backend into `files.s3` in `Revolt.toml` (see `values.yaml`).

## Quick start

1. Install dependencies and render values:

```bash
helm dependency update charts/stoatchat
```

2. Copy and edit values:

```bash
cp charts/stoatchat/values.yaml /tmp/stoatchat-values.yaml
```

3. Set the required domain and secrets in your values file:

- `global.domain`
- `secrets.REVOLT__PUSHD__VAPID__PRIVATE_KEY`
- `secrets.REVOLT__PUSHD__VAPID__PUBLIC_KEY`
- `secrets.REVOLT__FILES__ENCRYPTION_KEY`
- `secrets.REVOLT__API__LIVEKIT__NODES__WORLDWIDE__KEY`
- `secrets.REVOLT__API__LIVEKIT__NODES__WORLDWIDE__SECRET`

4. Install:

```bash
helm upgrade --install stoatchat charts/stoatchat -n stoatchat --create-namespace -f /tmp/stoatchat-values.yaml
```

## Install from OCI

The CI workflow publishes chart packages to GHCR as OCI artifacts.

```bash
# login (if your package visibility requires auth)
echo "${GITHUB_TOKEN}" | helm registry login ghcr.io -u <github-user> --password-stdin

# install directly from OCI
helm install stoatchat oci://ghcr.io/miggiv2/charts/stoatchat --version 0.1.2 -n stoatchat --create-namespace

# or upgrade using OCI source
helm upgrade stoatchat oci://ghcr.io/miggiv2/charts/stoatchat --version 0.1.2 -n stoatchat
```

## Using existing secrets/config

If you already have managed resources:

- set `existingSecretsName` to reuse an existing Secret
- set `config.existingRevoltTomlConfigMap` and `config.existingLivekitConfigMap` to reuse ConfigMaps

## Notes about voice/video

- `livekit` and `voice-ingress` are disabled by default.
- If you enable them, ensure your cluster/network setup supports the required voice/RTC networking model.
- To expose LiveKit media ports externally, enable `components.livekit.mediaService.enabled=true`.
- For k3s ServiceLB pinning to a specific node pool, set `components.livekit.mediaService.serviceLbPool` (for example `main`).
- To pin the LiveKit pod to a specific node, use `components.livekit.nodeSelector` and matching `tolerations`.

## CI workflow

This repo includes `.github/workflows/build-chart.yml` to lint/template/package the chart and push it to GHCR on push events.
