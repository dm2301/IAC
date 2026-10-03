# Entornos DEV y QA

Dos entornos aislados con tres contenedores en cadena: Frontend (nginx) -> Backend (node) -> Base de datos (postgresql), aprovisionados con Terraform (provider `docker`) y workspaces separados.

## Requisitos

- Terraform >= 1.5
- Docker en ejecucion
- Archivos `.env.dev` y `.env.qa` locales (partir de `.env.example`)

## Inicializacion (una vez)

```
cd terraform
terraform init
terraform workspace new dev
terraform workspace new qa
```

## Entorno DEV

```
cd terraform
terraform workspace select dev
terraform apply
```

Verificar:

```
terraform output
curl http://localhost:4002/
```

Prueba: http://localhost:4001

Apagar:

```
terraform destroy
```

## Entorno QA

```
cd terraform
terraform workspace select qa
terraform apply
```

Verificar:

```
terraform output
curl http://localhost:5002/
```

Prueba: http://localhost:5001

Apagar:

```
terraform destroy
```

## Puertos

| Entorno | Frontend | Backend | PostgreSQL |
|---------|----------|---------|------------|
| DEV     | 4001     | 4002    | 4003       |
| QA      | 5001     | 5002    | 5003       |
