import os
import requests
from PIL import Image
import io
import datetime
import json
import re

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 student-project-image-collector',
    'Referer': 'https://www.samsungmobilepress.com/'
}
base_dir = r'F:\PRM_PROJECT_GROUP3\Project-Nhom3-PRM393\assets\images\products'
now_str = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

models = {
    'samsung_s25_ultra': 'galaxy-s25-ultra',
    'samsung_s25': 'galaxy-s25',
    'samsung_s25_plus': 'galaxy-s25-plus',
    'samsung_z_fold6': 'galaxy-z-fold6',
    'samsung_a55': 'galaxy-a55-5g'
}

all_items = {}
for name, path in models.items():
    url = f'https://www.samsungmobilepress.com/media-assets/{path}'
    r = requests.get(url, headers=headers)
    chunks = re.findall(r'self\.__next_f\.push\(\[1,"(.*?)"\]\)', r.text)
    full_data = "".join(chunks).encode('utf-8').decode('unicode_escape')
    items = re.findall(r'\"filename\":\"([^\"]+)\"[^}]*?\"imageUrl\":\"([^\"]+)\"', full_data)
    if not items:
        items = re.findall(r'\"imageUrl\":\"([^\"]+)\"[^}]*?\"filename\":\"([^\"]+)\"', full_data)
        items = [(fn, u) for u, fn in items]
    all_items[name] = dict(items)

plan = [
    ('samsung_s25_ultra', 'main.jpg', '001-galaxy-s25ultra-titaniumsilverblue-device-spen-front.jpg'),
    ('samsung_s25_ultra', 'gallery_1.jpg', '004-galaxy-s25ultra-titaniumsilverblue-device-back.jpg'),
    ('samsung_s25_ultra', 'gallery_2.jpg', '006-galaxy-s25ultra-titaniumsilverblue-device-front-l30.jpg'),
    ('samsung_s25_ultra', 'gallery_3.jpg', '005-product-galaxy-s25ultra-titaniumsilverblue-titaniumblack-titaniumgray-titaniumwhitesilver.jpg'),
    
    ('samsung_s25', 'main.jpg', '001-galaxy-s25-icyblue-front.jpg'),
    ('samsung_s25', 'gallery_1.jpg', '003-galaxy-s25-icyblue-back.jpg'),
    ('samsung_s25', 'gallery_2.jpg', '004-galaxy-s25-icyblue-front-l30.jpg'),
    ('samsung_s25', 'gallery_3.jpg', '008-galaxy-s25-icyblue-l-side.jpg'),
    
    ('samsung_s25_plus', 'main.jpg', '001-galaxy-s25plus-navy-front.jpg'),
    ('samsung_s25_plus', 'gallery_1.jpg', '003-galaxy-s25plus-navy-back.jpg'),
    ('samsung_s25_plus', 'gallery_2.jpg', '004-galaxy-s25plus-navy-front-l30.jpg'),
    ('samsung_s25_plus', 'gallery_3.jpg', '008-galaxy-s25plus-navy-l-side.jpg'),
    
    ('samsung_z_fold6', 'main.jpg', '004-galaxy-zfold6-silvershadow-openfront115.jpg'),
    ('samsung_z_fold6', 'gallery_1.jpg', '002-galaxy-zfold6-silvershadow-openback115.jpg'),
    ('samsung_z_fold6', 'gallery_2.jpg', '001-galaxy-zfold6-silvershadow-back.jpg'),
    ('samsung_z_fold6', 'gallery_3.jpg', '007-galaxy-zfold6-silvershadow-side.jpg'),
    
    ('samsung_a55', 'main.jpg', '001-galaxy-a55-5g-awesomeiceblue-front.jpg'),
    ('samsung_a55', 'gallery_1.jpg', '003-galaxy-a55-5g-awesomeiceblue-back.jpg'),
    ('samsung_a55', 'gallery_2.jpg', '004-galaxy-a55-5g-awesomeiceblue-front-l30.jpg'),
    ('samsung_a55', 'gallery_3.jpg', '009-galaxy-a55-5g-awesomeiceblue-r-side.jpg'),
]

results = []

for pid, fname, src_key in plan:
    pdir = os.path.join(base_dir, pid)
    os.makedirs(pdir, exist_ok=True)
    dst = os.path.join(pdir, fname)
    
    img_url = all_items[pid].get(src_key)
    if not img_url:
        print(f'Error: missing {pid} {src_key}')
        continue
        
    src_page = f'https://www.samsungmobilepress.com/media-assets/{models[pid]}'
    
    r = requests.get(img_url, headers=headers)
    if r.status_code != 200:
        print(f'Failed {img_url}: {r.status_code}')
        continue
        
    im = Image.open(io.BytesIO(r.content))
    w, h = im.size
    
    if w > 1600:
        new_w = 1600
        new_h = int(h * (1600 / w))
        im = im.resize((new_w, new_h), Image.Resampling.LANCZOS)
        w, h = im.size
        
    im.save(dst, 'JPEG', quality=95)
    sz_kb = os.path.getsize(dst) / 1024
    print(f'Saved {pid}/{fname}: {w}x{h}, {sz_kb:.1f} KB (from {src_key})')
    
    results.append({
        'product_id': pid,
        'file': fname,
        'source_page_url': src_page,
        'image_url': img_url,
        'source_name': 'Samsung Mobile Press (Official Media Assets)',
        'license_or_terms': 'Ảnh báo chí chính thức nhà sản xuất (Samsung Press Kit), dùng cho đồ án học tập',
        'author_or_credit': 'Samsung Electronics',
        'downloaded_at': now_str,
        'width': w,
        'height': h,
        'size_kb': round(sz_kb, 1)
    })

with open('temp_inspect/samsung_results.json', 'w', encoding='utf-8') as f:
    json.dump(results, f, ensure_ascii=False, indent=2)
print('Done Samsung!')
