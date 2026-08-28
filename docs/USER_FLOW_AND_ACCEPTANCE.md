# User Flows and Acceptance Checks

## Who uses the project

The present API has no browser frontend. The meaningful user journeys are therefore API-consumer and developer/operator journeys. This is appropriate for the current DevOps portfolio scope.

## API consumer journey: manage a task

```text
Start → API health check → Create task → List tasks → Read one task
      → Update task → Delete task → Confirm it no longer exists
```

| Stage | Expected response | Important negative case |
|---|---|---|
| Service check | `GET /health` returns 200 and `status: ok`. | API unavailable returns a connection failure. |
| Database check | `GET /db-health` confirms the database query works. | Database failure returns 500 without exposing credentials. |
| Create | `POST /api/tasks` with a non-empty title returns 201 and the saved task. | Missing/blank title returns 400. |
| List/read | `GET /api/tasks` lists saved tasks; `GET /api/tasks/:id` returns one. | Invalid ID returns 400; unknown task returns 404. |
| Update | `PUT /api/tasks/:id` returns the updated task. | Invalid field types return 400; unknown task returns 404. |
| Delete | `DELETE /api/tasks/:id` returns success. | A second read returns 404. |

## API consumer journey: store text in object storage

```text
Start → POST text with key → API ensures bucket exists → Floci/S3 stores object
      → GET object list → confirm key and metadata are present
```

| Stage | Expected response | Important negative case |
|---|---|---|
| Upload | `POST /api/uploads` returns 201 and the object key. | Empty key or non-string content returns 400. |
| List | `GET /api/uploads` returns stored object metadata. | Storage unavailability returns a safe 500 response. |

## Developer/operator journey: reproduce the local environment

```text
Clone repository → configure documented environment → docker compose up --build -d
→ verify API/database/storage → run smoke tests → docker compose down
→ docker compose up -d → confirm PostgreSQL task data remains
```

The developer should be able to reproduce the behaviour without an AWS account. Floci test credentials are local-only placeholders; they must never be reused for real AWS.

## Core verification checklist

Run this checklist before adding AWS infrastructure and later as CI smoke tests.

```bash
docker compose up --build -d
curl --fail http://localhost:3000/health
curl --fail http://localhost:3000/db-health
```

Then verify each positive and negative case:

- Create, list, retrieve, update, and delete a task.
- Confirm blank task title, invalid IDs, and unknown task IDs return the documented 400/404 responses.
- Upload a text object and ensure it appears in `GET /api/uploads`.
- Restart Compose without `-v` and confirm an earlier task persists.

## Known gaps to resolve at the appropriate stage

- The checks above are currently manual. Replace them with automated smoke/integration tests before CI is treated as a release gate.
- Compose uses start order rather than health-gated dependency readiness. Add service health checks during polish.
- The upload endpoint stores text supplied as JSON; real multipart file upload and download are optional product features, not needed for the cloud architecture MVP.
- No frontend currently exists; loading, empty, and responsive UI states therefore do not apply yet. If a frontend is added, it must add a real demonstration purpose rather than distract from the platform scope.
