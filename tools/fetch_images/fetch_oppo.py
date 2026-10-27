import os
import io
import json
import time
from datetime import datetime, timezone
import requests
from PIL import Image

BASE_DIR = r"F:\PRM_PROJECT_GROUP3\Project-Nhom3-PRM393\assets\images\products"
INSPECT_DIR = r"F:\PRM_PROJECT_GROUP3\Project-Nhom3-PRM393\temp_inspect"
os.makedirs(INSPECT_DIR, exist_ok=True)

HEADERS = {
    'User-Agent': 'student-project-image-collector (educational project; contact student group)'
}

items = [
    # 1. oppo_find_x8
    {
        'product_id': 'oppo_find_x8',
        'file': 'main.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/product-asset-library/find/find-x8-series/en/oppo-find-x8/main/assets/images-color-b-1.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-find-x/find-x8/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': None,
        'max_dim': 1600,
    },
    {
        'product_id': 'oppo_find_x8',
        'file': 'gallery_1.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/product-asset-library/find/find-x8-series/en/oppo-find-x8/main/assets/images-color-b-3.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-find-x/find-x8/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': None,
        'max_dim': 1600,
    },
    {
        'product_id': 'oppo_find_x8',
        'file': 'gallery_2.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/common/mkt/v2-2/find-x8-series-en/find-x8/products/black-titanium-pink.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-find-x/find-x8/specs/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': None,
        'max_dim': 1600,
    },
    {
        'product_id': 'oppo_find_x8',
        'file': 'gallery_3.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/common/mkt/v2-2/find-x8-series-en/find-x8/listpage/436-600-white-v2.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-find-x/find-x8/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': 872,
        'max_dim': None,
    },
    # 2. oppo_find_x8_pro
    {
        'product_id': 'oppo_find_x8_pro',
        'file': 'main.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/product-asset-library/find/find-x8-series/en/oppo-find-x8-pro/white-apac/assets/images-color-konka-b-1.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-find-x/find-x8-pro/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': 880,
        'max_dim': None,
    },
    {
        'product_id': 'oppo_find_x8_pro',
        'file': 'gallery_1.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/product-asset-library/find/find-x8-series/en/oppo-find-x8-pro/white-apac/assets/images-lens-phone-kon-pc-1-88.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-find-x/find-x8-pro/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': 800,
        'max_dim': None,
    },
    {
        'product_id': 'oppo_find_x8_pro',
        'file': 'gallery_2.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/common/mkt/v2-2/find-x8-series-en/find-x8-pro/products/932-720.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-find-x/find-x8-pro/specs/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': None,
        'max_dim': 1600,
    },
    {
        'product_id': 'oppo_find_x8_pro',
        'file': 'gallery_3.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/product-asset-library/find/find-x8-series/en/oppo-find-x8-pro/white-apac/assets/images-color-konka-b-3.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-find-x/find-x8-pro/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': 800,
        'max_dim': None,
    },
    # 3. oppo_reno_13_pro
    {
        'product_id': 'oppo_reno_13_pro',
        'file': 'main.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/common/mkt/v2-2/reno13-series/list-page/reno13-pro-5g/purple.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-reno/reno13-pro/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': 800,
        'max_dim': None,
    },
    {
        'product_id': 'oppo_reno_13_pro',
        'file': 'gallery_1.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/product-asset-library/reno/reno13-series/en/reno13-pro/purple-grey/v1/assets/images-design-phone-s1-1.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-reno/reno13-pro/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': None,
        'max_dim': 1600,
    },
    {
        'product_id': 'oppo_reno_13_pro',
        'file': 'gallery_2.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/common/mkt/v2-2/reno13-series/specs/reno13-pro-5g/grey-purple.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-reno/reno13-pro/specs/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': 800,
        'max_dim': None,
    },
    {
        'product_id': 'oppo_reno_13_pro',
        'file': 'gallery_3.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/product-asset-library/reno/reno13-series/en/reno13-pro/purple-grey/v1/assets/images-camera-phone-front-s1-1.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-reno/reno13-pro/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': 800,
        'max_dim': None,
    },
    # 4. oppo_reno_12_f
    {
        'product_id': 'oppo_reno_12_f',
        'file': 'main.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/common/mkt/v2-2/reno12-f-en/product/860-720-green.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-reno/reno12-f-5g/specs/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': None,
        'max_dim': 1600,
    },
    {
        'product_id': 'oppo_reno_12_f',
        'file': 'gallery_1.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/common/mkt/v2-2/reno12-f-en/product/860-720-green-orange.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-reno/reno12-f-5g/specs/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': None,
        'max_dim': 1600,
    },
    {
        'product_id': 'oppo_reno_12_f',
        'file': 'gallery_2.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/common/mkt/v2-2/reno12-f-en/listpage/427-600-orange.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-reno/reno12-f-5g/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': 800,
        'max_dim': None,
    },
    {
        'product_id': 'oppo_reno_12_f',
        'file': 'gallery_3.webp',
        'image_url': 'https://www.oppo.com/content/dam/oppo/product-asset-library/reno/reno12-series/en/reno12-f-5g-green/assets/images-ai-power-phone-amg5green-1.png',
        'source_page_url': 'https://www.oppo.com/vn/smartphones/series-reno/reno12-f-5g/',
        'source_name': 'OPPO Vietnam official',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'OPPO',
        'target_width': 800,
        'max_dim': None,
    },
]

