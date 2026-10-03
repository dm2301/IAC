output "frontend_url" {
  description = "URL de prueba del frontend"
  value       = "http://localhost:${local.entorno.frontend}"
}

output "backend_url" {
  description = "URL de prueba del backend"
  value       = "http://localhost:${local.entorno.backend}"
}

output "bd_puerto" {
  description = "Puerto host de PostgreSQL"
  value       = local.entorno.bd
}
