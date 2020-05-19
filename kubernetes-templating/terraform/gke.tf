resource "google_container_cluster" "hw8" {
  name               = var.cluster_name
  location           = var.zone
  initial_node_count = 1
  remove_default_node_pool = true
  min_master_version = var.kubernetes_version
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "hw8_nodes" {
  name       = "${var.cluster_name}-pool"
  location   = var.zone
  cluster    = google_container_cluster.hw8.name
  node_count = var.node_count
  version = var.kubernetes_version
  node_config {
    preemptible  = true
    machine_type = var.machine_type
    
    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}