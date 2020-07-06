FROM node:12-slim

LABEL repository="https://github.com/locked-graphql/repo-sync.git"
LABEL homepage="https://github.com/locked-graphql/repo-sync.git"
LABEL maintainer="Dr. Frank Zickert"

LABEL com.github.actions.name="GitHub Action to keep the public repo in sync"
LABEL com.github.actions.description="Automatically push subdirectories in a monorepo to their own repositories"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git && \
    apt-get install -y jq

COPY "entrypoint.sh" "/entrypoint.sh"
ENTRYPOINT ["/entrypoint.sh"]
