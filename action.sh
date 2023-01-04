#!/bin/bash

set -e
set -o pipefail

###
# Environment variable definitions.
##

if [[ -z "${HUGO_VERSION}" ]]; then
    HUGO_VERSION=$(curl -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/gohugoio/hugo/releases?page=1&per_page=1" | jq -r ".[].tag_name" | sed 's/v//g')
    echo "No HUGO_VERSION was set, so defaulting to ${HUGO_VERSION}"
fi

if [[ "${HUGO_EXTENDED}" = "true" ]]; then
  EXTENDED_INFO=" (extended)"
  EXTENDED_URL="extended_"
else
  EXTENDED_INFO=""
  EXTENDED_URL=""
fi

###
# Downloading of Hugo.
###
echo "Downloading Hugo: ${HUGO_VERSION}${EXTENDED_INFO}"
URL=https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${EXTENDED_URL}${HUGO_VERSION}_Linux-64bit.tar.gz
echo "Using '${URL}' to download Hugo"
curl -sSL "${URL}" > /tmp/hugo.tar.gz
tar -C /tmp -xf /tmp/hugo.tar.gz
mv /tmp/hugo /usr/bin/hugo

###
# Optionally install Go.
###
# shellcheck disable=SC2153
if [[ -n "${GO_VERSION}" ]]; then
  echo "Installing Go: ${GO_VERSION}"

  curl -sL "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" > /tmp/go.tar.gz
  tar -C /tmp -xf /tmp/go.tar.gz
  mv /tmp/go /go
  rm -rf \
    /usr/local/go/pkg/*/cmd \
    /usr/local/go/pkg/bootstrap \
    /usr/local/go/pkg/obj \
    /usr/local/go/pkg/tool/*/api \
    /usr/local/go/pkg/tool/*/go_bootstrap \
    /usr/local/go/src/cmd/dist/dist \
    /tmp/go.tar.gz

  # Provide version details and sanity check installation
  echo "Installed Go: ${GO_VERSION}"
  go version
fi

# https://github.com/actions/checkout/issues/766
git config --global --add safe.directory "${PWD}"

###
# Build the site.
###
echo "Building the Hugo site with: 'hugo ${HUGO_ARGS}'"
hugo "${HUGO_ARGS}"

echo "Complete"
