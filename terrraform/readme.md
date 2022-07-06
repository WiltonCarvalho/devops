# Terraform
```
cat <'EOF'> provider.tf 
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}
EOF
```
```
cat <<'EOF'> container.tf 
provider "docker" {
  host = "tcp://127.0.0.1:2376"
}
resource "docker_image" "nginx" {
  name = "nginx:stable"
}

# Create a container
resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "nginx"
  memory = "256"
  memory_swap = "-1"
  ports {
    internal = "80"
    external = "8080"
    protocol = "tcp"
  }
  healthcheck {
    test = ["CMD", "curl", "-fsSL", "http://localhost"]
    interval = "10s"
    timeout = "3s"
    start_period = "3s"
    retries = 1
  }
}
EOF
```