# Evaluation API Reference

AI-powered document evaluation and tender analysis.

## Agent Endpoints

### Generate Evaluation (Sync)
Analyze documents with AI and generate comprehensive evaluation.

```bash
api_post "/agent/generate-evaluate" '{
  "submissionId": "<uuid>",
  "fileIds": ["<uuid>", "<uuid>"],
  "prompt": "Evaluate this tender submission for technical compliance"
}'
```

**Use Cases:**
- Tender document analysis
- Proposal evaluation
- Requirement extraction
- Document comparison

### Generate Evaluation V2 (Async Queue)
Queue evaluation job for background processing.

```bash
api_post "/agent/generate-evaluate-v2" '{
  "submissionId": "<uuid>",
  "submissionEvaluationId": "<uuid>",
  "referenceFileIds": ["<uuid>"],
  "model": "gemini-2.5-flash",
  "keyValueEvaluationItems": [
    {"key": "technical_score", "description": "Technical compliance score 0-100"}
  ]
}'
# Returns: { "message": "...", "submissionEvaluationId": "<uuid>" }
```

### Summarize Issue
Summarize differences between submission and BOQ.

```bash
api_post "/agent/summarize-issue" '{
  "boqId": "<uuid>",
  "submissionId": "<uuid>",
  "issueData": "..."
}'
```

### Sign-Off Document Composition
Generate structured data for decision paper.

```bash
api_post "/agent/sign-off-document-composition/<submissionId>"
# Returns JSON structure for DOCX generation
```

## Evaluation Template Endpoints

### Get Templates for Package
```bash
api_get "/evaluation/templates/<packageId>"
```

### Get Template for Package Revision
```bash
api_get "/evaluation/template/<packageRevisionId>"
```

### Upsert Evaluation Template
```bash
api_post "/evaluation/template/upsert" '{
  "packageRevisionId": "<uuid>",
  "name": "Technical Evaluation",
  "keyItems": [
    {"key": "compliance", "description": "Compliance score", "weight": 30}
  ]
}'
```

### Create Evaluation Key Item
```bash
api_post "/evaluation/template/create-new-key-item" '{
  "evaluationTemplateId": "<uuid>",
  "key": "new_criteria",
  "description": "New evaluation criteria"
}'
```

## Submission Evaluation Endpoints

### Get Submission Evaluation
```bash
api_get "/evaluation/submission-evaluation/<submissionId>"
```

### Upsert Submission Evaluation
```bash
api_post "/evaluation/submission-evaluation/upsert" '{
  "submissionId": "<uuid>",
  "evaluationTemplateId": "<uuid>",
  "status": "IN_PROGRESS"
}'
```

### Upsert Evaluation Item
```bash
api_post "/evaluation/submission-evaluation-item/upsert" '{
  "submissionId": "<uuid>",
  "submissionEvaluationId": "<uuid>",
  "key": "technical_score",
  "value": "85",
  "notes": "Good technical compliance"
}'
```

### Batch Upsert Evaluation Items
```bash
api_post "/evaluation/submission-evaluation-items/batch-upsert" '{
  "submissionId": "<uuid>",
  "submissionEvaluationId": "<uuid>",
  "items": [
    {"key": "score1", "value": "90"},
    {"key": "score2", "value": "85"}
  ]
}'
```

## Compare Evaluation Endpoints

### Generate Compare Evaluation
Compare multiple submissions.

```bash
api_post "/evaluation/generate-compare-evaluation/" '{
  "packageRevisionId": "<uuid>",
  "submissionIds": ["<uuid>", "<uuid>"],
  "criteria": ["price", "technical", "delivery"]
}'
```

### Get Compare Evaluations
```bash
api_get "/evaluation/compare-evaluation/<packageRevisionId>"
```

### Delete Compare Evaluation
```bash
api_delete "/evaluation/compare-evaluation/<id>"
```

## Evaluation Status Values

| Status | Description |
|--------|-------------|
| `NOT_STARTED` | Evaluation not yet begun |
| `IN_PROGRESS` | Evaluation being processed |
| `COMPLETED` | Evaluation finalized |

## Sheet Types

| Type | Purpose |
|------|---------|
| `TECHNICAL` | Technical evaluation criteria |
| `FINANCE` | Financial evaluation |
| `PAYMENT` | Payment-related evaluation |
| `NOTE` | Additional notes |

## Workflow Example

```bash
# 1. Create evaluation template
TEMPLATE=$(api_post "/evaluation/template/upsert" '{
  "packageRevisionId": "'$PKG_REV_ID'",
  "name": "Standard Evaluation",
  "keyItems": [
    {"key": "price", "weight": 40},
    {"key": "technical", "weight": 40},
    {"key": "delivery", "weight": 20}
  ]
}')

# 2. Create submission evaluation
EVAL=$(api_post "/evaluation/submission-evaluation/upsert" '{
  "submissionId": "'$SUBMISSION_ID'",
  "evaluationTemplateId": "'$(echo $TEMPLATE | jq -r '.data.id')'"
}')

# 3. Queue AI evaluation
api_post "/agent/generate-evaluate-v2" '{
  "submissionId": "'$SUBMISSION_ID'",
  "submissionEvaluationId": "'$(echo $EVAL | jq -r '.data.id')'",
  "referenceFileIds": ["'$FILE_ID'"],
  "model": "gemini-2.5-flash"
}'

# 4. Check evaluation status
api_get "/evaluation/submission-evaluation/$SUBMISSION_ID"
```
