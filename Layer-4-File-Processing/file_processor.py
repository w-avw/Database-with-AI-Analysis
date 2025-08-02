#!/usr/bin/env python3
"""
Layer 4: File Processing
Handles encoding conversion and file preparation for import
"""

import os
import sys
import subprocess
from pathlib import Path

def detect_encoding(file_path):
    """Detect file encoding using the file command"""
    try:
        result = subprocess.run(['file', '--mime-encoding', str(file_path)], 
                              capture_output=True, text=True)
        encoding = result.stdout.split(':')[1].strip()
        return encoding
    except:
        return 'unknown'

def convert_to_utf8(file_path, output_path=None):
    """Convert file from UTF-16 to UTF-8"""
    if output_path is None:
        output_path = file_path.with_suffix('.utf8.csv')
    
    file_path = Path(file_path)
    output_path = Path(output_path)
    
    print(f"🔄 Converting {file_path.name} to UTF-8...")
    
    # Try UTF-16LE first (most common for Windows files)
    try:
        result = subprocess.run([
            'iconv', '-f', 'UTF-16LE', '-t', 'UTF-8', 
            str(file_path)
        ], capture_output=True, text=True, check=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(result.stdout)
        
        # Validate conversion
        with open(output_path, 'r', encoding='utf-8') as f:
            first_line = f.readline()
            if 'ID;Date' in first_line or ';' in first_line:
                print(f"✅ Successfully converted from UTF-16LE")
                return output_path
    except subprocess.CalledProcessError:
        pass
    
    # Try UTF-16BE if LE failed
    try:
        result = subprocess.run([
            'iconv', '-f', 'UTF-16BE', '-t', 'UTF-8',
            str(file_path)
        ], capture_output=True, text=True, check=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(result.stdout)
            
        print(f"✅ Successfully converted from UTF-16BE")
        return output_path
    except subprocess.CalledProcessError:
        pass
    
    # If both fail, assume it's already UTF-8
    print(f"📄 File appears to be UTF-8 already")
    return file_path

def validate_csv_structure(file_path):
    """Validate that file has proper CSV structure with semicolon delimiter"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            first_line = f.readline().strip()
            
            # Check for semicolon delimiter
            if ';' not in first_line:
                return False, "No semicolon delimiter found"
            
            # Check for expected headers
            expected_headers = ['ID', 'Date', 'Source']
            if not any(header in first_line for header in expected_headers):
                return False, "Expected headers not found"
            
            # Count fields
            field_count = len(first_line.split(';'))
            if field_count < 10:
                return False, f"Too few fields ({field_count}), expected 20+"
            
            return True, f"Valid CSV with {field_count} fields"
            
    except Exception as e:
        return False, f"Validation error: {e}"

def process_file(input_path, output_dir=None):
    """Complete file processing pipeline"""
    input_path = Path(input_path)
    
    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")
    
    if output_dir is None:
        output_dir = Path.cwd() / "processed"
    
    output_dir = Path(output_dir)
    output_dir.mkdir(exist_ok=True)
    
    print(f"📂 Processing: {input_path.name}")
    
    # Step 1: Detect encoding
    encoding = detect_encoding(input_path)
    print(f"🔍 Detected encoding: {encoding}")
    
    # Step 2: Convert to UTF-8 if needed
    if 'utf-16' in encoding.lower() or 'utf16' in encoding.lower():
        utf8_path = output_dir / f"{input_path.stem}.utf8.csv"
        processed_file = convert_to_utf8(input_path, utf8_path)
    else:
        # Copy to output directory with .csv extension
        processed_file = output_dir / f"{input_path.stem}.csv"
        import shutil
        shutil.copy2(input_path, processed_file)
        print(f"📋 Copied to: {processed_file}")
    
    # Step 3: Validate structure
    is_valid, message = validate_csv_structure(processed_file)
    if is_valid:
        print(f"✅ {message}")
    else:
        print(f"❌ Validation failed: {message}")
        return None
    
    # Step 4: Show file stats
    with open(processed_file, 'r', encoding='utf-8') as f:
        line_count = sum(1 for _ in f)
    
    print(f"📊 File ready: {line_count:,} lines")
    
    return processed_file

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 file_processor.py <input_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    
    try:
        processed_file = process_file(input_file)
        if processed_file:
            print(f"\n🎉 File processing complete!")
            print(f"📁 Output: {processed_file}")
            print(f"💡 Ready for import with Layer-3-Core-Import-Engine")
        else:
            print(f"\n❌ File processing failed")
            sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
