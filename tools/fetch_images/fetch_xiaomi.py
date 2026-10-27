import requests
from PIL import Image
import io
import os
import datetime
import json

base_dir = r"F:\PRM_PROJECT_GROUP3\Project-Nhom3-PRM393\assets\images\products"

def process_and_save(img_bytes, dest_path, max_dim=1600, min_dim=800, max_kb=500):
    im = Image.open(io.BytesIO(img_bytes))
    w, h = im.size
    
    # check if needs resize
    if max(w, h) > max_dim:
        scale = max_dim / max(w, h)
        w, h = int(w * scale), int(h * scale)
        im = im.resize((w, h), Image.Resampling.LANCZOS)
    elif max(w, h) < min_dim:
        scale = min_dim / max(w, h)
        w, h = int(w * scale), int(h * scale)
        im = im.resize((w, h), Image.Resampling.LANCZOS)
    
    # decide format
    if im.mode in ('RGBA', 'LA') or (im.mode == 'P' and 'transparency' in im.info):
        im_rgba = im.convert('RGBA')
        buf = io.BytesIO()
        im_rgba.save(buf, format='WEBP', quality=90)
        dest_file = os.path.splitext(dest_path)[0] + '.webp'
        if len(buf.getvalue()) > max_kb * 1024:
            buf = io.BytesIO()
            im_rgba.save(buf, format='WEBP', quality=80)
    else:
        im_rgb = im.convert('RGB')
        buf = io.BytesIO()
        im_rgb.save(buf, format='JPEG', quality=90)
        dest_file = os.path.splitext(dest_path)[0] + '.jpg'
        if len(buf.getvalue()) > max_kb * 1024:
            buf = io.BytesIO()
            im_rgb.save(buf, format='JPEG', quality=80)
            
    with open(dest_file, 'wb') as f:
        f.write(buf.getvalue())
        
    final_size_kb = round(os.path.getsize(dest_file) / 1024, 1)
    im_final = Image.open(dest_file)
    fw, fh = im_final.size
    print(f"Saved {dest_file}: {fw}x{fh}, {final_size_kb} KB")
    return os.path.basename(dest_file), fw, fh, final_size_kb

headers = {'User-Agent': 'student-project-image-collector'}
results = []
downloaded_at = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# 1. xiaomi_15
x15_items = [
    ('main', 'https://www.mi.com/vn/product/xiaomi-15/', 'https://i02.appmifile.com/496_item_vn/03/03/2025/c3e301e7d03d9b9a289b807e7ddc7b1b.png'),
    ('gallery_1', 'https://www.mi.com/vn/product/xiaomi-15/', 'https://i02.appmifile.com/mi-com-product/fly-birds/xiaomi-15/pc/031d30f2cfab177f07a181e0cd03fcf4.png'),
    ('gallery_2', 'https://www.mi.com/vn/product/xiaomi-15/', 'https://i02.appmifile.com/mi-com-product/fly-birds/xiaomi-15/pc/83b79d00dcc202c40732b6e775eebc2e.jpg'),
    ('gallery_3', 'https://www.mi.com/vn/product/xiaomi-15/', 'https://i02.appmifile.com/mi-com-product/fly-birds/xiaomi-15/pc/8eb3e2077532372335921249aa85dc5b.png'),
]

prod_dir = os.path.join(base_dir, 'xiaomi_15')
os.makedirs(prod_dir, exist_ok=True)
for fname, page_url, img_url in x15_items:
    r = requests.get(img_url, headers=headers)
    target = os.path.join(prod_dir, fname)
    saved_name, w, h, size_kb = process_and_save(r.content, target)
    results.append({
        'product_id': 'xiaomi_15',
        'file': saved_name,
        'source_page_url': page_url,
        'image_url': img_url,
        'source_name': 'Xiaomi Vietnam Official Store',
        'license_or_terms': 'ảnh sản phẩm nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'Xiaomi Corporation',
        'downloaded_at': downloaded_at,
        'width': w,
        'height': h,
        'size_kb': size_kb
    })

