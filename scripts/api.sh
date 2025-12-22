#!/bin/bash
# Tender App API Helper Script
# Usage: source .claude/skills/tender-api/scripts/api.sh

# Configuration
TENDER_API_URL="${TENDER_API_URL:-https://tender-api.sipher.gg/api}"
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
    echo "1. Go to https://tender.sipher.gg/cli-tokens"
    echo "2. Login with Microsoft if prompted"
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

# =============================================================================
# GLOBAL SEARCH FUNCTIONS
# Quick lookup for projects, packages, submissions, contractors
# =============================================================================

# Search projects by name
# Usage: search_projects "keyword"
search_projects() {
  check_auth || return 1
  local keyword="$1"
  local take="${2:-50}"
  echo -e "${YELLOW}Searching projects: ${keyword}${NC}"
  api_get "/project?skip=0&take=${take}" | jq --arg q "$keyword" '.data | map(select(.name | test($q; "i"))) | .[] | {id, name, description, status, createdAt}'
}

# Search packages by name (across all projects or specific project)
# Usage: search_packages "keyword" [projectId]
search_packages() {
  check_auth || return 1
  local keyword="$1"
  local projectId="$2"
  echo -e "${YELLOW}Searching packages: ${keyword}${NC}"

  if [ -n "$projectId" ]; then
    api_get "/project/${projectId}" | jq --arg q "$keyword" '.packages | map(select(.name | test($q; "i"))) | .[] | {id, name, description, projectId}'
  else
    # Search across all projects
    api_get "/project?skip=0&take=100" | jq --arg q "$keyword" '.data[].packages | .[]? | select(.name | test($q; "i")) | {id, name, description, projectId}'
  fi
}

# Search submissions by contractor name or package
# Usage: search_submissions "keyword" [packageId]
search_submissions() {
  check_auth || return 1
  local keyword="$1"
  local packageId="$2"
  echo -e "${YELLOW}Searching submissions: ${keyword}${NC}"

  if [ -n "$packageId" ]; then
    api_get "/submission?packageId=${packageId}&skip=0&take=100" | jq --arg q "$keyword" '.data | map(select(.contractor.name | test($q; "i") // .packageVersion.name | test($q; "i"))) | .[] | {id, contractorName: .contractor.name, packageName: .packageVersion.name, status: .evaluationStatus, createdAt}'
  else
    # Need to iterate through packages
    echo "Tip: Provide packageId for faster search"
    api_get "/project?skip=0&take=50" | jq -r '.data[].packages[]?.id' | while read pkgId; do
      api_get "/submission?packageId=${pkgId}&skip=0&take=50" 2>/dev/null | jq --arg q "$keyword" '.data[]? | select(.contractor.name | test($q; "i") // false) | {id, contractorName: .contractor.name, packageId}'
    done
  fi
}

# Search contractors by name
# Usage: search_contractors "keyword"
search_contractors() {
  check_auth || return 1
  local keyword="$1"
  echo -e "${YELLOW}Searching contractors: ${keyword}${NC}"
  api_get "/contractor?skip=0&take=100" | jq --arg q "$keyword" '.data | map(select(.name | test($q; "i"))) | .[] | {id, name, email, phone, address}'
}

# Get project details with all packages
# Usage: get_project_details <projectId>
get_project_details() {
  check_auth || return 1
  local projectId="$1"
  if [ -z "$projectId" ]; then
    echo -e "${RED}Usage: get_project_details <projectId>${NC}"
    return 1
  fi
  echo -e "${YELLOW}Project Details: ${projectId}${NC}"
  api_get "/project/${projectId}" | jq '{id, name, description, status, createdAt, packages: [.packages[]? | {id, name, description}]}'
}

# Get package details with submissions summary
# Usage: get_package_details <packageId>
get_package_details() {
  check_auth || return 1
  local packageId="$1"
  if [ -z "$packageId" ]; then
    echo -e "${RED}Usage: get_package_details <packageId>${NC}"
    return 1
  fi
  echo -e "${YELLOW}Package Details: ${packageId}${NC}"

  # Get package info
  local package_info=$(api_get "/package/${packageId}")

  # Get submissions for this package
  local submissions=$(api_get "/submission?packageId=${packageId}&skip=0&take=100")

  echo "$package_info" | jq '.'
  echo ""
  echo -e "${YELLOW}Submissions:${NC}"
  echo "$submissions" | jq '.data | .[] | {id, contractor: .contractor.name, status: .evaluationStatus, createdAt}'
}

