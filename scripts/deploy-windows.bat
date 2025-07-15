@echo off
REM Docker Python Framework - Windows Deploy Script (Batch)
REM This script builds and deploys a Python application using Docker

setlocal enabledelayedexpansion

REM Configuration with defaults
if "%APP_NAME%"=="" set APP_NAME=python-app
if "%IMAGE_NAME%"=="" set IMAGE_NAME=%APP_NAME%
if "%IMAGE_TAG%"=="" set IMAGE_TAG=latest
if "%CONTAINER_NAME%"=="" set CONTAINER_NAME=%APP_NAME%-container
if "%PORT%"=="" set PORT=8000
if "%HOST_PORT%"=="" set HOST_PORT=%PORT%

REM Get command from first argument
set COMMAND=%1
if "%COMMAND%"=="" set COMMAND=deploy

REM Color codes (limited in batch)
set INFO_COLOR=[94m
set SUCCESS_COLOR=[92m
set WARNING_COLOR=[93m
set ERROR_COLOR=[91m
set RESET_COLOR=[0m

goto main

:log_info
echo %INFO_COLOR%[INFO]%RESET_COLOR% %~1
goto :eof

:log_success
echo %SUCCESS_COLOR%[SUCCESS]%RESET_COLOR% %~1
goto :eof

:log_warning
echo %WARNING_COLOR%[WARNING]%RESET_COLOR% %~1
goto :eof

:log_error
echo %ERROR_COLOR%[ERROR]%RESET_COLOR% %~1
goto :eof

:show_usage
echo Usage: %0 [COMMAND]
echo.
echo Commands:
echo   build     Build the Docker image
echo   run       Run the container
echo   stop      Stop the container
echo   restart   Restart the container
echo   logs      Show container logs
echo   shell     Open shell in container
echo   clean     Remove container and image
echo   deploy    Build and run (default)
echo.
echo Environment Variables:
echo   APP_NAME      Application name (default: python-app)
echo   IMAGE_NAME    Docker image name (default: %%APP_NAME%%)
echo   IMAGE_TAG     Docker image tag (default: latest)
echo   CONTAINER_NAME Container name (default: %%APP_NAME%%-container)
echo   PORT          Container port (default: 8000)
echo   HOST_PORT     Host port (default: %%PORT%%)
echo.
echo Examples:
echo   %0 deploy
echo   set APP_NAME=myapp && set PORT=3000 && %0 build
echo   %0 run
goto :eof

:check_docker
docker --version >nul 2>&1
if errorlevel 1 (
    call :log_error "Docker is not installed or not in PATH"
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    call :log_error "Docker daemon is not running"
    exit /b 1
)
goto :eof

:check_requirements
if not exist "requirements.txt" (
    call :log_warning "requirements.txt not found, creating a basic one"
    echo # Add your Python dependencies here > requirements.txt
    echo # Example: >> requirements.txt
    echo # flask==2.3.3 >> requirements.txt
    echo # requests==2.31.0 >> requirements.txt
)
goto :eof

:check_app_directory
if not exist "app" (
    call :log_warning "app/ directory not found, creating it"
    mkdir app
    
    if not exist "app\main.py" (
        call :log_warning "app/main.py not found, creating a sample one"
        (
            echo #!/usr/bin/env python3
            echo """
            echo Sample Python application for Docker framework
            echo """
            echo.
            echo def main():
            echo     print("Hello from Docker Python Framework!"^)
            echo     print("This is a sample application."^)
            echo     
            echo     # Keep the container running
            echo     try:
            echo         import time
            echo         while True:
            echo             time.sleep(60^)
            echo             print("Application is running..."^)
            echo     except KeyboardInterrupt:
            echo         print("Application stopped."^)
            echo.
            echo if __name__ == "__main__":
            echo     main()
        ) > app\main.py
    )
)
goto :eof

:build_image
call :log_info "Building Docker image: %IMAGE_NAME%:%IMAGE_TAG%"

call :check_requirements
call :check_app_directory

docker build -t "%IMAGE_NAME%:%IMAGE_TAG%" .
if errorlevel 1 (
    call :log_error "Failed to build image"
    exit /b 1
)

call :log_success "Image built successfully: %IMAGE_NAME%:%IMAGE_TAG%"
goto :eof

:stop_container
docker ps -q -f name="%CONTAINER_NAME%" >nul 2>&1
if not errorlevel 1 (
    call :log_info "Stopping container: %CONTAINER_NAME%"
    docker stop "%CONTAINER_NAME%" >nul
    call :log_success "Container stopped"
) else (
    call :log_info "Container %CONTAINER_NAME% is not running"
)
goto :eof

:remove_container
docker ps -a -q -f name="%CONTAINER_NAME%" >nul 2>&1
if not errorlevel 1 (
    call :log_info "Removing container: %CONTAINER_NAME%"
    docker rm "%CONTAINER_NAME%" >nul
    call :log_success "Container removed"
)
goto :eof

:run_container
call :stop_container
call :remove_container

call :log_info "Running container: %CONTAINER_NAME%"
call :log_info "Port mapping: %HOST_PORT%:%PORT%"

docker run -d --name "%CONTAINER_NAME%" -p "%HOST_PORT%:%PORT%" --restart unless-stopped "%IMAGE_NAME%:%IMAGE_TAG%"
if errorlevel 1 (
    call :log_error "Failed to start container"
    exit /b 1
)

call :log_success "Container started successfully"
call :log_info "Container name: %CONTAINER_NAME%"
call :log_info "Access your application at: http://localhost:%HOST_PORT%"
goto :eof

:show_logs
docker ps -q -f name="%CONTAINER_NAME%" >nul 2>&1
if errorlevel 1 (
    call :log_error "Container %CONTAINER_NAME% is not running"
    exit /b 1
)

call :log_info "Showing logs for container: %CONTAINER_NAME%"
docker logs -f "%CONTAINER_NAME%"
goto :eof

:open_shell
docker ps -q -f name="%CONTAINER_NAME%" >nul 2>&1
if errorlevel 1 (
    call :log_error "Container %CONTAINER_NAME% is not running"
    exit /b 1
)

call :log_info "Opening shell in container: %CONTAINER_NAME%"
docker exec -it "%CONTAINER_NAME%" /bin/bash
goto :eof

:clean_all
call :log_info "Cleaning up Docker resources"

call :stop_container
call :remove_container

docker images -q "%IMAGE_NAME%:%IMAGE_TAG%" >nul 2>&1
if not errorlevel 1 (
    call :log_info "Removing image: %IMAGE_NAME%:%IMAGE_TAG%"
    docker rmi "%IMAGE_NAME%:%IMAGE_TAG%" >nul
    call :log_success "Image removed"
)

call :log_success "Cleanup completed"
goto :eof

:deploy
call :log_info "Starting deployment process"
call :build_image
if errorlevel 1 exit /b 1
call :run_container
if errorlevel 1 exit /b 1
call :log_success "Deployment completed successfully!"
goto :eof

:main
call :check_docker
if errorlevel 1 exit /b 1

if /i "%COMMAND%"=="build" (
    call :build_image
) else if /i "%COMMAND%"=="run" (
    call :run_container
) else if /i "%COMMAND%"=="stop" (
    call :stop_container
) else if /i "%COMMAND%"=="restart" (
    call :stop_container
    call :run_container
) else if /i "%COMMAND%"=="logs" (
    call :show_logs
) else if /i "%COMMAND%"=="shell" (
    call :open_shell
) else if /i "%COMMAND%"=="clean" (
    call :clean_all
) else if /i "%COMMAND%"=="deploy" (
    call :deploy
) else if /i "%COMMAND%"=="help" (
    call :show_usage
) else (
    call :log_error "Unknown command: %COMMAND%"
    call :show_usage
    exit /b 1
)

endlocal

