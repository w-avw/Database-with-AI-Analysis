#!/usr/bin/env python3
"""
Auto-import watchdog for Universal DB
Monitors a drop folder and automatically imports any .txt or .csv files
"""

import os
import sys
import time
import shutil
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# Import our simple importer
from simple_import import get_connection, ensure_table_exists, import_file

class AutoImportHandler(FileSystemEventHandler):
    def __init__(self, drop_dir, processed_dir, failed_dir):
        self.drop_dir = Path(drop_dir)
        self.processed_dir = Path(processed_dir)
        self.failed_dir = Path(failed_dir)
        
        # Create directories if they don't exist
        self.processed_dir.mkdir(exist_ok=True)
        self.failed_dir.mkdir(exist_ok=True)
        
        print(f"🎯 Auto-import initialized:")
        print(f"   📂 Drop folder: {self.drop_dir}")
        print(f"   ✅ Processed: {self.processed_dir}")
        print(f"   ❌ Failed: {self.failed_dir}")
    
    def on_created(self, event):
        if event.is_directory:
            return
            
        file_path = Path(event.src_path)
        
        # Only process .txt and .csv files
        if file_path.suffix.lower() not in ['.txt', '.csv']:
            return
        
        # Wait for file to be completely written
        self._wait_for_file_complete(file_path)
        
        print(f"\n🔔 New file detected: {file_path.name}")
        self._process_file(file_path)
    
    def _wait_for_file_complete(self, file_path, max_wait=10):
        """Wait until file is completely written"""
        for _ in range(max_wait):
            try:
                # Try to open file exclusively - if it fails, file is still being written
                with open(file_path, 'r+b') as f:
                    pass
                time.sleep(1)  # Additional safety buffer
                return
            except (IOError, OSError):
                time.sleep(1)
        print(f"⚠️  File may still be writing: {file_path.name}")
    
    def _convert_to_utf8(self, file_path):
        """Convert file to UTF-8 if needed"""
        utf8_path = file_path.with_suffix('.utf8.csv')
        
        try:
            # Try UTF-16LE first (most common for your files)
            os.system(f"iconv -f UTF-16LE -t UTF-8 '{file_path}' > '{utf8_path}' 2>/dev/null")
            
            # Check if conversion worked
            with open(utf8_path, 'r', encoding='utf-8') as f:
                first_line = f.readline()
                if 'ID;Date' in first_line or 'Source' in first_line:
                    print(f"✅ Converted from UTF-16LE to UTF-8")
                    return utf8_path
        except:
            pass
        
        try:
            # Try UTF-16BE
            os.system(f"iconv -f UTF-16BE -t UTF-8 '{file_path}' > '{utf8_path}' 2>/dev/null")
            
            with open(utf8_path, 'r', encoding='utf-8') as f:
                first_line = f.readline()
                if 'ID;Date' in first_line or 'Source' in first_line:
                    print(f"✅ Converted from UTF-16BE to UTF-8")
                    return utf8_path
        except:
            pass
        
        # If conversions failed, assume it's already UTF-8
        print(f"📄 File appears to be UTF-8 already")
        return file_path
    
    def _process_file(self, file_path):
        """Process a single file"""
        try:
            # Convert to UTF-8 if needed
            working_file = self._convert_to_utf8(file_path)
            
            # Get database connection
            conn = get_connection()
            ensure_table_exists(conn)
            
            # Import the file
            success = import_file(str(working_file), conn)
            conn.close()
            
            if success:
                # Move to processed folder
                processed_path = self.processed_dir / file_path.name
                shutil.move(str(file_path), str(processed_path))
                print(f"✅ Moved to processed: {processed_path}")
                
                # Clean up temporary UTF-8 file if it was created
                if working_file != file_path and working_file.exists():
                    working_file.unlink()
            else:
                # Move to failed folder
                failed_path = self.failed_dir / file_path.name
                shutil.move(str(file_path), str(failed_path))
                print(f"❌ Moved to failed: {failed_path}")
                
        except Exception as e:
            print(f"❌ Error processing {file_path.name}: {e}")
            try:
                failed_path = self.failed_dir / file_path.name
                shutil.move(str(file_path), str(failed_path))
                print(f"❌ Moved to failed: {failed_path}")
            except:
                print(f"❌ Could not move file to failed folder")

def main():
    drop_dir = "/workspaces/Universal-DB/drop"
    processed_dir = "/workspaces/Universal-DB/processed"
    failed_dir = "/workspaces/Universal-DB/failed"
    
    # Create drop directory if it doesn't exist
    Path(drop_dir).mkdir(exist_ok=True)
    
    # Set up file monitoring
    event_handler = AutoImportHandler(drop_dir, processed_dir, failed_dir)
    observer = Observer()
    observer.schedule(event_handler, drop_dir, recursive=False)
    
    print(f"\n🚀 Universal DB Auto-Import Started")
    print(f"👀 Watching: {drop_dir}")
    print(f"💡 Drop any .txt or .csv files here for automatic import!")
    print(f"🛑 Press Ctrl+C to stop\n")
    
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print(f"\n🛑 Stopping auto-import...")
        observer.stop()
    
    observer.join()
    print(f"✅ Auto-import stopped")

if __name__ == "__main__":
    main()
