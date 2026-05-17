import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # The exact regex for color: X in SvgPicture or generic replacements.
    # We will look for: color: (something not closing parenthesis or comma),
    # And replace with: colorFilter: const ColorFilter.mode(\1, BlendMode.srcIn),
    
    # Actually, a simpler way is just regex:
    # r"color:\s*([^,)\n]+)" -> r"colorFilter: const ColorFilter.mode(\1, BlendMode.srcIn)"
    # Since these files ONLY have deprecation warnings for `color:` in `SvgPicture`.
    
    # Wait, let's look at `lib/screens/product/views/components/notify_me_card.dart`
    #   color: Theme.of(context).iconTheme.color,
    # This isn't const. So we should use `ColorFilter.mode(\1, BlendMode.srcIn)`
    
    new_content = re.sub(r'color:\s*([^,)\n]+)(?=[,)])', r'colorFilter: ColorFilter.mode(\1, BlendMode.srcIn)', content)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

def main():
    files_to_fix = [
        r"d:\projects\auraweb\petroleum\petro-world\lib\screens\product\views\components\notify_me_card.dart",
        r"d:\projects\auraweb\petroleum\petro-world\lib\screens\product\views\components\product_list_tile.dart",
        r"d:\projects\auraweb\petroleum\petro-world\lib\screens\product\views\components\product_quantity.dart",
        r"d:\projects\auraweb\petroleum\petro-world\lib\screens\product\views\location_permission_store_availability_screen.dart",
        r"d:\projects\auraweb\petroleum\petro-world\lib\screens\product\views\product_buy_now_screen.dart",
        r"d:\projects\auraweb\petroleum\petro-world\lib\screens\profile\views\components\profile_card.dart",
        r"d:\projects\auraweb\petroleum\petro-world\lib\screens\search\views\components\search_form.dart"
    ]
    
    for filepath in files_to_fix:
        if os.path.exists(filepath):
            process_file(filepath)

if __name__ == '__main__':
    main()
