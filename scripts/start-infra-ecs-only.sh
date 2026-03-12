#!/bin/bash
set -e

# Script SEGURO para encender SOLO ECS de Zenova
# Asume que RDS y Redis ya están activos

REGION="us-east-1"
ECS_CLUSTER="quotezen-dev-backend"
ECS_SERVICE="quotezen-dev-backend"

echo "========================================"
echo "🟢 ENCENDIENDO SOLO ECS DE ZENOVA"
echo "========================================"
echo ""

# Encender ECS Service
echo "1️⃣ Iniciando ECS Service..."
aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --desired-count 1 \
  --region "$REGION" \
  --no-cli-pager

echo "✅ ECS Service iniciado (desired count = 1)"
echo ""

# Verificar estado del servicio
echo "2️⃣ Esperando a que la tarea de ECS esté corriendo..."
sleep 10

RUNNING_COUNT=$(aws ecs describe-services \
  --cluster "$ECS_CLUSTER" \
  --services "$ECS_SERVICE" \
  --region "$REGION" \
  --query 'services[0].runningCount' \
  --output text)

echo "   Tareas corriendo: $RUNNING_COUNT"

if [ "$RUNNING_COUNT" == "1" ]; then
  echo "✅ Servicio ECS corriendo correctamente"
else
  echo "⚠️  Servicio ECS aún iniciando, verifica en la consola"
fi
echo ""

# Obtener endpoint del ALB
echo "3️⃣ Obteniendo endpoint del servicio..."
ALB_DNS=$(aws elbv2 describe-load-balancers \
  --region "$REGION" \
  --query 'LoadBalancers[?LoadBalancerName==`quotezen-dev-backend-alb`].DNSName' \
  --output text)

echo ""
echo "========================================"
echo "✅ ECS ENCENDIDO"
echo "========================================"
echo ""
echo "Servicios activos:"
echo "  ✅ ECS: 1 tarea corriendo"
echo "  🟢 RDS: Activo (no modificado)"
echo "  🟢 Redis: Activo (no modificado)"
echo ""
echo "Endpoint del servicio:"
echo "  🌐 http://$ALB_DNS"
echo ""
echo "Verificar salud del servicio:"
echo "  curl http://$ALB_DNS/health"
echo ""
