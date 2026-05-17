There does not appear to be an official, maintained upstream Helm chart for Stoat/Revolt in the sources reviewed, while the official self-hosted project is explicitly centered on Docker Compose and documents deployment that way. So in practice, you should assume **you will need to create your own chart** or convert the stack into plain Kubernetes manifests and wrap them with Helm. [github](https://github.com/stoatchat/self-hosted)

## How hard it is

It is **not trivial**, but for someone comfortable with Kubernetes, Helm, and Flux it is very doable because the Compose setup is mostly a collection of standard containers, env files, ports, and volumes rather than anything magical. The main work is splitting one Compose-defined stack into Kubernetes primitives: Deployments or StatefulSets, Services, Ingress, Secrets, ConfigMaps, and persistent storage. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)

The upstream repo also notes recent breaking changes and added components such as RabbitMQ and `pushd`, which means your chart needs to track upstream fairly closely rather than being a one-time conversion. That makes a private chart feasible, but you should expect ongoing maintenance as the stack evolves. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)

## What to map

From the upstream self-hosted repo, the deployment includes the back end, web front end, file server, metadata/image proxy, database, and supporting services, with configuration driven by `.env.web`, `Revolt.toml`, and the generated setup flow. At minimum, your chart should separate these concerns: [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)

- Web frontend deployment, usually stateless. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)
- API/backend deployment, with config from `Revolt.toml`. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)
- Caddy or your own Ingress controller; on Kubernetes I would usually replace bundled Caddy with Ingress. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)
- MongoDB, Redis, RabbitMQ, and object storage, either self-managed in-cluster or delegated to existing charts/operators depending on your cluster standards. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)
- Push daemon and any other newly added auxiliary services the Compose file now expects. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)

## Best chart strategy

The easiest path is usually **not** “convert the Compose file 1:1 into one giant chart.” A better pattern is to create one small app chart for Stoat-specific components and depend on existing community charts for MongoDB, Redis, RabbitMQ, and MinIO/S3-compatible storage, because those dependencies already handle persistence, probes, upgrades, and security better than a hand-rolled copy of Compose would. [github](https://github.com/prometheus-community/helm-charts)

A practical Helm layout would be:
- `templates/deployment-web.yaml`
- `templates/deployment-api.yaml`
- `templates/deployment-autumn-or-files.yaml`
- `templates/deployment-pushd.yaml`
- `templates/service-*.yaml`
- `templates/ingress.yaml`
- `templates/configmap-revolt.yaml`
- `templates/secret-env.yaml`
- optional dependency blocks in `Chart.yaml` for MongoDB, Redis, RabbitMQ, and MinIO

That approach keeps your own chart focused on the Stoat-specific parts while offloading generic infrastructure to better-maintained charts. [github](https://github.com/prometheus-community/helm-charts)

## Is it easy to make your own

Yes, if your goal is a **basic internal chart for your own cluster**, it is reasonably achievable because the upstream docs make clear which config files and public URLs matter, such as `REVOLT_PUBLIC_URL`, `HOSTNAME`, and the `app` and `events` values in `Revolt.toml`. No, if your goal is a polished public chart for others, because you then need to support upgrades, migrations, storage backends, optional reverse-proxy modes, and upstream changes like the November 2024 config rename and new services. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)

A good rule of thumb:
- Personal chart for your homelab or cluster: moderate effort. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)
- Reusable public Helm chart: high effort, ongoing maintenance. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)

## Recommended path

I’d recommend this sequence:
1. Start from the upstream Compose repo and list every service, image, volume, env var, and dependency edge. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)
2. Replace bundled infrastructure with proven subcharts or external services where possible, especially MongoDB, Redis, RabbitMQ, and object storage. [github](https://github.com/prometheus-community/helm-charts)
3. Put `Revolt.toml` in a ConfigMap, sensitive values in Secrets, and expose only `/`, `/api`, and `/ws` through a single HTTPS Ingress, since the upstream custom-domain guidance uses those public endpoints. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)
4. Use Flux to manage the HelmRelease once the chart is stable, instead of trying to invent the chart and GitOps structure at the same time. [opensourcealternative](https://opensourcealternative.to/alternativesto/discord)

If you want, I can draft a **starter Helm chart structure** next, including `Chart.yaml`, `values.yaml`, Deployments, Services, and an Ingress for `/`, `/api`, and `/ws`.
