# Quick Start Guide

This guide will help you get the Docker Python Framework up and running in minutes.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)
- **Git** (optional): For cloning the repository

### Verify Docker Installation

```bash
# Check Docker version
docker --version

# Verify Docker is running
docker info
```

## Step 1: Get the Framework

### Option A: Download/Clone
```bash
# Clone the repository
git clone <repository-url> my-python-app
cd my-python-app
```

### Option B: Download ZIP
1. Download the framework as a ZIP file
2. Extract to your desired directory
3. Navigate to the directory in terminal

## Step 2: Choose Your Platform

### Linux/macOS Users

1. **Make the script executable**:
   ```bash
   chmod +x scripts/deploy-linux.sh
   ```

2. **Deploy the application**:
   ```bash
   ./scripts/deploy-linux.sh deploy
   ```

3. **Access the application**:
   Open your browser and go to: http://localhost:8000

### Windows Users (PowerShell)

1. **Open PowerShell as Administrator** (if needed for Docker)

2. **Navigate to the project directory**:
   ```powershell
   cd path\to\docker-python-framework
   ```

3. **Deploy the application**:
   ```powershell
   .\scripts\deploy-windows.ps1 deploy
   ```

4. **Access the application**:
   Open your browser and go to: http://localhost:8000

### Windows Users (Command Prompt)

1. **Open Command Prompt as Administrator** (if needed for Docker)

2. **Navigate to the project directory**:
   ```cmd
   cd path\to\docker-python-framework
   ```

3. **Deploy the application**:
   ```cmd
   scripts\deploy-windows.bat deploy
   ```

4. **Access the application**:
   Open your browser and go to: http://localhost:8000

## Step 3: Verify Installation

Once the deployment is complete, you should see:

1. **Console output** indicating successful deployment
2. **Web interface** at http://localhost:8000 showing:
   - Application status
   - System information
   - Available API endpoints

### Test the API Endpoints

```bash
# Health check
curl http://localhost:8000/api/health

# System information
curl http://localhost:8000/api/info

# Environment variables
curl http://localhost:8000/api/env
```

## Step 4: Customize Your Application

### Modify the Python Application

1. **Edit the main application file**:
   ```bash
   # Linux/Mac
   nano app/main.py
   
   # Windows
   notepad app\main.py
   ```

2. **Add your application logic** to `app/main.py`

3. **Update dependencies** in `requirements.txt`:
   ```txt
   # Add your required packages
   requests==2.31.0
   pandas==2.1.4
   your-package==1.0.0
   ```

### Configure Environment

1. **Copy the environment template**:
   ```bash
   cp .env.example .env
   ```

2. **Edit the .env file** with your configuration:
   ```env
   APP_NAME=my-awesome-app
   PORT=3000
   DEBUG=True
   ```

3. **Redeploy with new configuration**:
   ```bash
   # Linux/Mac
   ./scripts/deploy-linux.sh deploy
   
   # Windows PowerShell
   .\scripts\deploy-windows.ps1 deploy
   
   # Windows Batch
   scripts\deploy-windows.bat deploy
   ```

## Step 5: Development Workflow

### Common Commands

```bash
# View application logs
./scripts/deploy-linux.sh logs

# Stop the application
./scripts/deploy-linux.sh stop

# Restart the application
./scripts/deploy-linux.sh restart

# Open shell in container for debugging
./scripts/deploy-linux.sh shell

# Clean up (remove container and image)
./scripts/deploy-linux.sh clean
```

### Using Docker Compose (Alternative)

```bash
# Copy environment template
cp .env.example .env

# Start with docker-compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## Next Steps

1. **Read the main README.md** for detailed documentation
2. **Check the troubleshooting guide** if you encounter issues
3. **Explore the sample application** code in `app/main.py`
4. **Customize the Dockerfile** if you need additional system packages
5. **Set up CI/CD** for automated deployments

## Quick Reference

### File Structure
```
docker-python-framework/
├── app/main.py              # Your Python application
├── requirements.txt         # Python dependencies
├── Dockerfile              # Docker configuration
├── docker-compose.yml      # Compose configuration
├── .env.example           # Environment template
└── scripts/               # Deploy scripts
```

### Environment Variables
- `APP_NAME`: Application name
- `PORT`: Application port (default: 8000)
- `DEBUG`: Debug mode (default: False)

### Useful URLs
- Application: http://localhost:8000
- Health check: http://localhost:8000/api/health
- System info: http://localhost:8000/api/info

## Getting Help

- Check the [troubleshooting guide](troubleshooting.md)
- Review the main [README.md](../README.md)
- Create an issue if you find bugs
- Start a discussion for questions

Happy coding! 🚀

