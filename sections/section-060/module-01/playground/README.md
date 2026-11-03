# Build And Release Pipelines - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-077-playground-060-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A clean cluster for modelling pipeline stages with Jobs, promoting one image through two environments and practising scoped identities, release records and rollback. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-077-playground-060-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and ideas to try |
