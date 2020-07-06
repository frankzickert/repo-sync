#!/bin/bash

set -e

FOLDER=$1
GITHUB_USERNAME=$2
#STARTER_NAME="${3:-name}"
BASE=$(pwd)

git config --global user.email "fzickert@googlemail.com"
git config --global user.name "$GITHUB_USERNAME"

echo "Cloning folders in $FOLDER and pushing to $GITHUB_USERNAME"
echo "Using $STARTER_NAME as the repo name"

# sync to read-only clones
for folder in $FOLDER/*; do
  echo "check $folder"
  [[ $folder == */i_* ]] || continue # skip the internal folders
  #[ -d "$folder" ] || continue # only directories
  cd $BASE

  echo "$folder"

  #NAME=$(cat $folder/package.json | jq --arg name "$STARTER_NAME" -r '.[$name]')
  #echo "  Name: $NAME"
  #IS_WORKSPACE=$(cat $folder/package.json | jq -r '.workspaces')
  CLONE_DIR="__${$STARTER_NAME}__clone__"
  #echo "  Clone dir: $CLONE_DIR"

  # clone, delete files in the clone, and copy (new) files over
  # this handles file deletions, additions, and changes seamlessly
  git clone --depth 1 https://$API_TOKEN_GITHUB@github.com/$GITHUB_USERNAME/$STARTER_NAME.git $CLONE_DIR &> /dev/null
  cd $CLONE_DIR
  find . | grep -v ".git" | grep -v "^\.*$" | xargs rm -rf # delete all files (to handle deletions in monorepo)
  
  if [ -d "$folder" ]; then
    cp -r $BASE/$folder/. .
  else
    cp $BASE/$folder .
  fi

  # generate a new yarn.lock file based on package-lock.json unless you're in a workspace
  #if [ "$IS_WORKSPACE" = null ]; then
  #  echo "  Regenerating yarn.lock"
  #  rm -rf yarn.lock
  #  yarn
  #fi

  # Commit if there is anything to
  if [ -n "$(git status --porcelain)" ]; then
    echo  "  Committing $STARTER_NAME to $GITHUB_REPOSITORY"
    git add .
    git commit --message "Update $STARTER_NAME from $GITHUB_REPOSITORY"
    git push origin master
    echo  "  Completed $STARTER_NAME"
  else
    echo "  No changes, skipping $STARTER_NAME"
  fi

  cd $BASE
done
