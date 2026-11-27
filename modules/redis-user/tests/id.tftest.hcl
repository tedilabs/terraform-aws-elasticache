mock_provider "aws" {}
mock_provider "telemetry" {}

variables {
  name           = "id-test"
  resource_group = { enabled = false }
  telemetry      = { enabled = false }
}

run "iam_defaults_to_name" {
  command = plan
  assert {
    condition     = aws_elasticache_user.this.user_id == "id-test"
    error_message = "An IAM user must default its ID to the username."
  }
}

run "valkey_password_defaults_to_engine_prefix" {
  command = plan
  variables {
    authentication = {
      mode      = "password"
      passwords = ["test-password-123456"]
    }
  }
  assert {
    condition     = aws_elasticache_user.this.user_id == "valkey-id-test"
    error_message = "A Valkey password user must default its ID to `valkey-{name}`."
  }
}

run "redis_no_password_defaults_to_engine_prefix" {
  command = plan
  variables {
    engine         = "redis"
    authentication = { mode = "no-password-required" }
  }
  assert {
    condition     = aws_elasticache_user.this.user_id == "redis-id-test"
    error_message = "A Redis passwordless user must default its ID to `redis-{name}`."
  }
}

run "explicit_id_is_used" {
  command = plan
  variables {
    id = "custom-id"
    authentication = {
      mode      = "password"
      passwords = ["test-password-123456"]
    }
  }
  assert {
    condition     = aws_elasticache_user.this.user_id == "custom-id" && aws_elasticache_user.this.user_name == "id-test"
    error_message = "An explicit ID must be used as the user ID without changing the username."
  }
}

run "iam_rejects_id_different_from_name" {
  command = plan
  variables {
    id = "custom-id"
  }
  expect_failures = [var.id]
}
