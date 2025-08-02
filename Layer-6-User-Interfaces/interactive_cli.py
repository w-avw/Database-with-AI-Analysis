#!/usr/bin/env python3
"""
Layer 6: User Interfaces - Interactive CLI
Advanced command-line interface with menus and guided operations
"""

import os
import sys
from pathlib import Path

# Add other layers to path
project_root = Path(__file__).parent.parent
sys.path.append(str(project_root / "Layer-3-Core-Import-Engine"))
sys.path.append(str(project_root / "Layer-4-File-Processing"))
sys.path.append(str(project_root / "Layer-5-Connection-Management"))

try:
    from simple_import import get_connection, import_file, show_stats, ensure_table_exists
    from file_processor import process_file
    from connection_manager import DatabaseConfig, load_environment_config
except ImportError as e:
    print(f"❌ Error importing required modules: {e}")
    print("💡 Make sure all layers are properly set up")
    sys.exit(1)

class UniversalDBCLI:
    """Interactive command-line interface for Universal DB"""
    
    def __init__(self):
        self.db_config = None
        self.setup_database()
    
    def setup_database(self):
        """Initialize database configuration"""
        print("🔧 Setting up database configuration...")
        load_environment_config()
        self.db_config = DatabaseConfig()
        
        if not self.db_config.test_connection():
            print("❌ Cannot connect to database. Please check your configuration.")
            sys.exit(1)
    
    def show_main_menu(self):
        """Display main menu options"""
        print("\n" + "="*50)
        print("🚀 Universal DB - Interactive Interface")
        print("="*50)
        print("1. 📂 Import single file")
        print("2. 📁 Process and import file (with encoding conversion)")
        print("3. 📊 Show database statistics")
        print("4. 🔧 Test database connection")
        print("5. 📋 Show recent imports")
        print("6. 🗑️  Truncate database (clear all data)")
        print("7. ❌ Exit")
        print("-"*50)
    
    def get_user_choice(self):
        """Get and validate user choice"""
        try:
            choice = input("Enter your choice (1-7): ").strip()
            return int(choice)
        except ValueError:
            print("❌ Please enter a valid number")
            return None
    
    def import_single_file(self):
        """Handle single file import"""
        file_path = input("📂 Enter file path: ").strip().strip('"\'')
        
        if not file_path:
            print("❌ No file path provided")
            return
        
        file_path = Path(file_path)
        if not file_path.exists():
            print(f"❌ File not found: {file_path}")
            return
        
        truncate = input("🗑️  Truncate table before import? (y/N): ").strip().lower()
        truncate_table = truncate in ['y', 'yes']
        
        print(f"\n🚀 Importing {file_path.name}...")
        
        conn = self.db_config.get_connection()
        if conn:
            ensure_table_exists(conn)
            success = import_file(str(file_path), conn, truncate_table)
            
            if success:
                print("✅ Import completed successfully!")
                show_stats(conn)
            else:
                print("❌ Import failed")
            
            conn.close()
    
    def process_and_import(self):
        """Handle file processing and import"""
        file_path = input("📂 Enter file path (will be processed for encoding): ").strip().strip('"\'')
        
        if not file_path:
            print("❌ No file path provided")
            return
        
        file_path = Path(file_path)
        if not file_path.exists():
            print(f"❌ File not found: {file_path}")
            return
        
        try:
            # Process file first
            print(f"\n🔄 Processing {file_path.name}...")
            processed_file = process_file(file_path)
            
            if processed_file:
                truncate = input("\n🗑️  Truncate table before import? (y/N): ").strip().lower()
                truncate_table = truncate in ['y', 'yes']
                
                print(f"\n🚀 Importing processed file...")
                
                conn = self.db_config.get_connection()
                if conn:
                    ensure_table_exists(conn)
                    success = import_file(str(processed_file), conn, truncate_table)
                    
                    if success:
                        print("✅ Processing and import completed successfully!")
                        show_stats(conn)
                    else:
                        print("❌ Import failed")
                    
                    conn.close()
            
        except Exception as e:
            print(f"❌ Error during processing: {e}")
    
    def show_database_stats(self):
        """Display database statistics"""
        print("\n📊 Fetching database statistics...")
        conn = self.db_config.get_connection()
        if conn:
            show_stats(conn)
            conn.close()
    
    def test_connection(self):
        """Test database connection"""
        print("\n🔧 Testing database connection...")
        self.db_config.show_config()
        print()
        success = self.db_config.test_connection()
        
        if success:
            print("✅ Connection test successful!")
        else:
            print("❌ Connection test failed!")
    
    def show_recent_imports(self):
        """Show recent import activity"""
        print("\n📋 Recent import activity...")
        conn = self.db_config.get_connection()
        if conn:
            try:
                with conn.cursor() as cur:
                    cur.execute("""
                        SELECT 
                            DATE(imported_at) as import_date,
                            COUNT(*) as records_imported,
                            MIN(imported_at) as first_import,
                            MAX(imported_at) as last_import
                        FROM call_records 
                        WHERE imported_at >= CURRENT_DATE - INTERVAL '7 days'
                        GROUP BY DATE(imported_at)
                        ORDER BY import_date DESC;
                    """)
                    
                    results = cur.fetchall()
                    if results:
                        print(f"{'Date':<12} {'Records':<10} {'First Import':<20} {'Last Import':<20}")
                        print("-" * 65)
                        for row in results:
                            print(f"{row[0]:<12} {row[1]:<10,} {row[2]:<20} {row[3]:<20}")
                    else:
                        print("No recent imports found")
                        
            except Exception as e:
                print(f"❌ Error fetching recent imports: {e}")
            finally:
                conn.close()
    
    def truncate_database(self):
        """Truncate all data from database"""
        print("\n⚠️  WARNING: This will delete ALL data from the database!")
        confirm1 = input("Type 'DELETE ALL DATA' to confirm: ").strip()
        
        if confirm1 == "DELETE ALL DATA":
            confirm2 = input("Are you absolutely sure? (yes/NO): ").strip().lower()
            
            if confirm2 == "yes":
                conn = self.db_config.get_connection()
                if conn:
                    try:
                        with conn.cursor() as cur:
                            cur.execute("TRUNCATE TABLE call_records;")
                            conn.commit()
                        print("✅ Database truncated successfully")
                    except Exception as e:
                        print(f"❌ Error truncating database: {e}")
                        conn.rollback()
                    finally:
                        conn.close()
            else:
                print("❌ Truncation cancelled")
        else:
            print("❌ Confirmation text incorrect. Truncation cancelled")
    
    def run(self):
        """Main application loop"""
        try:
            while True:
                self.show_main_menu()
                choice = self.get_user_choice()
                
                if choice == 1:
                    self.import_single_file()
                elif choice == 2:
                    self.process_and_import()
                elif choice == 3:
                    self.show_database_stats()
                elif choice == 4:
                    self.test_connection()
                elif choice == 5:
                    self.show_recent_imports()
                elif choice == 6:
                    self.truncate_database()
                elif choice == 7:
                    print("👋 Goodbye!")
                    break
                else:
                    print("❌ Invalid choice. Please select 1-7")
                
                input("\nPress Enter to continue...")
                
        except KeyboardInterrupt:
            print("\n\n👋 Goodbye!")
        except Exception as e:
            print(f"\n❌ Unexpected error: {e}")

def main():
    """Entry point for interactive CLI"""
    cli = UniversalDBCLI()
    cli.run()

if __name__ == "__main__":
    main()
