#!/bin/sh

set -e

eval `ssh-agent`
GITHUB_DEPLOY_KEY_FILE=/tmp/github_deploy_key
echo "${GITHUB_DEPLOY_KEY}" > $GITHUB_DEPLOY_KEY_FILE && chmod 600 $GITHUB_DEPLOY_KEY_FILE
ssh-add $GITHUB_DEPLOY_KEY_FILE
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
git clone --depth 1 git@github.com:chanzuckerberg/meta-datadog-config.git

cd /opt && \
    chamber exec meta-${ENV}-${SERVICE_NAME} -- \
    bundle exec ./datadog-backup-all.rb --backup-dir /meta-datadog-config --name-filter-regex '^meta-.*'

cd /meta-datadog-config
git config user.name 'CZI Datadog Management'
git config user.email '<>'
git commit --all --message 'Backup of latest Datadog state'
git push origin HEAD


