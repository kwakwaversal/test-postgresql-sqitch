FROM gitpod/workspace-postgresql

RUN sudo apt-get update \
 && sudo apt-get install -y \
    postgresql-10-pgtap jq tree \
 && sudo rm -rf /var/lib/apt/lists/*
