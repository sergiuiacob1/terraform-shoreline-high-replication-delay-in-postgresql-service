terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "high_replication_delay_in_postgresql_service" {
  source    = "./modules/high_replication_delay_in_postgresql_service"

  providers = {
    shoreline = shoreline
  }
}