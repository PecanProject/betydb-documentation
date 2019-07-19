#!/bin/sh

set -e

[ -z "${GITHUB_PAT}" ] && exit 0
[ "${TRAVIS_BRANCH}" != "master" ] && exit 0

GH_USER=${TRAVIS_REPO_SLUG%/*}

git config --global user.email "pecanproj@gmail.com"
git config --global user.name "TRAVIS-DOC-BUILD"

git clone https://${GITHUB_PAT}@github.com/${TRAVIS_REPO_SLUG}.git book-output

cd book-output

rsync -av --delete ../_book/ ./technical/
git add --all *
git commit -m "Update the book -- technical" || true
git push -q origin master
