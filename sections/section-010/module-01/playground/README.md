# Desired State, Rendering And Controllers - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-077-playground-010-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the Starfleet workloads (`scout`, `probe`, `shuttle` in `starfleet`, `drifter` in `outpost`). Use it to read desired state and status, delete pods and watch controllers repair them, render Kustomize overlays and create and resolve drift. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-077-playground-010-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and ideas to try |
