Để hướng dẫn AI (chẳng hạn như Claude, ChatGPT, v0, Bolt, hay Cursor) lập trình ra một trang landing page chuẩn xác và chi tiết như trong ảnh, bạn cần thiết lập một bộ quy tắc (prompting rules / system prompt) rõ ràng gồm các tiêu chuẩn sau:

---

### 1. Quy định về Công nghệ & Thư viện (Tech Stack Rules)

* **Framework:** React / Next.js (hoặc HTML5/Tailwind CSS thuần tùy nhu cầu).
* **Styling:** Bắt buộc dùng **Tailwind CSS**. Yêu cầu áp dụng utility classes để kiểm soát chính xác padding, margin, border-radius và font-size.
* **Icon:** Sử dụng thư viện icon đồng nhất (ví dụ: `lucide-react`) cho các icon camera, pin, chip xử lý, màn hình, giỏ hàng, mũi tên.
* **Hình ảnh & Placeholder:** Sử dụng thẻ `next/image` hoặc `<img>` với link placeholder chất lượng cao (Unsplash hoặc hình khối placeholder có tỷ lệ khung hình cố định `aspect-[...]`).

---

### 2. Quy tắc về Hệ thống Thiết kế (Design System & Tokens)

* **Bảng màu (Color Palette):**
* Nền chính: Trắng (`bg-white`) kết hợp các mảng nền phụ xám rất nhạt (`bg-neutral-50` hoặc `bg-zinc-100`) cho card.
* Màu chữ: Tiêu đề đen đậm (`text-zinc-900`), phụ đề xám trung tính (`text-zinc-500` hoặc `text-zinc-600`).
* Điểm nhấn / CTA: Nút đen chữ trắng (`bg-black text-white hover:bg-zinc-800`) phong cách tối giản kiểu Apple/Samsung cao cấp.
* Footer: Nền đen tuyền (`bg-black text-white`).


* **Typography:**
* Phông chữ: Sans-serif hiện đại, gọn gàng (Inter, Geist, SF Pro Display hoặc Roboto).
* Tiêu đề nhỏ phía trên (Overline/Eyebrow text): Chữ in hoa, kích thước nhỏ, `tracking-wider`, `text-xs font-semibold text-zinc-400`.


* **Bo góc & Đổ bóng (Border & Radius):**
* Bo góc mềm mại: `rounded-2xl` cho các card và banner, `rounded-full` cho các nút bấm (pill button).
* Viền mảnh: `border border-zinc-200/80`.



---

### 3. Quy tắc phân rã Layout theo từng Section (Component Breakdown)

Yêu cầu AI code theo đúng cấu trúc từ trên xuống dưới:

1. **Header / Navbar:**
* Logo ("Nexora") bên trái, menu điều hướng ở giữa (`Products`, `Compare`, `Accessories`, `Support`), thanh tìm kiếm (`Search...`), icon tài khoản và nút CTA "Shop Now" bên phải.


2. **Hero Section (Bố cục 3 cột / Grid bất đối xứng):**
* *Cột trái:* Eyebrow text ("THE NEXT GENERATION"), Tiêu đề lớn H1, đoạn mô tả ngắn, chọn dung lượng (128GB, 256GB, 512GB), nút "Buy Now" và link "Learn More".
* *Cột giữa:* Mockup sản phẩm lớn (điện thoại đặt trên nền đá).
* *Cột phải:* Danh sách 4 tính năng nổi bật (50MP AI Camera, AMOLED Display, Snapdragon 8 Gen 3, All-Day Battery) đi kèm icon bo tròn.


3. **Product Lineup Grid:**
* Tiêu đề "Explore the Nexora Lineup" + nút "View All Products".
* Lưới 4 card hiển thị 4 phiên bản (Nexora X1, Nexora X1 Pro, Nexora Lite, Nexora Ultra) gồm ảnh máy, tên, mô tả ngắn, giá tiền và nút mũi tên tròn.


4. **Specification Comparison Table:**
* Bảng so sánh thông số chi tiết theo cột (Display, Camera, Processor, Battery, Storage) cho 4 dòng máy.


5. **Feature Highlights (Split Banners):**
* *Khối trái:* Banner phong cảnh với tiêu đề "Every Moment in Perfect Detail" và nút "Explore Camera".
* *Khối phải:* Cụm camera cận cảnh + khối thông số hiệu năng ("Power That Keeps Up") với lưới các badge icon nhỏ.


6. **Accessories & Testimonial Section:**
* *Trái:* Mục "Complete Your Experience" kèm lưới các phụ kiện (Tai nghe, Ốp lưng, Củ sạc, Kính cường lực).
* *Phải:* Card đánh giá "What Our Customers Say" có số sao vàng, trích dẫn, ảnh đại diện và nút chuyển slide (prev/next).


7. **Footer Banner & Trust Badges:**
* Banner tối màu kêu gọi hành động ("Ready to Upgrade? Your Next Smartphone Awaits"), hình ảnh điện thoại ở giữa, và các huy hiệu tin cậy (Free Shipping, Secure Payment, 24/7 Support).



