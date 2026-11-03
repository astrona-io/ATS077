# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 4 GiB of free memory, because Argo CD and a Git server run in the cluster.
- Network access at start, because Argo CD is installed from the upstream release manifest.
- `kubectl` and `jq`.
- You know what a Deployment is, and what a Kustomize overlay is.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads in `starfleet` and `outpost`, Argo CD 3.5.4 in `argocd` and a Git server in `gitea`.
