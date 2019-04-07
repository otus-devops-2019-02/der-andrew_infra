terraform {
  # Версия terraform
  required_version = ">=0.11,<0.12"
}

provider "google" {
  # Версия провайдера
  version = "2.0.0"

  # ID проекта
  project = "${var.project}"

  region = "${var.region}"
}

resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать static IP для доступа из Интернет
    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    # путь до публичного ключа
    ssh-keys = "appuser:${file("${var.public_key_path}")}"
  }

  connection {
    type  = "ssh"
    user  = "appuser"
    agent = false

    # путь до приватного ключа
    private_key = "${file("${var.private_key_path}")}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}

resource "google_compute_firewall" "firewall_ssh" {
  name    = "default-allow-ssh"
  network = "default"
  description = "Allow ssh from any"
  priority = "65534"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_project_metadata_item" "default" {
  key   = "appuser1"
  value = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQDJZCNT32ijx2RERZ8vz58QM4twAbByjH1aZ9NRPml9+40uJjvP0kpBz34FCDAkf8YEW6Jtfj1hpwPfyTYewTXkN1PdUFF4inkSrnOwM5BcOe8iC7S+gqhRKeZskY1VfGOELFYd+kd/S4JOE1/4z1L+3g82muBa11/RJ6qWKgkzuYLMTrXIXfkFZ2Q7WwMMZUtsr1dSsrQBYP2GkOKrGQWpKH7IAdkC1uNcUGAu3Qjk4i8zmCkGLJmwyuFL0uYVHLPDpip0guorzWLRbRyj8Vbabrv1+P8JMdVe8J+Bnj8vKsv07vYJCN1KCsZYfJidDAl0BTaqsiNIaMBFJTaXkR appuser1"
  key   = "appuser2"
  value = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQDJZCNT32ijx2RERZ8vz58QM4twAbByjH1aZ9NRPml9+40uJjvP0kpBz34FCDAkf8YEW6Jtfj1hpwPfyTYewTXkN1PdUFF4inkSrnOwM5BcOe8iC7S+gqhRKeZskY1VfGOELFYd+kd/S4JOE1/4z1L+3g82muBa11/RJ6qWKgkzuYLMTrXIXfkFZ2Q7WwMMZUtsr1dSsrQBYP2GkOKrGQWpKH7IAdkC1uNcUGAu3Qjk4i8zmCkGLJmwyuFL0uYVHLPDpip0guorzWLRbRyj8Vbabrv1+P8JMdVe8J+Bnj8vKsv07vYJCN1KCsZYfJidDAl0BTaqsiNIaMBFJTaXkR appuser1"
}
