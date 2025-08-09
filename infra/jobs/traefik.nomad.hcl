job "traefik-simple" {
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 1
    
    network {
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
      port "admin" {
        static = 8080
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v3.4"
        ports = ["http", "https", "admin"]
        
        # Mount the entire directory instead of just the file
        volumes = [
          "/etc/nomad/traefik:/etc/traefik:ro",
          "/var/run/docker.sock:/var/run/docker.sock:ro"
        ]
      }

      resources {
        cpu    = 256
        memory = 512
      }
    }
  }
}