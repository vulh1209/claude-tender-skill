# Project Management API Reference

Manage projects, packages, BOQs, and contractors.

## Global Search

Search across all entities (projects, packages, submissions, BOQs, contractors) in a single query.

```bash
# Search across all entities
api_get "/global-search?search=keyword&skip=0&take=10"

# URL encode special characters (e.g., / becomes %2F)
api_get "/global-search?search=09%2F12%2F2025&skip=0&take=10"
```

**Response:**
```json
{
  "data": [
    {"id": "uuid", "name": "Package Name", "type": "package"},
    {"id": "uuid", "name": "Submission Name", "type": "submission"},
    {"id": "uuid", "name": "Project Name", "type": "project"}
  ],
  "total": 3
}
```

**Entity Types:** `project`, `package`, `submission`, `boq`, `contractor`

> **💡 Technical Notes:**
> - **Scoped vs Global**: `/packages`, `/submissions` are scoped endpoints (filtered by project/package). `/global-search` is unscoped and searches across all entities.
> - **URL Encoding**: Special characters must be URL encoded (e.g., `/` → `%2F`, space → `%20`). Without encoding, the server may misinterpret the URL path.
> - **Performance**: Global search typically uses full-text indexing (Elasticsearch, PostgreSQL FTS) for fast lookups across large datasets, while scoped endpoints use standard database queries.

---

## Projects

### List Projects
```bash
api_get "/project"
api_get "/project?search=construction&skip=0&take=20"
```

### Get Project
```bash
api_get "/project/<id>"
```

### Create Project
```bash
api_post "/project" '{
  "name": "Office Building Construction",
  "description": "New HQ construction project",
  "startDate": "2025-01-01",
  "endDate": "2025-12-31"
}'
```

### Update Project
```bash
api_patch "/project/<id>" '{
  "name": "Updated Project Name",
  "description": "Updated description"
}'
```

### Delete Project
```bash
# Soft delete (recoverable)
api_delete "/project/<id>"

# Hard delete (permanent)
api_delete "/project/<id>/hard"
```

### Restore Project
```bash
api_post "/project/<id>/restore"
```

## Packages

### List Packages
```bash
api_get "/packages?projectId=<uuid>"
api_get "/packages?projectId=<uuid>&search=electrical&skip=0&take=20"
```

### Get Package
```bash
api_get "/packages/<id>"
```

### Create Package
```bash
api_post "/packages" '{
  "projectId": "<uuid>",
  "name": "Electrical Works",
  "description": "Main electrical installation"
}'
```

### Update Package
```bash
api_put "/packages/<id>" '{
  "name": "Updated Package Name"
}'
```

### Delete Package
```bash
api_delete "/packages/<id>"
```

### Package Revisions

```bash
# Create new revision
api_post "/packages/<id>/revisions"

# List revisions
api_get "/packages/<id>/revisions"
```

## BOQ (Bill of Quantities)

### List BOQs
```bash
api_get "/boq?packageId=<uuid>"
api_get "/boq?packageId=<uuid>&search=steel&skip=0&take=50"
```

### Get BOQ
```bash
api_get "/boq/id/<id>"
```

### Create BOQ
```bash
api_post "/boq" '{
  "packageId": "<uuid>",
  "name": "Structural Steel BOQ",
  "description": "Steel work quantities"
}'
```

### Update BOQ
```bash
api_patch "/boq/<id>" '{
  "name": "Updated BOQ Name"
}'
```

### Delete BOQ
```bash
api_delete "/boq/<id>"
```

### Promote BOQ
Promote BOQ to a package revision.

```bash
api_post "/boq/promote" '{
  "boqId": "<uuid>",
  "packageRevisionId": "<uuid>"
}'
```

### Generate System Name
```bash
api_get "/boq/generate-system-name?packageId=<uuid>&prefix=BOQ"
```

## BOQ Items

### List BOQ Items
```bash
api_get "/boq-items?boqId=<uuid>&skip=0&take=100"
```

### Create BOQ Items (Batch)
```bash
api_post "/boq-items/batch" '{
  "boqId": "<uuid>",
  "items": [
    {
      "name": "Steel Beam 200x200",
      "unit": "kg",
      "quantity": 5000,
      "unitPrice": 25000
    },
    {
      "name": "Steel Column 300x300",
      "unit": "kg",
      "quantity": 3000,
      "unitPrice": 26000
    }
  ]
}'
```

### Update BOQ Items (Batch)
```bash
api_patch "/boq-items/batch" '{
  "items": [
    {"id": "<uuid>", "quantity": 5500},
    {"id": "<uuid>", "unitPrice": 27000}
  ]
}'
```

### Delete BOQ Items (Batch)
```bash
api_delete "/boq-items/batch" '{
  "ids": ["<uuid>", "<uuid>"]
}'
```

## Contractors

### List Contractors
```bash
api_get "/contractors"
api_get "/contractors?search=ABC&skip=0&take=20"
```

### Get Contractor
```bash
api_get "/contractors/<id>"
```

### Create Contractor
```bash
api_post "/contractors" '{
  "name": "ABC Construction Ltd",
  "email": "contact@abc-construction.com",
  "phone": "+84-123-456-789",
  "address": "123 Main St, Hanoi"
}'
```

### Update Contractor
```bash
api_patch "/contractors/<id>" '{
  "phone": "+84-987-654-321"
}'
```

### Delete Contractor
```bash
api_delete "/contractors/<id>"
```

## Hierarchy

```
Organization
└── Project
    └── Package
        └── Package Revision
            ├── BOQ
            │   └── BOQ Items
            └── Submission
                └── Submission Evaluation
```

## Workflow Example

```bash
# 1. Create project
PROJECT=$(api_post "/project" '{
  "name": "New Construction Project",
  "description": "2025 Office Building"
}')
PROJECT_ID=$(echo $PROJECT | jq -r '.data.id')

# 2. Create package
PACKAGE=$(api_post "/packages" '{
  "projectId": "'$PROJECT_ID'",
  "name": "Civil Works"
}')
PACKAGE_ID=$(echo $PACKAGE | jq -r '.data.id')

# 3. Get latest revision
REVISIONS=$(api_get "/packages/$PACKAGE_ID/revisions")
REVISION_ID=$(echo $REVISIONS | jq -r '.data[0].id')

# 4. Create BOQ
BOQ=$(api_post "/boq" '{
  "packageId": "'$PACKAGE_ID'",
  "name": "Foundation BOQ"
}')
BOQ_ID=$(echo $BOQ | jq -r '.data.id')

# 5. Add BOQ items
api_post "/boq-items/batch" '{
  "boqId": "'$BOQ_ID'",
  "items": [
    {"name": "Concrete Grade 30", "unit": "m3", "quantity": 500},
    {"name": "Steel Rebar", "unit": "kg", "quantity": 10000}
  ]
}'

# 6. List all items
api_get "/boq-items?boqId=$BOQ_ID"
```
