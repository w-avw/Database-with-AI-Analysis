#!/usr/bin/env python3
"""
Simple PostgreSQL importer for semicolon-separated data files.
Follows the insight: "minimal custom code, reusable, and easy to adjust"
"""

import os
import sys
import psycopg2
import argparse
from pathlib import Path

# PostgreSQL connection settings
PG_CONFIG = {
    "host": os.getenv("PGHOST", "localhost"),
    "port": int(os.getenv("PGPORT", "5432")),
    "database": os.getenv("PGDATABASE", "mydb"),
    "user": os.getenv("PGUSER", "myuser"),
    "password": os.getenv("PGPASSWORD", "mypassword")
}

def get_connection():
    """Get PostgreSQL connection"""
    try:
        return psycopg2.connect(**PG_CONFIG)
    except psycopg2.Error as e:
        print(f"❌ Database connection failed: {e}")
        sys.exit(1)

def ensure_table_exists(conn):
    """Create table if it doesn't exist"""
    create_table_sql = """
    CREATE TABLE IF NOT EXISTS call_records (
        id               SERIAL PRIMARY KEY,
        source_id        BIGINT,
        date_time        TIMESTAMP,
        source_type      TEXT,
        source           TEXT,
        source_fleet     TEXT,
        destination_type TEXT,
        destination      TEXT,
        destination_fleet TEXT,
        service_type     TEXT,
        service_type_info TEXT,
        ai_security      TEXT,
        e2ee_security    TEXT,
        disconnection_cause TEXT,
        duration_secs    INTEGER,
        time_in_queue_secs INTEGER,
        priority         INTEGER,
        source_location  TEXT,
        cell_reselection TEXT,
        status           TEXT,
        voice_recording  TEXT,
        call_forwarding  TEXT,
        source_nms       TEXT,
        network_controller TEXT,
        utc_offset_minutes INTEGER,
        imported_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """
    
    with conn.cursor() as cur:
        cur.execute(create_table_sql)
        conn.commit()
    print("✅ Table 'call_records' ready")

def import_file(file_path, conn, truncate=False):
    """Import a semicolon-separated file directly using PostgreSQL COPY"""
    
    if not os.path.exists(file_path):
        print(f"❌ File not found: {file_path}")
        return False
    
    print(f"📂 Processing: {os.path.basename(file_path)}")
    
    try:
        with conn.cursor() as cur:
            if truncate:
                cur.execute("TRUNCATE TABLE call_records;")
                print("🗑️  Truncated existing data")
            
            # Use PostgreSQL's COPY command with semicolon delimiter
            copy_sql = """
            COPY call_records (
                source_id, date_time, source_type, source, source_fleet,
                destination_type, destination, destination_fleet, service_type,
                service_type_info, ai_security, e2ee_security, disconnection_cause,
                duration_secs, time_in_queue_secs, priority, source_location,
                cell_reselection, status, voice_recording, call_forwarding,
                source_nms, network_controller, utc_offset_minutes
            )
            FROM STDIN
            WITH (FORMAT CSV, DELIMITER ';', HEADER true, ENCODING 'UTF8');
            """
            
            with open(file_path, 'r', encoding='utf-8') as f:
                cur.copy_expert(copy_sql, f)
            
            # Get count of imported records
            cur.execute("SELECT COUNT(*) FROM call_records WHERE imported_at >= CURRENT_TIMESTAMP - INTERVAL '1 minute';")
            count = cur.fetchone()[0]
            
            conn.commit()
            print(f"✅ Successfully imported {count} records")
            return True
            
    except psycopg2.Error as e:
        print(f"❌ Import failed: {e}")
        conn.rollback()
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def show_stats(conn):
    """Show database statistics"""
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM call_records;")
        total = cur.fetchone()[0]
        
        cur.execute("""
            SELECT 
                COUNT(*) as recent_imports,
                MAX(imported_at) as last_import
            FROM call_records 
            WHERE imported_at >= CURRENT_TIMESTAMP - INTERVAL '1 hour';
        """)
        recent, last_import = cur.fetchone()
        
        print(f"\n📊 Database Statistics:")
        print(f"   📋 Total records: {total:,}")
        print(f"   📈 Recent imports (1h): {recent:,}")
        print(f"   🕐 Last import: {last_import}")

def main():
    parser = argparse.ArgumentParser(description="Simple PostgreSQL importer for semicolon-separated data")
    parser.add_argument("file", nargs="?", help="File to import")
    parser.add_argument("--truncate", action="store_true", help="Truncate table before import")
    parser.add_argument("--stats", action="store_true", help="Show database statistics")
    parser.add_argument("--watch", type=str, help="Watch directory for new files")
    
    args = parser.parse_args()
    
    # Get database connection
    conn = get_connection()
    ensure_table_exists(conn)
    
    if args.stats:
        show_stats(conn)
    elif args.file:
        success = import_file(args.file, conn, args.truncate)
        if success:
            show_stats(conn)
    elif args.watch:
        print(f"🔍 Watching directory: {args.watch}")
        print("(Watch functionality can be added with watchdog library)")
    else:
        parser.print_help()
    
    conn.close()

if __name__ == "__main__":
    main()
