# Document Comparison API Reference

Compare Excel files and analyze differences.

## Excel Diff API

### Compare Two Excel Files (V3)
Advanced comparison using LCS + pair scoring algorithm.

```bash
api_post "excel-diff/v3/compare" '{
  "fileData1": "<base64-encoded-xlsx>",
  "fileData2": "<base64-encoded-xlsx>"
}'
```

**Response:**
```json
{
  "sheets": [
    {
      "name": "Sheet1",
      "changes": [
        {
          "type": "MODIFIED",
          "row": 5,
          "column": "B",
          "oldValue": "100",
          "newValue": "150",
          "cellAddress": "B5"
        },
        {
          "type": "ADDED",
          "row": 10,
          "data": ["Item X", "200", "kg"]
        },
        {
          "type": "DELETED",
          "row": 8,
          "data": ["Old Item", "50", "pcs"]
        }
      ],
      "summary": {
        "added": 2,
        "deleted": 1,
        "modified": 5,
        "unchanged": 42
      }
    }
  ],
  "overallSummary": {
    "totalSheets": 3,
    "sheetsWithChanges": 1,
    "totalChanges": 8
  }
}
```

## Change Types

| Type | Description |
|------|-------------|
| `ADDED` | New row in file 2 |
| `DELETED` | Row removed (in file 1 only) |
| `MODIFIED` | Cell value changed |
| `UNCHANGED` | No changes |

## Using with Files

### Compare Uploaded Files

```bash
# 1. Read files as base64
FILE1_B64=$(base64 -i file1.xlsx)
FILE2_B64=$(base64 -i file2.xlsx)

# 2. Compare
api_post "excel-diff/v3/compare" '{
  "fileData1": "'$FILE1_B64'",
  "fileData2": "'$FILE2_B64'"
}'
```

### Compare BOQ Submissions

```bash
# 1. Get submission files
SUBMISSION1=$(api_get "submissions/$SUB1_ID")
SUBMISSION2=$(api_get "submissions/$SUB2_ID")

# 2. Download file data
FILE1_DATA=$(api_get "files/$(echo $SUBMISSION1 | jq -r '.data.fileIds[0]')/download" | base64)
FILE2_DATA=$(api_get "files/$(echo $SUBMISSION2 | jq -r '.data.fileIds[0]')/download" | base64)

# 3. Compare
api_post "excel-diff/v3/compare" '{
  "fileData1": "'$FILE1_DATA'",
  "fileData2": "'$FILE2_DATA'"
}'
```

## Algorithm Features

The V3 comparison algorithm provides:

1. **LCS Alignment**: Longest Common Subsequence for row matching
2. **Similarity Scoring**: Handles reordered or modified content
3. **Multi-sheet Support**: Compares all sheets in workbook
4. **Cell-level Diff**: Precise identification of changed cells

## Use Cases

### 1. BOQ Version Comparison
Compare different versions of Bill of Quantities.

```bash
# Get two BOQ revisions
BOQ_V1=$(api_get "boq/id/$BOQ_ID")
BOQ_V2=$(api_get "boq/id/$BOQ_ID_V2")

# Export to Excel and compare
# (Frontend handles Excel export)
```

### 2. Submission vs Reference
Compare contractor submission against reference BOQ.

```bash
# Get reference BOQ file
REFERENCE_FILE=$(api_get "files/$REF_FILE_ID/download" | base64)

# Get submission file
SUBMISSION_FILE=$(api_get "files/$SUB_FILE_ID/download" | base64)

# Compare
DIFF=$(api_post "excel-diff/v3/compare" '{
  "fileData1": "'$REFERENCE_FILE'",
  "fileData2": "'$SUBMISSION_FILE'"
}')

# Analyze differences
echo $DIFF | jq '.sheets[].summary'
```

### 3. Price Comparison
Compare pricing between submissions.

```bash
# Compare two contractor submissions
api_post "excel-diff/v3/compare" '{
  "fileData1": "'$CONTRACTOR1_FILE'",
  "fileData2": "'$CONTRACTOR2_FILE'"
}'
```

## Response Structure

```typescript
interface CompareFilesV2Response {
  sheets: SheetChanges[];
  overallSummary: OverallSummary;
}

interface SheetChanges {
  name: string;
  changes: ChangeItem[];
  summary: SheetSummary;
}

interface ChangeItem {
  type: 'ADDED' | 'DELETED' | 'MODIFIED' | 'UNCHANGED';
  row: number;
  column?: string;
  cellAddress?: string;
  oldValue?: string;
  newValue?: string;
  data?: string[];
}

interface SheetSummary {
  added: number;
  deleted: number;
  modified: number;
  unchanged: number;
}

interface OverallSummary {
  totalSheets: number;
  sheetsWithChanges: number;
  totalChanges: number;
}
```

## Integration with Agent

Use document comparison results with AI evaluation.

```bash
# 1. Compare files
DIFF=$(api_post "excel-diff/v3/compare" '{
  "fileData1": "'$REF_FILE'",
  "fileData2": "'$SUB_FILE'"
}')

# 2. Summarize issues with AI
api_post "agent/summarize-issue" '{
  "boqId": "'$BOQ_ID'",
  "submissionId": "'$SUBMISSION_ID'",
  "issueData": '$(echo $DIFF | jq -c '.')'
}'
```