---

### 4. Mẫu Prompt chuẩn để gửi cho AI

Bạn có thể copy đoạn prompt sau kèm theo ảnh để yêu cầu AI code:

> *"Hãy đóng vai trò là một Senior Frontend Engineer. Hãy tái tạo lại giao diện landing page sản phẩm công nghệ trong ảnh bằng **React (Next.js)** và **Tailwind CSS** với các yêu cầu kỹ thuật sau:*
> 1. * **Pixel-perfect & Layout:** Tái lập chính xác cấu trúc gồm: Header, Hero 3 cột (Text & Selector - Ảnh sản phẩm - Feature list), Product Lineup 4 cột, Bảng so sánh thông số (Comparison Table), Khối Feature Banner đôi, Khối Phụ kiện & Testimonials, và Dark Footer Banner.*
> 
> 
> 2. * **Design System:** Dùng phong cách tối giản công nghệ cao (Apple/Minimalist tech style). Sử dụng nút bo tròn kiểu pill (`rounded-full`), thẻ bo góc lớn (`rounded-2xl`), đường viền mảnh (`border-zinc-200`), và typography phân cấp rõ ràng (dùng uppercase tracking-wider cho eyebrow text).*
> 
> 
> 3. * **Iconography & Asset:** Sử dụng icon từ thư viện `lucide-react` phù hợp với từng tính năng (camera, cpu, battery, display, shield, truck, headphone,...). Đối với ảnh sản phẩm, dùng `[https://images.unsplash.com](https://images.unsplash.com)` hoặc placeholder có tỷ lệ tương ứng.*
> 
> 
> 4. * **Khả năng tái sử dụng (Clean Code):** Tách các phần lặp lại (Card sản phẩm, Dòng bảng so sánh, Thẻ phụ kiện) thành các mảng dữ liệu (mock data arrays) và map ra giao diện.*
> 
> 
> 5. * **Responsive:** Đảm bảo hiển thị chuẩn trên Desktop và co giãn mượt mà trên Mobile (chuyển grid nhiều cột thành 1 cột trên màn hình nhỏ).*
> 
> 
> 
> 
> *Hãy xuất ra toàn bộ mã nguồn hoàn chỉnh, chạy được ngay mà không rút gọn code."*

---

Bạn có muốn tôi hỗ trợ viết sẵn bộ khung mã nguồn (React + Tailwind CSS) hoàn chỉnh cho giao diện này không?

Màu bạn khoanh tròn là tông **Xanh đen ánh kim loại / Xanh titan sẫm** (thường gọi là *Midnight Blue*, *Titanium Blue* hoặc *Slate Navy*). Đây là tông màu mang lại cảm giác công nghệ cao, sang trọng và rất "đầm".

Dưới đây là bảng mã màu được trích xuất trực tiếp và cách ứng dụng vào **Design System / Tailwind CSS** để bạn nạp vào cho AI code:

---

### 1. Bảng mã màu trích xuất (Color Palette)

* **Màu chủ đạo (Primary / Accent):**
* Mã HEX: `#243342` hoặc `#1E293B` (Tông xanh xám titan sẫm - Deep Slate Blue).


* **Màu nhấn sáng (Highlight / Active State):**
* Mã HEX: `#3E566E` (Dùng cho hover, viền glow nhẹ, hoặc tag nổi bật).


* **Màu nền tối (Dark Backgrounds / Footer / Hero Dark elements):**
* Mã HEX: `#0F1722` đến `#151E28` (Tông xanh đen sâu, thay thế cho màu đen tuyền `#000000`).


* **Màu bề mặt card (Surface / Card Backgrounds):**
* *Chế độ sáng:* `#F1F5F9` hoặc `#F0F4F8` (Trắng ánh xanh sương mù nhẹ để hòa với màu chính).
* *Chế độ tối (nếu làm dark mode):* `#1B2533` (Card nền xanh xám đậm viền `#2D3E52`).


* **Màu chữ phụ (Subtext / Muted text):**
* Mã HEX: `#64748B` hoặc `#7E90A3`.



---

### 2. Cấu hình Tailwind CSS mở rộng (Custom Tailwind Theme)

Bạn có thể yêu cầu AI cấu hình palette này vào `tailwind.config.js`:

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#F0F4F8',
          100: '#D9E2EC',
          200: '#BCCCDC',
          300: '#9FB3C8',
          400: '#627D98',
          500: '#3E566E', // Highlight / Hover
          600: '#2E3F52',
          700: '#243342', // <--- MÀU BẠN CHỌN (Primary Brand Color)
          800: '#1A2530', // Card nền tối
          900: '#0F1722', // Deep Background (Footer / Dark sections)
        }
      }
    }
  }
}