# 2. xiaomi_poco_f6_pro
poco_items = [
    ('main', 'https://www.mi.com/global/product/poco-f6-pro/', 'https://i02.appmifile.com/633_operatorx_operatorx_opx/24/05/2024/2febbb736455504c9ac0f80ee9feb97a.png'),
    ('gallery_1', 'https://www.po.co/global/product/poco-f6-pro/', 'https://i02.appmifile.com/mi-com-product/fly-birds/poco-f6-pro/PC/ultra_slim2.png'),
    ('gallery_2', 'https://www.po.co/global/product/poco-f6-pro/', 'https://i02.appmifile.com/mi-com-product/fly-birds/poco-f6-pro/PC/ultra_slim1.png'),
    ('gallery_3', 'https://www.po.co/global/product/poco-f6-pro/', 'https://i02.appmifile.com/mi-com-product/fly-birds/poco-f6-pro/PC/ultra_slim3.png'),
]

prod_dir = os.path.join(base_dir, 'xiaomi_poco_f6_pro')
os.makedirs(prod_dir, exist_ok=True)
for fname, page_url, img_url in poco_items:
    r = requests.get(img_url, headers=headers)
    target = os.path.join(prod_dir, fname)
    saved_name, w, h, size_kb = process_and_save(r.content, target)
    results.append({
        'product_id': 'xiaomi_poco_f6_pro',
        'file': saved_name,
        'source_page_url': page_url,
        'image_url': img_url,
        'source_name': 'Xiaomi / POCO Official Global Store',
        'license_or_terms': 'ảnh sản phẩm nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'Xiaomi / POCO',
        'downloaded_at': downloaded_at,
        'width': w,
        'height': h,
        'size_kb': size_kb
    })

# 3. xiaomi_redmi_note_14_pro
redmi_items = [
    ('main', 'https://www.mi.com/vn/product/redmi-note-14-pro-plus-5g/specs/', 'https://i02.appmifile.com/786_item_vn/08/01/2025/0f0b61d30545e793390c29646e99ee54.png'),
    ('gallery_1', 'https://www.mi.com/vn/product/redmi-note-14-pro-plus-5g/specs/', 'https://i02.appmifile.com/mi-com-product/fly-birds/redmi-note-14-pro-plus-5g/pc/dfc60c255c898343728eb15230dcac60.jpg'),
    ('gallery_2', 'https://www.mi.com/vn/product/redmi-note-14-pro-plus-5g/', 'https://i02.appmifile.com/mi-com-product/fly-birds/redmi-note-14-pro-plus-5g/pc/camera.jpg'),
    ('gallery_3', 'https://www.mi.com/vn/product/redmi-note-14-pro-plus-5g/', 'https://i02.appmifile.com/mi-com-product/fly-birds/redmi-note-14-pro-plus-5g/pc/Dual2-gobal.jpg'),
]

prod_dir = os.path.join(base_dir, 'xiaomi_redmi_note_14_pro')
os.makedirs(prod_dir, exist_ok=True)
for fname, page_url, img_url in redmi_items:
    r = requests.get(img_url, headers=headers)
    target = os.path.join(prod_dir, fname)
    saved_name, w, h, size_kb = process_and_save(r.content, target)
    results.append({
        'product_id': 'xiaomi_redmi_note_14_pro',
        'file': saved_name,
        'source_page_url': page_url,
        'image_url': img_url,
        'source_name': 'Xiaomi Vietnam Official Store',
        'license_or_terms': 'ảnh sản phẩm nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'Xiaomi Corporation',
        'downloaded_at': downloaded_at,
        'width': w,
        'height': h,
        'size_kb': size_kb
    })

with open(r'temp_inspect\xiaomi_results.json', 'w', encoding='utf-8') as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print("Saved Xiaomi results successfully!")
