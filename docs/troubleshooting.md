# Troubleshooting Guide

This guide helps you resolve common issues when using the Docker Python Framework.

## 🔧 General Troubleshooting Steps

1. **Check Docker status**: Ensure Docker is running
2. **Verify permissions**: Make sure scripts are executable
3. **Check ports**: Ensure the target port is available
4. **Review logs**: Check container logs for error messages
5. **Clean and rebuild**: Remove containers/images and rebuild

## 🐳 Docker Issues

### Docker Not Installed or Not Running

**Symptoms:**
- `docker: command not found`
- `Cannot connect to the Docker daemon`

**Solutions:**

**Linux:**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (logout/login required)
sudo usermod -aG docker $USER
```

**Windows:**
1. Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Start Docker Desktop
3. Wait for Docker to initialize

**macOS:**
1. Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Start Docker Desktop from Applications

### Docker Permission Issues

**Symptoms:**
- `permission denied while trying to connect to the Docker daemon socket`

**Solutions:**

**Linux:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes (logout/login or use newgrp)
newgrp docker

# Or run with sudo (not recommended for regular use)
sudo ./scripts/deploy-linux.sh deploy
```

**Windows:**
- Run PowerShell or Command Prompt as Administrator
- Ensure Docker Desktop is running

### Docker Daemon Not Responding

**Symptoms:**
- Commands hang or timeout
- `Error response from daemon`

**Solutions:**
```bash
# Restart Docker service (Linux)
sudo systemctl restart docker

# Or restart Docker Desktop (Windows/Mac)
# Close and reopen Docker Desktop

# Check Docker system info
docker system info

# Clean up Docker resources
docker system prune -f
```

## 🚀 Deployment Issues

### Port Already in Use

**Symptoms:**
- `port is already allocated`
- `bind: address already in use`

**Solutions:**
```bash
# Find what's using the port
sudo netstat -tulpn | grep :8000  # Linux
netstat -ano | findstr :8000      # Windows

# Use a different port
HOST_PORT=8001 ./scripts/deploy-linux.sh deploy

# Or stop the conflicting service
sudo kill -9 <PID>  # Linux
taskkill /PID <PID> /F  # Windows
```

### Script Permission Denied

**Symptoms:**
- `Permission denied` when running scripts
- `cannot execute binary file`

**Solutions:**

**Linux/Mac:**
```bash
# Make script executable
chmod +x scripts/deploy-linux.sh

# Check file permissions
ls -la scripts/

# Run with bash explicitly
bash scripts/deploy-linux.sh deploy
```

**Windows:**
```powershell
# Enable script execution (PowerShell as Admin)
Set-ExecutionPolicy RemoteSigned

# Or run with explicit PowerShell
powershell -ExecutionPolicy Bypass -File scripts\deploy-windows.ps1 deploy
```

### Build Failures

**Symptoms:**
- `failed to build`
- `Error during build`

**Solutions:**
```bash
# Clean everything and rebuild
./scripts/deploy-linux.sh clean
./scripts/deploy-linux.sh build

# Check Dockerfile syntax
docker build --no-cache -t test .

# Build with verbose output
docker build --progress=plain -t test .

# Check available disk space
df -h  # Linux/Mac
dir C:\ # Windows
```

## 📦 Application Issues

### Container Starts But Application Doesn't Work

**Symptoms:**
- Container is running but no response on port
- `Connection refused` errors

**Solutions:**
```bash
# Check container status
docker ps

# Check container logs
./scripts/deploy-linux.sh logs

# Check if application is listening on correct port
docker exec -it python-app-container netstat -tulpn

# Verify port mapping
docker port python-app-container

# Test from inside container
docker exec -it python-app-container curl localhost:8000
```

### Python Import Errors

**Symptoms:**
- `ModuleNotFoundError`
- `ImportError`

**Solutions:**
```bash
# Check if requirements.txt is correct
cat requirements.txt

# Rebuild with no cache
docker build --no-cache -t python-app .

# Check installed packages in container
docker exec -it python-app-container pip list

# Install missing packages
echo "missing-package==1.0.0" >> requirements.txt
./scripts/deploy-linux.sh deploy
```

### Application Crashes on Startup

**Symptoms:**
- Container exits immediately
- Exit code 1 or other non-zero codes

**Solutions:**
```bash
# Check container logs
docker logs python-app-container

# Run container interactively for debugging
docker run -it --rm python-app /bin/bash

# Check Python syntax
python -m py_compile app/main.py

# Test application locally
cd app && python main.py
```

## 🌐 Network Issues

### Cannot Access Application from Browser

