# Documentation Utilisateur

## Architecture

Description de l'architecture déployée par Terraform :

- **Un réseau principal connecté à un VPC :**
    - **Subnet public** : utilisé pour héberger le bastion et le service NAT.
    - **Subnet privé** : utilisé pour héberger les machines virtuelles (VM) de l’application web.

- **Les principaux services :**
    1. **Bastion** : point d’entrée sécurisé pour les connexions SSH vers les ressources en subnet privé.
    2. **Service NAT (Network Address Translation)** : permet aux VM privées d’accéder à Internet sans être directement
       exposées.
    3. **Load Balancer** : répartit le trafic entrant entre les VM, garantissant haute disponibilité et redondance.

---

## Étapes pas-à-pas

### 1. Préparation et application de Terraform

1. **Configuration des variables :**
    - Configurez vos credentials outscale
        - Ouvrez le fichier `terraform.tfvars` et configurez vos clés d’accès en rajoutant des variables nommées
          `access_key_id` et `secret_key_id`
        - Ou bien, configurez les variables d’environnement `TF_VAR_access_key_id` et `TF_VAR_secret_key_id`
    - Assurez-vous qu’un fichier **priv_key.pem** (clée privée RSA) existe dans le répertoire du projet. Ce fichier sera
      utilisé pour créer la clé publique associée qui permettra l’accès SSH au bastion et aux VM web.

2. **Initialiser Terraform :**
   Depuis le répertoire racine du projet, exécutez la commande suivante :
   ```bash
   terraform init
   ```

3. **Validation de la configuration :**
   Vérifiez que le plan Terraform est correct et prêt à être appliqué :
   ```bash
   terraform plan
   ```

4. **Appliquer le déploiement :**
   Lancer la création des ressources sur Outscale :
   ```bash
   terraform apply
   ```
   _Remarque : Saisissez "yes" lorsque Terraform demande confirmation._

---

### 2. Connexion à la machine bastion

1. **Récupération de l’adresse IP publique du bastion :**
   Apres l'exécution de la commande `terraform apply`, l'adresse IP publique du bastion est disponible dans les outputs
   Terraform sous le nom `bastion_public_ip`.

2. **Connexion SSH au bastion :**
   À partir de votre terminal, utilisez la commande suivante pour établir la connexion SSH :
   ```bash
   ssh -i ./priv_key.pem outscale@<bastion_public_ip>
   ```

3. **Accès aux VM privées :**
   Depuis le bastion, vous pouvez accéder aux adresses IP privées des VM déployées dans le subnet privé.
   Les adresses IP privées des VM web sont disponibles dans les outputs Terraform sous le nom `web_private_ips`.

---

### 3. Vérification de l’état de l’application web

1. **Récupération de l’adresse IP publique du Load Balancer :**
   L'IP publique du load balancer est disponible dans les outputs Terraform sous le nom `lb_public_ip`.

2. **Vérification à l’aide d’un navigateur ou de la commande curl :**
   Pour vérifier que l’application est déployée et en ligne, procédez comme suit :
    - Exemple avec un navigateur :
      Ouvrez un navigateur et entrez cette URL : `http://<lb_public_ip>`
    - Exemple avec curl :
      ```bash
      curl http://<lb_public_ip>
      ```
   Une page affichant `VM Web` et l’index correspondant de la VM web doit être visible.
   Rafrachissez la page, ou répétez la commande curl pour vérifier que le Load Balancer répartit le trafic entre les VM
   web.
   Vous devriez voir apparaitre les indices 0 et 1, correspondant aux deux VM web déployées.

---

## Concepts Clés

### **1. Bastion**

Une machine bastion est une passerelle qui permet de sécuriser les connexions SSH vers les machines privées. Elle limite
les expositions au réseau public, réduisant ainsi les vecteurs d'attaques éventuels.
La machine bastion est la seule machine du réseau à être directement accessible depuis l’extérieur.

### **2. NAT (Network Address Translation)**

Le service NAT permet aux machines dans le subnet privé (comme les VM web) d’obtenir un accès à Internet, tout en les
cachant depuis l’extérieur. Cela sécurise leurs communications tout en permettant des mises à jour ou la transmission de
données.
Le service utilise de la ré-écriture d'addresse IP dans les paquets sortants et entrants pour permettre aux machines
privées d'accéder à Internet de manière transparente, mais avec une adresse IP publique unique (celle du NAT).

### **3. Load Balancer (Équilibreur de charge)**

Il agit comme un distributeur pour diviser les requêtes entrantes sur plusieurs VM web, augmentant ainsi la capacité et
la disponibilité.
L'ajout d'un "Health-check", une vérification de l'état d'une des VM web, permet de s'assurer que le trafic est dirigé
vers des VM web en état de fonctionnement.
