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
        image = "traefik:v3.6.1"
        ports = ["http", "https", "admin"]
        
        # Mount the entire directory instead of just the file
        volumes = [
          # Map host config directory to internal config path (READ-ONLY)
          # Host source: /opt/traefik/config (where we copied traefik.yml)
          # Container destination: /etc/traefik/ (where Traefik expects the config file)
          "/opt/traefik/config:/etc/traefik:ro", 
          
          # Map ACME storage to a persistent, Writable host volume (NOT READ-ONLY)
          # Host source: /opt/traefik/acme (where acme.json will be written)
          # Container destination: /acme (Matches the new 'storage' path in traefik.yml)
          "/opt/traefik/acme:/acme", 
          
          # Docker Socket for Nomad Provider
          "/var/run/docker.sock:/var/run/docker.sock"
        ]
      }

      resources {
        cpu    = 256
        memory = 512
      }
    }
  }
}