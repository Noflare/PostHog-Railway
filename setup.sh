#!/bin/bash

# Assurez-vous d'avoir Docker et Docker Compose installés

# Charger les variables d'environnement depuis le fichier .env
if [ -f .env ]; then
    export $(cat .env | xargs)
else
    echo "Le fichier .env n'existe pas. Veuillez le créer avec les variables nécessaires."
    exit 1
fi

# Clonez le référentiel PostHog depuis GitHub
git clone https://github.com/PostHog/posthog.git
cd posthog

# Assurez-vous d'avoir les dernières mises à jour
git pull

# Configuration Docker Compose
cat > docker-compose.yml <<EOF
version: '3'
services:
  posthog:
    image: posthog/posthog:\${POSTHOG_APP_TAG}
    environment:
      - POSTHOG_SECRET=\${POSTHOG_SECRET}
      - SENTRY_DSN=\${SENTRY_DSN}
      - DATABASE_URL=postgresql://\${POSTGRES_USER}:\${POSTGRES_PASSWORD}@db/\${POSTGRES_DB}
    depends_on:
      - db
    ports:
      - "8000:8000"
  db:
    image: postgres:12
    environment:
      - POSTGRES_PASSWORD=\${POSTGRES_PASSWORD}
      - POSTGRES_USER=\${POSTGRES_USER}
      - POSTGRES_DB=\${POSTGRES_DB}
EOF

# Démarrer les services
docker-compose up -d

# Attendre que PostHog soit prêt
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost
