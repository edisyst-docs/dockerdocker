FROM jenkins/inbound-agent:latest

USER root

# Installa solo Docker e Git (NON docker-compose)
RUN apt-get update && \
    apt-get install -y \
    git \
    docker.io \
    && apt-get clean

# Aggiungi l'utente jenkins al gruppo docker
RUN usermod -aG docker jenkins

# Torna all'utente jenkins
USER jenkins