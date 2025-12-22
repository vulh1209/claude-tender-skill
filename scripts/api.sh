#!/bin/bash
# Tender App API Helper Script
# Usage: source .claude/skills/tender-api/scripts/api.sh

# Configuration
TENDER_API_URL="${TENDER_API_URL:-http://localhost:3000/api}"
TENDER_CLI_TOKEN="${TENDER_CLI_TOKEN}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if token is set
check_auth() {
  if [ -z "$TENDER_CLI_TOKEN" ]; then
    echo -e "${RED}Error: TENDER_CLI_TOKEN not set${NC}"
    echo ""
    echo "To set up authentication:"
    echo "1. Login to Tender App UI"
    echo "2. Go to Settings > CLI Tokens"
    echo "3. Generate a new token"
    echo "4. Run: export TENDER_CLI_TOKEN=\"tnd_your_token_here\""
    return 1
  fi
  return 0
}

# GET request
# Usage: api_get "/endpoint" [extra_curl_args...]
api_get() {
  check_auth || return 1
  local endpoint="$1"
  shift
  curl -s -X GET "${TENDER_API_URL}${endpoint}" \
    -H "Authorization: Bearer ${TENDER_CLI_TOKEN}" \
    -H "Content-Type: application/json" \
    "$@"
}

# POST request
# Usage: api_post "/endpoint" '{"json": "body"}' [extra_curl_args...]
api_post() {
  check_auth || return 1
  local endpoint="$1"
  local body="$2"
  shift 2
  curl -s -X POST "${TENDER_API_URL}${endpoint}" \
    -H "Authorization: Bearer ${TENDER_CLI_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$body" \
    "$@"
}

# PUT request
# Usage: api_put "/endpoint" '{"json": "body"}' [extra_curl_args...]
api_put() {
  check_auth || return 1
  local endpoint="$1"
  local body="$2"
  shift 2
  curl -s -X PUT "${TENDER_API_URL}${endpoint}" \
    -H "Authorization: Bearer ${TENDER_CLI_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$body" \
    "$@"
}

# PATCH request
# Usage: api_patch "/endpoint" '{"json": "body"}' [extra_curl_args...]
api_patch() {
  check_auth || return 1
  local endpoint="$1"
  local body="$2"
  shift 2
  curl -s -X PATCH "${TENDER_API_URL}${endpoint}" \
    -H "Authorization: Bearer ${TENDER_CLI_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$body" \
    "$@"
}

# DELETE request
# Usage: api_delete "/endpoint" [extra_curl_args...]
api_delete() {
  check_auth || return 1
  local endpoint="$1"
  shift
  curl -s -X DELETE "${TENDER_API_URL}${endpoint}" \
    -H "Authorization: Bearer ${TENDER_CLI_TOKEN}" \
    -H "Content-Type: application/json" \
    "$@"
}

# Upload file with multipart/form-data
# Usage: api_upload "/endpoint" "fieldname" "/path/to/file" [extra_curl_args...]
api_upload() {
  check_auth || return 1
  local endpoint="$1"
  local fieldname="$2"
  local filepath="$3"
  shift 3
  curl -s -X POST "${TENDER_API_URL}${endpoint}" \
    -H "Authorization: Bearer ${TENDER_CLI_TOKEN}" \
    -F "${fieldname}=@${filepath}" \
    "$@"
}

# Download file
# Usage: api_download "/endpoint" "/path/to/save" [extra_curl_args...]
api_download() {
  check_auth || return 1
  local endpoint="$1"
  local output="$2"
  shift 2
  curl -s -X GET "${TENDER_API_URL}${endpoint}" \
    -H "Authorization: Bearer ${TENDER_CLI_TOKEN}" \
    -o "$output" \
    "$@"
}

# Check API health
# Usage: api_health
api_health() {
  local response
  response=$(curl -s -X GET "${TENDER_API_URL}/health" 2>/dev/null)
  if [ $? -eq 0 ] && echo "$response" | grep -q "ok\|healthy"; then
    echo -e "${GREEN}API is healthy${NC}"
    echo "$response" | jq . 2>/dev/null || echo "$response"
    return 0
  else
    echo -e "${RED}API is not responding${NC}"
    echo "URL: ${TENDER_API_URL}"
    return 1
  fi
}

# Check authentication status
# Usage: api_whoami
api_whoami() {
  check_auth || return 1
  local response
  response=$(api_get "/auth/profile")
  if echo "$response" | grep -q "email"; then
    echo -e "${GREEN}Authenticated as:${NC}"
    echo "$response" | jq '.user' 2>/dev/null || echo "$response"
    return 0
  else
    echo -e "${RED}Authentication failed${NC}"
    echo "$response" | jq . 2>/dev/null || echo "$response"
    return 1
  fi
}

# Print help
api_help() {
  echo "Tender App API Helper Functions"
  echo "================================"
  echo ""
  echo "Setup:"
  echo "  export TENDER_CLI_TOKEN=\"tnd_your_token\""
  echo "  export TENDER_API_URL=\"http://localhost:3000/api\"  # optional"
  echo ""
  echo "Functions:"
  echo "  api_get \"/endpoint\"                    - GET request"
  echo "  api_post \"/endpoint\" '{\"json\":\"body\"}'  - POST request"
  echo "  api_put \"/endpoint\" '{\"json\":\"body\"}'   - PUT request"
  echo "  api_patch \"/endpoint\" '{\"json\":\"body\"}' - PATCH request"
  echo "  api_delete \"/endpoint\"                 - DELETE request"
  echo "  api_upload \"/endpoint\" \"field\" \"/file\" - Upload file"
  echo "  api_download \"/endpoint\" \"/output\"     - Download file"
  echo "  api_health                             - Check API health"
  echo "  api_whoami                             - Check authentication"
  echo "  api_help                               - Show this help"
  echo ""
  echo "Examples:"
  echo "  api_get \"/project?skip=0&take=10\" | jq '.data'"
  echo "  api_post \"/price-history/query\" '{\"query\": \"cement price\"}'"
  echo "  api_upload \"/price-history/upload\" \"file\" \"./prices.xlsx\""
}

# Print status on source
if [ -n "$TENDER_CLI_TOKEN" ]; then
  echo -e "${GREEN}Tender API helper loaded${NC}"
  echo "Token: ${TENDER_CLI_TOKEN:0:12}..."
  echo "URL: ${TENDER_API_URL}"
  echo "Run 'api_help' for available commands"
else
  echo -e "${YELLOW}Tender API helper loaded (no token set)${NC}"
  echo "Run 'api_help' for setup instructions"
fi
