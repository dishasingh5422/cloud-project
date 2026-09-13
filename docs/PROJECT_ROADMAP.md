# Cloud Three-Tier Platform — Product and Engineering Roadmap

## Purpose

This is a DevOps/cloud portfolio project, not a feature-heavy consumer product. Its primary users are:

1. a developer who needs a repeatable local and AWS deployment workflow; and
2. a reviewer who needs clear evidence that the system is secure, automated, observable, and recoverable.

The project will stand out through operating discipline and evidence, rather than through adding every AWS service or unrelated AI/personalisation features.

## Verified current state

| Area | Status | Evidence / note |
|---|---|---|
| Application API | Complete locally | Node.js, TypeScript, Express, health endpoints, and task CRUD are implemented. |
| Data | Complete locally | PostgreSQL is initialised with `tasks` and persists through the Compose volume. |
| Object storage | Complete locally | The AWS JavaScript SDK uploads text and lists objects through Floci's S3-compatible endpoint. |
| Containers | Complete locally | Compose orchestrates API, PostgreSQL, and Floci; the API has a Dockerfile. |
| Basic robustness | Complete locally | Request validation and HTTP 400/404/500 responses exist, along with a repeatable smoke suite for the documented local API and Floci flows. |
| Infrastructure | Not started | Terraform root and VPC module files exist but are empty. |
| Deployment / operations | Not started | No AWS sandbox deployment, CI/CD, dashboard, alarm, or incident exercise yet. |

The local application foundation is complete. The overall three-tier platform is not complete until its AWS infrastructure, delivery path, and operational evidence exist.

## Phased roadmap

### Phase 1 — Core MVP

**Goal:** Reproducibly deploy the current API to a secure, monitored AWS three-tier environment.

1. Add repeatable API smoke tests for health, task CRUD, S3 upload/list, invalid input, and missing records.
2. Implement the Terraform VPC module: two AZs; public, private-app, and database subnet tiers; Internet Gateway; route tables; common tags; and validation.
3. Implement least-privilege security groups, then ALB, EC2 Auto Scaling Group, RDS PostgreSQL, IAM instance roles, and encrypted configuration/secrets.
4. Add a GitHub Actions baseline: application typecheck, smoke/integration tests, Docker build, `terraform fmt -check`, `terraform validate`, and security scanning.
5. Validate in a dedicated AWS sandbox after an explicit human-approved plan. Record deployment and teardown steps.

**MVP completion criteria**

- A fresh clone starts the local system and passes repeatable smoke tests.
- Terraform produces a validated modular configuration and a reviewed plan.
- An ALB routes only to healthy private app instances.
- The app accesses a private RDS instance and S3 through appropriately scoped identity and network access.
- The environment can be destroyed cleanly after validation.

### Phase 2 — Differentiating engineering features

**Goal:** Demonstrate the operational habits that distinguish a portfolio project from a tutorial copy.

| Feature | Problem solved | Why it is valuable |
|---|---|---|
| GitHub Actions with AWS OIDC | Avoids long-lived AWS access keys in GitHub. | Demonstrates modern credentialless CI/CD. |
| Pull-request Terraform plans | Makes infrastructure changes reviewable before they run. | Mirrors real-team change control. |
| CloudWatch dashboard and alarms | Provides visible health, error, latency, and capacity signals. | Shows observability, not just deployment. |
| ALB/ASG failure exercise | Proves recovery when an instance becomes unhealthy. | Provides concrete reliability evidence. |
| VPC Flow Logs and structured application logs | Supports diagnosis of application and network issues. | Shows layered observability and security awareness. |
| Secrets Manager and IAM roles | Keeps passwords and AWS permissions out of code and user data. | Demonstrates least privilege and secure configuration. |
| Cost controls | Budget alert, low-cost mode, documented NAT/RDS trade-offs, and teardown. | Demonstrates responsible cloud ownership. |
| Floci contract tests | Provides fast local S3/SQS/Secrets Manager API testing. | Shows cost-aware development while explicitly retaining real AWS validation. |

Floci remains limited to AWS API-oriented local tests. It is not evidence that VPC, NAT, ALB, EC2, IAM, RDS failover, or real AWS behaviour is correct.

### Phase 3 — Polish and presentation

**Goal:** Make the work easy to review, reproduce, and discuss in an interview.

1. Add clear Docker health checks and dependency readiness checks.
2. Improve API error responses, request-size limits, structured logs, and an empty-object response contract.
3. Add architecture, deployment, teardown, and incident-response runbooks.
4. Create one concise architecture diagram and a short recorded demo.
5. Capture evidence: successful CI, Terraform plan, healthy ALB targets, CloudWatch alarm, recovery exercise, and destroy output.
6. Add a short Well-Architected trade-off review covering security, reliability, cost, and operations.

## Features deliberately out of scope

- A frontend, onboarding journey, behavioural personalisation, or AI features are not required to demonstrate DevOps capability. They should be added only if they serve a specific application need.
- Kubernetes/EKS is not an automatic upgrade. The EC2 Auto Scaling implementation should be complete and explainable first.
- Adding AWS services without a user, operational, or architectural reason is not a portfolio advantage.

## Current priority order

1. Run and commit the repeatable local smoke suite.
2. Implement the VPC module and validate it locally — the next infrastructure task.
3. Add security groups, then ALB/EC2/RDS.
4. Add CI before allowing automated deployment.
5. Deploy to a cost-controlled AWS sandbox and capture operational evidence.