# Get submission details with evaluation
# Usage: get_submission_details <submissionId>
get_submission_details() {
  check_auth || return 1
  local submissionId="$1"
  if [ -z "$submissionId" ]; then
    echo -e "${RED}Usage: get_submission_details <submissionId>${NC}"
    return 1
  fi
  echo -e "${YELLOW}Submission Details: ${submissionId}${NC}"
  api_get "/submission/${submissionId}" | jq '{id, contractor: .contractor, packageVersion: .packageVersion.name, evaluationStatus, createdAt, files: [.files[]? | {id, name, type}]}'
}

# Get contractor details
# Usage: get_contractor_details <contractorId>
get_contractor_details() {
  check_auth || return 1
  local contractorId="$1"
  if [ -z "$contractorId" ]; then
    echo -e "${RED}Usage: get_contractor_details <contractorId>${NC}"
    return 1
  fi
  echo -e "${YELLOW}Contractor Details: ${contractorId}${NC}"
  api_get "/contractor/${contractorId}" | jq '.'
}

# List all projects (quick overview)
# Usage: list_projects [take]
list_projects() {
  check_auth || return 1
  local take="${1:-25}"
  echo -e "${YELLOW}Projects (top ${take}):${NC}"
  api_get "/project?skip=0&take=${take}" | jq '.data | .[] | {id, name, status, packagesCount: (.packages | length)}'
}

# List all contractors
# Usage: list_contractors [take]
list_contractors() {
  check_auth || return 1
  local take="${1:-50}"
  echo -e "${YELLOW}Contractors (top ${take}):${NC}"
  api_get "/contractor?skip=0&take=${take}" | jq '.data | .[] | {id, name, email}'
}

# Global search across all entities
# Usage: global_search "keyword"
global_search() {
  check_auth || return 1
  local keyword="$1"
  if [ -z "$keyword" ]; then
    echo -e "${RED}Usage: global_search \"keyword\"${NC}"
    return 1
  fi

  echo -e "${GREEN}=== Global Search: ${keyword} ===${NC}"
  echo ""

  echo -e "${YELLOW}📁 Projects:${NC}"
  search_projects "$keyword" 2>/dev/null | head -20
  echo ""

  echo -e "${YELLOW}📦 Packages:${NC}"
  search_packages "$keyword" 2>/dev/null | head -20
  echo ""

  echo -e "${YELLOW}🏢 Contractors:${NC}"
  search_contractors "$keyword" 2>/dev/null | head -20
  echo ""

  echo -e "${GREEN}=== End Search ===${NC}"
}

# =============================================================================
# HELP
# =============================================================================

# Print help
api_help() {
  echo "Tender App API Helper Functions"
  echo "================================"
  echo ""
  echo "Setup:"
  echo "  export TENDER_CLI_TOKEN=\"tnd_your_token\""
  echo "  export TENDER_API_URL=\"https://tender-api.sipher.gg/api\"  # optional"
  echo ""
  echo "Basic Functions:"
  echo "  api_get \"/endpoint\"                    - GET request"
  echo "  api_post \"/endpoint\" '{\"json\":\"body\"}'  - POST request"
  echo "  api_put \"/endpoint\" '{\"json\":\"body\"}'   - PUT request"
  echo "  api_patch \"/endpoint\" '{\"json\":\"body\"}' - PATCH request"
  echo "  api_delete \"/endpoint\"                 - DELETE request"
  echo "  api_upload \"/endpoint\" \"field\" \"/file\" - Upload file"
  echo "  api_download \"/endpoint\" \"/output\"     - Download file"
  echo "  api_health                             - Check API health"
  echo "  api_whoami                             - Check authentication"
  echo ""
  echo "Global Search Functions:"
  echo "  global_search \"keyword\"                - Search across all entities"
  echo "  search_projects \"keyword\"              - Search projects by name"
  echo "  search_packages \"keyword\" [projectId]  - Search packages"
  echo "  search_submissions \"keyword\" [pkgId]   - Search submissions"
  echo "  search_contractors \"keyword\"           - Search contractors"
  echo ""
  echo "Quick Lookup Functions:"
  echo "  list_projects [take]                   - List all projects"
  echo "  list_contractors [take]                - List all contractors"
  echo "  get_project_details <id>               - Get project with packages"
  echo "  get_package_details <id>               - Get package with submissions"
  echo "  get_submission_details <id>            - Get submission details"
  echo "  get_contractor_details <id>            - Get contractor details"
  echo ""
  echo "Examples:"
  echo "  global_search \"highway\"                 - Find anything with 'highway'"
  echo "  search_projects \"construction\"          - Find construction projects"
  echo "  get_project_details \"abc-123\"           - Get project details"
  echo "  api_get \"/project?skip=0&take=10\" | jq '.data'"
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
