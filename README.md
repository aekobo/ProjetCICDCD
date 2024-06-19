# ProjetCICDCD

Projet CI/CD/CD

Exécution du projet
Instructions pour Exécuter
1.	Téléchargez et installez Docker et Terraform si ce n'est pas déjà fait.
2.	Créez un fichier main.tf avec le code ci-dessus.
3.	Initialisez Terraform avec terraform init.
4.	Appliquez la configuration avec terraform apply.
Points à Vérifier
•	Si vous utilisez une image Docker privée, assurez-vous d'être authentifié avec docker login.
•	Si vous avez une image spécifique pour votre application, remplacez nginx:latest par l'image correcte.
Initialisation et validation 
 
Création du plan Terraform 
 
 
Application ou exécution  
 =======

Visualisation des 4 dockers crées(jenkinsserver, sonarqubeser, app & mysql)
$ docker ps
CONTAINER ID   IMAGE                 COMMAND                  CREATED        STATUS        PORTS                                              NAMES
299dfe59c964   dde0cca083bc          "/docker-entrypoint.…"   11 hours ago   Up 11 hours   0.0.0.0:8081->80/tcp                               app
86e0a5cd7cdf   4ba02798ce60          "/usr/sbin/sshd -D"      11 hours ago   Up 11 hours   0.0.0.0:2222->22/tcp, 0.0.0.0:8082->8080/tcp       jenkinsserver
6a21d903d597   5107333e08a8          "docker-entrypoint.s…"   11 hours ago   Up 11 hours   0.0.0.0:3306->3306/tcp, 33060/tcp                  mysql
21271716431f   4ba02798ce60          "/usr/sbin/sshd -D"      11 hours ago   Up 11 hours   0.0.0.0:9000->9000/tcp, 0.0.0.0:2223->22/tcp       sonarqubeserver
 =======
Les urls de connexions 
$ terraform output
app_url = "http://app:8081"
jenkins_url = "http://jenkinsserver:8082"
sonarqube_url = "http://sonarqubeserver:9000"
 =======
Application du code généré par le répository et le psuh 
$ git push -u origin main
Enumerating objects: 24, done.
Counting objects: 100% (24/24), done.
Delta compression using up to 8 threads
Compressing objects: 100% (17/17), done.
Writing objects: 100% (24/24), 6.68 MiB | 2.62 MiB/s, done.
Total 24 (delta 3), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (3/3), done.
To https://github.com/aekobo/ProjetCICDCD.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'. 
le psuh
 

Les IPs des dockers :
Jenskins :  172.19.0.3
Sonarqubeserver : 172.19.0. 4
App : 172.19.0.5
Mysql : 172.19.0.2

=====Les fichiers
a/ main.tf
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {}

# Pull de l'image Docker pour Ubuntu SSH
resource "docker_image" "ubuntu_ssh" {
  name = "fredericeducentre/ubuntu-ssh"
}

# Pull de l'image Docker pour MySQL
resource "docker_image" "mysql" {
  name = "mysql:5.7"
}

# Pull de l'image Docker pour l'application
resource "docker_image" "app" {
  name = "nginx:latest"  # Utilisez une image valide. Remplacez par l'image de votre application.
}

# Créer un réseau Docker commun
resource "docker_network" "ci_cd_network" {
  name = "ci_cd_network"
}

# Création de conteneur Docker pour Jenkins à partir de l'image Ubuntu SSH
resource "docker_container" "jenkinsserver" {
  depends_on = [docker_network.ci_cd_network, docker_image.ubuntu_ssh]
  name       = "jenkinsserver"
  image      = docker_image.ubuntu_ssh.image_id

  networks_advanced {
    name = docker_network.ci_cd_network.name
  }

  ports {
    internal = 22
    external = 2222  # Port externe pour la connexion SSH
  }
  ports {
    internal = 8080
    external = 8082  # Port externe pour Jenkins UI
  }
  memory = 1024
}

# Création de conteneur Docker pour SonarQube à partir de l'image Ubuntu SSH
resource "docker_container" "sonarqubeserver" {
  depends_on = [docker_network.ci_cd_network, docker_image.ubuntu_ssh]
  name       = "sonarqubeserver"
  image      = docker_image.ubuntu_ssh.image_id

  networks_advanced {
    name = docker_network.ci_cd_network.name
  }

  ports {
    internal = 22
    external = 2223  # Port externe pour la connexion SSH
  }
  ports {
    internal = 9000
    external = 9000  # Port externe pour SonarQube UI
  }
  memory = 2048
}

# Créer le conteneur MySQL
resource "docker_container" "mysql" {
  depends_on = [docker_network.ci_cd_network, docker_image.mysql]
  name       = "mysql"
  image      = docker_image.mysql.image_id

  networks_advanced {
    name = docker_network.ci_cd_network.name
  }

  env = [
    "MYSQL_ROOT_PASSWORD=yourpassword",
    "MYSQL_DATABASE=yourdatabase",
    "MYSQL_USER=youruser",
    "MYSQL_PASSWORD=yourpassword"
  ]

  ports {
    internal = 3306
    external = 3306
  }
}

# Créer le conteneur de l'application
resource "docker_container" "app" {
  depends_on = [docker_network.ci_cd_network, docker_container.mysql, docker_image.app]
  name       = "app"
  image      = docker_image.app.image_id

  networks_advanced {
    name = docker_network.ci_cd_network.name
  }

  env = [
    "DATABASE_HOST=mysql",
    "DATABASE_USER=youruser",
    "DATABASE_PASSWORD=yourpassword",
    "DATABASE_NAME=yourdatabase"
  ]

  ports {
    internal = 80
    external = 8081
  }
}

# Outputs
#output "jenkins_url" {
 # value = "http://${docker_container.jenkinsserver.name}:8082"
#}

#output "sonarqube_url" {
 # value = "http://${docker_container.sonarqubeserver.name}:9000"
#}

#output "app_url" {
 # value = "http://${docker_container.app.name}:8081"
#}

b/outputs.tf
output "jenkins_url" {
  value = "http://${docker_container.jenkinsserver.name}:8082"
}

output "sonarqube_url" {
  value = "http://${docker_container.sonarqubeserver.name}:9000"
}

output "app_url" {
  value = "http://${docker_container.app.name}:8081"
}


