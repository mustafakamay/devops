provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  burst_limit = 900
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "rabbitmq" {
  name       = "my-rabbitmq-release"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  version    = "11.12.0"

  set {
    name  = "auth.username"
    value = "user"
  }

  set {
    name  = "auth.password"
    value = "hkvU1bFiHGvm9zER"
  }
}

resource "kubernetes_secret" "rabbitmq_credentials" {
  metadata {
    name = "rabbitmq-secret"
    namespace = "default"
  }
  data = {
    "rabbitmq-username" = "user"
    "rabbitmq-password" = "hkvU1bFiHGvm9zER"
  }
}

resource "kubernetes_config_map" "rabbitmq_config" {
  metadata {
    name = "rabbitmq-config"
    namespace = "default"
  }
  data = {
    "RABBITMQ_HOST" = "my-rabbitmq-release.default.svc.cluster.local"
    "RABBITMQ_PORT" = "5672"
  }
}

resource "helm_release" "consumer" {
  name       = "consumer"
  chart      = "../helm/helm-consumer"
  
  set {
    name  = "rabbitmqSecret"
    value = "rabbitmq-secret"
  }

  set {
    name  = "rabbitmqConfigMap"
    value = "rabbitmq-config"
  }
}

resource "helm_release" "producer" {
  name       = "producer"
  chart      = "../helm/helm-producer"


  set {
    name  = "rabbitmqSecret"
    value = "rabbitmq-secret"
  }

  set {
    name  = "rabbitmqConfigMap"
    value = "rabbitmq-config"
  }
}
