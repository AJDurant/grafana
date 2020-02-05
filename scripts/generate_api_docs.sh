#!/usr/bin/env bash

# abort if we get any error
set -e

_branch="$(git rev-parse --abbrev-ref HEAD)"

if [ "${_branch}" == "master" ]; then
    echo "you cannot generate api docs from the master branch"
    echo "please checkout the release branch"
    echo "ex 'git checkout v5.1.x'"
    exit 1
fi

# always make sure we have a clean workspace
if ! git diff-index --quiet HEAD --; then
    echo "git workspace is dirty and contains changes"
    echo "make sure you have a clean workspace before running this script"
    exit 1
fi

# always make sure to pull latest changes from origin
echo "pulling latest changes from ${_branch}"
git pull origin "${_branch}"

# building grafana packages
echo "bulding grafana packages..."
yarn packages:build

# extract packages api documentation json
echo "extracting packages documentation data..."
yarn packages:docs-extract

# generating api documentation markdown
echo "generating markdown from documentation data..."
yarn packages:docs-to-markdown

echo "updated files:"
git status --porcelain | sed s/^...//

echo "press [y] to commit documentation update"
read -n 1 confirm

if [ "${confirm}" == "y" ]; then
    git commit -am "docs: updated packages api documentation"
else
    git checkout -- .
    echo "Abort! "
fi
