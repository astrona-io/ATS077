# Overview: GitOps And Deployment Configuration (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with Argo CD and a Git server, and then waits. There is no task, no `astrona submit` and no pass or fail. Create, break, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The example workloads in `starfleet` (`scout`, `probe`, `shuttle`) and `outpost` (`drifter`).
- Argo CD 3.5.4 in `argocd`. The web page is forwarded to `https://127.0.0.1:8080`. The initial admin password is in the Secret `argocd-initial-admin-secret`.
- A Gitea server in `gitea`, forwarded to `http://127.0.0.1:3000`. Sign in as `platform` with the password `starfleet-gitops`.
- The private repository `starfleet/scout-deploy` with `base`, `overlays/staging` (tag 6.15.0, one replica) and `overlays/production` (tag 6.14.0, two replicas).
- No repository credentials and no Application exist yet.

## Practice tasks

- Create a repository Secret and an Application without `automated` and read `OutOfSync` and `Missing`. Then add `automated` and watch the Deployment appear.
- Scale a synced Deployment by hand and watch `selfHeal` revert it. Turn `selfHeal` off and repeat.
- Remove a file from the overlay in Git and see `prune` delete the resource.
- Clone the repository, run `kubectl kustomize overlays/production` and diff it against staging.
- Promote production to 6.15.0 with a commit, and compare `git rev-parse HEAD` with `.status.sync.revision`.
- Revert the commit and confirm the image returns to 6.14.0.
