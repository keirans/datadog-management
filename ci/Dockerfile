FROM ruby:2.5.3-alpine3.8
LABEL maintainer="meta-dpt@chanzuckerberg.com"

# Install chamber
RUN apk update \
    && apk add wget make gcc libc-dev git openssh \
    && wget -q https://github.com/segmentio/chamber/releases/download/v2.2.0/chamber-v2.2.0-linux-amd64 \
    && mv chamber-v2.2.0-linux-amd64 /usr/bin/ \
    && ln -s /usr/bin/chamber-v2.2.0-linux-amd64 /usr/bin/chamber \
    && chmod +x /usr/bin/chamber \
    && mkdir root/.aws

COPY Gemfile *.rb ci/docker_entrypoint.sh /opt/

RUN (cd opt && bundle install)

RUN apk del wget make gcc libc-dev

ENTRYPOINT /opt/docker_entrypoint.sh
