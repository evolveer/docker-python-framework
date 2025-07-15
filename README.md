# Docker Python Framework

A comprehensive Docker framework for deploying Python applications with cross-platform deploy scripts for Linux and Windows.

## 🚀 Features

- **Multi-stage Dockerfile** with security best practices
- **Cross-platform deploy scripts** (Linux Bash, Windows PowerShell, Windows Batch)
- **Sample Flask web application** with health checks and API endpoints
- **Docker Compose support** for easy orchestration
- **Environment configuration** with .env file support
- **Comprehensive documentation** and examples
- **Security-focused** with non-root user and minimal attack surface
- **Production-ready** with health checks and restart policies

## 📁 Project Structure

```
docker-python-framework/
├── Dockerfile                 # Multi-stage Docker configuration
├── docker-compose.yml         # Docker Compose configuration
├── requirements.txt           # Python dependencies
├── .dockerignore             # Docker build exclusions
├── .env.example              # Environment variables template
├── README.md                 # This documentation
├── app/                      # Application directory
│   └── main.py              # Sample Flask application
├── scripts/                  # Deploy scripts
│   ├── deploy-linux.sh      # Linux/macOS deploy script
│   ├── deploy-windows.ps1   # Windows PowerShell script
│   └── deploy-windows.bat   # Windows Batch script
└── docs/                     # Additional documentation
    ├── quick-start.md        # Quick start guide
    └── troubleshooting.md    # Troubleshooting guide
```

## 🎯 Quick Start

### Prerequisites

- Docker installed and running
- Git (optional, for cloning)

### Linux/macOS

```bash
# Clone or download the framework
git clone <repository-url> my-python-app
cd my-python-app

# Make the script executable
chmod +x scripts/deploy-linux.sh

# Deploy the application
./scripts/deploy-linux.sh deploy

# Access the application
open http://localhost:8000
```

### Windows (PowerShell)

```powershell
# Clone or download the framework
git clone <repository-url> my-python-app
cd my-python-app

# Deploy the application
.\scripts\deploy-windows.ps1 deploy

# Access the application
start http://localhost:8000
```

### Windows (Command Prompt)

```cmd
# Clone or download the framework
git clone <repository-url> my-python-app
cd my-python-app

# Deploy the application
scripts\deploy-windows.bat deploy

# Access the application
start http://localhost:8000
```

### Using Docker Compose

```bash
# Copy environment template
cp .env.example .env

# Edit .env file with your configuration
# nano .env

# Start the application
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the application
docker-compose down
```



## 🛠️ Usage

### Deploy Script Commands

All deploy scripts support the following commands:

| Command   | Description                    |
|-----------|--------------------------------|
| `build`   | Build the Docker image         |
| `run`     | Run the container             |
| `stop`    | Stop the container            |
| `restart` | Restart the container         |
| `logs`    | Show container logs           |
| `shell`   | Open shell in container       |
| `clean`   | Remove container and image    |
| `deploy`  | Build and run (default)       |

### Environment Variables

Configure the deployment using environment variables:

| Variable        | Description                    | Default        |
|----------------|--------------------------------|----------------|
| `APP_NAME`     | Application name               | `python-app`   |
| `IMAGE_NAME`   | Docker image name              | `$APP_NAME`    |
| `IMAGE_TAG`    | Docker image tag               | `latest`       |
| `CONTAINER_NAME` | Container name               | `$APP_NAME-container` |
| `PORT`         | Container port                 | `8000`         |
| `HOST_PORT`    | Host port                      | `$PORT`        |

### Examples

```bash
# Custom application name and port
APP_NAME=myapp PORT=3000 ./scripts/deploy-linux.sh deploy

# Build only
./scripts/deploy-linux.sh build

# View logs
./scripts/deploy-linux.sh logs

# Open shell for debugging
./scripts/deploy-linux.sh shell

# Clean up everything
./scripts/deploy-linux.sh clean
```

## 🔧 Customization

### Modifying the Application

1. **Edit the Python application**: Modify `app/main.py` with your application code
2. **Update dependencies**: Edit `requirements.txt` to include your required packages
3. **Environment configuration**: Copy `.env.example` to `.env` and customize
4. **Docker configuration**: Modify `Dockerfile` if you need additional system packages

### Adding Dependencies

Edit `requirements.txt` and add your dependencies:

```txt
# Web frameworks
flask==3.0.0
fastapi==0.104.1

# Database
sqlalchemy==2.0.23
psycopg2-binary==2.9.9

# Your custom dependencies
your-package==1.0.0
```

### Custom Dockerfile Modifications

The Dockerfile supports build arguments for customization:

```dockerfile
# Build with custom user
docker build --build-arg APP_USER=myuser --build-arg APP_UID=1001 -t myapp .

# Build with different Python version (modify Dockerfile)
FROM python:3.12-slim as builder
```

