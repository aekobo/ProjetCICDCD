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
