#!/bin/bash
# Script de déploiement complet
set -e
echo "=== Déploiement de l'infrastructure web ==="
# Variables
ENVIRONMENT=${1:-dev}
TERRAFORM_DIR="./terraform"
ANSIBLE_DIR="./ansible"
# Validation des prérequis
echo "Vérification des prérequis..."
command -v terraform >/dev/null 2>&1 || { echo "Terraform requis mais non installé."; exit 1; }
command -v ansible >/dev/null 2>&1 || { echo "Ansible requis mais non installé."; exit 1; }
# Déploiement Terraform
echo "Déploiement de l'infrastructure avec Terraform..."
cd $TERRAFORM_DIR
terraform init
terraform plan -var="environment=$ENVIRONMENT"
terraform apply -var="environment=$ENVIRONMENT" -auto-approve
# Récupération des IPs pour l'inventaire Ansible
echo "Génération de l'inventaire Ansible..."
INSTANCE_IPS=$(terraform output -json instance_ips | jq -r '.[]')
ALB_DNS=$(terraform output -raw alb_dns_name)
# Création de l'inventaire dynamique
cat > ../ansible/inventory/hosts << EOF
[webservers]
EOF
for ip in $INSTANCE_IPS; do
echo "$ip ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/my-key-pair.pem" >> ../ansible/inventory/
done
# Attente que les instances soient prêtes
echo "Attente de la disponibilité des instances..."
sleep 60
# Déploiement Ansible
echo "Configuration des serveurs avec Ansible..."
cd ../ansible
ansible-playbook -i inventory/hosts playbooks/site.yml
# Vérification finale
echo "Vérification du déploiement..."
echo "Application accessible à : http://$ALB_DNS"
curl -f "http://$ALB_DNS" || echo "Attention : L'application n'est pas encore accessible"
echo "=== Déploiement terminé ==="