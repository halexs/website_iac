# website_iac

Terraform for [kaelnomads.com](https://kaelnomads.com). The site was originally built by hand in the AWS
console; this repo transposes those resources into code. Frontend source lives in
[`kaelnomads-js`](https://github.com/halexs/kaelnomads-js).

## Architecture

```
GitHub (kaelnomads-js) -> CodePipeline -> CodeBuild (dev) -> S3 dev bucket  -> CloudFront dev  -> dev.kaelnomads.com
                                      \-> manual approval -> CodeBuild (prod) -> S3 main bucket -> CloudFront prod -> kaelnomads.com
Route53 zone + ACM cert (DNS validated, *.kaelnomads.com) front both distributions.
```

| Module                      | Purpose                                                                            | Status |
|-----------------------------|------------------------------------------------------------------------------------|--------|
| `bootstrap/`                | State bucket (`kaelnomads-terraform-state`), IAM notes. Uses a **local** backend.  | manual |
| `modules/website_s3`        | Website buckets (`main`, `dev`), public-read policy, CloudFront, ACM certificate   | active |
| `modules/route53`           | Hosted zone, apex/www/dev alias records, cert validation records                   | active |
| `modules/codepipeline`      | Pipeline, CodeBuild projects (dev/prod), IAM roles, artifact bucket                | active |
| `modules/website_backend`   | Lambda + API Gateway for `/location` (`get_location.py`)                           | **disabled** (commented out in root `main.tf`) |

State for the root module is stored in S3 (`provider.tf`: bucket `kaelnomads-terraform-state`, key `website-js`).

## Prerequisites

- Terraform >= 1.x and the AWS CLI
- An AWS profile named `kaelnomads` (override with the 2nd arg of `mfa_aws.sh`)
- An MFA device; the account enforces MFA

## Usage

```sh
# 1. Get MFA-backed temporary credentials (must be sourced so the exports persist)
. ./mfa_aws.sh <6-digit-code> [profile]

# 2. Standard workflow
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

`mfa_aws.sh` also writes the credentials to `.env` (git-ignored). The MFA device ARN is hardcoded in
the script; edit it if the device changes.

## CI

`.github/workflows/ci.yml` runs `terraform fmt -check` (non-blocking until the code base is formatted once) and `terraform validate` (root and `bootstrap/`, no backend) on every PR and push to `main`.
A speculative `terraform plan` job runs on PRs only when the repo variable `AWS_ROLE_ARN` is set to a read-only IAM role that trusts GitHub OIDC.
There is intentionally no automatic `apply`; apply manually with MFA credentials.

## Conventions

- Run `terraform fmt -recursive` before committing.
- Keep provider constraints in each module's `main.tf` (`aws ~> 5.0`).
- `import.tf` / `s3_import.tf` files hold (mostly commented) scaffolding used to import resources
  that predate Terraform. Do not delete the commented blocks without checking they have been imported.
- Never commit state, `.env`, or `lambda_function_payload.zip` (all covered by `.gitignore`).

## Known gaps

See [`docs/ISSUE_PLANS.md`](docs/ISSUE_PLANS.md) for per-issue plans and the "Cross-cutting findings"
section (broad IAM policies, tracked bootstrap state file, no S3 state locking, etc.).
