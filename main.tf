resource "kubernetes_namespace" "nginx" {
     metadata {
       name= "terraform-nginx"
     }
}

resource "kubernetes_deployment" "deploy-nginx" {
   metadata {
     name= "terraform-nginx"
     namespace = kubernetes_namespace.nginx.metadata.0.name
     labels = {
        "tool" = "terraform"
        "deploy" = "nginx"
            }
   }
   spec  {
       replicas= "2"
       selector {
         match_labels = {
            terraform= "nginx-pod"
         }
       }
       template {
           metadata {
             name= "nginx"
             labels = {
               "terraform" = "nginx-pod"
             }
           }
           spec {
             container {
                name= "terraform-cont"
                image= "nginx"
             port {
                container_port= "80"
                 }
              }
           }
            
        }

   }
}

resource "kubernetes_service" "nginx-service" {
   metadata {
     name = kubernetes_deployment.deploy-nginx.metadata.0.name
     namespace = kubernetes_namespace.nginx.metadata.0.name
     labels = {
       "svc" = "nginx"
       }
   }
   spec {
    selector = {
         terraform = kubernetes_deployment.deploy-nginx.spec.0.template.0.metadata.0.labels.terraform
        }
    type = "NodePort"
    port {
       port = "80"
       target_port = "80"
       node_port = "30023"
    }
  }
}

