# GitOps And Deployment Configuration - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-077-playground-070-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

Argo CD 3.5.4 and an in-cluster Git server holding a Kustomize repository for `scout`. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-077-playground-070-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. Argo CD is installed from the upstream release manifest at start, so the host needs network access.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, port-forwards, init scripts) |
| `manifests/lab-start.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `manifests/gitea.yaml` | The in-cluster Git server |
| `bootstrap/` | Installs Gitea and Argo CD and seeds the repository |
| `repos/scout-deploy/` | The Kustomize base and the two overlays pushed to Git |
| `docs/overview.md` | What the environment contains and ideas to try |
