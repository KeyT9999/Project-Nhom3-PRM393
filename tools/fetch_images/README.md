# Hướng dẫn thu thập ảnh sản phẩm SmartStore
1. Cài đặt các thư viện cần thiết: `pip install requests pillow beautifulsoup4`
2. Chạy toàn bộ quá trình tự động: `python tools/fetch_images/run_all.py`
3. Hoặc chạy từng hãng theo thứ tự: `fetch_apple.py` -> `fetch_samsung.py` -> `fetch_xiaomi.py` -> `fetch_oppo.py`
4. Dữ liệu nguồn và metadata kích thước/dung lượng được tự động ghi vào `assets/images/products/SOURCES.csv`
5. Toàn bộ ảnh được lưu tại `assets/images/products/<product_id>/`, đúng chuẩn kích thước và dung lượng <= 500 KB.
