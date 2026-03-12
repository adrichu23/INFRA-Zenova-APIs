#!/bin/bash
set -e

# Script para ELIMINAR COMPLETAMENTE la infraestructura de Zenova
# ⚠️ ADVERTENCIA: Este script ELIMINA PERMANENTEMENTE todos los recursos
# ⚠️ Asegúrate de hacer BACKUP de las bases de datos antes de ejecutar

REGION="us-east-1"
ECS_CLUSTER="quotezen-dev-backend"
ECS_SERVICE="quotezen-dev-backend"
RDS_INSTANCE="quotezen"
REDIS_CLUSTER="quotezen-dev-redis-001"

echo "========================================"
echo "🔴⚠️  ELIMINACIÓN COMPLETA DE INFRAESTRUCTURA"
echo "========================================"
echo ""
echo "Este script eliminará PERMANENTEMENTE:"
echo "  - ECS Cluster y Service"
echo "  - RDS PostgreSQL (quotezen)"
echo "  - Redis ElastiCache"
echo "  - ALB"
echo "  - VPC y subnets"
echo ""
echo "⚠️  ASEGÚRATE DE HACER BACKUP DE LAS BASES DE DATOS PRIMERO"
echo ""
read -p "¿Estás seguro de continuar? (escribe 'SI' para confirmar): " CONFIRM

if [ "$CONFIRM" != "SI ELIMINAR TODO" ]; then
  echo "❌ Operación cancelada por seguridad"
  echo "   Para continuar, debes escribir exactamente: SI ELIMINAR TODO"
  exit 1
fi

echo ""
echo "Iniciando eliminación..."
echo ""

# 1. Eliminar ECS Service
echo "1️⃣ Eliminando ECS Service..."
aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --desired-count 0 \
  --region "$REGION" \
  --no-cli-pager

sleep 5

aws ecs delete-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --force \
  --region "$REGION" \
  --no-cli-pager

echo "✅ ECS Service eliminado"
echo ""

# 2. Eliminar ECS Cluster
echo "2️⃣ Eliminando ECS Cluster..."
aws ecs delete-cluster \
  --cluster "$ECS_CLUSTER" \
  --region "$REGION" \
  --no-cli-pager

echo "✅ ECS Cluster eliminado"
echo ""

# 3. Crear snapshot de RDS antes de eliminar
echo "3️⃣ Creando snapshot de RDS..."
SNAPSHOT_ID="${RDS_INSTANCE}-final-snapshot-$(date +%Y%m%d-%H%M%S)"
aws rds create-db-snapshot \
  --db-instance-identifier "$RDS_INSTANCE" \
  --db-snapshot-identifier "$SNAPSHOT_ID" \
  --region "$REGION" \
  --no-cli-pager

echo "✅ Snapshot creado: $SNAPSHOT_ID"
echo ""

# 4. Eliminar RDS
echo "4️⃣ Eliminando RDS Instance..."
aws rds delete-db-instance \
  --db-instance-identifier "$RDS_INSTANCE" \
  --skip-final-snapshot \
  --region "$REGION" \
  --no-cli-pager

echo "✅ RDS Instance eliminado"
echo ""

# 5. Eliminar Redis
echo "5️⃣ Eliminando Redis ElastiCache..."
aws elasticache delete-cache-cluster \
  --cache-cluster-id "$REDIS_CLUSTER" \
  --region "$REGION" \
  --no-cli-pager

echo "✅ Redis ElastiCache eliminado"
echo ""

# 6. Nota sobre recursos restantes
echo "⚠️  Recursos restantes que deben eliminarse manualmente desde la consola AWS:"
echo "   - ALB y Target Groups"
echo "   - VPC, Subnets, Internet Gateway, NAT Gateway"
echo "   - Security Groups"
echo "   - ECR repositories"
echo "   - Cognito User Pools"
echo "   - Secrets Manager secrets"
echo ""
echo "O usa Terraform para eliminar el resto:"
echo "   cd /Users/conker/git/zenova/zenova-infra"
echo "   terraform destroy -var-file=environments/dev.tfvars"
echo ""

echo "========================================"
echo "✅ RECURSOS PRINCIPALES ELIMINADOS"
echo "========================================"
echo ""
echo "Snapshot de RDS guardado como: $SNAPSHOT_ID"
echo ""
echo "Ahorro estimado: ~\$87-113/mes (costo completo)"
echo ""
