#!/bin/bash
# Script d'initialisation des instances
apt-get update
apt-get install -y python3 ansible  # Pour permettre a Ansible de se connecter plus tard

# eventuellement d'autres configurations initiales
echo "Instance initialisee avec succes"