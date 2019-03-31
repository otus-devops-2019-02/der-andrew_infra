terraform {
  # Версия terraform
  required_version = "0.11.11"
}
provider "google" {
  # Версия провайдера
  version = "2.0.0"

  # ID проекта
  project = "infra-451193"

  region = "europe-west-1"
}
