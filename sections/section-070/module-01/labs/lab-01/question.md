# Question

Solve this question on: `terminal`

Argo CD is installed in the namespace `argocd`. A private Git repository `starfleet/scout-deploy` holds a Kustomize base and the overlays `overlays/staging` and `overlays/production` for the application `scout`. The repository is served inside the cluster at `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. The user is `platform` and the password is `starfleet-gitops`. Argo CD has no credentials for it and no Application exists.

Deliver the staging overlay with Argo CD.

1. Give Argo CD read access to the repository with a repository Secret in `argocd`.

2. Create the Application `scout-staging` in `argocd`. It uses the project `default`, tracks the branch `main`, uses the path `overlays/staging` and deploys to the namespace `staging` on the in-cluster server. Turn on automated sync with `prune` and `selfHeal`, and let Argo CD create the namespace.

3. Wait until the Application is `Synced` and `Healthy` and the Deployment `scout` runs in `staging`.

Do not create the resources of `scout` with `kubectl`. The Application must own them. Do not delete, scale down or replace `scout`, `probe` or `shuttle` in `starfleet`. `kubectl` already points at the cluster as the cluster administrator.
