# Environment Boundaries - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-077-playground-030-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node cluster with the Starfleet workloads and three environment namespaces (dev, test, prod), each with a ConfigMap named app-config. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-077-playground-030-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and ideas to try |
