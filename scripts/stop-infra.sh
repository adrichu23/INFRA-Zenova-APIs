#!/bin/bash
set -e

# Script para apagar infraestructura de Zenova y reducir costos
# Este script NO usa Terraform, usa AWS CLI directamente

# ⚠️  ADVERTENCIA: Este script apaga la instancia RDS "quotezen"
# Si esta instancia contiene TAMBIÉN la base de datos de Quotezen-app,
# esto afectará a AMBOS proyectos (Zenova y Quotezen).
# VERIFICA antes de ejecutar que esta instancia es SOLO para Zenova.

REGION="us-east-1"
ECS_CLUSTER="quotezen-dev-backend"
ECS_SERVICE="quotezen-dev-backend"
RDS_INSTANCE="quotezen"

echo "⚠️  ADVERTENCIA: Este script apagará la instancia RDS 'quotezen'"
echo "   Si Quotezen-app también usa esta instancia, AMBOS proyectos se verán afectados."
echo ""
read -p "¿Estás seguro de que esta instancia RDS es SOLO para Zenova? (escribe 'SI' para confirmar): " CONFIRM

if [ "$CONFIRM" != "SI" ]; then
  echo "❌ Operación cancelada"
  exit 1
fi

echo ""

echo "========================================"
echo "🔴 APAGANDO INFRAESTRUCTURA ZENOVA"
echo "========================================"
echo ""

# 1. Detener ECS Service (ahorro ~$12-15/mes)
echo "1️⃣ Deteniendo ECS Service..."
aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --desired-count 0 \
  --region "$REGION" \
  --no-cli-pager

echo "✅ ECS Service detenido (desired count = 0)"
echo ""

# 2. Detener RDS Instance (ahorro ~$15-18/mes)
echo "2️⃣ Deteniendo RDS Instance..."
aws rds stop-db-instance \
  --db-instance-identifier "$RDS_INSTANCE" \
  --region "$REGION" \
  --no-cli-pager

echo "✅ RDS Instance detenido (se reiniciará automáticamente en 7 días)"
echo ""

# 3. Redis NO se puede detener, solo eliminar
echo "⚠️  Redis ElastiCache NO se puede 'pausar', solo eliminar."
echo "   Para eliminar Redis (ahorro ~$12-15/mes pero PERMANENTE):"
echo "   aws elasticache delete-cache-cluster --cache-cluster-id quotezen-dev-redis-001 --region $REGION"
echo ""

echo "========================================"
echo "✅ INFRAESTRUCTURA PARCIALMENTE APAGADA"
echo "========================================"
echo ""
echo "Recursos apagados:"
echo "  ✅ ECS: 0 tareas corriendo"
echo "  ✅ RDS: Detenido (se reinicia automáticamente en 7 días)"
echo ""
echo "Recursos aún activos (generan costo):"
echo "  🟡 ALB: ~\$16-20/mes"
echo "  🟡 VPC/NAT Gateway: ~\$32-45/mes"
echo "  🟡 Redis: ~\$12-15/mes"
echo "  🟡 ECR: ~\$0.10/GB"
echo ""
echo "Ahorro estimado: ~\$27-33/mes (30-35% del total)"
echo "Costo restante: ~\$60-80/mes"
echo ""
echo "Para apagar completamente, ver: scripts/destroy-infra.sh"
