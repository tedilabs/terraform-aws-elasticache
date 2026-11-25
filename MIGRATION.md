# Migration from terraform-aws-db

The ElastiCache modules and examples have moved from `tedilabs/terraform-aws-db` to `tedilabs/terraform-aws-elasticache`. The initial import is based on `terraform-aws-db` commit `7eb131ecd9f33da3d081769a78a5bc350ad44ae5`.

## Module sources

| Previous source | New source |
| --- | --- |
| `tedilabs/db/aws//modules/elasticache-redis-cluster` | `tedilabs/elasticache/aws//modules/redis-cluster` |
| `tedilabs/db/aws//modules/elasticache-redis-user` | `tedilabs/elasticache/aws//modules/redis-user` |
| `tedilabs/db/aws//modules/elasticache-redis-user-group` | `tedilabs/elasticache/aws//modules/redis-user-group` |

After the first release is published to the Terraform Registry, update each module's `source` and `version`. Keep the module block label and its inputs unchanged:

```hcl
module "cache" {
  source  = "tedilabs/elasticache/aws//modules/redis-cluster"
  version = "~> 0.1.0"

  # Keep the existing inputs here.
}
```

Before the registry release, use `git::https://github.com/tedilabs/terraform-aws-elasticache.git//modules/redis-cluster?ref=<commit-sha>` with an actual commit SHA from the new repository. Omit the `version` argument for Git sources. Use the corresponding subdirectory for the user and user-group modules.

Run `terraform init` to install the new module sources, then review `terraform plan` before applying. Existing releases of `tedilabs/db/aws`, including `v0.5.1`, remain available at their original tags; consumers following the old repository's `main` branch must migrate before the removal is merged.

## Existing deployments

- Resource and nested module block addresses are preserved. Changing only the package source and subdirectory does not require `terraform state mv` or a `moved` block when the calling module labels and `count`/`for_each` keys stay the same.
- Package metadata changes to `terraform-aws-elasticache`, and module metadata drops the `elasticache-` prefix. Module tags, Resource Group tag queries, and telemetry metadata reflect these new names.
- When Resource Groups are enabled, their default names are derived from the package and module names. To retain an existing group's name, set `resource_group.name` explicitly to its current value before migrating (for example, `terraform-aws-db.elasticache-redis-cluster.<existing-name>`). Otherwise the plan can replace that Resource Group. Module tags and the group's tag query will still change.
- This import preserves the source repository's Terraform code except for package metadata. All modules require Terraform `>= 1.16`; the cluster module requires AWS provider `>= 6.51`, and the user and user-group modules require `>= 6.33`. If upgrading from an older release, also review changes between that release and the imported source commit.

## Examples and labels

| Previous example directory | New example directory |
| --- | --- |
| `elasticache-redis-full` | [`redis-full`](./examples/redis-full) |
| `elasticache-redis-muti-az` | [`redis-muti-az`](./examples/redis-muti-az) |
| `elasticache-redis-single` | [`redis-single`](./examples/redis-single) |
| `elasticache-valkey-with-users` | [`valkey-with-users`](./examples/valkey-with-users) |

The new repository defines `:floppy_disk: redis-cluster`, `:floppy_disk: redis-user`, and `:floppy_disk: redis-user-group` labels and matches them to the renamed module paths. The old repository no longer defines or auto-applies the ElastiCache module labels. Existing labels on historical issues and pull requests are retained by its non-deleting label synchronization workflow.
