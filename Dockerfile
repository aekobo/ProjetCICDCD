FROM hashicorp/terraform:latest

# Installez wget et unzip si nécessaire
RUN apk add --no-cache wget unzip
