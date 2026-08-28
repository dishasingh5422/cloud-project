# ADR 0001: Local-first development with bounded Floci use

**Status:** Accepted  
**Date:** 2026-08-28

## Context

The project needs fast, repeatable local development without requiring a paid AWS environment for every application test. It also needs credible proof that the final AWS network and managed services work as designed.

## Decision

Run the API, PostgreSQL, and Floci with Docker Compose locally. Use Floci only for AWS API-shaped integration tests, beginning with S3-compatible object storage. Configure AWS endpoints and credentials through environment variables so the same application code can target Floci locally and real AWS in a sandbox.

## Consequences

### Benefits

- Fast local testing without an AWS account or cloud cost.
- The application uses the standard AWS JavaScript SDK rather than a project-specific fake API.
- S3, and later suitable services such as SQS or Secrets Manager, can be tested in a reproducible environment.

### Trade-offs and boundaries

- Floci does not prove real AWS VPC routing, NAT, ALB health behaviour, EC2 lifecycle, IAM edge cases, RDS availability, service quotas, or production performance.
- Terraform networking and compute plans must be verified in a dedicated AWS sandbox before the project claims AWS deployment support.
- The Floci container image must be pinned to a tested version before CI is introduced; `latest` is acceptable only during early exploration.

## Alternatives considered

- **Real AWS for all development:** more faithful but slower and incurs cost.
- **Pure mocks:** fast but do not test AWS SDK request/response compatibility.
- **No local S3 test:** simpler, but misses a useful local integration test and weakens the project's cost-aware workflow.
