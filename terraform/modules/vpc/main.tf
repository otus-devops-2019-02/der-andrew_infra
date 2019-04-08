resource "google_compute_firewall" "firewall_ssh" {
  name        = "default-allow-ssh-${var.inst_suff}"
  network     = "default"
  description = "Allow ssh from any"
  priority    = "65534"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.source_ranges}"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default-${var.inst_suff}"
  network = "default"

  allow {
    protocol = "tcp"

    ports = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default-${var.inst_suff}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  source_tags = ["reddit-app"]
  target_tags = ["reddit-db"]
}
