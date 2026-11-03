# Platform Architecture - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-077-playground-040-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node cluster with the Starfleet workloads. The module adds a custom resource definition, a policy and role bindings during the exercises. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-077-playground-040-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and ideas to try |
