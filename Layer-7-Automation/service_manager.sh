#!/bin/bash
# Layer 7: Automation - Drop Folder Service
# Systemd service configuration for production deployment

# Create systemd service file
create_service_file() {
    local service_file="/etc/systemd/system/universal-db-auto-import.service"
    local project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    
    echo "🔧 Creating systemd service file..."
    
    sudo tee "$service_file" > /dev/null << EOF
[Unit]
Description=Universal DB Auto Import Service
After=network.target postgresql.service docker.service
Wants=postgresql.service docker.service

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$project_root/Layer-7-Automation
Environment=PYTHONPATH=$project_root/Layer-3-Core-Import-Engine:$project_root/Layer-4-File-Processing:$project_root/Layer-5-Connection-Management
ExecStart=/usr/bin/python3 $project_root/Layer-7-Automation/auto_import.py
Restart=always
RestartSec=10

# Load environment from Layer-1
EnvironmentFile=-$project_root/Layer-1-Infrastructure/.env

# Logging
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    echo "✅ Service file created: $service_file"
}

# Install and start service
install_service() {
    echo "🚀 Installing Universal DB Auto Import Service..."
    
    # Create service file
    create_service_file
    
    # Reload systemd
    sudo systemctl daemon-reload
    
    # Enable service
    sudo systemctl enable universal-db-auto-import.service
    
    echo "✅ Service installed and enabled"
    echo "💡 Use 'sudo systemctl start universal-db-auto-import' to start"
}

# Remove service
uninstall_service() {
    echo "🗑️  Uninstalling Universal DB Auto Import Service..."
    
    # Stop service if running
    sudo systemctl stop universal-db-auto-import.service 2>/dev/null
    
    # Disable service
    sudo systemctl disable universal-db-auto-import.service 2>/dev/null
    
    # Remove service file
    sudo rm -f /etc/systemd/system/universal-db-auto-import.service
    
    # Reload systemd
    sudo systemctl daemon-reload
    
    echo "✅ Service uninstalled"
}

# Show service status
show_status() {
    echo "📊 Universal DB Auto Import Service Status"
    echo "=========================================="
    
    if systemctl is-active --quiet universal-db-auto-import.service; then
        echo "🟢 Status: Running"
    else
        echo "🔴 Status: Stopped"
    fi
    
    echo ""
    echo "📋 Service Details:"
    systemctl status universal-db-auto-import.service --no-pager
    
    echo ""
    echo "📜 Recent Logs:"
    sudo journalctl -u universal-db-auto-import.service --lines=10 --no-pager
}

# Show help
show_help() {
    echo "Universal DB Auto Import Service Manager"
    echo "======================================="
    echo ""
    echo "Commands:"
    echo "  install     Install and enable the auto-import service"
    echo "  uninstall   Remove the auto-import service"
    echo "  status      Show service status and logs"
    echo "  start       Start the service"
    echo "  stop        Stop the service"
    echo "  restart     Restart the service"
    echo "  logs        Show service logs"
    echo "  help        Show this help message"
    echo ""
    echo "Usage: $0 <command>"
}

# Main script logic
case "$1" in
    install)
        install_service
        ;;
    uninstall)
        uninstall_service
        ;;
    status)
        show_status
        ;;
    start)
        sudo systemctl start universal-db-auto-import.service
        echo "🚀 Service started"
        ;;
    stop)
        sudo systemctl stop universal-db-auto-import.service
        echo "🛑 Service stopped"
        ;;
    restart)
        sudo systemctl restart universal-db-auto-import.service
        echo "🔄 Service restarted"
        ;;
    logs)
        sudo journalctl -u universal-db-auto-import.service -f
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
