# resume
This repo manages my resume in a JSONResume format.

## Structure
- The resume itself is declared at resume.yaml and follows the JSONResume jsonschema as specified in the schema header.
- Sensitive details that I want to inject into my resume are held in the `secrets/` directory. You should never check in a decrypted version of the contents of this directory.
- Full rendering requires decrypting `secrets/resume.sops.yaml`.
- The project is managed using a nix devshell declared by the flake.nix
- Binaries provided by the nix devshell may not be present on the ambient `PATH` in every agent session.
- Prefer running repo workflows through `nix develop -c <command>` or existing wrapper scripts rather than assuming tools like `go`, `sops`, `yq`, or `goresume` are globally available.
- If `nix` is not on `PATH`, try `/nix/var/nix/profiles/default/bin/nix`.
- I'm using the `goresume` binary as tooling to render my resume that I can send to recruiters.
- Use `scripts/export-resume-with-secrets.sh` to render variants.
- The local `goresume` fork is built from `forks/goresume.
- If the local Go build fails on VCS stamping, use `go build -buildvcs=false`.

## Style Guide
These preferences are settled and should not be revisited unless asked.
- Adhere to the JSONResume jsonschema. I will sometimes ask to build off of the schema when it doesn't fully fit my needs.
- Sentences should be presented in the past tense.
- The first sentence of a highlight or summary should be concise and describe the project/responsibility/role at a high level.
- Each fact within a highligh or summary should be separated by a period rather than by a comma.
- The `professional` theme is the default PDF theme.
- The desired output is a clean one-page resume.

## Highlight Priorities
- Older roles should usually keep summaries first. Add or retain their highlights only when they clearly support the target job.
- For applying to observability roles, prioritize Block observability migrations, resilience work, AI workload telemetry, Datadog, OpenTelemetry, and incident-response content.
- For applying to platform roles, prioritize GitOps, EKS/Kubernetes, Terraform, Argo CD, Helm, and multi-cluster rollout content.
- For applying to data platform or security data roles, prioritize Trino/Presto migration, query replay tooling, Elasticsearch, ClickHouse, and downstream security analytics mentions.
- For applying to AI platform roles, prioritize the Block AI observability bullet and any production platform work around LLM agents or AI workloads.
