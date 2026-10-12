# Issue plans of action - website_iac

> **Audience:** a future LLM coding agent implementing the open GitHub issues of `halexs/website_iac`.
> Written 2026-10-12 from a full read of the repository. Each section below is also posted as a comment on the matching issue.
>
> **How to use:** pick an issue, read its plan and dependencies, implement on a feature branch, and open a PR that says `Closes #N`.
> Verify file paths against the current tree before editing; the code may have moved since this was written.
> Sibling repo: `kaelnomads-js`. Cookbook and fileshare issues exist in both repos; build the backend/infra in `website_iac` first.

## Suggested order

Issue numbers: 8 -> 16 -> 17 -> 7 -> 12 -> 13 -> 18

## #7 - Transfer IAM Roles to IaC terraform

**Issue text:** _(none)_

**Goal:** Manage IAM roles in Terraform.

**Current state:** `modules/codepipeline/iam.tf` already manages the CodeBuild and CodePipeline roles; the Lambda role lives in the disabled `modules/website_backend/lambda.tf` (name `kaelnomads-getLocation-role-udgzobzp`, references an account-specific managed policy ARN); MFA-enforcement policy is only a commented JSON in `bootstrap/iam.tf`; users/admin accounts are not managed.

**Plan**
1. Inventory what exists: `aws iam list-roles`, `list-users`, `list-policies --scope Local`; list each as managed / unmanaged in this doc.
2. In `bootstrap/iam.tf`, turn the commented MFA policy into `aws_iam_policy` (use `aws_iam_policy_document` data source) + an `aws_iam_group` (`admins`) with the policy attached; add `aws_iam_user` + `aws_iam_user_group_membership` for existing users via `terraform import`.
3. Tighten existing roles (least privilege) as a second PR: replace `AmazonS3FullAccess`/`AWSCodeCommitFullAccess` in `modules/codepipeline/vars.tf` with scoped inline policies (S3 on the website + artifact buckets only; `cloudfront:CreateInvalidation` on the two distributions; logs on the codebuild log group). The `codepipeline_manual` policy contains many unused services (Beanstalk, OpsWorks, DeviceFarm...) and `Resource: "*"` - prune to: S3 artifact bucket, `codebuild:BatchGetBuilds/StartBuild`, `codestar-connections:UseConnection` on the connection ARN, `iam:PassRole` on the codebuild role.
4. Replace the hardcoded account id (`043038001148`) with `data.aws_caller_identity.current.account_id`.
5. For each pre-existing role, add `import {}` blocks, run `terraform plan` until it shows no diff, then apply.

**Acceptance:** `terraform plan` clean; no console-created IAM roles/users remain unmanaged; pipeline still deploys.
**Risks:** tightening policies can break the pipeline - change one at a time and run the pipeline after each. Never apply bootstrap IAM changes while relying on the user being changed (lock-out); keep a break-glass admin.

## #8 - Bootstrap code for terraform

**Issue text:** _(none)_

**Goal:** Bootstrap code for Terraform.

**Current state:** `bootstrap/` (local backend) creates only the `kaelnomads-terraform-state` bucket. The state file and backup are committed to git (`.gitignore` patterns `*.tfstate*` do not match `terraform.state`). The root module's S3 backend (`provider.tf`) has no locking, versioning or encryption setup.

**Plan**
1. Harden the state bucket in `bootstrap/main.tf`: `aws_s3_bucket_versioning` (enabled), `aws_s3_bucket_server_side_encryption_configuration` (AES256 or KMS), `aws_s3_bucket_public_access_block` (all true), `lifecycle { prevent_destroy = true }`.
2. Enable locking: Terraform >= 1.10 supports `use_lockfile = true` in the S3 backend (no DynamoDB table needed); otherwise add an `aws_dynamodb_table` with `LockID`. Update `provider.tf` accordingly and add `required_version`.
3. Stop tracking state: `git rm --cached bootstrap/terraform.state bootstrap/terraform.state.backup`, rely on the (already added) `*.state` ignore, and review the file first for sensitive values. If it must live somewhere, `terraform init -migrate-state` it into the bucket under key `bootstrap`.
4. Move the IAM scaffolding to #7; make `bootstrap/README.md` a runnable runbook (init -> plan -> apply -> verify bucket).
5. Add a `Makefile` or `scripts/` with `make bootstrap`, `make plan`, `make apply` (runs `fmt -check` and `validate`).
6. CI: GitHub Action running `terraform fmt -check` and `validate` (no apply).

