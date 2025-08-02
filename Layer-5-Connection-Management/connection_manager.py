#!/usr/bin/env python3
"""
Layer 5: Connection Management
Centralized database connection handling and configuration
"""

import os
import sys
import psycopg2
from pathlib import Path

class DatabaseConfig:
    """Centralized database configuration management"""
    
    def __init__(self):
        self.config = {
            "host": os.getenv("PGHOST", "localhost"),
            "port": int(os.getenv("PGPORT", "5433")),
            "database": os.getenv("PGDATABASE", "mydb"),
            "user": os.getenv("PGUSER", "myuser"),
            "password": os.getenv("PGPASSWORD", "mypass")
        }
    
    def get_connection_string(self):
        """Get PostgreSQL connection string"""
        return f"postgresql://{self.config['user']}:{self.config['password']}@{self.config['host']}:{self.config['port']}/{self.config['database']}"
    
    def get_connection(self):
        """Get database connection with error handling"""
        try:
            conn = psycopg2.connect(**self.config)
            return conn
        except psycopg2.OperationalError as e:
            print(f"❌ Database connection failed: {e}")
            return None
        except Exception as e:
            print(f"❌ Unexpected connection error: {e}")
            return None
    
    def test_connection(self):
        """Test database connectivity"""
        print(f"🔗 Testing connection to {self.config['host']}:{self.config['port']}/{self.config['database']}")
        
        conn = self.get_connection()
        if conn:
            try:
                with conn.cursor() as cur:
                    cur.execute("SELECT version();")
                    version = cur.fetchone()[0]
                    print(f"✅ Connected successfully")
                    print(f"📊 PostgreSQL version: {version}")
                conn.close()
                return True
            except Exception as e:
                print(f"❌ Connection test failed: {e}")
                return False
        return False
    
    def show_config(self):
        """Display current configuration (without password)"""
        safe_config = self.config.copy()
        safe_config['password'] = '***'
        
        print("🔧 Database Configuration:")
        for key, value in safe_config.items():
            print(f"   {key.upper()}: {value}")

class ConnectionPool:
    """Simple connection pool for multiple operations"""
    
    def __init__(self, config, max_connections=5):
        self.config = config
        self.max_connections = max_connections
        self.connections = []
        self.in_use = set()
    
    def get_connection(self):
        """Get a connection from the pool"""
        # Reuse existing connection
        for conn in self.connections:
            if conn not in self.in_use and not conn.closed:
                self.in_use.add(conn)
                return conn
        
        # Create new connection if under limit
        if len(self.connections) < self.max_connections:
            conn = self.config.get_connection()
            if conn:
                self.connections.append(conn)
                self.in_use.add(conn)
                return conn
        
        return None
    
    def return_connection(self, conn):
        """Return connection to pool"""
        if conn in self.in_use:
            self.in_use.remove(conn)
    
    def close_all(self):
        """Close all connections in pool"""
        for conn in self.connections:
            if not conn.closed:
                conn.close()
        self.connections.clear()
        self.in_use.clear()

def load_environment_config():
    """Load configuration from environment file if it exists"""
    env_file = Path("../Layer-1-Infrastructure/.env")
    
    if env_file.exists():
        print(f"📄 Loading configuration from {env_file}")
        with open(env_file, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    os.environ[key] = value
        print("✅ Environment configuration loaded")
    else:
        print("⚠️  No .env file found, using default configuration")

def main():
    """Test and display connection management functionality"""
    print("🚀 Universal DB - Connection Management")
    print("=" * 40)
    
    # Load environment configuration
    load_environment_config()
    
    # Initialize database configuration
    db_config = DatabaseConfig()
    db_config.show_config()
    
    print()
    
    # Test connection
    if db_config.test_connection():
        print("\n🎉 Connection management ready!")
        
        # Demo connection pool
        print("\n🔄 Testing connection pool...")
        pool = ConnectionPool(db_config, max_connections=3)
        
        # Get multiple connections
        conn1 = pool.get_connection()
        conn2 = pool.get_connection()
        
        if conn1 and conn2:
            print("✅ Connection pool working correctly")
            pool.return_connection(conn1)
            pool.return_connection(conn2)
            pool.close_all()
        
    else:
        print("\n❌ Connection management setup failed")
        print("💡 Check your database configuration and ensure Docker container is running")
        sys.exit(1)

if __name__ == "__main__":
    main()
