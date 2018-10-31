# Datadog Management Tools

This repository contains a set of tools to backup and restore Datadog
dashboards, screenboards, and monitors to and from local JSON files.

## Requirements

* Ruby 2.3.x+.
* Recommend using [`rvm`](https://rvm.io/) for non-root, sandboxed gem dependency management.

Note that this tool uses the Datadog Ruby SDK and the Datadog APIs:
* [Datadog Ruby SDK](https://github.com/DataDog/dogapi-rb)
* [Datadog API](https://docs.datadoghq.com/api/)

## Installation

1. Clone this repository.
1. `bundle install`
1. Setup the configuration file. Copy `datadog-config.yaml-sample` to `path/to/config/datadog-config.yaml`, and edit.

## Usage

To backup all dashboards, screenboards, and monitors as JSON files stored in a local directory:
```bash
bundle exec datadog-backup-all.rb --config path/to/config/datadog-config.yaml
```

To restore a single dashboard, screenboard, or monitor:
```bash
bundle exec datadog-restore.rb --config path/to/config/datadog-config.yaml --object dashboard --file /path/to/dashboards/Some\ Dashboard.json
```

To make a copy of a single dashboard, screenboard, or monitor:
```bash
bundle exec datadog-restore.rb --config path/to/config/datadog-config.yaml --object dashboard --file /path/to/dashboards/Some\ Dashboard.json --altname "Copy of Some Dashboard"
```
