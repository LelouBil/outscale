terraform {
  required_providers {
    outscale = {
      source  = "outscale/outscale"
      version = ">=0.12.0"
    }
  }
}
provider "outscale" {
  access_key_id  = var.access_key_id
  secret_key_id  = var.secret_key_id
  region         = var.region
}