results = []

for item in items:
    pid = item['product_id']
    fname = item['file']
    img_url = item['image_url']
    prod_dir = os.path.join(BASE_DIR, pid)
    os.makedirs(prod_dir, exist_ok=True)
    out_path = os.path.join(prod_dir, fname)

    print(f"Fetching {pid}/{fname} from {img_url}...")
    time.sleep(1.2)  # Respect polite crawling rate limit

    resp = requests.get(img_url, headers=HEADERS, timeout=20)
    if resp.status_code != 200:
        print(f"FAILED {img_url} with status {resp.status_code}")
        continue

    im = Image.open(io.BytesIO(resp.content))
    im = im.convert('RGBA')

    w, h = im.size
    target_w = item.get('target_width')
    max_d = item.get('max_dim')

    if target_w and w < target_w:
        factor = target_w / w
        new_w = target_w
        new_h = int(h * factor)
        im = im.resize((new_w, new_h), Image.Resampling.LANCZOS)
    elif max_d and max(w, h) > max_d:
        factor = max_d / max(w, h)
        new_w = int(w * factor)
        new_h = int(h * factor)
        im = im.resize((new_w, new_h), Image.Resampling.LANCZOS)

    # Ensure width is within 800 - 1600 if possible
    w, h = im.size
    if w < 800:
        factor = 800 / w
        im = im.resize((800, int(h * factor)), Image.Resampling.LANCZOS)
    elif w > 1600:
        factor = 1600 / w
        im = im.resize((1600, int(h * factor)), Image.Resampling.LANCZOS)

    # Save as WebP with high quality
    im.save(out_path, 'WEBP', quality=90)
    size_kb = round(os.path.getsize(out_path) / 1024, 1)

    # If size > 500 KB, compress
    quality = 85
    while size_kb > 500 and quality > 30:
        im.save(out_path, 'WEBP', quality=quality)
        size_kb = round(os.path.getsize(out_path) / 1024, 1)
        quality -= 10

    final_w, final_h = im.size
    print(f" Saved {pid}/{fname}: {final_w}x{final_h}, {size_kb} KB")

    results.append({
        'product_id': pid,
        'file': fname,
        'source_page_url': item['source_page_url'],
        'image_url': img_url,
        'source_name': item['source_name'],
        'license_or_terms': item['license_or_terms'],
        'author_or_credit': item['author_or_credit'],
        'downloaded_at': datetime.now(timezone.utc).isoformat(),
        'width': final_w,
        'height': final_h,
        'size_kb': size_kb
    })

with open(os.path.join(INSPECT_DIR, 'oppo_results.json'), 'w', encoding='utf-8') as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print("\nDone fetching all OPPO images! Total images saved:", len(results))
