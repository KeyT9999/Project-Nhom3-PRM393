import os
import json
import glob
from PIL import Image
from datetime import datetime, timezone

BASE_DIR = r"F:\PRM_PROJECT_GROUP3\Project-Nhom3-PRM393\assets\images\products"
SOURCES_CSV = os.path.join(BASE_DIR, "SOURCES.csv")

# 1. Copied products metadata
copied_products = [
    {
        'product_id': 'iphone_16_pro_max',
        'file': 'main.jpg',
        'source_page_url': 'Nguồn nội bộ dự án (assets/images/lineup_16_promax.jpg)',
        'image_url': 'assets/images/lineup_16_promax.jpg',
        'source_name': 'Apple Inc. / Dự án nội bộ',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'Apple Inc.',
    },
    {
        'product_id': 'iphone_16_pro',
        'file': 'main.jpg',
        'source_page_url': 'Nguồn nội bộ dự án (assets/images/lineup_16_pro.jpg)',
        'image_url': 'assets/images/lineup_16_pro.jpg',
        'source_name': 'Apple Inc. / Dự án nội bộ',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'Apple Inc.',
    },
    {
        'product_id': 'iphone_16_plus',
        'file': 'main.jpg',
        'source_page_url': 'Nguồn nội bộ dự án (assets/images/lineup_16_plus.jpg)',
        'image_url': 'assets/images/lineup_16_plus.jpg',
        'source_name': 'Apple Inc. / Dự án nội bộ',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'Apple Inc.',
    },
    {
        'product_id': 'iphone_16',
        'file': 'main.jpg',
        'source_page_url': 'Nguồn nội bộ dự án (assets/images/lineup_16_standard.jpg)',
        'image_url': 'assets/images/lineup_16_standard.jpg',
        'source_name': 'Apple Inc. / Dự án nội bộ',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'Apple Inc.',
    },
    {
        'product_id': 'airpods_pro_2',
        'file': 'main.jpg',
        'source_page_url': 'Nguồn nội bộ dự án (assets/images/acc_airpods_pro.jpg)',
        'image_url': 'assets/images/acc_airpods_pro.jpg',
        'source_name': 'Apple Inc. / Dự án nội bộ',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'Apple Inc.',
    },
    {
        'product_id': 'magsafe_charger_25w',
        'file': 'main.jpg',
        'source_page_url': 'Nguồn nội bộ dự án (assets/images/acc_magsafe_charger.jpg)',
        'image_url': 'assets/images/acc_magsafe_charger.jpg',
        'source_name': 'Apple Inc. / Dự án nội bộ',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'Apple Inc.',
    },
    {
        'product_id': 'clear_case_magsafe',
        'file': 'main.jpg',
        'source_page_url': 'Nguồn nội bộ dự án (assets/images/acc_clear_case.jpg)',
        'image_url': 'assets/images/acc_clear_case.jpg',
        'source_name': 'Apple Inc. / Dự án nội bộ',
        'license_or_terms': 'Ảnh báo chí nhà sản xuất, dùng cho đồ án học tập',
        'author_or_credit': 'Apple Inc.',
    },
]

# Enrich copied products with actual dimensions and size
for p in copied_products:
    fpath = os.path.join(BASE_DIR, p['product_id'], p['file'])
    im = Image.open(fpath)
    p['downloaded_at'] = datetime.fromtimestamp(os.path.getmtime(fpath), tz=timezone.utc).isoformat()
    p['width'] = im.size[0]
    p['height'] = im.size[1]
    p['size_kb'] = round(os.path.getsize(fpath) / 1024, 1)

all_rows = list(copied_products)

# 2. Add Apple results
with open('temp_inspect/apple_results.json', 'r', encoding='utf-8') as f:
    all_rows.extend(json.load(f))

# 3. Add Samsung results
with open('temp_inspect/samsung_results.json', 'r', encoding='utf-8') as f:
    all_rows.extend(json.load(f))

# 4. Add Xiaomi results
with open('temp_inspect/xiaomi_results.json', 'r', encoding='utf-8') as f:
    all_rows.extend(json.load(f))

# 5. Add Oppo results
with open('temp_inspect/oppo_results.json', 'r', encoding='utf-8') as f:
    all_rows.extend(json.load(f))

# Write to SOURCES.csv
import csv
fields = [
    'product_id', 'file', 'source_page_url', 'image_url', 
    'source_name', 'license_or_terms', 'author_or_credit', 
    'downloaded_at', 'width', 'height', 'size_kb'
]

with open(SOURCES_CSV, 'w', encoding='utf-8-sig', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fields)
    writer.writeheader()
    for row in all_rows:
        writer.writerow({k: row.get(k, '') for k in fields})

print(f"Generated SOURCES.csv with {len(all_rows)} rows at {SOURCES_CSV}")
