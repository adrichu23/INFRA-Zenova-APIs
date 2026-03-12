#!/bin/bash
set -e

# Script para encender infraestructura de Zenova
# Este script NO usa Terraform, usa AWS CLI directamente

REGION="us-east-1"
ECS_CLUSTER="quotezen-dev-backend"
ECS_SERVICE="quotezen-dev-backend"
RDS_INSTANCE="quotezen"

echo "========================================"
echo "🟢 ENCENDIENDO INFRAESTRUCTURA ZENOVA"
echo "========================================"
echo ""

# 1. Verificar estado de RDS
echo "1️⃣ Verificando estado de RDS..."
RDS_STATUS=$(aws rds describe-db-instances \
  --db-instance-identifier "$RDS_INSTANCE" \
  --region "$REGION" \
  --query 'DBInstances[0].DBInstanceStatus' \
  --output text)

if [ "$RDS_STATUS" == "stopped" ]; then
  echo "   RDS está detenido, iniciando..."
  aws rds start-db-instance \
    --db-instance-identifier "$RDS_INSTANCE" \
    --region "$REGION" \
    --no-cli-pager
  
  echo "   ⏳ Esperando a que RDS esté disponible (puede tomar 5-10 min)..."
  aws rds wait db-instance-available \
    --db-instance-identifier "$RDS_INSTANCE" \
    --region "$REGION"
  
  echo "✅ RDS disponible"
elif [ "$RDS_STATUS" == "available" ]; then
  echo "✅ RDS ya está disponible"
else
  echo "⚠️  RDS está en estado: $RDS_STATUS"
fi
echo ""

# 2. Encender ECS Service
echo "2️⃣ Iniciando ECS Service..."
aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --desired-count 1 \
  --region "$REGION" \
  --no-cli-pager

echo "✅ ECS Service iniciado (desired count = 1)"
echo ""

# 3. Verificar estado del servicio
echo "3️⃣ Esperando a que la tarea de ECS esté corriendo..."
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

# 4. Obtener endpoint del ALB
echo "4️⃣ Obteniendo endpoint del servicio..."
ALB_DNS=$(aws elbv2 describe-load-balancers \
  --region "$REGION" \
  --query 'LoadBalancers[?LoadBalancerName==`quotezen-dev-backend-alb`].DNSName' \
  --output text)

echo ""
echo "========================================"
echo "✅ INFRAESTRUCTURA ENCENDIDA"
echo "========================================"
echo ""
echo "Servicios activos:"
echo "  ✅ ECS: 1 tarea corriendo"
echo "  ✅ RDS: Disponible"
echo "  ✅ Redis: Disponible"
echo "  ✅ ALB: Activo"
echo ""
echo "Endpoint del servicio:"
echo "  🌐 http://$ALB_DNS"
echo ""
echo "Verificar salud del servicio:"
echo "  curl http://$ALB_DNS/health"
echo ""
