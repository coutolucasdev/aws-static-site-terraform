terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

# Sufixo aleatório: nomes de bucket são únicos no mundo todo
resource "random_id" "sufixo" {
  byte_length = 4
}

resource "aws_s3_bucket" "site" {
  bucket = "lucas-portfolio-site-${random_id.sufixo.hex}"

  tags = {
    Projeto = "aws-static-site-terraform"
  }
}

# Mantém o bucket totalmente privado por enquanto
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "nome_do_bucket" {
  value = aws_s3_bucket.site.bucket
}

# Envia a página para o bucket
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${path.module}/site/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/site/index.html")
}