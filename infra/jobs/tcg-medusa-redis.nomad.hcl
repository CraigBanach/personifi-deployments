job "tcg-medusa-redis" {
  datacenters = ["dc1"]
  type        = "service"

  group "redis" {
    task "redis" {
      driver = "docker"

      config {
        image = "redis:7-alpine"
        network_mode = "host"
        args  = ["redis-server", "--appendonly", "yes", "--bind", "127.0.0.1", "172.17.0.1", "--port", "26379"]
        volumes = [
          "/opt/tcg-medusa/redis:/data"
        ]
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
