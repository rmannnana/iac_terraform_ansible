# iac_terraform_ansible
Ceci est un exemple de définition d'infrastructure cloud aws avec Terraform et Ansible

######################################################################################
###########  Structure du projet:  ###########
iac_terraform_ansible/
├── ansible/
│   ├── group_vars/
│   │   └── all/
│   │       └── vault.yml
│   └── playbooks/
│       ├── configure-webserver.yml
│       └── site.yml    # Playbook principal
├── group_vars/
├── host_vars/
├── inventories/
├── README.md
├── roles/
│   └── common/
│       └── tasks/
│           └── main.yml
├── scripts/
│   └── deploy.sh       # Script d'intégration
├── templates/
│   ├── index.html.j2
│   └── nginx-site.conf.j2
└── terraform/          # Infrastructure
    ├── backend.tf
    ├── infrastructure.tf
    └── main.tf


#######Commandes utiles:############


1. Déployer l'infrastructure avec Terraform :

        cd terraform

        # Initialisation
        terraform init

        # Vérification de la syntaxe
        terraform validate

        # Planification (voir ce qui sera créé)
        terraform plan -var="db_password=VotreMotDePasse123!"

        # Application (création réelle)
        terraform apply -var="db_password=VotreMotDePasse123!"


2. Récupérer les outputs pour Ansible :

        cd ../ansible

        # Tester la connexion
        ansible -i inventories/hosts webservers -m ping

        # Lancer le playbook
        ansible-playbook -i inventories/hosts playbooks/site.yml --ask-vault-pass


3. Configurer avec Ansible :
        cd ../ansible

        # Tester la connexion
        ansible -i inventories/hosts webservers -m ping

        # Lancer le playbook
        ansible-playbook -i inventories/hosts playbooks/site.yml --ask-vault-pass


Ou utiliser le script de déploiement  :

        chmod +x ../scripts/deploy.sh
        ../scripts/deploy.sh

