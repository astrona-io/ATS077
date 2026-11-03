# Question

Solve this question on: `terminal`

Argo CD delivers `scout` from the Git repository `starfleet/scout-deploy` to two environments. The Application `scout-staging` tracks `overlays/staging` and the Application `scout-production` tracks `overlays/production`, both on the branch `main` with automated sync, `prune` and `selfHeal`. Staging runs `ghcr.io/stefanprodan/podinfo:6.15.0`. Production runs `ghcr.io/stefanprodan/podinfo:6.14.0`.

The Git server is reachable from your terminal at `http://127.0.0.1:3000` (the port-forward `gitea`). The user is `platform` and the password is `starfleet-gitops`. Inside the cluster the repository is `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`.

Promote production to 6.15.0 through Git and record the result.

1. Clone the repository, change the image tag in `overlays/production/kustomization.yaml` from `6.14.0` to `6.15.0`, commit, and push to `main`. Do not change the production Deployment with `kubectl`.

2. Wait until `scout-production` is `Synced` and `Healthy` and its synced revision is the commit you pushed.

3. In `argocd`, create the ConfigMap `promotion-record` with the keys `commit` (the commit hash at the head of `main`), `synced-revision` (the revision from `.status.sync.revision` of `scout-production`), `image` (the image that production runs) and `environment` (`production`). Derive the values from Git and the cluster.

Keep both Applications as they are, with automated `prune` and `selfHeal`. Do not delete, scale down or replace `scout`, `probe` or `shuttle` in `starfleet`. `kubectl` already points at the cluster as the cluster administrator.
