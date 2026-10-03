# Entornos DEV y QA

Dos entornos aislados con tres contenedores en cadena: Frontend (nginx) -> Backend (node) -> Base de datos (postgresql).

## Entorno DEV

Levantar:

```
docker compose -f docker-compose.dev.yml --env-file .env.dev up -d
```

Verificar:

```
docker compose -f docker-compose.dev.yml --env-file .env.dev ps
```

Prueba: http://localhost:4001

Apagar:

```
docker compose -f docker-compose.dev.yml --env-file .env.dev down
```

## Entorno QA

Levantar:

```
docker compose -f docker-compose.qa.yml --env-file .env.qa up -d
```

Verificar:

```
docker compose -f docker-compose.qa.yml --env-file .env.qa ps
```

Prueba: http://localhost:5001

Apagar:

```
docker compose -f docker-compose.qa.yml --env-file .env.qa down
```
