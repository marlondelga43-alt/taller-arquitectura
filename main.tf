# Archivo: main.tf
#
# Configuración de Terraform para el Taller de Arquitectura
# ¡OJO! Esto es solo para demostración en Cloud Shell.
# No creará recursos reales a menos que se aplique (no lo haremos).

terraform {
  required_providers {
    # Usaremos el proveedor de Google Cloud
    google = {
      source  = "hashicorp/google"
      version = "5.10.0"
    }
  }
}

provider "google" {
  project = "tu-proyecto-de-gcloud" # Esto es solo un placeholder
  region  = "us-central1"
  zone    = "us-central1-c"
}

# Definición de "infraestructura como código"
# 1. Una red virtual para nuestra app
resource "google_compute_network" "vpc_network" {
  name                    = "taller-arquitectura-vpc"
  auto_create_subnetworks = true
}

# 2. Una regla de firewall para permitir tráfico web (HTTP)
resource "google_compute_firewall" "default" {
  name    = "taller-firewall-allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"] # Puerto HTTP
  }
  source_ranges = ["0.0.0.0/0"] # Permitir desde cualquier IP
}

# 3. Un servidor web (máquina virtual)
resource "google_compute_instance" "web_server" {
  name         = "eventflow-web-server"
  machine_type = "e2-micro" # Una máquina pequeña y barata
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      # Asigna una IP pública (efímera)
    }
  }
}
