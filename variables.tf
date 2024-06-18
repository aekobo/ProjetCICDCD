# Définition des variables nécessaires
variable "docker_image" {
  description = "Docker image to use for the containers"
  type        = string
  default     = "fredericeducentre/ubuntu-ssh"
}