**Acceptance:** fresh account/clone can go from zero to working remote state by following the README; no state in git.
**Risks:** migrating backends is one-way-ish; back up the state file first. Leaked old state remains in git history - rotate anything sensitive.

## #12 - Feature Request: Fileshare

**Issue text:** Due to VT's storage not being unlimited, bought Google storage. However, the data is still on google, so that needs to be migrated to a cheaper solution, such as S3.

**Goal:** Move data off paid Google storage to cheap S3 (same request as `kaelnomads-js` #10; this repo provisions the infra).

**Plan**
1. New module `modules/fileshare`: `aws_s3_bucket` (`kaelnomads-fileshare-<suffix>`) with versioning, SSE, full public-access block, and lifecycle rules (transition to `INTELLIGENT_TIERING` immediately, or `GLACIER_IR`/`DEEP_ARCHIVE` after 30/90 days for archive prefixes; abort incomplete multipart uploads after 7 days; expire noncurrent versions after 90 days).
2. IAM: a dedicated `fileshare-migrator` user/role scoped to the bucket (`s3:PutObject`, `ListBucket`) for the rclone job; remove it after migration. Add it via the IAM approach in #7.
3. Migrate with rclone from the user's machine (`rclone copy gdrive: s3:<bucket>`, then `rclone check`). Document commands in `docs/FILESHARE_MIGRATION.md`.
4. Sharing (optional): CloudFront + Origin Access Control in front of the bucket with signed URLs, or presigned URLs minted by a Lambda (reuse the backend module). Never use a public bucket policy.
5. Budget guardrail: `aws_budgets_budget` with an email alert at e.g. $5/month.
6. Wire the module into root `main.tf` and output the bucket name.

**Acceptance:** `terraform apply` creates the private bucket with lifecycle; data verified; budget alarm exists.
**Dependencies:** #7 (IAM), #16/#18 (shared Lambda patterns). Frontend page tracked in `kaelnomads-js` #10.

## #13 - Feature Request: Cookbook

**Issue text:** Would like to add a cooking tab to help with weekly meal prep.

Ideally I can choose a dish I want, and then the backend DB can coordinate the ingredients to see what other cuisines I can also make and what I need to buy.

**Goal:** Backend for the cookbook (dish -> ingredients -> shopping list + "what else can I make"). Frontend is `kaelnomads-js` #11.

**Plan**
1. **Data store:** `modules/website_backend/dynamodb.tf` has a commented table; the earlier note says a DB was "overkill" for locations, but it fits here. Use one table, on-demand billing (`PAY_PER_REQUEST`), single-table design:
   - `PK=DISH#<id>`, `SK=META` (name, cuisine, servings, steps)
   - `PK=DISH#<id>`, `SK=ING#<ingredient>` (qty, unit, aisle)
   - GSI1 `PK=ING#<ingredient>`, `SK=DISH#<id>` to answer "which dishes use X".
2. **Endpoints** (API Gateway REST or HTTP API -> Lambda, Python 3.12): `GET /dishes`, `GET /dishes/{id}`, `POST /dishes`, `PUT /dishes/{id}` (writes auth-protected), `POST /plan`.
3. **/plan algorithm:** sum ingredients of selected dishes (normalising units, scale by servings) -> shopping list. For suggestions: ingredient set U of selected dishes; for each other dish D, `missing = D.ingredients - U`; return dishes with `len(missing) <= 2` sorted by fewest missing. Pantry staples (salt, oil) excluded via a `staple` flag.
4. **Seed data:** `scripts/seed_dishes.py` loading `data/dishes.json`.
5. **Terraform:** table, Lambda (`archive_file` as in existing `lambda.tf`), least-privilege role (`dynamodb:GetItem/Query/PutItem` on table + GSI ARNs only), API Gateway with CORS for kaelnomads.com, an API key or Cognito/JWT authorizer for writes, usage plan throttling.
6. **Tests:** pytest for the plan algorithm (pure function, no AWS), `moto` for handler tests.

**Acceptance:** `POST /plan` with two dish ids returns merged list and suggestions; writes require auth; table in Terraform state.
**Dependencies:** #16 (Lambda dev workflow), #7 (IAM). Related to the (disabled) `website_backend` module; re-enable it first (see #17).

## #16 - Lambda Dev

**Issue text:** Come up with a way to develop future lambda function

**Goal:** A way to develop future Lambda functions.

**Current state:** `modules/website_backend` packages a single file (`get_location.py`) with `archive_file`; the Lambda role name was copied from the console; a stray `test.js` exists; the module is commented out of the root `main.tf` (last commit "Delete apigateway + lambda"); `python3.9` runtime is deprecated.

**Plan**
1. Layout: `lambdas/<name>/{handler.py,requirements.txt,tests/}` at repo root, one directory per function; delete `test.js`.
2. A reusable module `modules/lambda_function` taking `name`, `source_dir`, `runtime` (default `python3.12`), `env`, `policy_json`, creating: role + least-privilege inline policy, `archive_file` (zip of dir), `aws_lambda_function`, `aws_cloudwatch_log_group` (14-day retention), optional API Gateway route via a `routes` input.
3. Local dev: AWS SAM CLI `sam local invoke` / `sam local start-api` with a generated `events/*.json`, or plain `pytest` calling `lambda_handler(event, None)`; use `moto` for S3/DynamoDB. Add `make test-lambdas`.
4. Deploy: `terraform apply` (zip hash drives updates). Separate dev/prod via `aliases` or a `var.env` suffix; add Lambda `publish = true` and alias `live`.
5. CI: GitHub Action running pytest + `terraform validate`.
6. Document the workflow in `docs/LAMBDA_DEV.md` and replace the debug `print` statements with structured `logging`.

**Acceptance:** adding a new function = new dir under `lambdas/` + one module block; tests run locally; runtime up to date.
**Dependencies:** unblocks #13, #17, #18.

## #17 - Try open s3 bucket with location.json file

**Issue text:** _(none)_

**Goal:** Have the Lambda open the S3 bucket and return `locations.json`.

**Current state:** `get_location.py` returns a hardcoded string; the real logic is commented out (`s3.Object('kaelnomads-resources','locations.json')`). The live API the site calls (`https://acalgr3bv1.execute-api.us-east-1.amazonaws.com/beta/location`) was created manually and is not in Terraform. Also the old code returned `'body': json_content` (a dict), which API Gateway proxy integrations reject - body must be a string. Frontend (`TravelMap.js`) reads `responseData["body"]`, so it currently expects the body to be an *object* nested in the JSON response (see compatibility note).

**Plan**
1. Rewrite `get_location.py`: read bucket/key from env vars (`LOCATIONS_BUCKET`, `LOCATIONS_KEY`), create the boto3 client outside the handler, `get_object` -> parse JSON, return
   `{"statusCode":200,"headers":{"Content-Type":"application/json","Access-Control-Allow-Origin":"https://kaelnomads.com","Cache-Control":"max-age=300"},"body": json.dumps(data)}`; return 502 with a safe message on `ClientError`.
2. **Compatibility:** with proper proxy output the browser receives the JSON directly, not `{statusCode, body}`. Either (a) update `TravelMap.js` to use `await response.json()` directly (preferred, coordinate with `kaelnomads-js`), or (b) temporarily keep the old envelope. Do (a) and deploy backend + frontend together, or support both in the frontend (`data.body ?? data`).
3. Least privilege: replace `AmazonS3ReadOnlyAccess` with a policy allowing `s3:GetObject` on `arn:aws:s3:::kaelnomads-resources/locations.json` only. Pass the bucket name via Terraform variable.
4. Re-enable `module "website_backend"` in root `main.tf`; import/replace the manually created API (`modules/website_backend/import.tf` already scaffolds the import) so the URL consumed by the site stays stable; add the API key / usage plan the frontend sends (`X-API-KEY`) and CORS `OPTIONS`.
5. Unit-test with `moto`; manual check with `curl`.
6. Move the API URL out of frontend source into `REACT_APP_API_URL` (see kaelnomads-js cross-cutting notes).

**Acceptance:** `GET /location` returns the real S3 JSON with 200 and CORS headers; Terraform owns the API; site map renders from it.
**Dependencies:** #16 (module layout), #7. Feeds `kaelnomads-js` #8.

## #18 - Feature Request: Saving images + GIFs

**Issue text:** Given a gif or image url link, it will save it under a bucket in s3.

**Goal:** Given a GIF/image URL, save it to an S3 bucket.

**Plan**
1. Endpoint `POST /images` with body `{ "url": "https://..." }` -> Lambda -> S3 `PutObject`. Returns `{ key, url }`.
2. **Security (SSRF is the main risk):** allow only `https`; resolve the hostname and reject private/loopback/link-local/metadata ranges (169.254.169.254, 10/8, 172.16/12, 192.168/16, ::1); disable redirects or re-validate each hop; cap download size (e.g. 25 MB via streaming and `Content-Length` check) and timeout (10s); verify the content-type is `image/*` and sniff magic bytes (GIF/PNG/JPEG/WebP); never trust the file extension. Require auth (API key or JWT) - no anonymous writes.
3. Storage: dedicated bucket (or `images/` prefix in the fileshare bucket from #12), key = SHA-256 of bytes (`images/<sha256>.<ext>`) to dedupe; set `ContentType`, `CacheControl: public,max-age=31536000,immutable`. Private bucket + CloudFront (OAC) for serving.
4. Lambda: Python with stdlib `urllib` (no heavy deps), memory 256 MB, timeout 20s, reserved concurrency to cap cost.
5. Terraform via the `lambda_function` module from #16: bucket, role limited to `s3:PutObject` on the prefix, API route, throttling.
6. Tests: pytest for URL validation (SSRF cases), size/type limits, with `moto`.
7. Optional follow-ups: thumbnail generation; list endpoint for the frontend gallery (`kaelnomads-js` #4/#10).

**Acceptance:** valid image URL ends up in S3 and is retrievable via CloudFront; SSRF/oversize/non-image inputs rejected with 4xx.
**Dependencies:** #16, #12.

## Cross-cutting findings (tech debt)

- **State files tracked in git:** `bootstrap/terraform.state` and `.backup` are committed (ignore patterns did not match; `.gitignore` now covers `*.state`, but the files must still be untracked - see #8).
- **No state locking / versioning** on the S3 backend (#8).
- **Over-broad IAM:** `AmazonS3FullAccess`, `AWSCodeCommitFullAccess`, `AmazonDynamoDBFullAccess` on build/pipeline roles; the `codepipeline_manual` policy grants many unrelated services on `*` (#7).
- **Hardcoded identifiers:** AWS account id in `mfa_aws.sh`, the Lambda role policy ARN, and the CodeStar connection ARN in `codepipeline.tf`. Prefer variables / `aws_caller_identity`.
- **Destructive defaults:** `force_destroy = true` on the website and artifact buckets.
- **Public S3 website origins** with `http-only` and legacy `TLSv1`/`TLSv1.1` in the prod CloudFront origin ssl protocols; consider OAC with a private bucket and drop legacy protocols.
- **Dev CloudFront** allows `PUT/POST/DELETE` on a static site; restrict to `GET, HEAD, OPTIONS`.
- **Provider requirements:** `random` and `archive` providers are used but not declared in `required_providers`; no `required_version`.
- **Backend module is disabled** and contains a Python 3.9 runtime, commented-out experiments and a stray `test.js` (#16, #17).
- **Empty `terraform.tfvars`** is committed; remove it or document variables.
- **`random_string` suffix** on bucket names changes if state is lost, which would recreate buckets; consider fixed names or `ignore_changes`.
- **No CI:** add a `terraform fmt -check` / `validate` workflow (#8).
