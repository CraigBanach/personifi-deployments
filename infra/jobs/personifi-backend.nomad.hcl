job "personifi-backend" {
  datacenters = ["dc1"]
  type        = "service"

  group "personifi" {
    network {
      port "app" {}
    }

    task "personifi-backend" {
      driver = "docker"

      template {
        data = <<EOF
Database__ConnectionString="{{ with nomadVar "personifi/database" }}{{ .connection_string }}{{ end }}"
EOF
        destination = "local/db.env"
        env         = true
      }

      template {
        data = <<EOF
DOCKER_USERNAME="{{ with nomadVar "personifi/ghcr" }}{{ .username }}{{ end }}"
DOCKER_PASSWORD="{{ with nomadVar "personifi/ghcr" }}{{ .password }}{{ end }}"
EOF
        destination = "local/docker-auth.env"
        env = true
      }

      config {
        image = "ghcr.io/craigbanach/personifibackend"
        ports = ["app"]
        
        # Docker labels for Traefik discovery
        labels = {
          "traefik.enable" = "true"
          "traefik.http.routers.personifi.rule" = "PathPrefix(`/api`)"
          "traefik.http.services.personifi.loadbalancer.server.port" = "8080"
        }
        
        auth {
          username = "${DOCKER_USERNAME}"
          password = "${DOCKER_PASSWORD}"
        }
      }

      env {
        ASPNETCORE_ENVIRONMENT = "Production"
        ASPNETCORE_URLS = "http://0.0.0.0:8080"
        Auth0__Domain = "https://dev-ga2rkd7xxfzornug.us.auth0.com"
        Auth0__Audience = "personifi-backend-api"
      }

      resources {
        cpu    = 256
        memory = 512
      }
    }
  }
}