### Environment Configuration

Create a `.env` file from the template:

```bash
cp .env.example .env
```

Edit the `.env` file with your specific configuration:

```env
APP_NAME=my-awesome-app
PORT=3000
DEBUG=True
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
```

## 🚀 Deployment Options

### Local Development

```bash
# Quick start for development
./scripts/deploy-linux.sh deploy

# With debug mode
DEBUG=True ./scripts/deploy-linux.sh deploy
```

### Production Deployment

1. **Set production environment variables**:
   ```bash
   export DEBUG=False
   export PORT=80
   export HOST_PORT=80
   ```

2. **Use production WSGI server**: Uncomment `gunicorn` in `requirements.txt` and modify `app/main.py`:
   ```python
   # For production, use gunicorn instead of Flask dev server
   if __name__ == "__main__":
       import gunicorn.app.wsgiapp as wsgi
       wsgi.run()
   ```

3. **Deploy with resource limits**:
   ```bash
   # Using docker-compose with resource limits
   docker-compose up -d
   ```

### Cloud Deployment

The framework is ready for cloud deployment on:

- **AWS ECS/Fargate**: Use the Dockerfile directly
- **Google Cloud Run**: Compatible out of the box
- **Azure Container Instances**: Ready to deploy
- **Kubernetes**: Use the Docker image with your K8s manifests
- **Heroku**: Add a `Procfile` with `web: python app/main.py`

### CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Build and Deploy
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .
      - name: Deploy
        run: |
          # Your deployment commands here
          ./scripts/deploy-linux.sh deploy
```


## 📡 API Documentation

The sample application provides the following endpoints:

### Health Check
```http
GET /api/health
```
Returns application health status.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T12:00:00.000000",
  "service": "docker-python-framework"
}
```

### System Information
```http
GET /api/info
```
Returns system and Python environment information.

### Environment Variables
```http
GET /api/env
```
Returns safe environment variables (sensitive data filtered).

### Home Page
```http
GET /
```
Returns a web interface with application status and documentation.

## 🔍 Monitoring and Logging

### Viewing Logs

```bash
# Real-time logs
./scripts/deploy-linux.sh logs

# Docker compose logs
docker-compose logs -f

# Direct docker logs
docker logs -f python-app-container
```

### Health Checks

The application includes built-in health checks:

- **Docker health check**: Configured in Dockerfile
- **Compose health check**: Configured in docker-compose.yml
- **API health endpoint**: Available at `/api/health`

### Monitoring Integration

The framework is ready for monitoring integration:

```python
# Add to requirements.txt for monitoring
prometheus-client==0.19.0
structlog==23.2.0

# Add to app/main.py for metrics
from prometheus_client import Counter, Histogram, generate_latest
```

## 🛡️ Security Features

- **Non-root user**: Application runs as non-privileged user
- **Multi-stage build**: Minimal production image
- **Security scanning**: Compatible with container security tools
- **Environment isolation**: Sensitive data through environment variables
- **Resource limits**: Configurable CPU and memory limits
- **Health checks**: Automatic restart on failure

## 🐛 Troubleshooting

### Common Issues

1. **Port already in use**:
   ```bash
   # Change the port
   HOST_PORT=8001 ./scripts/deploy-linux.sh deploy
   ```

2. **Docker daemon not running**:
   ```bash
   # Start Docker service
   sudo systemctl start docker  # Linux
   # Or start Docker Desktop on Windows/Mac
   ```

3. **Permission denied**:
   ```bash
   # Make script executable
   chmod +x scripts/deploy-linux.sh
   ```

4. **Build failures**:
   ```bash
   # Clean and rebuild
   ./scripts/deploy-linux.sh clean
   ./scripts/deploy-linux.sh build
   ```

### Debug Mode

Enable debug mode for detailed logging:

```bash
DEBUG=True ./scripts/deploy-linux.sh deploy
```

### Container Shell Access

Access the running container for debugging:

```bash
# Open bash shell
./scripts/deploy-linux.sh shell

# Or directly with docker
docker exec -it python-app-container /bin/bash
```

## 📚 Additional Documentation

- [Quick Start Guide](docs/quick-start.md) - Step-by-step setup instructions
- [Troubleshooting Guide](docs/troubleshooting.md) - Common issues and solutions
- [API Reference](docs/api-reference.md) - Detailed API documentation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Setup

```bash
# Clone the repository
git clone <repository-url>
cd docker-python-framework

# Create development environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt

# Run locally for development
python app/main.py
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Docker community for best practices
- Flask team for the excellent web framework
- Python community for the amazing ecosystem

## 📞 Support

- Create an issue for bug reports
- Start a discussion for questions
- Check the troubleshooting guide for common issues

---

**Happy Dockerizing! 🐳**

