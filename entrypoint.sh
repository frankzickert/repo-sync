#!/bin/bash

set -e


GITHUB_USERNAME=$1
STARTER_NAME="${2:-name}"
BASE=$(pwd)
CLONE_DIR="__${STARTER_NAME}__clone__"

git clone --depth 1 https://$API_TOKEN_GITHUB@github.com/$GITHUB_USERNAME/$STARTER_NAME.git $CLONE_DIR &> /dev/null
cd $CLONE_DIR
find . | grep -v ".git" | grep -v "^\.*$" | xargs rm -rf # delete all files (to handle deletions in monorepo)
  

git config --global user.email "fzickert@googlemail.com"
git config --global user.name "$GITHUB_USERNAME"

echo "Cloning folders and pushing to $GITHUB_USERNAME"
echo "Using $STARTER_NAME as the repo name"

# sync to read-only clones
for folder in *; do
  echo "check $folder"
  [[ $folder != */i_* ]] || continue # skip the internal folders
  [[ $folder == */.github* ]] || continue # skip the github folders
  #[ -d "$folder" ] || continue # only directories
  cd $BASE

  echo "$folder"

  #NAME=$(cat $folder/package.json | jq --arg name "$STARTER_NAME" -r '.[$name]')
  #echo "  Name: $NAME"
  #IS_WORKSPACE=$(cat $folder/package.json | jq -r '.workspaces')
  
  #echo "  Clone dir: $CLONE_DIR"

  # clone, delete files in the clone, and copy (new) files over
  # this handles file deletions, additions, and changes seamlessly
  cd $CLONE_DIR

  if [ -d "$folder" ]; then
    echo "copy folder $BASE/$folder/"
    cp -r $BASE/$folder/ .
  else
    echo "copy file $BASE/$folder"
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
