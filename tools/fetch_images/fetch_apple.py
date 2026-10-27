import os
import requests
from PIL import Image
import io
import datetime

headers = {'User-Agent': 'student-project-image-collector'}
base_dir = r'F:\PRM_PROJECT_GROUP3\Project-Nhom3-PRM393\assets\images\products'
now_str = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

apple_items = [
    # (product_id, filename, image_url, source_page, source_name, license, author, fmt, quality)
    (
        'iphone_15', 'main.webp',
        'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/iphone-15-blue-select-202309?wid=1200&hei=1200&fmt=png-alpha',
        'https://www.apple.com/vn/shop/buy-iphone/iphone-15',
        'Apple Store Vietnam (Official CDN)',
        'Ảnh sản phẩm chính thức nhà sản xuất, dùng cho đồ án học tập phi thương mại',
        'Apple Inc.',
        'WEBP', 95
    ),
    (
        'iphone_15', 'gallery_1.webp',
        'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/iphone15-digitalmat-gallery-1-202309?wid=1200&hei=1200&fmt=png-alpha',
        'https://www.apple.com/vn/shop/buy-iphone/iphone-15',
        'Apple Store Vietnam (Official CDN)',
        'Ảnh sản phẩm chính thức nhà sản xuất, dùng cho đồ án học tập phi thương mại',
        'Apple Inc.',
        'WEBP', 95
    ),
    (
        'iphone_15', 'gallery_2.jpg',
        'https://www.apple.com/newsroom/images/2023/09/apple-debuts-iphone-15-and-iphone-15-plus/article/Apple-iPhone-15-lineup-design-230912_big.jpg.large.jpg',
        'https://www.apple.com/vn/newsroom/2023/09/apple-debuts-iphone-15-and-iphone-15-plus/',
        'Apple Newsroom Vietnam',
        'Ảnh báo chí chính thức nhà sản xuất (Apple Press Kit), dùng cho đồ án học tập',
        'Apple Inc.',
        'JPEG', 92
    ),
    (
        'iphone_15', 'gallery_3.webp',
        'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/iphone15-digitalmat-gallery-3-202309?wid=1200&hei=1200&fmt=png-alpha',
        'https://www.apple.com/vn/shop/buy-iphone/iphone-15',
        'Apple Store Vietnam (Official CDN)',
        'Ảnh sản phẩm chính thức nhà sản xuất, dùng cho đồ án học tập phi thương mại',
        'Apple Inc.',
        'WEBP', 95
    ),
    (
        'apple_20w_adapter', 'main.png',
        'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/MHJE3?wid=1000&hei=1000&fmt=png-alpha',
        'https://www.apple.com/vn/shop/product/MHJE3ZA/A/bo-tiep-hop-nguon-usb-c-20w',
        'Apple Store Vietnam (Official CDN)',
        'Ảnh sản phẩm chính thức nhà sản xuất, dùng cho đồ án học tập phi thương mại',
        'Apple Inc.',
        'PNG', None
    ),
    (
        'apple_20w_adapter', 'gallery_1.png',
        'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/MHJE3_AV1?wid=1000&hei=1000&fmt=png-alpha',
        'https://www.apple.com/vn/shop/product/MHJE3ZA/A/bo-tiep-hop-nguon-usb-c-20w',
        'Apple Store Vietnam (Official CDN)',
        'Ảnh sản phẩm chính thức nhà sản xuất, dùng cho đồ án học tập phi thương mại',
        'Apple Inc.',
        'PNG', None
    ),
    (
        'apple_20w_adapter', 'gallery_2.png',
        'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/MHJE3_AV2?wid=1000&hei=1000&fmt=png-alpha',
        'https://www.apple.com/vn/shop/product/MHJE3ZA/A/bo-tiep-hop-nguon-usb-c-20w',
        'Apple Store Vietnam (Official CDN)',
        'Ảnh sản phẩm chính thức nhà sản xuất, dùng cho đồ án học tập phi thương mại',
        'Apple Inc.',
        'PNG', None
    )
]

results = []

for pid, fname, img_url, src_page, src_name, lic, author, fmt, q in apple_items:
    pdir = os.path.join(base_dir, pid)
    os.makedirs(pdir, exist_ok=True)
    dst = os.path.join(pdir, fname)
    
    r = requests.get(img_url, headers=headers)
    if r.status_code != 200:
        print(f'Failed {img_url}: status {r.status_code}')
        continue
    
    im = Image.open(io.BytesIO(r.content))
    w, h = im.size
    
    # Resize if w > 1600
    if w > 1600:
        new_w = 1600
        new_h = int(h * (1600 / w))
        im = im.resize((new_w, new_h), Image.Resampling.LANCZOS)
        w, h = im.size
    
    # Save
    if fmt == 'WEBP':
        im.save(dst, 'WEBP', quality=q)
    elif fmt == 'JPEG':
        if im.mode in ('RGBA', 'LA', 'P'):
            bg = Image.new('RGB', im.size, (255, 255, 255))
            bg.paste(im, mask=im.split()[-1] if im.mode == 'RGBA' else None)
            im = bg
        im.save(dst, 'JPEG', quality=q)
    else: # PNG
        im.save(dst, 'PNG', optimize=True)
        
    sz_kb = os.path.getsize(dst) / 1024
    print(f'Saved {pid}/{fname}: {w}x{h}, {sz_kb:.1f} KB (format {fmt})')
    
    results.append({
        'product_id': pid,
        'file': fname,
        'source_page_url': src_page,
        'image_url': img_url,
        'source_name': src_name,
        'license_or_terms': lic,
        'author_or_credit': author,
        'downloaded_at': now_str,
        'width': w,
        'height': h,
        'size_kb': round(sz_kb, 1)
    })

import json
with open('temp_inspect/apple_results.json', 'w', encoding='utf-8') as f:
    json.dump(results, f, ensure_ascii=False, indent=2)
print('Done Apple!')
