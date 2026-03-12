# Infraestructura Terraform — Zenova

Este repositorio gestiona la infraestructura como código (IaC) del proyecto **Zenova** en AWS usando Terraform.

- **Cuenta AWS:** `060795906495`
- **Región:** `us-east-1`
- **Ambiente:** `dev`
- **Estado:** Destruido (última operación: 2026-03-17)

---

## Arquitectura actual

Recursos gestionados por Terraform:

- **VPC** — `quotezen-dev-vpc` — Red aislada con 3 subnets públicas, 3 privadas y NAT Gateway
- **ECR** — `quotezen-dev-backend` — Almacena imágenes Docker
- **ALB** — `quotezen-dev-backend-alb` — Balanceo de carga HTTP (idle timeout: 120s)
- **ECS** — `quotezen-dev-backend` — Cluster Fargate (256 CPU / 512 MB, 1 tarea)
- **Redis** — `quotezen-dev-redis` — ElastiCache cache.t3.micro con AUTH token, transit encryption y credenciales en Secrets Manager

### Recursos excluidos de Terraform

- **RDS PostgreSQL** (`quotezen`) — Compartido con el proyecto Quotezen. Módulo comentado en `main.tf`, no es gestionado por Terraform.

---

## Requisitos previos

- Terraform >= 0.14.9 (probado con v1.14.6)
- AWS CLI configurado con credenciales válidas
- Docker (para desplegar la aplicación)
- Acceso al bucket S3 `quotezen-terraform-poc-infra-deploy` (backend de estado)

---

## Estructura del proyecto

```
zenova-infra/
├── environments/
│   └── dev.tfvars              # Variables del ambiente dev
├── modules/
│   ├── alb/                    # Application Load Balancer
│   ├── cloudfront/             # CloudFront (definido, no activo)
│   ├── cognito/                # Cognito (definido, no activo)
│   ├── ecr/                    # Elastic Container Registry
│   ├── ecs/                    # Elastic Container Service (Fargate)
│   ├── rds/                    # RDS (definido, excluido por seguridad)
│   ├── redis/                  # ElastiCache Redis (AUTH token + Secrets Manager)
│   ├── s3/                     # S3 (definido, no activo)
│   └── vpc/                    # Virtual Private Cloud
├── scripts/
│   ├── start-infra.sh          # Encender infra completa (AWS CLI)
│   ├── start-infra-ecs-only.sh # Encender solo ECS (seguro)
│   ├── stop-infra.sh           # Apagar infra (AWS CLI, parcial)
│   ├── stop-infra-ecs-only.sh  # Apagar solo ECS (seguro)
│   └── destroy-infra.sh        # Destruir todo
├── templates/
│   ├── ecs/                    # Container definitions
│   └── iam/                    # Políticas IAM
├── main.tf                     # Configuración principal
├── variables.tf                # Variables declaradas
├── INFRASTRUCTURE_INVENTORY.md # Inventario detallado de recursos
└── README.md                   # Este archivo
```

---

## Uso básico


### Set aws credentials

```bash
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""

```


### Inicializar Terraform

```bash
terraform init
```

### Ver qué cambiaría (solo lectura, no modifica nada)

```bash
terraform plan -var-file=environments/dev.tfvars
```

### Aplicar cambios

```bash
terraform apply -var-file=environments/dev.tfvars
```

---

## Encender y apagar la infraestructura

### Opción 1: Terraform destroy/apply

Elimina y recrea toda la infraestructura. Mayor ahorro pero requiere redesplegar la app.

#### Apagar

```bash
terraform destroy -var-file=environments/dev.tfvars
```

Elimina: VPC, ECR, ALB, ECS, Redis (incluyendo AUTH token y Secrets Manager), NAT Gateway y recursos asociados.
**NO toca:** RDS (excluido de Terraform).

#### Encender

```bash
# 1. Recrear infraestructura (~10-15 min)
terraform apply -var-file=environments/dev.tfvars

# 2. Desde el proyecto de zenova ejecutar el script
./deploy_clean.sh
```

ECS levantará la tarea automáticamente la última versión del codigo donde se ejecuta el script.

**Tiempos estimados:** Apagar ~2-3 min | Prender (infra + app) ~15-20 min


