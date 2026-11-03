---
draft: true
exam_objectives:
- Application Environments and Infrastructure Concepts
---
# Environment Boundaries, Dependencies And Resource Isolation

This module explains how application environments are separated on a platform. It covers what a namespace does and does not isolate, how quotas and limits keep shared capacity fair, and how identity, data and configuration stay specific to one environment while the same artifact moves through all of them.

## Learning Goals

- Distinguish development, test and production environments by purpose.
- Explain identity, data and capacity separation.
- Reason about configuration parity without assuming identical conditions.
- Create a quota, a limit range and an environment-specific configuration, and read the signals they produce.

## Before You Start

You should know what a pod, a Deployment and a namespace are. The hands-on part uses a playground with a kind cluster and `kubectl`. Technical terms are defined where they first appear.

## Reading Order

1. Environments And The Boundaries That Separate Them
2. Quotas, Limits And Capacity Isolation
3. Identity, Data And Environment Lifecycle
4. Summary

<!-- astrona:playground -->
