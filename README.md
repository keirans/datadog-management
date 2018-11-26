# Datadog Management Tools

This repository contains a set of tools to backup and restore Datadog
dashboards, screenboards, and monitors to and from local JSON
files. By committing these JSON files to a Git repository, you can
maintain a auditable history of changes.

## Requirements

* Ruby 2.3.x+.
* Recommend using [`rvm`](https://rvm.io/) for non-root, sandboxed gem dependency management.

Note that this tool uses the Datadog Ruby SDK and the Datadog APIs:
* [Datadog Ruby SDK](https://github.com/DataDog/dogapi-rb)
* [Datadog API](https://docs.datadoghq.com/api/)

## Installation

1. Clone this repository.
1. `bundle install`
1. Set and export DD_API_KEY and DD_APP_KEY environment variables.

## Usage

To backup all dashboards, screenboards, and monitors as JSON files stored in a local directory:
```bash
bundle exec datadog-backup-all.rb --backup-dir <dir> --name-filter-regex <file>
```

To restore a single dashboard, screenboard, or monitor:
```bash
bundle exec datadog-restore.rb --object dashboard --file /path/to/dashboards/Some\ Dashboard.json
```

To make a copy of a single dashboard, screenboard, or monitor:
```bash
bundle exec datadog-restore.rb --object dashboard --file /path/to/dashboards/Some\ Dashboard.json --altname "Copy of Some Dashboard"
```

## Deployment

This application is intended to deployed to AWS ECS, which requires a Dockert image to be built and published to Docker Hub, and for AWS Param Store params to be set:

1. The Docker image must be built and published as follows (set VERSION, below):
```
docker build . --file ci/Dockerfile --tag chanzuckerberg/datadog-management:<VERSION>
docker push chanzuckerberg/datadog-management:<VERSION>
```

Note: The image that is built is (currently) hardcoded to perform a backup of the Datadog state and commit it to the [meta-datadog-config](https://github.com/chanzuckerberg/meta-datadog-config) Github Repo.

Note: The Docker image's entrypoint expects that following environment variables to be set at run-time:    

- ENV: A value of either `dev`, `staging`, or `prod`
- SERVICE: The name of the service, which will be used to find additional configuration parameters in AWS Param Store

2. You must generate an RSA key pair. The public key of the pair must be
set [here](https://github.com/chanzuckerberg/meta-datadog-config/settings/keys) as the Deploy Key [meta-datadog-config](https://github.com/chanzuckerberg/meta-datadog-config) Github Repo. The private key will set as an AWS Param Store parameter (see below). 

3. The Docker image's entrypoint expects that following AWS Param Store variables to be set under the `meta-<ENV>-<SERVICE>`:
- DD_API_KEY: An API key set on the (Datadog Integration API page)[https://app.datadoghq.com/account/settings#api]
- DD_APP_KEY: An application key set on the (Datadog Integration API page)[https://app.datadoghq.com/account/settings#api]
- GITHUB_DEPLOY_KEY: The private key of an RSA key pair. Use "\n" for line breaks when specifying the value, since this is a multi-line value.

4. Update `chanzuckerberg/meta-infra` Git repo [here](https://github.com/chanzuckerberg/meta-infra/blob/master/terraform/envs/prod/datadog-backup/main.tf#L4) to bump the prod environment VERSION of the Docker image (set above).