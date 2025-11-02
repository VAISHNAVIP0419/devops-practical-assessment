# Kubernetes namespace for the application
resource "kubernetes_namespace" "app" {
  metadata {
    name = "three-tier-app"
  }

  depends_on = [module.eks]
}

# Deploy MySQL
resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:5.7"

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "admin123"
          }

          env {
            name  = "MYSQL_DATABASE"
            value = "employees"
          }

          port {
            container_port = 3306
          }
        }
      }
    }
  }

  depends_on = [module.eks]
}

resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = "mysql"
    }

    port {
      port        = 3306
      target_port = 3306
    }

    type = "ClusterIP"
  }
}

# Deploy Backend API
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        container {
          name  = "backend"
          image = "amanpathak/three-tier-backend:latest"

          env {
            name  = "DB_HOST"
            value = "mysql"
          }

          env {
            name  = "DB_USER"
            value = "root"
          }

          env {
            name  = "DB_PASSWORD"
            value = "admin123"
          }

          env {
            name  = "DB_NAME"
            value = "employees"
          }

          port {
            container_port = 8080
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.mysql]
}

resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = "backend"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

# Deploy Frontend
resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          name  = "frontend"
          image = "amanpathak/three-tier-frontend:latest"

          env {
            name  = "REACT_APP_BACKEND_URL"
            value = "http://backend:8080"
          }

          port {
            container_port = 3000
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.backend]
}

# Create an ALB Ingress for the frontend
resource "kubernetes_ingress_v1" "frontend" {
  metadata {
    name      = "frontend-ingress"
    namespace = kubernetes_namespace.app.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = "frontend"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.frontend]
}