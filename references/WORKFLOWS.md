# Common Workflows

End-to-end workflows for common tender management tasks.

## 1. Complete Tender Setup

Set up a new tender from scratch.

```bash
#!/bin/bash
source .claude/skills/tender-api/scripts/api.sh

# Verify connection
api_whoami

# 1. Create Project
PROJECT=$(api_post "/project" '{
  "name": "Highway Construction 2025",
  "description": "National Highway Section A-B"
}')
PROJECT_ID=$(echo $PROJECT | jq -r '.data.id')
echo "Created project: $PROJECT_ID"

# 2. Create Package
PACKAGE=$(api_post "/packages" '{
  "projectId": "'$PROJECT_ID'",
  "name": "Civil Works Package"
}')
PACKAGE_ID=$(echo $PACKAGE | jq -r '.data.id')
echo "Created package: $PACKAGE_ID"

# 3. Get Package Revision
PACKAGE_DETAIL=$(api_get "/packages/$PACKAGE_ID")
REVISION_ID=$(echo $PACKAGE_DETAIL | jq -r '.data.revisions[0].id')
echo "Package revision: $REVISION_ID"

# 4. Create BOQ
BOQ=$(api_post "/boq" '{
  "packageId": "'$PACKAGE_ID'",
  "name": "Civil Works BOQ v1"
}')
BOQ_ID=$(echo $BOQ | jq -r '.data.id')
echo "Created BOQ: $BOQ_ID"

# 5. Add BOQ Items
api_post "/boq-items/batch" '{
  "boqId": "'$BOQ_ID'",
  "items": [
    {"name": "Excavation", "unit": "m3", "quantity": 10000, "unitPrice": 50000},
    {"name": "Concrete C30", "unit": "m3", "quantity": 5000, "unitPrice": 1500000},
    {"name": "Steel Rebar", "unit": "kg", "quantity": 200000, "unitPrice": 25000}
  ]
}'

# 6. Create Evaluation Template
TEMPLATE=$(api_post "/evaluation/template/upsert" '{
  "packageRevisionId": "'$REVISION_ID'",
  "name": "Standard Evaluation",
  "keyItems": [
    {"key": "price", "description": "Price competitiveness", "weight": 40},
    {"key": "technical", "description": "Technical capability", "weight": 35},
    {"key": "experience", "description": "Past experience", "weight": 15},
    {"key": "delivery", "description": "Delivery schedule", "weight": 10}
  ]
}')

echo "Tender setup complete!"
echo "Project ID: $PROJECT_ID"
echo "Package ID: $PACKAGE_ID"
echo "Revision ID: $REVISION_ID"
echo "BOQ ID: $BOQ_ID"
```

## 2. Process Contractor Submission

Handle incoming contractor bid.

```bash
#!/bin/bash
source .claude/skills/tender-api/scripts/api.sh

REVISION_ID="<package-revision-id>"
CONTRACTOR_ID="<contractor-id>"
PROPOSAL_FILE="contractor_proposal.pdf"

# 1. Upload proposal file
echo "Uploading proposal..."
FILE=$(api_upload "/files/upload" "$PROPOSAL_FILE")
FILE_ID=$(echo $FILE | jq -r '.id')

# 2. Create submission
echo "Creating submission..."
SUBMISSION=$(api_post "/submissions" '{
  "packageRevisionId": "'$REVISION_ID'",
  "contractorId": "'$CONTRACTOR_ID'",
  "name": "ABC Corp Tender Bid",
  "fileIds": ["'$FILE_ID'"],
  "notes": "Received on 2025-12-22"
}')
SUBMISSION_ID=$(echo $SUBMISSION | jq -r '.data.id')

# 3. Create evaluation record
echo "Initializing evaluation..."
EVAL=$(api_post "/evaluation/submission-evaluation/upsert" '{
  "submissionId": "'$SUBMISSION_ID'"
}')
EVAL_ID=$(echo $EVAL | jq -r '.data.id')

# 4. Queue AI evaluation
echo "Running AI evaluation..."
api_post "/agent/generate-evaluate-v2" '{
  "submissionId": "'$SUBMISSION_ID'",
  "submissionEvaluationId": "'$EVAL_ID'",
  "referenceFileIds": ["'$FILE_ID'"],
  "model": "gemini-2.5-flash",
  "keyValueEvaluationItems": [
    {"key": "price", "description": "Analyze pricing competitiveness"},
    {"key": "technical", "description": "Evaluate technical approach"},
    {"key": "experience", "description": "Assess past project experience"},
    {"key": "delivery", "description": "Review delivery timeline"}
  ]
}'

echo "Submission processed: $SUBMISSION_ID"
echo "Evaluation ID: $EVAL_ID"
echo "Check status: api_get evaluation/submission-evaluation/$SUBMISSION_ID"
```

## 3. Compare Submissions

Compare multiple contractor bids.

