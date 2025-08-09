# Frontend service
job "personifi-frontend" {
  datacenters = ["dc1"]
  type        = "service"

  group "personifi" {
    network {
      port "app" {}
    }

    task "personifi-frontend" {
      driver = "docker"
      
      template {
        data = <<EOF
AUTH0_SECRET="{{ with nomadVar "personifi/auth0-frontend" }}{{ .auth0_secret }}{{ end }}"
AUTH0_CLIENT_SECRET="{{ with nomadVar "personifi/auth0-frontend" }}{{ .auth0_client_secret }}{{ end }}"
EOF
        destination = "local/auth.env"
        env         = true
      }

      config {
        image = "ghcr.io/craigbanach/personifi-app:latest"
        ports = ["app"]
        
        labels = {
          "traefik.enable" = "true"
          "traefik.http.routers.frontend.rule" = "Host(`91.99.76.125`)"
          "traefik.http.services.frontend.loadbalancer.server.port" = "3000"
        }
      }
      
      env {
        NODE_ENV = "production"
        # API calls to your backend service
        APP_BASE_URL = "http://91.99.76.125"
        PERSONIFI_BACKEND_URL = "http://91.99.76.125/api"
        AUTH0_DOMAIN = "https://dev-ga2rkd7xxfzornug.us.auth0.com"
        AUTH0_CLIENT_ID = "VLPgXIfdcsqfxOEIAgOjq47gBmZ9yA5U"
        AUTH0_SCOPE = "openid profile email read:balances transaction:create"
        AUTH0_AUDIENCE = "personifi-backend-api"
      }
    }
  }
}