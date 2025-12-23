# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-22

### Added
- Initial release of Tender API Plugin for Claude Code
- **Skills**
  - `tender-api`: Core skill for interacting with Tender App APIs
- **Commands**
  - `/tender-search`: Quick search across all entities (projects, packages, submissions, contractors)
  - `/tender-setup`: Set up Tender API authentication
- **API Helpers** (`scripts/api.sh`)
  - HTTP methods: `api_get`, `api_post`, `api_put`, `api_patch`, `api_delete`
  - File operations: `api_upload`, `api_download`
  - Search functions: `global_search`, `search_projects`, `search_packages`, `search_submissions`, `search_contractors`
  - Lookup functions: `get_project_details`, `get_package_details`, `get_submission_details`, `get_contractor_details`
  - Utility functions: `api_health`, `api_whoami`
- **Reference Documentation**
  - Authentication guide (`AUTH.md`)
  - CLI Token management (`CLI-TOKEN.md`)
  - AI Evaluation endpoints (`EVALUATION.md`)
  - Price Intelligence with RAG (`PRICE-INTELLIGENCE.md`)
  - Document Comparison (`DOCUMENT-COMPARISON.md`)
  - Project Management (`PROJECT.md`)
  - Submission handling (`SUBMISSION.md`)
  - End-to-end workflows (`WORKFLOWS.md`)

### Security
- CLI token-based authentication
- Environment variable configuration (no hardcoded secrets)