```bash
#!/bin/bash
source .claude/skills/tender-api/scripts/api.sh

REVISION_ID="<package-revision-id>"

# 1. Get all submissions
SUBMISSIONS=$(api_get "/submissions?packageRevisionId=$REVISION_ID")
SUBMISSION_IDS=$(echo $SUBMISSIONS | jq -r '[.data[].id]')

echo "Found $(echo $SUBMISSIONS | jq '.data | length') submissions"

# 2. Compare submissions
echo "Comparing submissions..."
COMPARISON=$(api_post "/submissions/compare-submissions" '{
  "packageRevisionId": "'$REVISION_ID'",
  "submissionIds": '$SUBMISSION_IDS'
}')

# 3. Display summary
echo "Comparison Summary:"
echo $COMPARISON | jq '.totals'

# 4. Generate compare evaluation
echo "Generating comparison evaluation..."
api_post "/evaluation/generate-compare-evaluation/" '{
  "packageRevisionId": "'$REVISION_ID'",
  "submissionIds": '$SUBMISSION_IDS'
}'

# 5. Get comparison results
echo "Comparison evaluations:"
api_get "/evaluation/compare-evaluation/$REVISION_ID"
```

## 4. Price Intelligence Query

Query historical pricing data.

```bash
#!/bin/bash
source .claude/skills/tender-api/scripts/api.sh

# 1. Check available data sources
echo "Available price data sources:"
api_get "/price-history/sources?take=10" | jq '.data[] | {id, fileName, sourceType}'

# 2. Query for specific material
echo "Querying cement prices..."
QUERY_RESULT=$(api_post "/price-history/query" '{
  "query": "What are the current cement prices in the market? Compare prices from different suppliers.",
  "model": "gemini-2.5-flash"
}')

echo "Answer:"
echo $QUERY_RESULT | jq -r '.answer'

echo "Sources:"
echo $QUERY_RESULT | jq '.citations[] | {fileName, snippet}'

# 3. View query history
echo "Recent queries:"
api_get "/price-history/query-history" | jq '.[0:5] | .[] | {query, createdAt}'
```

## 5. Generate Decision Document

Create sign-off document for tender award.

```bash
#!/bin/bash
source .claude/skills/tender-api/scripts/api.sh

SUBMISSION_ID="<winning-submission-id>"

# 1. Verify evaluation is complete
EVAL_STATUS=$(api_get "/evaluation/submission-evaluation/$SUBMISSION_ID")
STATUS=$(echo $EVAL_STATUS | jq -r '.status')

if [ "$STATUS" != "COMPLETED" ]; then
  echo "Evaluation not complete. Current status: $STATUS"
  exit 1
fi

# 2. Generate sign-off document
echo "Generating decision document..."
DOC_DATA=$(api_post "/agent/sign-off-document-composition/$SUBMISSION_ID")

# 3. Display document structure
echo "Document structure:"
echo $DOC_DATA | jq 'keys'

echo "Service Description:"
echo $DOC_DATA | jq -r '.serviceDescription'

echo "Conclusion:"
echo $DOC_DATA | jq -r '.conclusion'

# Save for frontend DOCX generation
echo $DOC_DATA > sign_off_document_data.json
echo "Document data saved to sign_off_document_data.json"
```

## 6. Bulk File Upload

Upload multiple price documents.

```bash
#!/bin/bash
source .claude/skills/tender-api/scripts/api.sh

FOLDER="./price_documents"

# Upload all PDFs in folder
for file in "$FOLDER"/*.pdf; do
  if [ -f "$file" ]; then
    filename=$(basename "$file")
    echo "Uploading: $filename"

    api_upload "/price-history/upload" "$file" \
      "productCategory=construction&keywords=price,quotation"

    echo "Uploaded: $filename"
  fi
done

echo "All files uploaded. Checking processing status..."
sleep 5

# Check processing status
api_get "/price-history/sources?take=20" | jq '.data[] | {fileName, processingStatus}'
```

## 7. Daily Status Report

Generate daily tender status report.

```bash
#!/bin/bash
source .claude/skills/tender-api/scripts/api.sh

echo "=== Daily Tender Status Report ==="
echo "Date: $(date)"
echo ""

# 1. Active Projects
echo "--- Active Projects ---"
api_get "/project" | jq '.data[] | {name, id}'

# 2. Pending Evaluations
echo ""
echo "--- Pending Evaluations ---"
# Get all packages and check submissions
PACKAGES=$(api_get "/packages")
for pkg_id in $(echo $PACKAGES | jq -r '.data[].id'); do
  PKG_DETAIL=$(api_get "/packages/$pkg_id")
  REV_ID=$(echo $PKG_DETAIL | jq -r '.data.revisions[0].id')

  SUBS=$(api_get "/submissions?packageRevisionId=$REV_ID")
  PENDING=$(echo $SUBS | jq '[.data[] | select(.evaluationStatus != "COMPLETED")] | length')

  if [ "$PENDING" -gt 0 ]; then
    echo "Package: $(echo $PKG_DETAIL | jq -r '.data.name') - $PENDING pending"
  fi
done

# 3. Recent Activity
echo ""
echo "--- Recent Activity (Last 24h) ---"
api_get "/activity-log?take=10" | jq '.data[] | {eventType, createdAt}'

echo ""
echo "=== End of Report ==="
```

## Environment Variables

Set these for all workflows:

```bash
export TENDER_CLI_TOKEN="tnd_your_token_here"
export TENDER_API_URL="https://api.tender-app.com"  # Optional, has default
```

## Error Handling

```bash
# Check API response status
response=$(api_get "/project/$PROJECT_ID")
if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
  echo "Error: $(echo $response | jq -r '.message')"
  exit 1
fi

# Verify required IDs
if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" == "null" ]; then
  echo "Error: Project ID is required"
  exit 1
fi
```
