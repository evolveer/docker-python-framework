#!/usr/bin/env python3
"""
Sample Python application for Docker framework
This is a Flask web application that demonstrates the framework capabilities.
"""

import os
import sys
import logging
from datetime import datetime
from flask import Flask, jsonify, render_template_string

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create Flask application
app = Flask(__name__)

# Configuration
app.config['DEBUG'] = os.getenv('DEBUG', 'False').lower() == 'true'
PORT = int(os.getenv('PORT', 8000))
HOST = os.getenv('HOST', '0.0.0.0')

# HTML template for the home page
HOME_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Docker Python Framework</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 30px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }
        h1 {
            text-align: center;
            margin-bottom: 30px;
            font-size: 2.5em;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .info-card {
            background: rgba(255, 255, 255, 0.1);
            padding: 20px;
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .info-card h3 {
            margin-top: 0;
            color: #ffd700;
        }
        .endpoints {
            margin-top: 30px;
        }
        .endpoint {
            background: rgba(255, 255, 255, 0.1);
            padding: 15px;
            margin: 10px 0;
            border-radius: 8px;
            border-left: 4px solid #ffd700;
        }
        .endpoint code {
            background: rgba(0, 0, 0, 0.3);
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
        }
        .status {
            text-align: center;
            font-size: 1.2em;
            margin: 20px 0;
            padding: 15px;
            background: rgba(0, 255, 0, 0.2);
            border-radius: 8px;
            border: 1px solid rgba(0, 255, 0, 0.3);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Docker Python Framework</h1>
        
        <div class="status">
            ✅ Application is running successfully!
        </div>
        
        <div class="info-grid">
            <div class="info-card">
                <h3>🕒 Server Time</h3>
                <p>{{ current_time }}</p>
            </div>
            <div class="info-card">
                <h3>🐍 Python Version</h3>
                <p>{{ python_version }}</p>
            </div>
            <div class="info-card">
                <h3>🌐 Host Information</h3>
                <p>Host: {{ host }}<br>Port: {{ port }}</p>
            </div>
            <div class="info-card">
                <h3>📦 Environment</h3>
                <p>Debug: {{ debug_mode }}<br>Container: {{ in_container }}</p>
            </div>
        </div>
        
        <div class="endpoints">
            <h3>🔗 Available Endpoints</h3>
            <div class="endpoint">
                <strong>GET /</strong> - This home page
            </div>
            <div class="endpoint">
                <strong>GET /api/health</strong> - Health check endpoint<br>
                <code>curl http://localhost:{{ port }}/api/health</code>
            </div>
            <div class="endpoint">
                <strong>GET /api/info</strong> - System information as JSON<br>
                <code>curl http://localhost:{{ port }}/api/info</code>
            </div>
            <div class="endpoint">
                <strong>GET /api/env</strong> - Environment variables<br>
                <code>curl http://localhost:{{ port }}/api/env</code>
            </div>
        </div>
        
        <div style="text-align: center; margin-top: 30px; opacity: 0.8;">
            <p>🚀 Ready to deploy your Python application!</p>
            <p>Modify <code>app/main.py</code> and <code>requirements.txt</code> to customize your application.</p>
        </div>
    </div>
</body>
</html>
"""

@app.route('/')
def home():
    """Home page with application information"""
    return render_template_string(HOME_TEMPLATE,
        current_time=datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC'),
        python_version=sys.version.split()[0],
        host=HOST,
        port=PORT,
        debug_mode=app.config['DEBUG'],
        in_container=os.path.exists('/.dockerenv')
    )

@app.route('/api/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'service': 'docker-python-framework'
    })

@app.route('/api/info')
def system_info():
    """System information endpoint"""
    return jsonify({
        'python_version': sys.version,
        'platform': sys.platform,
        'executable': sys.executable,
        'path': sys.path[:3],  # First 3 paths only
        'environment': {
            'DEBUG': os.getenv('DEBUG', 'False'),
            'PORT': PORT,
            'HOST': HOST,
            'in_container': os.path.exists('/.dockerenv')
        },
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/env')
def environment_variables():
    """Environment variables endpoint (filtered for security)"""
    # Only show safe environment variables
    safe_vars = {}
    for key, value in os.environ.items():
        if not any(sensitive in key.upper() for sensitive in ['PASSWORD', 'SECRET', 'KEY', 'TOKEN']):
            safe_vars[key] = value
    
    return jsonify({
        'environment_variables': safe_vars,
        'count': len(safe_vars),
        'timestamp': datetime.now().isoformat()
    })

@app.errorhandler(404)
def not_found(error):
    """404 error handler"""
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested resource was not found',
        'status_code': 404
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """500 error handler"""
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'An internal server error occurred',
        'status_code': 500
    }), 500

def main():
    """Main function to run the application"""
    logger.info(f"Starting Docker Python Framework application")
    logger.info(f"Python version: {sys.version}")
    logger.info(f"Debug mode: {app.config['DEBUG']}")
    logger.info(f"Server will run on {HOST}:{PORT}")
    
    try:
        # Run the Flask application
        app.run(
            host=HOST,
            port=PORT,
            debug=app.config['DEBUG'],
            threaded=True
        )
    except KeyboardInterrupt:
        logger.info("Application stopped by user")
    except Exception as e:
        logger.error(f"Application error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

