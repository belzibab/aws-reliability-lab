# SLO policy — aws-reliability-lab

## SLOs definidos

| SLO | Objetivo | Ventana |
|-----|----------|---------|
| Availability | 99.9% | 30 días |
| Latency p99 | < 2s | 30 días |
| Error rate | < 0.1% | 30 días |

## Error budget

Con un objetivo de 99.9% de availability en 30 días:
- Budget total: 43.2 minutos de downtime permitido
- Burn rate de alerta: 5x

## Política de error budget

| Estado del budget | Acción |
|-------------------|--------|
| > 50% restante | Deployments normales permitidos |
| 25-50% restante | Deployments solo con aprobación del tech lead |
| < 25% restante | Freeze de deployments — solo hotfixes |
| 0% restante | Freeze total — foco en reliability |

## Alertas configuradas

- `alb-5xx-errors` — más de 10 errores 5xx por minuto
- `alb-latency-p99` — latencia p99 supera 2 segundos
- `ecs-running-tasks` — tareas corriendo por debajo de 1
