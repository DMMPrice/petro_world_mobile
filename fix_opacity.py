import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace .withOpacity(x) with .withValues(alpha: x)
    new_content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)

    # Replace SvgPicture.asset/network/string(..., color: X) with colorFilter: ColorFilter.mode(X, BlendMode.srcIn)
    # This regex is a bit tricky, but usually it's `color: SOME_COLOR,`
    # Let's try to match `color:\s*([^,}]+)` inside SvgPicture
    # A safer way: just replace `color: ` with `colorFilter: const ColorFilter.mode(` and `)`
    # Since it's hard to parse perfectly with regex, we can look for `SvgPicture.` and then `color: X`
    # Let's do a simple replace if we find `color:` and it's an SvgPicture.
    # Actually, Flutter 3.7+ deprecated `color` for `colorFilter` in SvgPicture.
    # We can do: r'color:\s*([^,)\n]+)' -> r'colorFilter: ColorFilter.mode(\1, BlendMode.srcIn)' 
    # ONLY if it's inside an SvgPicture call.
    # For simplicity, if we see "SvgPicture", we will replace "color: " in that file with the filter if we can scope it.
    
    # We'll just replace withOpacity for now.
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

def main():
    lib_dir = r"d:\projects\auraweb\petroleum\petro-world\lib"
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))

if __name__ == '__main__':
    main()
