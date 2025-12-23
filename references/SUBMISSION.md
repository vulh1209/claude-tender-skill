# Submission API Reference

Manage tender submissions from contractors.

## Submissions

### List Submissions
Get all submissions for a package revision.

```bash
api_get "/submissions?packageRevisionId=<uuid>"
api_get "/submissions?packageRevisionId=<uuid>&skip=0&take=20"
```

### Get Submission
```bash
api_get "/submissions/<id>"
```

### Create Submission
```bash
api_post "/submissions" '{
  "packageRevisionId": "<uuid>",
  "contractorId": "<uuid>",
  "name": "ABC Corp Bid",
  "fileIds": ["<uuid>", "<uuid>"],
  "notes": "Initial submission"
}'
```

### Update Submission
```bash
api_put "/submissions/<id>" '{
  "name": "ABC Corp Bid - Revised",
  "fileIds": ["<uuid>", "<uuid>", "<uuid>"],
  "notes": "Updated with price revision"
}'
```

### Delete Submission
```bash
api_delete "/submissions/<id>"
```

### Get Perfect Ideal Submission
Get the reference/ideal submission for comparison.

> **⚠️ Important:** "PERFECT IDEAL" is a **system-generated virtual contractor**, NOT a real contractor. It represents the ideal/baseline submission created automatically by the system based on the original BOQ (Bill of Quantities) from the package. This serves as a reference point for comparing actual contractor submissions against the expected/ideal values.

```bash
api_get "/submissions/perfect-ideal/<packageRevisionId>"
```

### Generate System Name
```bash
api_get "/submissions/system-name/<packageRevisionId>?prefix=SUB"
```

## Compare Submissions

### Compare Multiple Submissions
```bash
api_post "/submissions/compare-submissions" '{
  "packageRevisionId": "<uuid>",
  "submissionIds": ["<uuid>", "<uuid>", "<uuid>"]
}'
```

**Response:**
```json
{
  "comparisons": [
    {
      "itemName": "Concrete Grade 30",
      "unit": "m3",
      "perfectIdeal": 500,
      "submissions": {
        "<submission1-id>": {"quantity": 500, "unitPrice": 1500000},
        "<submission2-id>": {"quantity": 520, "unitPrice": 1450000}
      }
    }
  ],
  "totals": {
    "<submission1-id>": 750000000,
    "<submission2-id>": 754000000
  }
}
```

> **Note:** The `perfectIdeal` field in the response represents values from the **system-generated PERFECT IDEAL submission** (see above), which serves as the baseline/reference. It is NOT a real contractor submission but rather the ideal values from the original BOQ for comparison purposes.

### Get Package Value
Get aggregated values for package.

```bash
api_get "/submissions/package-value/<packageRevisionId>"
```

## Submission Evaluation

See [EVALUATION.md](./EVALUATION.md) for detailed evaluation endpoints.

### Quick Reference

```bash
# Get evaluation for submission
api_get "/evaluation/submission-evaluation/<submissionId>"

# Create/update evaluation
api_post "/evaluation/submission-evaluation/upsert" '{
  "submissionId": "<uuid>",
  "evaluationTemplateId": "<uuid>"
}'

# Update evaluation items
api_post "/evaluation/submission-evaluation-items/batch-upsert" '{
  "submissionId": "<uuid>",
  "submissionEvaluationId": "<uuid>",
  "items": [
    {"key": "price_score", "value": "85"},
    {"key": "technical_score", "value": "90"}
  ]
}'
```

## Evaluation Status

| Status | Description |
|--------|-------------|
| `NOT_STARTED` | No evaluation begun |
| `IN_PROGRESS` | Evaluation in progress |
| `COMPLETED` | Evaluation finalized |

## File Attachments

Submissions can include file attachments. Use the File API to upload files first, then include `fileIds` in submission.

```bash
# 1. Upload file
FILE=$(api_upload "/files/upload" "/path/to/proposal.pdf")
FILE_ID=$(echo $FILE | jq -r '.id')

# 2. Create submission with file
api_post "/submissions" '{
  "packageRevisionId": "'$PKG_REV_ID'",
  "contractorId": "'$CONTRACTOR_ID'",
  "name": "Contractor Proposal",
  "fileIds": ["'$FILE_ID'"]
}'
```

## Workflow Example

```bash
# 1. Get package revision
PACKAGE=$(api_get "/packages/$PACKAGE_ID")
REVISION_ID=$(echo $PACKAGE | jq -r '.data.revisions[0].id')

# 2. Get contractor
CONTRACTORS=$(api_get "/contractors")
CONTRACTOR_ID=$(echo $CONTRACTORS | jq -r '.data[0].id')

# 3. Upload proposal file
FILE=$(api_upload "/files/upload" "proposal.pdf")
FILE_ID=$(echo $FILE | jq -r '.id')

# 4. Create submission
SUBMISSION=$(api_post "/submissions" '{
  "packageRevisionId": "'$REVISION_ID'",
  "contractorId": "'$CONTRACTOR_ID'",
  "name": "ABC Corp Tender Submission",
  "fileIds": ["'$FILE_ID'"]
}')
SUBMISSION_ID=$(echo $SUBMISSION | jq -r '.data.id')

# 5. Create evaluation
EVAL=$(api_post "/evaluation/submission-evaluation/upsert" '{
  "submissionId": "'$SUBMISSION_ID'"
}')

# 6. Run AI evaluation
api_post "/agent/generate-evaluate-v2" '{
  "submissionId": "'$SUBMISSION_ID'",
  "submissionEvaluationId": "'$(echo $EVAL | jq -r '.data.id')'",
  "referenceFileIds": ["'$FILE_ID'"],
  "model": "gemini-2.5-flash"
}'

# 7. Check evaluation status
api_get "/evaluation/submission-evaluation/$SUBMISSION_ID"

# 8. Compare with other submissions
OTHER_SUBMISSIONS=$(api_get "/submissions?packageRevisionId=$REVISION_ID")
api_post "/submissions/compare-submissions" '{
  "packageRevisionId": "'$REVISION_ID'",
  "submissionIds": '$(echo $OTHER_SUBMISSIONS | jq '[.data[].id]')'
}'
```

## Best Practices

1. **Include all relevant files**: Attach all proposal documents to submission
2. **Use evaluation templates**: Create consistent evaluation criteria
3. **Compare submissions**: Use compare endpoint for side-by-side analysis
4. **Track evaluation status**: Monitor progress through status field
5. **Generate sign-off documents**: Use agent API for decision papers
