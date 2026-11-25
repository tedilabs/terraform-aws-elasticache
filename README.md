# terraform-aws-elasticache

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tedilabs/terraform-aws-elasticache?color=blue&sort=semver&style=flat-square)
![GitHub](https://img.shields.io/github/license/tedilabs/terraform-aws-elasticache?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

Terraform modules which create ElastiCache resources on AWS.

- [redis-cluster](./modules/redis-cluster)
- [redis-user](./modules/redis-user)
- [redis-user-group](./modules/redis-user-group)


## Target AWS Services

Terraform Modules from [this package](https://github.com/tedilabs/terraform-aws-elasticache) were written to manage the following AWS Services with Terraform.

- **AWS ElastiCache**
  - Redis and Valkey clusters
  - Redis and Valkey users and user groups


## Migration from terraform-aws-db

These modules were moved from [tedilabs/terraform-aws-db](https://github.com/tedilabs/terraform-aws-db), with the `elasticache-` prefix removed from module and example directory names. See the [migration guide](./MIGRATION.md) for source mappings and existing deployment considerations.


## Usage

The registry examples below target the first `v0.1.0` release. Until that release is published to the Terraform Registry, use a Git source pinned to a commit from this repository, as described in the migration guide.

### ElastiCache Redis

This example uses an existing ElastiCache subnet group in the configured AWS region. The module derives its VPC ID from the subnet group, so `vpc_id` is no longer an input. Terraform credentials need `elasticache:DescribeCacheSubnetGroups`. If the subnet group is created in the same configuration, pass its resource or module output to `subnet_group`.

```tf
module "cluster" {
  source  = "tedilabs/elasticache/aws//modules/redis-cluster"
  version = "~> 0.1.0"

  name        = "example-redis-full"
  description = "Managed by Terraform."

  engine = {
    type    = "redis"
    version = "7.1"
  }
  durability = "default"

  node_instance_type = "cache.t4g.micro"
  # node_size          = 1
  cluster_mode = {
    state      = "ENABLED"
    shard_size = 3
    replicas   = 2
  }


  ## Network
  ip_address_type              = "IPv4"
  discovery_ip_address_type    = "IPv4"
  port                         = 6379
  subnet_group                 = "example-redis-subnet-group"
  preferred_availability_zones = []

  default_security_group = {
    enabled     = true
    name        = "example-redis-full-default-sg"
    description = "Managed by Terraform."

    ingress_rules = [
      {
        id         = "all"
        ipv4_cidrs = ["0.0.0.0/0"]
      }
    ]
  }
  security_groups = []


  ## Parameters
  default_parameter_group = {
    enabled     = true
    name        = "example-redis-full-parameter-group"
    description = "Managed by Terraform."
    parameters = {
      "lazyfree-lazy-eviction"   = "yes"
      "lazyfree-lazy-expire"     = "yes"
      "lazyfree-lazy-server-del" = "yes"
      "rename-commands"          = "KEYS BLOCKED"
    }
  }
  parameter_group = null


  ## Auth
  password                 = sensitive("helloworld!#!!1234")
  password_update_strategy = "ROTATE"
  user_groups              = []


  ## Encryption
  encryption_at_rest = {
    enabled = true
    kms_key = null
  }
  encryption_in_transit = {
    enabled = true
    mode    = "required"
  }


  ## Backup
  backup = {
    enabled             = true
    window              = "16:00-17:00"
    retention           = 1
    final_snapshot_name = "example-redis-full-final"
  }


  ## Restore
  restore = {
    backup_name = null
    rdb_s3_arns = null
  }


  ## Maintenance
  maintenance = {
    window                             = "fri:18:00-fri:20:00"
    auto_upgrade_minor_version_enabled = true
    notification_sns_topic             = null
  }


  ## Logging
  logging_slow_log = {
    enabled = false
    format  = "JSON"

    destination = {
      type = "CLOUDWATCH_LOGS"
      name = null
    }
  }
  logging_engine_log = {
    enabled = false
    format  = "JSON"

    destination = {
      type = "CLOUDWATCH_LOGS"
      name = null
    }
  }


  ## Attributes
  multi_az_enabled      = true
  auto_failover_enabled = true
  apply_immediately     = true

  timeouts = {
    create = "60m"
    update = "45m"
    delete = "40m"
  }

  tags = {
    "project" = "terraform-aws-elasticache-examples"
  }
}
```


## Examples

### ElastiCache Redis

- [Single Redis Instance](./examples/redis-single)
- [Multi-AZs Redis Cluster (Sharding Disabled)](./examples/redis-muti-az)
- [Full Redis Cluster (Sharding Enabled)](./examples/redis-full)
- [Valkey Cluster with RBAC(Role Based Access Control)](./examples/valkey-with-users)


## Self Promotion

Like this project? Follow the repository on [GitHub](https://github.com/tedilabs/terraform-aws-elasticache). And if you're feeling especially charitable, follow **[posquit0](https://github.com/posquit0)** on GitHub.


## License

Provided under the terms of the [Apache License](LICENSE).

Copyright © 2022-2026, [Byungjin Park](https://www.posquit0.com).