**Symptoms:**
- Browser shows "This site can't be reached"
- Connection timeout

**Solutions:**
```bash
# Verify container is running
docker ps | grep python-app

# Check port mapping
docker port python-app-container

# Test with curl
curl http://localhost:8000

# Check firewall settings (Linux)
sudo ufw status
sudo ufw allow 8000

# Check Windows Firewall
# Windows Security > Firewall & network protection
```

### DNS Resolution Issues

**Symptoms:**
- Cannot reach external services from container
- `Name resolution failed`

**Solutions:**
```bash
# Test DNS from container
docker exec -it python-app-container nslookup google.com

# Use different DNS servers
docker run --dns=8.8.8.8 --dns=8.8.4.4 ...

# Check Docker daemon DNS settings
docker system info | grep -i dns
```

## 💾 Resource Issues

### Out of Disk Space

**Symptoms:**
- `no space left on device`
- Build failures due to space

**Solutions:**
```bash
# Check disk usage
df -h

# Clean Docker resources
docker system prune -a -f

# Remove unused images
docker image prune -a -f

# Remove unused volumes
docker volume prune -f

# Check Docker space usage
docker system df
```

### Memory Issues

**Symptoms:**
- Container killed (exit code 137)
- Out of memory errors

**Solutions:**
```bash
# Check container resource usage
docker stats python-app-container

# Increase Docker memory limit (Docker Desktop)
# Settings > Resources > Memory

# Add memory limits to docker-compose.yml
deploy:
  resources:
    limits:
      memory: 1G
```

## 🔍 Debugging Techniques

### Enable Debug Mode

```bash
# Set debug environment variable
DEBUG=True ./scripts/deploy-linux.sh deploy

# Or edit .env file
echo "DEBUG=True" >> .env
docker-compose up -d
```

### Access Container Shell

```bash
# Open bash shell in running container
./scripts/deploy-linux.sh shell

# Or directly with docker
docker exec -it python-app-container /bin/bash

# For debugging, run container interactively
docker run -it --rm python-app /bin/bash
```

### Check Container Health

```bash
# Check health status
docker inspect python-app-container | grep -i health

# Manual health check
curl http://localhost:8000/api/health

# Check container processes
docker exec -it python-app-container ps aux
```

### Monitor Logs in Real-time

```bash
# Follow logs
./scripts/deploy-linux.sh logs

# Docker compose logs
docker-compose logs -f

# Filter logs
docker logs python-app-container 2>&1 | grep ERROR
```

## 🔧 Environment-Specific Issues

### Windows-Specific Issues

**Line Ending Problems:**
```bash
# Convert line endings (if using Git)
git config --global core.autocrlf true

# Or use dos2unix
dos2unix scripts/deploy-linux.sh
```

**Path Issues:**
```powershell
# Use forward slashes in PowerShell
./scripts/deploy-windows.ps1

# Or use backslashes in CMD
scripts\deploy-windows.bat
```

### macOS-Specific Issues

**Docker Desktop Performance:**
```bash
# Increase resources in Docker Desktop
# Preferences > Resources > Advanced

# Use Docker volume for better performance
docker run -v $(pwd):/app ...
```

### Linux-Specific Issues

**SELinux Issues:**
```bash
# Check SELinux status
sestatus

# Temporarily disable (not recommended for production)
sudo setenforce 0

# Or add SELinux context
sudo chcon -Rt svirt_sandbox_file_t /path/to/project
```

## 📞 Getting Additional Help

### Collect Debug Information

Before asking for help, collect this information:

```bash
# System information
uname -a                    # Linux/Mac
systeminfo                 # Windows

# Docker information
docker version
docker info
docker system df

# Container information
docker ps -a
docker logs python-app-container

# Application logs
./scripts/deploy-linux.sh logs
```

### Where to Get Help

1. **Check this troubleshooting guide** first
2. **Review the main README.md** for configuration options
3. **Search existing issues** in the repository
4. **Create a new issue** with debug information
5. **Join community discussions** for questions

### Creating a Good Bug Report

Include:
- Operating system and version
- Docker version
- Complete error messages
- Steps to reproduce
- Expected vs actual behavior
- Relevant configuration files

## 🚀 Prevention Tips

1. **Keep Docker updated** to the latest stable version
2. **Regularly clean up** unused Docker resources
3. **Monitor disk space** and container resource usage
4. **Use specific version tags** in requirements.txt
5. **Test locally** before deploying to production
6. **Backup important data** before major changes
7. **Use .env files** for environment-specific configuration

---

If you've tried all the solutions above and still have issues, please create an issue with detailed information about your problem.

