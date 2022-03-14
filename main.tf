terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "<your-token>"
  cloud_id  = "<your-cloud-id>"
  folder_id = var.folder-id
  zone      = "ru-central1-b"
}

variable "folder-id" {
  default = "<your-folder-id>"
}

resource "yandex_kubernetes_cluster" "zonal_cluster_resource_name" {
  name        = "k8s-cluster-new"
  description = "k8s-cluster-new"

  network_id = "<your-network-id>"

  master {
    
    zonal {
      zone      = "ru-central1-b"
      subnet_id = "<your-subnet-id>"
    }

    version   = "1.20"
    public_ip = true

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "monday"
        start_time = "15:00"
        duration   = "3h"
      }

      maintenance_window {
        day        = "friday"
        start_time = "10:00"
        duration   = "4h30m"
      }
    }
  }
  
  service_account_id      = "<your-sa-id>"
  node_service_account_id = "<your-sa-id>"
  release_channel = "REGULAR"
}


resource "yandex_kubernetes_node_group" "my_node_group" {
  cluster_id  = "${yandex_kubernetes_cluster.zonal_cluster_resource_name.id}"
  name        = "k8s-cluster-zonal-template-node-group"
  description = "k8s-cluster-zonal-template-node-group"
  version     = "1.20"


  instance_template {
    platform_id = "standard-v3"

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-b"
    }
  }
  
  deploy_policy {
    max_expansion = "3"
    max_unavailable = "1"
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "15:00"
      duration   = "3h"
    }

    maintenance_window {
      day        = "friday"
      start_time = "10:00"
      duration   = "4h30m"
    }
  }
}
