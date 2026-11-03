# Ownership, Feedback And Guardrails - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-077-playground-020-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads and a namespace `sandbox` with a Deployment `crew` that has no security context. Use it to label ownership, add probes, break and roll back a rollout, and enforce the restricted Pod Security Standard. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-077-playground-020-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and ideas to try |
