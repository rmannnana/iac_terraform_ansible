#!/bin/bash
# Script de deploiement complet
set -e
echo "=== Deploiement de l'infrastructure web ==="
# Variables
ENVIRONMENT=${1:-dev}
TERRAFORM_DIR="./terraform"
ANSIBLE_DIR="./ansible"
# Validation des prerequis
echo "Verification des prerequis..."
command -v terraform >/dev/null 2>&1 || { echo "Terraform requis mais non installe."; exit 1; }
command -v ansible >/dev/null 2>&1 || { echo "Ansible requis mais non installe."; exit 1; }
# Deploiement Terraform
echo "Deploiement de l'infrastructure avec Terraform..."
cd $TERRAFORM_DIR
terraform init
terraform plan -var="environment=$ENVIRONMENT"
terraform apply -var="environment=$ENVIRONMENT" -auto-approve
# Recuperation des IPs pour l'inventaire Ansible
echo "Generation de l'inventaire Ansible..."
INSTANCE_IPS=$(terraform output -json instance_ips | jq -r '.[]')
ALB_DNS=$(terraform output -raw alb_dns_name)
# Creation de l'inventaire dynamique
cat > ../ansible/inventory/hosts << EOF
[webservers]
EOF
for ip in $INSTANCE_IPS; do
echo "$ip ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/my-key-pair.pem" >> ../ansible/inventory/
done
# Attente que les instances soient prêtes
echo "Attente de la disponibilite des instances..."
sleep 60
# Deploiement Ansible
echo "Configuration des serveurs avec Ansible..."
cd ../ansible
ansible-playbook -i inventory/hosts playbooks/site.yml
# Verification finale
echo "Verification du deploiement..."
echo "Application accessible a : http://$ALB_DNS"
curl -f "http://$ALB_DNS" || echo "Attention : L'application n'est pas encore accessible"
echo "=== Deploiement termine ==="