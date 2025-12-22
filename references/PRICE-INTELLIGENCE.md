# Price Intelligence API Reference

RAG-based price data querying and historical price management.

> **Note:** All endpoints require Admin role.

## Query Price Data

### RAG Query
Query price data using natural language.

```bash
api_post "/price-history/query" '{
  "query": "What is the current price of cement in Hanoi?",
  "model": "gemini-2.5-flash",
  "filters": {
    "sourceType": "manual",
    "keywords": ["cement", "construction"]
  }
}'
```

**Response:**
```json
{
  "answer": "Based on the latest data from December 2025...",
  "citations": [
    {
      "sourceId": "uuid",
      "fileName": "cement-prices-dec-2025.pdf",
      "snippet": "Cement price: 85,000 VND/bag",
      "pageNumber": 2
    }
  ],
  "confidence": 0.92
}
```

### Get Query History
```bash
api_get "/price-history/query-history"
api_get "/price-history/query-history/<id>"
```

## Data Sources Management

### Upload Manual File
Upload price document for RAG indexing.

```bash
api_upload "/price-history/upload" \
  "/path/to/price-list.pdf" \
  "productCategory=construction&keywords=cement,steel"
```

**Supported formats:** PDF, DOCX, XLSX, TXT, PNG, JPG, WEBP (OCR)

**Max file size:** 5MB

### List Data Sources
```bash
api_get "/price-history/sources?skip=0&take=20"
api_get "/price-history/sources?sourceType=manual"
api_get "/price-history/sources?keyword=cement"
```

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `skip` | number | Pagination offset |
| `take` | number | Page size |
| `sourceType` | string | `manual`, `email`, `web_scrape` |
| `keyword` | string | Filter by keyword |

### Get/Delete Data Source
```bash
api_get "/price-history/sources/<id>"
api_delete "/price-history/sources/<id>"
```

### Download Source File
```bash
curl -OJ "$API_URL/price-history/sources/<id>/download" \
  -H "Authorization: Bearer $TENDER_CLI_TOKEN"
```

### Download OCR Text
```bash
curl -OJ "$API_URL/price-history/sources/<id>/download-ocr" \
  -H "Authorization: Bearer $TENDER_CLI_TOKEN"
```

### Retry Failed Embedding
```bash
api_post "/price-history/sources/<id>/retry-embed"
```

## Email Crawl Configuration

### Create Email Config
Set up automatic email crawling for price updates.

```bash
api_post "/price-history/email-config" '{
  "email": "procurement@company.com",
  "password": "app-password",
  "keywords": ["price list", "quotation"],
  "senderFilters": ["@supplier.com"]
}'
```

### List/Delete Email Configs
```bash
api_get "/price-history/email-configs"
api_delete "/price-history/email-config/<id>"
```

### Trigger Email Crawl
```bash
api_post "/price-history/email-config/<id>/crawl"
api_post "/price-history/email-crawl-all"
```

## Web Crawl Configuration

### Create Web Crawl Config
Set up scheduled web scraping.

```bash
api_post "/price-history/web-crawl-configs" '{
  "name": "Steel Prices Monitor",
  "url": "https://example.com/steel-prices",
  "schedule": "0 8 * * *",
  "selectors": {
    "price": ".price-value",
    "product": ".product-name"
  }
}'
```

### Manage Web Crawl Configs
```bash
api_get "/price-history/web-crawl-configs?skip=0&take=20"
api_get "/price-history/web-crawl-configs/<id>"
api_patch "/price-history/web-crawl-configs/<id>" '{"schedule": "0 9 * * *"}'
api_delete "/price-history/web-crawl-configs/<id>"
```

### Trigger Web Crawl
```bash
api_post "/price-history/web-crawl-configs/<id>/trigger"
```

## Price Items

### Get All Price Items
```bash
api_get "/price-history/price-items/all?skip=0&take=50"
```

### Get Price Items for Config
```bash
api_get "/price-history/price-items?configId=<uuid>&skip=0&take=50"
```

### Get Price History for Item
```bash
api_get "/price-history/price-items/<id>/history"
```

## Processing Status

| Status | Description |
|--------|-------------|
| `pending` | Queued for processing |
| `processing` | Currently being indexed |
| `completed` | Successfully indexed |
| `failed` | Processing failed |

## Source Types

| Type | Description |
|------|-------------|
| `manual` | Manually uploaded files |
| `email` | Crawled from email |
| `web_scrape` | Scraped from web |

## Workflow Example

```bash
# 1. Upload price document
SOURCE=$(api_upload "/price-history/upload" \
  "cement-prices.pdf" \
  "productCategory=construction&keywords=cement,building")

# 2. Wait for processing (check status)
api_get "/price-history/sources/$(echo $SOURCE | jq -r '.id')"

# 3. Query prices
api_post "/price-history/query" '{
  "query": "What is the cheapest cement option available?",
  "model": "gemini-2.5-flash"
}'

# 4. View query history
api_get "/price-history/query-history"
```
