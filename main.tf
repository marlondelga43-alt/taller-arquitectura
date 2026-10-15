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

# Rangos de origen permitidos para HTTP. Por defecto solo red privada.
# Para una prueba desde tu equipo, reemplaza el valor por tu IP con /32.
# Nunca uses 0.0.0.0/0 sin una justificación documentada.
variable "allowed_source_ranges" {
  description = "Rangos CIDR autorizados a conectarse al puerto 80"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# 2. Una regla de firewall para permitir tráfico web (HTTP) solo desde rangos autorizados
resource "google_compute_firewall" "default" {
  name    = "taller-firewall-allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"] # Puerto HTTP
  }
  source_ranges = var.allowed_source_ranges
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

  # Sin access_config: la VM no tiene IP pública. Se accede por un balanceador
  # de carga o por IAP, no directamente desde internet.
  network_interface {
    network = google_compute_network.vpc_network.name
  }

  # Bloquea las llaves SSH a nivel de proyecto; solo se usan llaves de la instancia.
  metadata = {
    block-project-ssh-keys = "TRUE"
  }
}
