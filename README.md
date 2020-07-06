# Push Subdirectories

GitHub Action to push subdirectories to separate repositories.


## Usage

```yml
name: Publish Public Repo
on: push
jobs:
  master:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: publish:starters
        uses: locked-graphql/repo-sync@master
        env:
          API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          args: locked-graphql locked-graphql
```

The `GITHUB_TOKEN` will automatically be defined, the `API_TOKEN_GITHUB` needs to be set in the `Secrets` section of your repository options. You can retrieve the `API_TOKEN_GITHUB` [here](https://github.com/settings/tokens) (set the `repo` permission).

The action accepts two arguments

1. GitHub username
2. Repository name of the destination repository
