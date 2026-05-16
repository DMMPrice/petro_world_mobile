import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'print(' in content:
        new_content = content.replace('print(', 'debugPrint(')
        
        # Ensure import is present if debugPrint is used
        if 'package:flutter/foundation.dart' not in new_content:
            new_content = "import 'package:flutter/foundation.dart';\n" + new_content
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

def main():
    files_to_fix = [
        r"d:\projects\auraweb\petroleum\petro-world\lib\providers\providers.dart",
        r"d:\projects\auraweb\petroleum\petro-world\lib\screens\notification\view\notifications_screen.dart",
        r"d:\projects\auraweb\petroleum\petro-world\lib\services\logistics_service.dart",
        r"d:\projects\auraweb\petroleum\petro-world\lib\services\supabase_service.dart"
    ]
    
    for filepath in files_to_fix:
        if os.path.exists(filepath):
            process_file(filepath)

if __name__ == '__main__':
    main()