```

---

### 3. Luật chỉ định màu cho AI (Prompt bổ sung)

Khi đưa prompt cho AI, bạn bổ sung trực tiếp đoạn quy định màu sắc này:

> **Quy tắc phối màu chủ đạo (Color System Rule):**
> * **Primary Brand Color:** Sử dụng mã màu `#243342` (Titanium Blue / Slate Navy) làm tông màu chủ đạo nhận diện sản phẩm.
> * **Nút bấm & CTA chính:** Dùng màu `#243342` (hoặc `bg-brand-700`), khi hover chuyển sang `#3E566E` (`hover:bg-brand-500`), chữ trắng.
> * **Footer & Dark Banners:** Thay vì dùng màu đen `#000000`, hãy dùng tông xanh đen chiều sâu `#0F1722` để đồng nhất với dải màu của máy.
> * **Card & Viền:**
> * Các khối card sản phẩm và bảng so sánh sử dụng nền xám ánh xanh sương mù `#F1F5F9` hoặc viền `border-[#CBD5E1]`.
> * Thẻ đang active/chọn (ví dụ bộ nhớ 128GB/256GB) có viền hoặc nền theo mã `#243342`.
> 
> 
> * **Glow / Gradient:** Các phần gradient nền (Hero background glow) dùng hiệu ứng ánh sáng nhẹ chuyển từ `#243342` mờ (opacity 10-15%) sang trong suốt.
> 
>Màu bạn khoanh tròn là tông **Xanh đen ánh kim loại / Xanh titan sẫm** (thường gọi là *Midnight Blue*, *Titanium Blue* hoặc *Slate Navy*). Đây là tông màu mang lại cảm giác công nghệ cao, sang trọng và rất "đầm".

Dưới đây là bảng mã màu được trích xuất trực tiếp và cách ứng dụng vào **Design System / Tailwind CSS** để bạn nạp vào cho AI code:

---

### 1. Bảng mã màu trích xuất (Color Palette)

* **Màu chủ đạo (Primary / Accent):**
* Mã HEX: `#243342` hoặc `#1E293B` (Tông xanh xám titan sẫm - Deep Slate Blue).


* **Màu nhấn sáng (Highlight / Active State):**
* Mã HEX: `#3E566E` (Dùng cho hover, viền glow nhẹ, hoặc tag nổi bật).


* **Màu nền tối (Dark Backgrounds / Footer / Hero Dark elements):**
* Mã HEX: `#0F1722` đến `#151E28` (Tông xanh đen sâu, thay thế cho màu đen tuyền `#000000`).


* **Màu bề mặt card (Surface / Card Backgrounds):**
* *Chế độ sáng:* `#F1F5F9` hoặc `#F0F4F8` (Trắng ánh xanh sương mù nhẹ để hòa với màu chính).
* *Chế độ tối (nếu làm dark mode):* `#1B2533` (Card nền xanh xám đậm viền `#2D3E52`).


* **Màu chữ phụ (Subtext / Muted text):**
* Mã HEX: `#64748B` hoặc `#7E90A3`.



---

### 2. Cấu hình Tailwind CSS mở rộng (Custom Tailwind Theme)

Bạn có thể yêu cầu AI cấu hình palette này vào `tailwind.config.js`:

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#F0F4F8',
          100: '#D9E2EC',
          200: '#BCCCDC',
          300: '#9FB3C8',
          400: '#627D98',
          500: '#3E566E', // Highlight / Hover
          600: '#2E3F52',
          700: '#243342', // <--- MÀU BẠN CHỌN (Primary Brand Color)
          800: '#1A2530', // Card nền tối
          900: '#0F1722', // Deep Background (Footer / Dark sections)
        }
      }
    }
  }
}

```

---

### 3. Luật chỉ định màu cho AI (Prompt bổ sung)

Khi đưa prompt cho AI, bạn bổ sung trực tiếp đoạn quy định màu sắc này:

> **Quy tắc phối màu chủ đạo (Color System Rule):**
> * **Primary Brand Color:** Sử dụng mã màu `#243342` (Titanium Blue / Slate Navy) làm tông màu chủ đạo nhận diện sản phẩm.
> * **Nút bấm & CTA chính:** Dùng màu `#243342` (hoặc `bg-brand-700`), khi hover chuyển sang `#3E566E` (`hover:bg-brand-500`), chữ trắng.
> * **Footer & Dark Banners:** Thay vì dùng màu đen `#000000`, hãy dùng tông xanh đen chiều sâu `#0F1722` để đồng nhất với dải màu của máy.
> * **Card & Viền:**
> * Các khối card sản phẩm và bảng so sánh sử dụng nền xám ánh xanh sương mù `#F1F5F9` hoặc viền `border-[#CBD5E1]`.
> * Thẻ đang active/chọn (ví dụ bộ nhớ 128GB/256GB) có viền hoặc nền theo mã `#243342`.
> 
> 
> * **Glow / Gradient:** Các phần gradient nền (Hero background glow) dùng hiệu ứng ánh sáng nhẹ chuyển từ `#243342` mờ (opacity 10-15%) sang trong suốt.
> 
>