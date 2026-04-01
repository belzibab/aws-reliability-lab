# Regional failover runbook

## Objetivo
Documentar el proceso de failover manual de us-east-1 a us-west-2 en caso de outage regional.

## Indicadores de activación
- Route53 health check en estado UNHEALTHY por más de 3 minutos
- Alarma `alb-5xx-errors` activa con más de 50 errores/min
- ECS running tasks = 0 por más de 2 minutos

## Pasos

### 1. Verificar el incidente (2 min)
```bash
# Verificar estado del health check
aws route53 get-health-check-status \
  --health-check-id HEALTH_CHECK_ID \
  --region us-east-1

# Verificar tareas ECS corriendo
aws ecs describe-services \
  --cluster aws-reliability-lab-dev-cluster \
  --services aws-reliability-lab-dev-service \
  --region us-east-1 \
  --query "services[0].{running:runningCount,desired:desiredCount}"
```

### 2. Activar región de failover (5 min)
```bash
# Aplicar infraestructura en us-west-2
cd terraform/us-west-2
terraform apply -auto-approve
```

### 3. Verificar recuperación (3 min)
```bash
# Confirmar que la app responde en us-west-2
curl http://ALB_DNS_US_WEST_2/health
```

### 4. Comunicación
- Notificar al equipo via Slack: canal #incidents
- Abrir postmortem en Confluence

## RTO objetivo: 10 minutos
## RPO objetivo: 5 minutos

## Post-incidente
- Completar postmortem dentro de 48 horas
- Revisar error budget en dashboard de CloudWatch
- Actualizar este runbook si el proceso cambió
