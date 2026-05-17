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
  - MongoDB, Redis, RabbitMQ, MinIO

## Design defaults

Following `GUIDE.md` recommendations, the chart defaults to **external infrastructure endpoints**.  
You can enable bundled dependencies by toggling:

- `infrastructure.mongodb.enabled=true`
- `infrastructure.redis.enabled=true`
- `infrastructure.rabbitmq.enabled=true`
- `infrastructure.minio.enabled=true`

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

## Using existing secrets/config

If you already have managed resources:

- set `existingSecretsName` to reuse an existing Secret
- set `config.existingRevoltTomlConfigMap` and `config.existingLivekitConfigMap` to reuse ConfigMaps

## Notes about voice/video

- `livekit` and `voice-ingress` are disabled by default.
- If you enable them, ensure your cluster/network setup supports the required voice/RTC networking model.

## CI workflow

This repo includes `.github/workflows/build-chart.yml` to lint, template, and package the chart on pushes and pull requests.
