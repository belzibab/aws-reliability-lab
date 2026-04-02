# aws-reliability-lab

A production-grade multi-region reliability platform on AWS, built to demonstrate: infrastructure as code, observability, SLO-driven operations, and chaos engineering.

![image alt](https://github.com/belzibab/belzibab/blob/8f2fd84d83e7c3789ee4c5af70e4d78c1555f31e/images/aws-reliability-lab-bg.png)

## Architecture

![image alt](https://github.com/belzibab/belzibab/blob/10dbc69b371856f8f29f812594c1257c2b837330/images/aws_reliability_lab_architecture.svg)

## Stack

| Layer | Technology |
|-------|-----------|
| IaC | Terraform 1.7 — modular, remote state on S3 + DynamoDB locking |
| Compute | ECS Fargate — serverless containers, no EC2 management |
| App | FastAPI (Python) — `/health`, `/metrics` (Prometheus), `/slow` |
| Database | RDS PostgreSQL 15 — private subnet, no public access |
| DNS | Route53 health checks — automatic failover detection |
| Observability | CloudWatch dashboards + SNS alarms + email notifications |
| CI/CD | GitHub Actions — OIDC auth, terraform plan on every push |
| Chaos | AWS FIS template — ECS task kill with stop condition |
| Security | tfsec + Checkov in pipeline, least-privilege IAM, private subnets |

## SLOs

| SLO | Target | Window |
|-----|--------|--------|
| Availability | 99.9% | 30 days |
| Latency p99 | < 2s | 30 days |
| Error rate | < 0.1% | 30 days |

Error budget policy: deployments freeze when budget drops below 25%. Full freeze at 0%. See [docs/slo-policy.md](docs/slo-policy.md).

## Repository structure
```
aws-reliability-lab/
├── terraform/
│   ├── modules/
│   │   ├── vpc/          # VPC, subnets, NAT gateway
│   │   ├── ecs/          # ECS Fargate, ALB, security groups
│   │   ├── rds/          # RDS PostgreSQL, subnet group
│   │   ├── route53/      # Health checks
│   │   ├── observability/ # CloudWatch dashboards, alarms, SNS
│   │   └── fis/          # Chaos engineering experiment templates
│   └── us-east-1/        # Region-specific configuration
├── app/
│   ├── main.py           # FastAPI app with Prometheus metrics
│   └── Dockerfile
├── chaos/
│   └── ecs-task-kill.json  # AWS FIS experiment template
├── runbooks/
│   └── regional-failover.md  # Step-by-step failover with RTO/RPO
└── docs/
    └── slo-policy.md     # Error budget policy
```

## Key engineering decisions

**OIDC over static keys** — GitHub Actions authenticates to AWS via OpenID Connect. No AWS credentials stored as secrets, no rotation required, no risk of key leakage.

**Modular Terraform** — each layer (vpc, ecs, rds, observability) is an independent reusable module. Adding us-west-2 means calling the same modules with a different region.

**Private subnets by default** — ECS tasks and RDS instances have no public IPs. All inbound traffic goes through the ALB. Database is unreachable from the internet.

**Chaos with stop conditions** — the FIS experiment template includes a CloudWatch alarm as a stop condition. If 5xx errors exceed threshold during the experiment, it halts automatically.

**SLO-first observability** — dashboards are built around SLO metrics (availability, p99 latency, error rate), not just infrastructure metrics. Alarms fire before SLO breach, not after.

## Running locally
```bash
# Bootstrap (one-time)
aws s3api create-bucket --bucket aws-reliability-lab-tfstate --region us-east-1
aws dynamodb create-table --table-name aws-reliability-lab-tflock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST --region us-east-1

# Deploy
cd terraform/us-east-1
terraform init
terraform plan
terraform apply

# Verify
curl http://$(terraform output -raw alb_dns_name)/health
curl http://$(terraform output -raw alb_dns_name)/metrics
```

## Chaos experiment
```bash
# Run the ECS task kill experiment
aws fis start-experiment \
  --experiment-template-id $(terraform output -raw fis_experiment_template_id) \
  --region us-east-1

# Monitor recovery in CloudWatch
# Expected: ECS replaces the killed task within 30-60 seconds
# SLO impact: < 1 minute of degraded availability
```

> Note: AWS FIS requires a paid account. The experiment template is included for reference and can be executed on non-free-tier accounts.

## Teardown
```bash
cd terraform/us-east-1
terraform destroy
```

> Remember to also delete the ECR repository and S3 bootstrap bucket manually if no longer needed.
>
> ## Screenshots
>
> ### SLO Dashboard - CloudWatch
> ![image alt](https://github.com/belzibab/aws-reliability-lab/blob/87c3f10ea4a847bc2770194a3590146181e56cb3/docs/screenshots/cloudwatchDashBoard.png)
> *ALB request count spike and p99 latency approaching SLO threshold (2s) during load test*
>
> ### ECS Service Health - CPU & Memory
> ![image alt](https://github.com/belzibab/aws-reliability-lab/blob/87c3f10ea4a847bc2770194a3590146181e56cb3/docs/screenshots/ecs-metrics.png)
> *CPU and memory utilization during load test - Fargate auto-manages capacity*
>
> ### Route53 Health Check
> ![image alt](https://github.com/belzibab/aws-reliability-lab/blob/87c3f10ea4a847bc2770194a3590146181e56cb3/docs/screenshots/Route53-healthcheck.png)
> *Primary ALB health check in healthy state*
