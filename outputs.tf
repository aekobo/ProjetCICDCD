output "jenkins_url" {
  value = "http://${docker_container.jenkinsserver.name}:8082"
}

output "sonarqube_url" {
  value = "http://${docker_container.sonarqubeserver.name}:9000"
}

output "app_url" {
  value = "http://${docker_container.app.name}:8081"
}
