terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {}

locals {
  nombre_entorno = terraform.workspace

  puertos = {
    dev = { frontend = 4001, backend = 4002, bd = 4003 }
    qa  = { frontend = 5001, backend = 5002, bd = 5003 }
  }

  entorno = local.puertos[local.nombre_entorno]
  raiz    = abspath("${path.module}/..")

  env_lineas = [
    for linea in split("\n", file("${local.raiz}/.env.${local.nombre_entorno}")) :
    trimspace(linea)
    if length(trimspace(linea)) > 0 && !startswith(trimspace(linea), "#")
  ]

  env = {
    for linea in local.env_lineas :
    trimspace(element(split("=", linea), 0)) => trimspace(
      join("=", slice(split("=", linea), 1, length(split("=", linea))))
    )
  }
}

resource "docker_network" "red" {
  name = "red-${local.nombre_entorno}"

  lifecycle {
    precondition {
      condition     = contains(["dev", "qa"], local.nombre_entorno)
      error_message = "Selecciona un workspace valido: terraform workspace select dev|qa."
    }
  }
}

resource "docker_volume" "datos" {
  name = "datos-${local.nombre_entorno}"
}

resource "docker_image" "nginx" {
  name = "nginx:1.27-alpine"
}

resource "docker_image" "node" {
  name = "node:20-alpine"
}

resource "docker_image" "postgres" {
  name = "postgres:16-alpine"
}

resource "docker_container" "bd" {
  name  = "bd-${local.nombre_entorno}"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_USER=${local.env["POSTGRES_USER"]}",
    "POSTGRES_PASSWORD=${local.env["POSTGRES_PASSWORD"]}",
    "POSTGRES_DB=${local.env["POSTGRES_DB"]}",
  ]

  ports {
    internal = 5432
    external = local.entorno.bd
  }

  volumes {
    volume_name    = docker_volume.datos.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.red.name
  }

  lifecycle {
    ignore_changes = [network_mode]
  }
}

resource "docker_container" "api" {
  name        = "api-${local.nombre_entorno}"
  image       = docker_image.node.image_id
  working_dir = "/app"
  command     = ["sh", "-c", "npm install --omit=dev && node index.js"]

  env = [
    "POSTGRES_HOST=bd-${local.nombre_entorno}",
    "POSTGRES_PORT=5432",
    "POSTGRES_USER=${local.env["POSTGRES_USER"]}",
    "POSTGRES_PASSWORD=${local.env["POSTGRES_PASSWORD"]}",
    "POSTGRES_DB=${local.env["POSTGRES_DB"]}",
    "PORT=3000",
  ]

  ports {
    internal = 3000
    external = local.entorno.backend
  }

  mounts {
    target = "/app"
    source = "${local.raiz}/backend"
    type   = "bind"
  }

  networks_advanced {
    name = docker_network.red.name
  }

  depends_on = [docker_container.bd]

  lifecycle {
    ignore_changes = [network_mode]
  }
}

resource "docker_container" "web" {
  name  = "web-${local.nombre_entorno}"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = local.entorno.frontend
  }

  mounts {
    target    = "/usr/share/nginx/html"
    source    = "${local.raiz}/frontend"
    type      = "bind"
    read_only = true
  }

  networks_advanced {
    name = docker_network.red.name
  }

  lifecycle {
    ignore_changes = [network_mode]
  }
}
