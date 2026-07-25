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

### Resource requests and limits

Every component under `components.*` ships a default `resources` block. Without
requests the kube-scheduler treats these pods as weightless and will happily
pack the entire stack onto a single node — which is what happens after a node
outage, and it does not unwind by itself once the node returns.

| Component | CPU request | Memory request | Memory limit |
| --- | --- | --- | --- |
| `api` | 50m | 128Mi | 512Mi |
| `events` | 25m | 64Mi | 256Mi |
| `autumn` | 25m | 64Mi | 512Mi |
| `january` | 25m | 64Mi | 256Mi |
| `gifbox` | 25m | 64Mi | 256Mi |
| `crond` | 10m | 64Mi | 256Mi |
| `pushd` | 10m | 64Mi | 256Mi |
| `web` | 10m | 64Mi | 256Mi |
| `voice-ingress` (opt-in) | 25m | 64Mi | 256Mi |
| `livekit` (opt-in) | 100m | 128Mi | 512Mi |

Defaults enabled: **180m CPU / 576Mi memory** requested. With voice enabled:
**305m CPU / 768Mi memory**.

Memory carries a limit so a runaway process cannot take the node with it. CPU
deliberately has no limit — CFS throttling on `livekit` surfaces as audio
glitches for every participant in a call. Override per component:

```yaml
components:
  api:
    resources:
      requests:
        memory: 256Mi
```

### MongoDB: prefer the operator

The bundled MongoDB subchart is fine for evaluation but pulls from Bitnami,
whose free `docker.io/bitnami/*` images are no longer maintained. For
production, run [MongoDB Community Operator](https://github.com/mongodb/mongodb-kubernetes-operator)
out of band — it gives you proper replica-set management, TLS, and rolling
upgrades. Then keep `infrastructure.mongodb.enabled=false` and point
`infrastructure.mongodb.uri` at the operator-managed connection string.

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

## Tests

Rendering assertions live in `charts/stoatchat/tests/` and run with
[helm-unittest](https://github.com/helm-unittest/helm-unittest):

```bash
helm plugin install https://github.com/helm-unittest/helm-unittest --verify=false
helm unittest charts/stoatchat
```

The suites are excluded from the packaged chart via `.helmignore`.

## CI workflow

This repo includes `.github/workflows/build-chart.yml` to lint/unittest/template/package the chart and push it to GHCR on push events.
