resource "aws_s3_bucket" "code-pipeline-artifacts" {
  bucket = "pipeline-artifacts-jose"
  acl    = "private"

  
}
