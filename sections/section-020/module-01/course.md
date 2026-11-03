---
draft: true
exam_objectives:
- DevOps Practices in Platform Engineering
---
# Shared Ownership, Feedback And Platform Enablement

This module explains how DevOps and DevSecOps practices work on a platform. It shows how ownership is recorded on cluster objects, how probes, rollouts and rollbacks give a team feedback, and how a platform team builds security guardrails that let product teams deploy alone inside a safe boundary.

## Learning Goals

- Explain DevOps and DevSecOps as collaborative practices.
- Distinguish platform enablement from transferring every responsibility.
- Reason about feedback, security and supported service boundaries.
- Add ownership labels, a readiness probe and a restricted security context to a workload.

## Before You Start

You should know what a pod, a Deployment and a namespace are. The hands-on part uses a playground with a kind cluster and `kubectl`. Technical terms are defined where they first appear.

## Reading Order

1. Shared Ownership And Platform Enablement
2. Feedback Signals: Probes, Rollouts And Rollback
3. DevSecOps Guardrails In The Platform
4. Summary

<!-- astrona:playground -->
