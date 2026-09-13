# Cloud Three-Tier Platform

A portfolio project demonstrating a three-tier application architecture built with Node.js, TypeScript, PostgreSQL, Docker, local AWS service emulation with Floci, and later AWS and Terraform.

## Current Stage

The local three-tier application foundation is complete.

The project currently includes:

- Node.js and TypeScript API using Express
- PostgreSQL database
- Task CRUD API with validation and error handling
- PostgreSQL running in Docker
- Node.js API running in Docker
- Docker Compose orchestration
- Automatic database table initialization
- Persistent PostgreSQL Docker volume
- Environment-based configuration
- TypeScript type checking
- Floci for local AWS service emulation
- S3-compatible object storage
- Upload and object listing API endpoints

## Architecture

Currently, the application runs locally using Docker Compose:

```text
             Client / curl
                   |
                   | HTTP Request
                   v
              Express API
              localhost:3000
                   |
         +---------+---------+
         |                   |
         v                   v
     PostgreSQL            Floci
     Docker container      Docker container
         |                   |
         v                   v
      Task data          Emulated S3
                              |
                              v
                    cloud-project-uploads
                              |
                              v
                          hello.txt
```

The API container communicates with PostgreSQL and Floci through the internal Docker network.

PostgreSQL data persists in the `postgres_data` volume even when the containers are stopped and recreated.

The current upload flow is:

```text
Client / curl
     |
     | POST /api/uploads
     v
Express API
     |
     v
AWS SDK
     |
     v
Floci
     |
     v
Emulated S3 Bucket
     |
     v
cloud-project-uploads
```

Later, this local architecture will become:

```text
                     Internet
                        |
                        v
             +---------------------+
             | Application Load    |
             | Balancer            |
             +----------+----------+
                        |
                        v
             +---------------------+
             |    EC2 Instances    |
             |                     |
             |  Node.js API Tier   |
             +----------+----------+
                        |
              +---------+---------+
              |                   |
              v                   v
     +----------------+   +----------------+
     | RDS PostgreSQL |   |    AWS S3      |
     |                |   |                |
     | Database Tier  |   | Object Storage |
     +----------------+   +----------------+
```

## Prerequisites

- Node.js
- Docker Desktop
- Docker Compose

## Start the Application

From the project root:

```bash
docker compose up --build -d
```

This starts:

```text
cloud-api
cloud-postgres
cloud-floci
```

Verify the containers:

```bash
docker compose ps
```

The API is available at:

```text
http://localhost:3000
```

Stop the containers:

```bash
docker compose down
```

## Environment Configuration

The local development environment uses:

```env
PORT=3000
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/cloudapp
```

When running through Docker Compose, the API communicates with PostgreSQL using the PostgreSQL service name:

```text
postgresql://postgres:postgres@postgres:5432/cloudapp
```

The API also uses the following environment variables for local S3-compatible storage:

```env
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_ENDPOINT_URL=http://floci:4566
S3_BUCKET=cloud-project-uploads
```

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/health` | Checks whether the API is running |
| GET | `/db-health` | Checks PostgreSQL connectivity |
| POST | `/api/tasks` | Creates a task |
| GET | `/api/tasks` | Returns all tasks |
| GET | `/api/tasks/:id` | Returns one task |
| PUT | `/api/tasks/:id` | Updates a task |
| DELETE | `/api/tasks/:id` | Deletes a task |
| POST | `/api/uploads` | Stores text content in the S3-compatible bucket |
| GET | `/api/uploads` | Lists stored objects |

## Task API Example

Create a task:

```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Deploy three-tier app","description":"Build the API tier"}'
```

Get all tasks:

```bash
curl http://localhost:3000/api/tasks
```

## Object Storage Example

Upload text to the S3-compatible bucket:

```bash
curl -X POST http://localhost:3000/api/uploads \
  -H "Content-Type: application/json" \
  -d '{"key":"hello.txt","content":"Hello from local AWS S3"}'
```

List stored objects:

```bash
curl http://localhost:3000/api/uploads
```

A successful response will return object metadata similar to:

```json
[
  {
    "Key": "hello.txt",
    "LastModified": "2026-08-25T19:14:29.000Z",
    "ETag": "\"26a4b92b89646e46ddfbe7ddec96efcf\"",
    "Size": 23,
    "StorageClass": "STANDARD"
  }
]
```

## Validation

The API currently validates:

- Task title must be a non-empty string.
- Task IDs must be positive numbers.
- Description must be a string when provided.
- `completed` must be a boolean.
- Upload keys must be non-empty strings.
- Upload content must be a string.
- Missing tasks return `404 Not Found`.
- Invalid requests return `400 Bad Request`.

## Database Persistence

PostgreSQL data is stored in a Docker volume named `postgres_data`.

This means the following sequence does not delete tasks:

```bash
docker compose down
docker compose up -d
```

The containers and Docker network are recreated, but the PostgreSQL data remains in the persistent volume.

## Local AWS Emulation

Floci is used only for local development and testing.

The application uses the AWS SDK for JavaScript to communicate with an S3-compatible API. Instead of connecting to real AWS S3, the SDK is configured to connect to the local Floci container.

Current flow:

```text
Express API
     |
     v
AWS SDK
     |
     v
Floci
     |
     v
Emulated S3 bucket
```

Later, Floci will be replaced by real AWS services managed through Terraform.

## Type Checking

Run:

```bash
cd app
npm run typecheck
```

## Automated Smoke Tests

Run the complete local API smoke-test flow from the project root:

```bash
npm run test:smoke
```

The command starts (or reuses) Docker Compose, waits for the API and database health checks, and verifies task CRUD, validation responses, and the Floci-backed S3 upload/list flow. It leaves the containers running and does not remove the PostgreSQL volume.

## Project Structure

```text
cloud-project/
│
├── app/
│   ├── src/
│   │   ├── index.ts
│   │   ├── db.ts
│   │   ├── storage.ts
│   │   └── sql/
│   │       └── init.sql
│   │
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── .env
│   ├── .env.example
│   └── package.json
│
├── infra/
│   ├── modules/
│   │   └── vpc/
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       └── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
│
├── tests/
│
├── docs/
│
├── docker-compose.yml
├── .gitignore
└── README.md
```

## Next Step

The next phase is building the AWS infrastructure with Terraform, starting with the VPC and network architecture.

The Terraform files will first be validated locally using:

```bash
terraform validate
```

No AWS infrastructure will be deployed during the initial Terraform module work.
