#!/bin/bash
set -e

# Script SEGURO para apagar SOLO ECS de Zenova
# NO toca RDS (por si es compartido con Quotezen-app)
# NO toca Redis

REGION="us-east-1"
ECS_CLUSTER="quotezen-dev-backend"
ECS_SERVICE="quotezen-dev-backend"

echo "========================================"
echo "🔴 APAGANDO SOLO ECS DE ZENOVA"
echo "========================================"
echo ""
echo "Este script SOLO apaga:"
echo "  ✅ ECS Service (contenedores de Zenova)"
echo ""
echo "NO toca:"
echo "  🟢 RDS (por seguridad, puede ser compartido)"
echo "  🟢 Redis (puede ser usado por Quotezen)"
echo "  🟢 ALB, VPC, etc."
echo ""

# Detener ECS Service (ahorro ~$12-15/mes)
echo "1️⃣ Deteniendo ECS Service..."
aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --desired-count 0 \
  --region "$REGION" \
  --no-cli-pager

echo "✅ ECS Service detenido (desired count = 0)"
echo ""

echo "========================================"
echo "✅ ECS APAGADO (VERSIÓN SEGURA)"
echo "========================================"
echo ""
echo "Recursos apagados:"
echo "  ✅ ECS: 0 tareas corriendo"
echo ""
echo "Recursos NO tocados (por seguridad):"
echo "  🟢 RDS: Sigue activo"
echo "  🟢 Redis: Sigue activo"
echo "  🟢 ALB: Sigue activo"
echo ""
echo "Ahorro estimado: ~\$12-15/mes (solo ECS)"
echo "Costo restante: ~\$75-98/mes"
echo ""
echo "Para encender ECS de nuevo:"
echo "  ./scripts/start-infra-ecs-only.sh"
