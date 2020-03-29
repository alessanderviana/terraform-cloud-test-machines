provider "google" {
  credentials = file(var.gcp_credentials)
  project     = var.gcp_project
  region      = var.gcp_region
  version     = "~> 2.7"
}

# data "google_compute_network" "net" {
#   name    = "default"
#   project = var.gcp_project
# }

resource "google_compute_firewall" "allow_ssh_test_machine" {
  name    = "default-allow-ssh-test-machine"
  network = var.gcp_vpc_name

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  allow {
    protocol = "tcp"
    ports = ["3309"]
  }

  allow {
    protocol = "tcp"
    ports = ["80"]
  }

  # IP address range from AWS SOMOS VPC and office
  source_ranges = [
    "187.20.240.8/32",
  ]
}

resource "google_compute_instance" "test_machine" {
 # count = 1
 name         = "test-machine" # -${count.index + 1}"
 # machine_type = "n1-standard-1"  # 3.75 GB RAM
 machine_type = "g1-small"  # 1.7 GB RAM
 zone         = "${var.gcp_region}-a"

 tags = [ "test-machine" ] # -${count.index + 1}"

 boot_disk {
   initialize_params {
     image = "ubuntu-1804-bionic-v20200317"
     # image = "ubuntu-1904-disco-v20190514"
   }
 }

 network_interface {
   subnetwork = "default"
   access_config { }
 }

 metadata = {
   ssh-keys = "${var.user}:${file("${var.pub_key}")}"
 }

  provisioner "file" {
     source      = "files"
     destination = "/tmp/files"

     connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.priv_key)
    host        = google_compute_instance.test_machine.network_interface.0.access_config.0.nat_ip
  }
}

# Teste
# docker run -it --rm mysql mysql -h10.128.0.12 -P3309 -ualessander -p

 metadata_startup_script = <<SCRIPT
    echo " ******************** INSTALL DOCKER"
    apt-get update -q
    curl -fsSL https://get.docker.com/ | bash
    usermod -aG docker ubuntu
    echo " ******************** INSTALL DOCKER-COMPOSE"
    curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
SCRIPT

}
