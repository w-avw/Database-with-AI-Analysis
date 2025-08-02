#!/usr/bin/env python3
"""
SQL Query Builder and Executor
Interactive tool for custom database queries
"""

import psycopg2
import os
import sys
from datetime import datetime

class QueryBuilder:
    def __init__(self):
        """Initialize database connection"""
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
            print(f"Error conectando: {e}")
            return False

    def close(self):
        """Close connection"""
        if hasattr(self, 'cur'):
            self.cur.close()
        if hasattr(self, 'conn'):
            self.conn.close()

    def show_table_info(self):
        """Display table structure and sample data"""
        print("=== INFORMACIÓN DE LA TABLA call_records ===")
        
        # Table structure
        self.cur.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'call_records'
            ORDER BY ordinal_position
        """)
        
        columns = self.cur.fetchall()
        print("\nEstructura de la tabla:")
        print("-" * 50)
        for col_name, data_type, nullable in columns:
            null_text = "NULL" if nullable == "YES" else "NOT NULL"
            print(f"{col_name:<20} {data_type:<15} {null_text}")
        
        # Sample data
        print(f"\nDatos de ejemplo (primeras 3 filas):")
        print("-" * 80)
        self.cur.execute("SELECT * FROM call_records LIMIT 3")
        rows = self.cur.fetchall()
        
        if rows:
            # Get column names
            col_names = [desc[0] for desc in self.cur.description]
            
            # Print headers
            for col in col_names[:5]:  # First 5 columns
                print(f"{col:<15}", end=" ")
            print()
            print("-" * 80)
            
            # Print data
            for row in rows:
                for val in row[:5]:  # First 5 columns
                    val_str = str(val)[:14] if val else "NULL"
                    print(f"{val_str:<15}", end=" ")
                print()

    def get_predefined_queries(self):
        """Return list of predefined useful queries"""
        return {
            "1": {
                "name": "Top 10 números que más llaman",
                "query": """
                    SELECT caller_number, COUNT(*) as call_count
                    FROM call_records 
                    WHERE caller_number IS NOT NULL AND caller_number != ''
                    GROUP BY caller_number 
                    ORDER BY call_count DESC 
                    LIMIT 10
                """
            },
            "2": {
                "name": "Llamadas por duración (rangos)",
                "query": """
                    SELECT 
                        CASE 
                            WHEN CAST(call_duration AS NUMERIC) < 30 THEN 'Corta (< 30s)'
                            WHEN CAST(call_duration AS NUMERIC) < 180 THEN 'Media (30s-3m)'
                            WHEN CAST(call_duration AS NUMERIC) < 600 THEN 'Larga (3m-10m)'
                            ELSE 'Muy Larga (> 10m)'
                        END as duration_range,
                        COUNT(*) as count
                    FROM call_records 
                    WHERE call_duration ~ '^[0-9]+(\.[0-9]+)?$'
                    GROUP BY duration_range
                    ORDER BY COUNT(*) DESC
                """
            },
            "3": {
                "name": "Llamadas por día de la semana",
                "query": """
                    SELECT 
                        EXTRACT(DOW FROM created_at) as day_num,
                        CASE EXTRACT(DOW FROM created_at)
                            WHEN 0 THEN 'Domingo'
                            WHEN 1 THEN 'Lunes'
                            WHEN 2 THEN 'Martes'
                            WHEN 3 THEN 'Miércoles'
                            WHEN 4 THEN 'Jueves'
                            WHEN 5 THEN 'Viernes'
                            WHEN 6 THEN 'Sábado'
                        END as day_name,
                        COUNT(*) as call_count
                    FROM call_records 
                    WHERE created_at IS NOT NULL
                    GROUP BY EXTRACT(DOW FROM created_at)
                    ORDER BY day_num
                """
            },
            "4": {
                "name": "Estadísticas de duración por tipo de llamada",
                "query": """
                    SELECT 
                        call_type,
                        COUNT(*) as count,
                        AVG(CAST(call_duration AS NUMERIC)) as avg_duration,
                        MIN(CAST(call_duration AS NUMERIC)) as min_duration,
                        MAX(CAST(call_duration AS NUMERIC)) as max_duration
                    FROM call_records 
                    WHERE call_duration ~ '^[0-9]+(\.[0-9]+)?$'
                        AND call_type IS NOT NULL AND call_type != ''
                    GROUP BY call_type
                    ORDER BY count DESC
                """
            },
            "5": {
                "name": "Números con más conversaciones únicas",
                "query": """
                    SELECT 
                        caller_number,
                        COUNT(DISTINCT called_number) as unique_contacts,
                        COUNT(*) as total_calls
                    FROM call_records 
                    WHERE caller_number IS NOT NULL AND caller_number != ''
                        AND called_number IS NOT NULL AND called_number != ''
                    GROUP BY caller_number 
                    HAVING COUNT(DISTINCT called_number) > 1
                    ORDER BY unique_contacts DESC, total_calls DESC
                    LIMIT 15
                """
            }
        }

    def execute_query(self, query):
        """Execute query and display results"""
        try:
            self.cur.execute(query)
            
            # Check if it's a SELECT query
            if query.strip().upper().startswith('SELECT'):
                rows = self.cur.fetchall()
                col_names = [desc[0] for desc in self.cur.description]
                
                if rows:
                    # Print headers
                    print()
                    for col in col_names:
                        print(f"{col:<20}", end="")
                    print()
                    print("-" * (len(col_names) * 20))
                    
                    # Print data
                    for row in rows:
                        for val in row:
                            val_str = str(val) if val is not None else "NULL"
                            if len(val_str) > 19:
                                val_str = val_str[:16] + "..."
                            print(f"{val_str:<20}", end="")
                        print()
                    
                    print(f"\nFilas devueltas: {len(rows)}")
                else:
                    print("No se encontraron resultados.")
            else:
                # For non-SELECT queries
                rows_affected = self.cur.rowcount
                print(f"Query ejecutado. Filas afectadas: {rows_affected}")
                self.conn.commit()
                
        except Exception as e:
            print(f"Error ejecutando query: {e}")
            self.conn.rollback()

    def interactive_mode(self):
        """Interactive query builder interface"""
        if not self.connect():
            return
        
        print("=" * 60)
        print("  UNIVERSAL DB - CONSTRUCTOR DE CONSULTAS")
        print("=" * 60)
        
        try:
            while True:
                print("\nOpciones:")
                print("1. Ver información de la tabla")
                print("2. Consultas predefinidas")
                print("3. Ejecutar consulta personalizada")
                print("4. Salir")
                
                choice = input("\nSeleccione opción [1-4]: ").strip()
                
                if choice == "1":
                    self.show_table_info()
                
                elif choice == "2":
                    queries = self.get_predefined_queries()
                    print("\nConsultas predefinidas:")
                    for key, query_info in queries.items():
                        print(f"{key}. {query_info['name']}")
                    
                    query_choice = input("\nSeleccione consulta [1-5]: ").strip()
                    if query_choice in queries:
                        print(f"\nEjecutando: {queries[query_choice]['name']}")
                        self.execute_query(queries[query_choice]['query'])
                    else:
                        print("Opción inválida")
                
                elif choice == "3":
                    print("\nIngrese su consulta SQL (termine con ';' en una línea vacía):")
                    query_lines = []
                    while True:
                        line = input()
                        if line.strip() == ';':
                            break
                        query_lines.append(line)
                    
                    query = '\n'.join(query_lines)
                    if query.strip():
                        self.execute_query(query)
                    else:
                        print("Consulta vacía")
                
                elif choice == "4":
                    print("Saliendo...")
                    break
                
                else:
                    print("Opción inválida")
                    
        except KeyboardInterrupt:
            print("\n\nSaliendo...")
        finally:
            self.close()

def main():
    """Main function"""
    if len(sys.argv) > 1 and sys.argv[1] == "--query":
        # Direct query mode
        if len(sys.argv) > 2:
            query = " ".join(sys.argv[2:])
            builder = QueryBuilder()
            if builder.connect():
                builder.execute_query(query)
                builder.close()
        else:
            print("Uso: python3 query_builder.py --query 'SELECT * FROM call_records LIMIT 5'")
    else:
        # Interactive mode
        builder = QueryBuilder()
        builder.interactive_mode()

if __name__ == "__main__":
    main()
