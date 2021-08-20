resource "aws_codebuild_project" "plan" {
  name          = "ci-cd-plan"
  description   = "plan stage for terraform"
  service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

 
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = var.dockerhub_crendentials
        credential_provider = "SECRETS_MANAGER"
        }
   }
   source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
   }
}




   resource "aws_codebuild_project" "apply" {
  name          = "ci-cd-apply"
  description   = "plan stage for terraform"
  build_timeout = "5"
  service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

 
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = var.dockerhub_crendentials
        credential_provider = "SECRETS_MANAGER"
        }
   }
   source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
   }
}

resource "aws_codepipeline"  "cicd_pipeline" {
    
    name = "tf-cicd"
    role_arn = aws_iam_role.tf-cicd-role.arn

    artifact_store {
        type="S3"
        location = aws_s3_bucket.code-pipeline-artifacts.id
    }

     stage {
        name = "Source"
        action{
            name = "Source"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["tf-code"]
            configuration = {
                FullRepositoryId = "josedlg/terraform-aws"
                BranchName   = "master"
                ConnectionArn = var.codestar_connector_credentials
                OutputArtifactFormat = "CODE_ZIP"
            }
        }
    }

        stage {
        name ="Plan"
        action{
            name = "Build"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["tf-code"]
            configuration = {
                ProjectName = "tf-cicd-plan"
            }
        }
    }

    stage {
        name ="Deploy"
        action{
            name = "Deploy"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["tf-code"]
            configuration = {
                ProjectName = "tf-cicd-apply"
            }
        }
    }


}