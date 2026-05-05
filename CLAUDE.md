# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**CloudHunt** is a personalized job discovery and matching platform for cloud engineering roles. Users upload a resume, answer preference questions, and the app surfaces ranked job matches with direct apply links.

**Tech Stack:**
- Backend: AWS Lambda (Python/boto3), DynamoDB, API Gateway, S3, EventBridge, CloudFront
- Frontend: React
- Infrastructure: Terraform (all infra as code)
- CI/CD: GitHub Actions (`terraform plan` on PR, `terraform apply` on merge to `main`)

## Division of Responsibilities

This project is intentionally structured so the human writes all backend, infrastructure, and algorithm code (for interview skill-building), and Claude Code handles frontend and boilerplate.

**Human writes (do not generate unless explicitly asked):**
- Terraform infrastructure (provider config, S3, DynamoDB tables + GSIs, API Gateway, EventBridge rules, CloudFront)
- IAM roles and policies — hand-crafted least-privilege per Lambda, never wildcards
- Lambda handlers in Python (resume upload, parsing, scraping, matching, tracking)
- DynamoDB table schemas and access pattern design
- Matching algorithm logic
- README with architecture and design decisions

**Claude Code generates:**
- React frontend scaffold, routing, component structure
- UI components (upload zone, job cards, filters, dashboard layout, Kanban tracker)
- `package.json`, ESLint, Prettier, tsconfig
- Skills taxonomy/keyword lists for the resume parser
- Unit/integration tests for Lambda handlers (using `moto` for S3/DynamoDB mocking)
- API response normalization functions (once the human defines the schema)
- Architecture diagrams (Mermaid/SVG) for the README

## Architecture Data Flow

```
React → CloudFront → S3 (frontend)
React → API Gateway → Lambda functions → DynamoDB / S3
S3 event (new resume) → resume-parser Lambda → DynamoDB UserProfiles
EventBridge cron → job-scraper Lambdas → DynamoDB Jobs
GET /matches/{user_id} → matching Lambda → reads UserProfiles + Jobs → scored results
POST/PATCH /applications → app-tracker Lambda → DynamoDB Applications
```

**DynamoDB tables:**
- `UserProfiles` — PK: `user_id`; skills, experience, preferences
- `Jobs` — PK: `job_id`; GSIs on location and posted_date
- `Applications` — PK: `user_id`, SK: `job_id`; status, applied_date, notes

## Development Commands

**Terraform (in `terraform/`):**
```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

**Python Lambda functions:**
```bash
pip install -r requirements.txt
pytest lambda_functions/<name>/tests/ -v   # uses moto for AWS mocking
black lambda_functions/
flake8 lambda_functions/
```

**React frontend (in `frontend/`):**
```bash
npm install
npm start          # dev server
npm run build
npm run lint
npm test
```

## Key Patterns

- **IAM**: Every Lambda gets its own role. Scope to specific resource ARNs, never `*`. This is a core interview talking point.
- **DynamoDB**: Design tables around access patterns first. Use `query` with GSI for filtered results; avoid `scan` in production paths.
- **Resume parsing**: `pdfplumber` or `PyPDF2` for text extraction, regex + skills taxonomy for structured extraction.
- **Job sources**: Adzuna API (free key), Remotive API (no auth), optionally JSearch/The Muse/USAJobs.
- **Testing**: Mock AWS with `moto` — never hit real AWS in tests.
- **Stretch goal**: Claude API integration in the matching Lambda to score job fit 1–100 with reasoning.
