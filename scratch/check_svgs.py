import os
import re

def check_svgs(directory):
    # This pattern looks for signs followed by space or space followed by sign then space
    pattern1 = re.compile(r'[+-]\s')
    pattern2 = re.compile(r'\s[+-]\s')
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.svg'):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                        path_matches = re.finditer(r'(d|points)="([^"]+)"', content)
                        for pm in path_matches:
                            attr_val = pm.group(2)
                            # Look for signs not followed by digit or dot
                            for sm in re.finditer(r'[+-][^0-9\.]', attr_val):
                                 print(f"Found suspicious sign in {path}:")
                                 print(f"  Context: ...{attr_val[max(0, sm.start()-10):min(len(attr_val), sm.end()+10)]}...")
                except Exception as e:
                    print(f"Error reading {path}: {e}")

if __name__ == "__main__":
    check_svgs('assets')
