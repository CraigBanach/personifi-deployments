job "tcg-medusa-redis" {
  datacenters = ["dc1"]
  type        = "service"

  group "redis" {
    network {
      port "redis" {
        static = 26379
        to     = 6379
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:7-alpine"
        ports = ["redis"]
        args  = ["redis-server", "--appendonly", "yes"]
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
