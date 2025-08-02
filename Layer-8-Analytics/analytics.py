#!/usr/bin/env python3
"""
Data Analytics Tool for Universal DB
Provides comprehensive analysis of imported call records.
"""

import psycopg2
import sys
import os
from datetime import datetime, timedelta
import json

class CallRecordsAnalyzer:
    def __init__(self):
        """Initialize database connection using Layer-5 configuration"""
        self.config = {
            'host': os.getenv('PGHOST', 'localhost'),
            'port': os.getenv('PGPORT', '5433'),
            'database': os.getenv('PGDATABASE', 'mydb'),
            'user': os.getenv('PGUSER', 'myuser'),
            'password': os.getenv('PGPASSWORD', 'mypass')
        }

    def connect(self):
        """Establish database connection"""
        try:
            self.conn = psycopg2.connect(**self.config)
            self.cur = self.conn.cursor()
            return True
        except Exception as e:
            print(f"Error conectando a la base de datos: {e}")
            return False

    def close(self):
        """Close database connection"""
        if hasattr(self, 'cur'):
            self.cur.close()
        if hasattr(self, 'conn'):
            self.conn.close()

    def get_basic_stats(self):
        """Get basic statistics about the dataset"""
        print("=== ESTADÍSTICAS BÁSICAS ===")
        
        # Total records
        self.cur.execute("SELECT COUNT(*) FROM call_records")
        total = self.cur.fetchone()[0]
        print(f"Total de registros: {total:,}")
        
        # Date range
        self.cur.execute("""
            SELECT MIN(created_at), MAX(created_at)
            FROM call_records 
            WHERE created_at IS NOT NULL
        """)
        date_range = self.cur.fetchone()
        if date_range[0]:
            print(f"Rango de fechas: {date_range[0]} → {date_range[1]}")
        
        # Record completeness
        self.cur.execute("""
            SELECT 
                COUNT(*) as total,
                COUNT(caller_number) as has_caller,
                COUNT(called_number) as has_called,
                COUNT(call_duration) as has_duration
            FROM call_records
        """)
        completeness = self.cur.fetchone()
        print(f"Completitud de datos:")
        print(f"  - Número origen: {completeness[1]:,} ({completeness[1]/completeness[0]*100:.1f}%)")
        print(f"  - Número destino: {completeness[2]:,} ({completeness[2]/completeness[0]*100:.1f}%)")
        print(f"  - Duración: {completeness[3]:,} ({completeness[3]/completeness[0]*100:.1f}%)")

    def analyze_call_patterns(self):
        """Analyze call patterns and trends"""
        print("\n=== PATRONES DE LLAMADAS ===")
        
        # Call duration statistics
        self.cur.execute("""
            SELECT 
                AVG(CAST(call_duration AS NUMERIC)) as avg_duration,
                MIN(CAST(call_duration AS NUMERIC)) as min_duration,
                MAX(CAST(call_duration AS NUMERIC)) as max_duration,
                STDDEV(CAST(call_duration AS NUMERIC)) as std_duration
            FROM call_records 
            WHERE call_duration ~ '^[0-9]+(\.[0-9]+)?$'
        """)
        duration_stats = self.cur.fetchone()
        if duration_stats[0]:
            print(f"Duración de llamadas (segundos):")
            print(f"  - Promedio: {duration_stats[0]:.2f}")
            print(f"  - Mínimo: {duration_stats[1]:.2f}")
            print(f"  - Máximo: {duration_stats[2]:.2f}")
            print(f"  - Desviación estándar: {duration_stats[3]:.2f}")

        # Top callers
        print(f"\nTop 10 números que más llaman:")
        self.cur.execute("""
            SELECT caller_number, COUNT(*) as call_count
            FROM call_records 
            WHERE caller_number IS NOT NULL AND caller_number != ''
            GROUP BY caller_number 
            ORDER BY call_count DESC 
            LIMIT 10
        """)
        top_callers = self.cur.fetchall()
        for i, (number, count) in enumerate(top_callers, 1):
            print(f"  {i:2d}. {number}: {count:,} llamadas")

        # Top destinations
        print(f"\nTop 10 números más llamados:")
        self.cur.execute("""
            SELECT called_number, COUNT(*) as call_count
            FROM call_records 
            WHERE called_number IS NOT NULL AND called_number != ''
            GROUP BY called_number 
            ORDER BY call_count DESC 
            LIMIT 10
        """)
        top_called = self.cur.fetchall()
        for i, (number, count) in enumerate(top_called, 1):
            print(f"  {i:2d}. {number}: {count:,} llamadas")

    def analyze_time_patterns(self):
        """Analyze temporal patterns"""
        print("\n=== PATRONES TEMPORALES ===")
        
        # Calls by hour (if timestamp data available)
        self.cur.execute("""
            SELECT 
                EXTRACT(HOUR FROM created_at) as hour,
                COUNT(*) as call_count
            FROM call_records 
            WHERE created_at IS NOT NULL
            GROUP BY EXTRACT(HOUR FROM created_at)
            ORDER BY hour
        """)
        hourly_data = self.cur.fetchall()
        if hourly_data:
            print("Distribución por hora del día:")
            for hour, count in hourly_data:
                bar = "█" * int(count / max(c[1] for c in hourly_data) * 50)
                print(f"  {int(hour):2d}:00 │{bar} {count:,}")

    def data_quality_report(self):
        """Generate data quality report"""
        print("\n=== REPORTE DE CALIDAD DE DATOS ===")
        
        # Empty or null fields
        fields_to_check = [
            'caller_number', 'called_number', 'call_duration',
            'call_status', 'call_type'
        ]
        
        for field in fields_to_check:
            self.cur.execute(f"""
                SELECT 
                    COUNT(*) as total,
                    COUNT(*) - COUNT({field}) as null_count,
                    COUNT(CASE WHEN {field} = '' THEN 1 END) as empty_count
                FROM call_records
            """)
            total, null_count, empty_count = self.cur.fetchone()
            valid_count = total - null_count - empty_count
            print(f"{field}:")
            print(f"  - Válidos: {valid_count:,} ({valid_count/total*100:.1f}%)")
            if null_count > 0:
                print(f"  - Nulos: {null_count:,} ({null_count/total*100:.1f}%)")
            if empty_count > 0:
                print(f"  - Vacíos: {empty_count:,} ({empty_count/total*100:.1f}%)")

        # Duplicate detection
        self.cur.execute("""
            SELECT COUNT(*) as total_records,
                   COUNT(DISTINCT (caller_number, called_number, call_duration, created_at)) as unique_combinations
            FROM call_records
        """)
        total, unique = self.cur.fetchone()
        potential_duplicates = total - unique
        if potential_duplicates > 0:
            print(f"\nPosibles duplicados: {potential_duplicates:,} registros")

    def export_summary(self, filename=None):
        """Export analysis summary to JSON"""
        if not filename:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"analytics_summary_{timestamp}.json"
        
        # Collect summary data
        self.cur.execute("SELECT COUNT(*) FROM call_records")
        total_records = self.cur.fetchone()[0]
        
        self.cur.execute("""
            SELECT 
                COUNT(DISTINCT caller_number) as unique_callers,
                COUNT(DISTINCT called_number) as unique_called,
                AVG(CAST(call_duration AS NUMERIC)) as avg_duration
            FROM call_records 
            WHERE caller_number IS NOT NULL 
            AND called_number IS NOT NULL
            AND call_duration ~ '^[0-9]+(\.[0-9]+)?$'
        """)
        summary_data = self.cur.fetchone()
        
        summary = {
            "analysis_timestamp": datetime.now().isoformat(),
            "total_records": total_records,
            "unique_callers": summary_data[0] if summary_data[0] else 0,
            "unique_called": summary_data[1] if summary_data[1] else 0,
            "average_duration": float(summary_data[2]) if summary_data[2] else 0,
            "database_info": {
                "host": self.config['host'],
                "port": self.config['port'],
                "database": self.config['database']
            }
        }
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2, ensure_ascii=False)
        
        print(f"\nResumen exportado a: {filename}")

    def run_full_analysis(self):
        """Run complete analysis suite"""
        if not self.connect():
            return False
        
        try:
            print("ANÁLISIS COMPLETO DE DATOS - Universal DB")
            print("=" * 50)
            print(f"Timestamp: {datetime.now()}")
            
            self.get_basic_stats()
            self.analyze_call_patterns()
            self.analyze_time_patterns()
            self.data_quality_report()
            self.export_summary()
            
            print("\n" + "=" * 50)
            print("Análisis completado exitosamente")
            
        except Exception as e:
            print(f"Error durante el análisis: {e}")
            return False
        finally:
            self.close()
        
        return True

def main():
    """Main function for command line usage"""
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        analyzer = CallRecordsAnalyzer()
        
        if command == "basic":
            if analyzer.connect():
                analyzer.get_basic_stats()
                analyzer.close()
        elif command == "patterns":
            if analyzer.connect():
                analyzer.analyze_call_patterns()
                analyzer.close()
        elif command == "quality":
            if analyzer.connect():
                analyzer.data_quality_report()
                analyzer.close()
        elif command == "export":
            if analyzer.connect():
                analyzer.export_summary()
                analyzer.close()
        elif command == "full":
            analyzer.run_full_analysis()
        else:
            print("Comandos disponibles:")
            print("  basic    - Estadísticas básicas")
            print("  patterns - Patrones de llamadas")
            print("  quality  - Reporte de calidad")
            print("  export   - Exportar resumen")
            print("  full     - Análisis completo")
    else:
        # Interactive mode
        analyzer = CallRecordsAnalyzer()
        analyzer.run_full_analysis()

if __name__ == "__main__":
    main()
