terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.22.2"
    }
  }
}

provider "rancher2" {
  api_url   = var.rancher_api_url
  token_key = var.rancher_admin_bearer_token
}

data "rancher2_cloud_credential" "rancher2_cloud_credential" {
  name = "my-aws-credz"
}

resource "rancher2_machine_config_v2" "rancher2_machine_config_v2" {
  generate_name = "rke2-terraform-test"
  amazonec2_config {
    ami            = ""
    region         = var.aws_region
    security_group = [var.aws_security_group_name]
    subnet_id      = var.aws_subnet_id
    vpc_id         = var.aws_vpc_id
    zone           = var.aws_zone_letter
  }
}

resource "rancher2_cluster_v2" "rancher2_cluster_v2" {
  name                                     = "dadfish"
  kubernetes_version                       = "v1.22.7+rke2r2"
  enable_network_policy                    = false
  default_cluster_role_for_project_members = "user"
  rke_config {
    machine_pools {
      name                         = "pool1"
      cloud_credential_secret_name = data.rancher2_cloud_credential.rancher2_cloud_credential.id
      control_plane_role           = true
      etcd_role                    = true
      worker_role                  = true
      quantity                     = 1
      machine_config {
        kind = rancher2_machine_config_v2.rancher2_machine_config_v2.kind
        name = rancher2_machine_config_v2.rancher2_machine_config_v2.name
      }
    }
  }
}
