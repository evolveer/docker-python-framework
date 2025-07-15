# Docker Python Framework - Windows Deploy Script (PowerShell)
# This script builds and deploys a Python application using Docker

param(
    [Parameter(Position=0)]
    [string]$Command = "deploy",
    
    [string]$AppName = $env:APP_NAME,
    [string]$ImageName = $env:IMAGE_NAME,
    [string]$ImageTag = $env:IMAGE_TAG,
    [string]$ContainerName = $env:CONTAINER_NAME,
    [string]$Port = $env:PORT,
    [string]$HostPort = $env:HOST_PORT
)

# Set default values
if (-not $AppName) { $AppName = "python-app" }
if (-not $ImageName) { $ImageName = $AppName }
if (-not $ImageTag) { $ImageTag = "latest" }
if (-not $ContainerName) { $ContainerName = "$AppName-container" }
if (-not $Port) { $Port = "8000" }
if (-not $HostPort) { $HostPort = $Port }

# Color functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Show-Usage {
    Write-Host "Usage: .\deploy-windows.ps1 [COMMAND] [OPTIONS]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  build     Build the Docker image"
    Write-Host "  run       Run the container"
    Write-Host "  stop      Stop the container"
    Write-Host "  restart   Restart the container"
    Write-Host "  logs      Show container logs"
    Write-Host "  shell     Open shell in container"
    Write-Host "  clean     Remove container and image"
    Write-Host "  deploy    Build and run (default)"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -AppName      Application name (default: python-app)"
    Write-Host "  -ImageName    Docker image name (default: `$AppName)"
    Write-Host "  -ImageTag     Docker image tag (default: latest)"
    Write-Host "  -ContainerName Container name (default: `$AppName-container)"
    Write-Host "  -Port         Container port (default: 8000)"
    Write-Host "  -HostPort     Host port (default: `$Port)"
    Write-Host ""
    Write-Host "Environment Variables (alternative to parameters):"
    Write-Host "  APP_NAME, IMAGE_NAME, IMAGE_TAG, CONTAINER_NAME, PORT, HOST_PORT"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\deploy-windows.ps1 deploy"
    Write-Host "  .\deploy-windows.ps1 build -AppName myapp -Port 3000"
    Write-Host "  .\deploy-windows.ps1 run"
}

function Test-Docker {
    try {
        $null = Get-Command docker -ErrorAction Stop
    }
    catch {
        Write-Error "Docker is not installed or not in PATH"
        exit 1
    }
    
    try {
        $null = docker info 2>$null
    }
    catch {
        Write-Error "Docker daemon is not running"
        exit 1
    }
}

function Test-Requirements {
    if (-not (Test-Path "requirements.txt")) {
        Write-Warning "requirements.txt not found, creating a basic one"
        @"
# Add your Python dependencies here
# Example:
# flask==2.3.3
# requests==2.31.0
"@ | Out-File -FilePath "requirements.txt" -Encoding UTF8
    }
}

function Test-AppDirectory {
    if (-not (Test-Path "app" -PathType Container)) {
        Write-Warning "app/ directory not found, creating it"
        New-Item -ItemType Directory -Path "app" -Force | Out-Null
        
        if (-not (Test-Path "app/main.py")) {
            Write-Warning "app/main.py not found, creating a sample one"
            @"
#!/usr/bin/env python3
"""
Sample Python application for Docker framework
"""

def main():
    print("Hello from Docker Python Framework!")
    print("This is a sample application.")
    
    # Keep the container running
    try:
        import time
        while True:
            time.sleep(60)
            print("Application is running...")
    except KeyboardInterrupt:
        print("Application stopped.")

if __name__ == "__main__":
    main()
"@ | Out-File -FilePath "app/main.py" -Encoding UTF8
        }
    }
}

function Build-Image {
    Write-Info "Building Docker image: ${ImageName}:${ImageTag}"
    
    Test-Requirements
    Test-AppDirectory
    
    $result = docker build -t "${ImageName}:${ImageTag}" .
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Image built successfully: ${ImageName}:${ImageTag}"
    }
    else {
        Write-Error "Failed to build image"
        exit 1
    }
}

function Stop-Container {
    $running = docker ps -q -f name="$ContainerName"
    if ($running) {
        Write-Info "Stopping container: $ContainerName"
        docker stop $ContainerName | Out-Null
        Write-Success "Container stopped"
    }
    else {
        Write-Info "Container $ContainerName is not running"
    }
}

function Remove-Container {
    $exists = docker ps -a -q -f name="$ContainerName"
    if ($exists) {
        Write-Info "Removing container: $ContainerName"
        docker rm $ContainerName | Out-Null
        Write-Success "Container removed"
    }
}

function Start-Container {
    # Stop and remove existing container
    Stop-Container
    Remove-Container
    
    Write-Info "Running container: $ContainerName"
    Write-Info "Port mapping: ${HostPort}:${Port}"
    
    $result = docker run -d --name $ContainerName -p "${HostPort}:${Port}" --restart unless-stopped "${ImageName}:${ImageTag}"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Container started successfully"
        Write-Info "Container name: $ContainerName"
        Write-Info "Access your application at: http://localhost:$HostPort"
    }
    else {
        Write-Error "Failed to start container"
        exit 1
    }
}

function Show-Logs {
    $running = docker ps -q -f name="$ContainerName"
    if ($running) {
        Write-Info "Showing logs for container: $ContainerName"
        docker logs -f $ContainerName
    }
    else {
        Write-Error "Container $ContainerName is not running"
        exit 1
    }
}

function Open-Shell {
    $running = docker ps -q -f name="$ContainerName"
    if ($running) {
        Write-Info "Opening shell in container: $ContainerName"
        docker exec -it $ContainerName /bin/bash
    }
    else {
        Write-Error "Container $ContainerName is not running"
        exit 1
    }
}

function Remove-All {
    Write-Info "Cleaning up Docker resources"
    
    # Stop and remove container
    Stop-Container
    Remove-Container
    
    # Remove image
    $imageExists = docker images -q "${ImageName}:${ImageTag}"
    if ($imageExists) {
        Write-Info "Removing image: ${ImageName}:${ImageTag}"
        docker rmi "${ImageName}:${ImageTag}" | Out-Null
        Write-Success "Image removed"
    }
    
    Write-Success "Cleanup completed"
}

function Start-Deploy {
    Write-Info "Starting deployment process"
    Build-Image
    Start-Container
    Write-Success "Deployment completed successfully!"
}

# Main script logic
Test-Docker

switch ($Command.ToLower()) {
    "build" {
        Build-Image
    }
    "run" {
        Start-Container
    }
    "stop" {
        Stop-Container
    }
    "restart" {
        Stop-Container
        Start-Container
    }
    "logs" {
        Show-Logs
    }
    "shell" {
        Open-Shell
    }
    "clean" {
        Remove-All
    }
    "deploy" {
        Start-Deploy
    }
    "help" {
        Show-Usage
    }
    default {
        Write-Error "Unknown command: $Command"
        Show-Usage
        exit 1
    }
}

