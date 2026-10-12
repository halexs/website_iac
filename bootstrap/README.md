# bootstrap

Prepares the AWS account so the root module can run. This directory uses a **local** backend
(`terraform.state`) because it creates the S3 bucket that the root module uses for remote state.

## What it manages today

- `main.tf`: S3 bucket `kaelnomads-terraform-state`
- `iam.tf`: a commented-out IAM policy that forces MFA for CLI and console (apply manually or convert to a resource)

## Planned

- Create initial IAM roles and users (issue #7)
- Enable bucket versioning + encryption + public-access block on the state bucket
- Set up admin accounts

## Usage

```sh
cd bootstrap
terraform init
terraform plan
terraform apply
```

> **Warning:** `terraform.state` and `terraform.state.backup` are currently tracked in git even though
> `*.tfstate*` is ignored (the filenames do not match the pattern). See `docs/ISSUE_PLANS.md`
> "Cross-cutting findings" for the remediation.
