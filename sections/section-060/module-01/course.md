---
draft: true
exam_objectives:
- Continuous Integration Fundamentals
---
# Build And Release Pipelines

This module explains how a pipeline turns a source revision into a checked, identifiable artifact, how that one artifact is promoted through environments, and how identities, release records and rollback keep a release defensible. Pipeline stages are modelled with Jobs and ConfigMaps in a cluster, so each stage leaves evidence that can be read.

## Learning Goals

- Trace source changes through build, checks and artifact publication.
- Explain what continuous integration checks.
- Distinguish continuous delivery from continuous deployment.
- Relate release identity to an immutable artifact.
- Give each pipeline stage its own narrow identity and keep a release record.

## Before You Start

You should know what a Deployment, a Job and a ConfigMap are. The hands-on parts use a playground with a kind cluster and `kubectl`. Technical terms are defined where they first appear.

## Reading Order

1. Source Changes And Build Evidence
2. Delivery, Deployment And Promotion Decisions
3. Pipeline Identities, Release Records And Rollback
4. Summary

<!-- astrona:playground -->
