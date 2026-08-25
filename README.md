# Cloud Three-Tier Platform

A portfolio project demonstrating a three-tier application architecture built with Node.js, TypeScript, PostgreSQL, Docker, and later AWS and Terraform.

## Current Stage

The local application backend is complete.

The project currently includes:

- Node.js and TypeScript API using Express
- PostgreSQL database
- PostgreSQL running in Docker
- Automatic database table initialization
- Environment-based configuration
- Task CRUD API
- Request validation and error handling
- TypeScript type checking

## Architecture

Currently, the application runs locally:

```text
Client / curl
     |
     | HTTP Request
     v
Express API
localhost:3000
     |
     | SQL Query
     v
PostgreSQL
Docker container
```

Later, this local architecture will become:

```text
Internet
   |
   v
Application Load Balancer
   |
   v
EC2 Application Tier
   |
   v
RDS PostgreSQL
```

## Prerequisites

- Node.js
- Docker Desktop
- Docker Compose

## Start PostgreSQL

From the project root:

```bash
docker compose up -d
```

Verify the container:

```bash
docker compose ps
```

## Start the API

From the `app` directory:

```bash
npm install
npm run dev
```

The API runs at:

```text
http://localhost:3000
```

## Environment Configuration

Create an `app/.env` file:

```env
PORT=3000
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/cloudapp
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

## Example Request

Create a task:

```bash
curl -X POST http://localhost:3000/api/tasks \
-H "Content-Type: application/json" \
-d '{"title":"Deploy three-tier app","description":"Build the API tier"}'
```

## Validation

The API currently validates:

- Task title must be a non-empty string.
- Task IDs must be positive numbers.
- Description must be a string when provided.
- `completed` must be a boolean.
- Missing tasks return `404 Not Found`.
- Invalid requests return `400 Bad Request`.

## Type Checking

Run:

```bash
cd app
npm run typecheck
```

## Next Step

Package the Node.js application into a Docker container, then begin building the AWS infrastructure with Terraform.