---
draft: true
exam_objectives:
- Platform Engineering Goals, Objectives, and Approaches
---
# User Needs, Golden Paths And Incremental Platform Adoption

This module explains how a platform team sets goals from the needs of its users, packages the recommended way to deploy a service as a golden path with Kustomize, and tracks adoption honestly, including the exceptions that cannot follow the path.

## Learning Goals

- Explain platform goals in terms of user outcomes.
- Distinguish a supported golden path from a universal mandate.
- Reason about feedback, prioritization and adoption evidence.
- Build a Kustomize base with overlays for two teams and measure adoption from the cluster.

## Before You Start

You should know what a Deployment, a Service and a namespace are. The hands-on part uses a playground with a kind cluster, `kubectl` and `jq`. Technical terms are defined where they first appear.

## Reading Order

1. User Needs And Platform Goals
2. Golden Paths With A Kustomize Base
3. Adoption, Feedback And Exceptions
4. Summary

<!-- astrona:playground -->
