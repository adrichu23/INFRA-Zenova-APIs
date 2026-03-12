#===================General===================#
aws_account             = "060795906495"
region                  = "us-east-1"
project                 = "quotezen"
environment             = "dev"
owner                   = "XalDigital"
createdby               = "TF"

#===================Tags===================#
xal_environment      = "Dev"
xal_project          = "quotezen"
xal_owner            = "daniel.correa@xaldigital.com"
xd_project_id        = "AWS-USA-0169-Zenova Rapid GenAI Assesment"
xd_backup_schedule   = "None"

#===================VPC===================#
vpc_cidr                = "172.31.0.0/16"
public_subnets_cidr     = ["172.31.0.0/20", "172.31.16.0/20", "172.31.32.0/20"]
private_subnets_cidr    = ["172.31.48.0/20", "172.31.64.0/20", "172.31.80.0/20"]
availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]

#===================ECR/ECS===================#

s3_bucket = "quotezen-terraform-poc-infra-deploy"

infra_configuration = {
    backend = {
        name = "Backend"
        clusters = ["backend"]
        alb = {
            port            = 80
            internal        = false
            health_path     = "/health"
            container_port  = 5000
            certificate_arn = "None"
        }
        tasks = {
            backend = {
                name                      = "backend"
                log_stream_prefix         = "backend"
                family                    = "backend"
                network_mode              = "awsvpc"
                requires_compatibilities  = ["FARGATE"]
                cpu                       = "256"
                memory                    = "512"
                container_definitions_path = "./templates/ecs/backend_container_definitions.json"
                image_tag                 = "latest"
                operating_system_family   = "LINUX"
                cpu_architecture          = "X86_64"
                desired_count             = 1
            }
        }
        iam = {
            backend = {
                role_name        = "backend-task-role"
                role_description = "Role for Backend ECS task execution"
                role_file_path   = "./templates/iam/backend-task-role.json"
                policy_name      = "backend-task-policy"
                policy_file_path = "./templates/iam/backend-task-policy.json"
            }
        }
    }
}

#===================RDS===================#
rds_configuration = {
    database_name                = "monitoring"
    master_username              = "quotezen_admin"
    backup_retention_period      = 7
    preferred_backup_window      = "07:00-09:00"
    preferred_maintenance_window = "Mon:22:00-Mon:23:00"
    storage_encrypted            = true
    db_port                      = 5432
    engine                       = "aurora-postgresql"
    engine_version               = "16.6"
    instance_class               = "db.t3.medium"
}

#===================Redis===================#
redis_configuration = {
    node_type        = "cache.t3.micro"
    port             = 6379
    parameter_group  = "default.redis6.x"
    engine_version   = "6.2"
}

db_secret_name          = "quotezen-middleware-db"
frontend_db_secret_name = "quotezen-dev-rds-postgresql"

#===================CloudFront===================#
enable_cloudfront                   = true
cloudfront_use_default_certificate  = true
cloudfront_certificate_arn          = "arn:aws:acm:us-east-1:734326689372:certificate/fa979739-393a-44c5-9a8d-11bb8cbd00c1"
cloudfront_price_class              = "PriceClass_All"
cloudfront_aliases                  = ["poc-oxxo-pic5.xaldigitalservices.com"]

#===================CloudFront Advanced===================#
default_root_object        = "index.html"
min_ttl                   = 0
default_ttl               = 3600
max_ttl                   = 86400
compress                  = true
ssl_support_method        = "sni-only"
minimum_protocol_version  = "TLSv1.2_2021"

#===================S3 Advanced===================#
bucket_acl                = "private"
block_public_acls         = true
block_public_policy       = true
ignore_public_acls        = true
restrict_public_buckets   = true

