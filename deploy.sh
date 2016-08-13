#!/bin/bash
set -e

if [ ! -d "$SOURCE_DIR" ]; then
  echo "SOURCE_DIR ($SOURCE_DIR) does not exist, build the source directory before deploying"
  exit 1
fi

if [ -n "$TRAVIS_BUILD_ID" ]; then
  echo FROM_BRANCH: $FROM_BRANCH
  echo ENCRYPTION_LABEL: $ENCRYPTION_LABEL
  echo GIT_NAME: $GIT_NAME
  if [ "$TRAVIS_BRANCH" != "$FROM_BRANCH" ]; then
    echo "Travis should only deploy from the FROM_BRANCH ($FROM_BRANCH) branch"
    exit 0
  else
    if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
      echo "Travis should not deploy from pull requests"
      exit 0
    else
      chmod 600 $SSH_KEY
      eval `ssh-agent -s`
      ssh-add $SSH_KEY
      git config --global user.name "$GIT_NAME"
      git config --global user.email "$GIT_NAME@users.noreply.github.com"
    fi
  fi
fi

TO_REPO_NAME=$(basename $TO_REPO)
TO_DIR=$(mktemp -d /tmp/$TO_REPO_NAME.XXXX)
REV=$(git rev-parse HEAD)
git clone --branch ${TO_BRANCH} ${TO_REPO} ${TO_DIR}
rsync -rt --delete --exclude=".git" --exclude=".travis.yml" $SOURCE_DIR/ $TO_DIR/
cd $TO_DIR
ls -all
#git add -A .
#git commit --allow-empty -m "Built from commit $REV"
#git push $TO_REPO $TO_BRANCH