FROM gitpod/workspace-postgres

RUN sudo apt-get update \
 && sudo apt-get install -y \
    postgresql-10-pgtap jq sqitch tree \
 && sudo rm -rf /var/lib/apt/lists/*
