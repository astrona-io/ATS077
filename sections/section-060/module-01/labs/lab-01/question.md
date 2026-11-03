# Question

Solve this question on: `terminal`

The team models its pipeline in the cluster. The namespace `ci` holds the ConfigMap `source`, which has the key `revision` with the revision to build. The namespaces `staging` and `production` exist and are empty. Run the check stage, write the build record and promote the same artifact to both environments.

1. In `ci`, create a Job named `unit-checks` that runs the image `curlimages/curl:8.22.0` with a shell command. The Job mounts the ConfigMap `source` as a volume and its command exits with status zero only when the file `revision` in the mount equals the revision in the ConfigMap and the file `greeting` is not empty. The Job does not retry (`backoffLimit: 0`). Label the Job `ci.starfleet.io/revision` with the actual revision from the ConfigMap. Wait for it to complete.

2. In `ci`, create the ConfigMap `build-record` with the keys `revision` (the revision from `source`), `image` (`ghcr.io/stefanprodan/podinfo:6.15.0`), `checks` (`passed`) and `job` (`unit-checks`).

3. Promote the image from the build record to both environments. In each of `staging` and `production`, create the ConfigMap `app-config` with the key `PODINFO_UI_MESSAGE` set to the name of the namespace, and a Deployment `scout` with one replica that runs the image from the record, names the container port `http` (`9898`) and reads `app-config` through `envFrom`. Both Deployments must be available.

Do not use a `latest` tag. Do not delete, scale down or replace `scout`, `probe` or `shuttle` in `starfleet`. `kubectl` already points at the cluster as the cluster administrator.
