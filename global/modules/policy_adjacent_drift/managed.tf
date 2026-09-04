resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "ice_config" "main" {
  system {
    name = "s3_bucket"

    capability {
      name    = "block_public_acls_enabled"
      handler = "ice"
      cmd     = "aws s3api get-public-access-block --bucket ${aws_s3_bucket.compliance_target.id} | grep -q '\"BlockPublicAcls\": true'"
    }
    capability {
      name    = "block_public_policy_enabled"
      handler = "ice"
      cmd     = "aws s3api get-public-access-block --bucket ${aws_s3_bucket.compliance_target.id} | grep -q '\"BlockPublicPolicy\": true'"
    }
  }

  system {
    name = "policy"

    requirement {
      name     = "public_access_blocked"
      contract = "block_public_acls_enabled and block_public_policy_enabled"
    }
  }
}
