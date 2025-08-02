#!/usr/bin/env python3
"""
Real-time Database Monitor
Displays live statistics and monitoring data
"""

import psycopg2
import time
import os
import sys
from datetime import datetime

class DatabaseMonitor:
    def __init__(self):
        """Initialize with database configuration"""
        self.config = {
            'host': os.getenv('PGHOST', 'localhost'),
            'port': os.getenv('PGPORT', '5433'),
            'database': os.getenv('PGDATABASE', 'mydb'),
            'user': os.getenv('PGUSER', 'myuser'),
            'password': os.getenv('PGPASSWORD', 'mypass')
        }
        self.running = True

    def connect(self):
        """Establish database connection"""
        try:
            self.conn = psycopg2.connect(**self.config)
            self.cur = self.conn.cursor()
            return True
        except Exception as e:
            print(f"Error conectando: {e}")
            return False

    def get_live_stats(self):
        """Get current database statistics"""
        stats = {}
        
        # Total records
        self.cur.execute("SELECT COUNT(*) FROM call_records")
        stats['total_records'] = self.cur.fetchone()[0]
        
        # Recent imports (last hour)
        self.cur.execute("""
            SELECT COUNT(*) FROM call_records 
            WHERE created_at > NOW() - INTERVAL '1 hour'
        """)
        stats['recent_imports'] = self.cur.fetchone()[0]
        
        # Database size
        self.cur.execute("""
            SELECT pg_size_pretty(pg_database_size(current_database()))
        """)
        stats['db_size'] = self.cur.fetchone()[0]
        
        # Table size
        self.cur.execute("""
            SELECT pg_size_pretty(pg_total_relation_size('call_records'))
        """)
        stats['table_size'] = self.cur.fetchone()[0]
        
        # Active connections
        self.cur.execute("""
            SELECT COUNT(*) FROM pg_stat_activity 
            WHERE datname = current_database()
        """)
        stats['active_connections'] = self.cur.fetchone()[0]
        
        return stats

    def display_stats(self, stats):
        """Display statistics in formatted output"""
        # Clear screen
        os.system('clear' if os.name == 'posix' else 'cls')
        
        print("=" * 60)
        print("    UNIVERSAL DB - MONITOR EN TIEMPO REAL")
        print("=" * 60)
        print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print()
        
        print("📊 ESTADÍSTICAS DE LA BASE DE DATOS")
        print("-" * 40)
        print(f"Total de registros:     {stats['total_records']:,}")
        print(f"Importados (1h):        {stats['recent_imports']:,}")
        print(f"Tamaño BD:              {stats['db_size']}")
        print(f"Tamaño tabla:           {stats['table_size']}")
        print(f"Conexiones activas:     {stats['active_connections']}")
        print()
        
        print("🔄 ESTADO DEL SISTEMA")
        print("-" * 40)
        print(f"Host:                   {self.config['host']}:{self.config['port']}")
        print(f"Base de datos:          {self.config['database']}")
        print(f"Usuario:                {self.config['user']}")
        print()
        
        print("⌨️  CONTROLES")
        print("-" * 40)
        print("Ctrl+C para salir")
        print("Actualización cada 5 segundos")

    def run_monitor(self):
        """Main monitoring loop"""
        if not self.connect():
            return False
        
        print("Iniciando monitor en tiempo real...")
        print("Presiona Ctrl+C para salir")
        
        try:
            while self.running:
                stats = self.get_live_stats()
                self.display_stats(stats)
                time.sleep(5)  # Update every 5 seconds
                
        except KeyboardInterrupt:
            print("\n\nMonitor detenido por el usuario.")
        except Exception as e:
            print(f"\nError en el monitor: {e}")
        finally:
            if hasattr(self, 'cur'):
                self.cur.close()
            if hasattr(self, 'conn'):
                self.conn.close()

def main():
    monitor = DatabaseMonitor()
    monitor.run_monitor()

if __name__ == "__main__":
    main()
