terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47.0"
    }
  }
}

provider "aws" {
  region = "us-west-2" # Oregon
}

resource "aws_amplify_app" "swarm-frontend" {
  name       = "swarm-frontend"
  repository = "https://github.com/swarm-io-internal/swarm-frontend"

  # GitHub basic auth
  enable_basic_auth      = true
  basic_auth_credentials = base64encode("username:password")
  access_token = "personal_access_token"

  # client_id = "Ov23liWgCeNMO69JYSA2"
  # Provide a valid GitHub OAuth token
  # oauth_token = "github_oauth_token"

  # The default build_spec added by the Amplify Console for React.
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci --cache .npm --prefer-offline
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - .next/cache/**/*
          - .npm/**/*
  EOT

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  environment_variables = {
    ENV = "test"
  }
}
