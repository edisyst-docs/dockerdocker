#!/bin/bash
echo "Setup Jenkins Agents"

# Ottieni il secret per ogni agente dalla web UI
echo "1. Accedi a http://localhost:8080"
echo "2. Vai in Manage Jenkins -> Nodes"
echo "3. Crea nuovo nodo per ogni agente"
echo "4. Copia il secret e modifica il docker-compose.yml"
echo "5. Riavvia: docker-compose up -d"