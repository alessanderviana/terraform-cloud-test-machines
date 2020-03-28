variable gcp_credentials {
  default = "~/repositorios/terraform/gcloud/credentials.json"
}

variable gcp_project {
  default = "infra-como-codigo-e-automacao"
}

variable gcp_vpc_name {
  default = "default"
}

variable gcp_region {
  default = "us-central1"
}

variable user {
  default = "ubuntu"
}

variable pub_key {
  default = "~/repositorios/terraform/alessander-tf.pub"
}

variable priv_key {
  default = "~/repositorios/terraform/alessander-tf"
}
