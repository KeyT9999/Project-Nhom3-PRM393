import os
import shutil
from PIL import Image

src_dir = r'F:\PRM_PROJECT_GROUP3\Project-Nhom3-PRM393\assets\images'
target_base = r'F:\PRM_PROJECT_GROUP3\Project-Nhom3-PRM393\assets\images\products'

copies = [
    ('lineup_16_promax.jpg', 'iphone_16_pro_max'),
    ('lineup_16_pro.jpg', 'iphone_16_pro'),
    ('lineup_16_plus.jpg', 'iphone_16_plus'),
    ('lineup_16_standard.jpg', 'iphone_16'),
    ('acc_airpods_pro.jpg', 'airpods_pro_2'),
    ('acc_magsafe_charger.jpg', 'magsafe_charger_25w'),
    ('acc_clear_case.jpg', 'clear_case_magsafe'),
]

copied_records = []

for src_name, folder in copies:
    dest_dir = os.path.join(target_base, folder)
    os.makedirs(dest_dir, exist_ok=True)
    dest_path = os.path.join(dest_dir, 'main.jpg')
    src_path = os.path.join(src_dir, src_name)
    
    # Check size and recompress if > 500 KB
    im = Image.open(src_path)
    # Ensure width in [800, 1600]
    w, h = im.size
    if w > 1600:
        new_w = 1600
        new_h = int(h * (1600 / w))
        im = im.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    # Save with quality=93 to ensure <= 500 KB
    im.save(dest_path, 'JPEG', quality=93)
    final_sz = os.path.getsize(dest_path)
    final_im = Image.open(dest_path)
    
    print(f'Copied {src_name} -> {folder}\\main.jpg: {final_im.size}, {final_sz/1024:.1f} KB')
