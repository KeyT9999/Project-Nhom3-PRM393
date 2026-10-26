/* ==========================================================================
   APPLE STORE PRO – IPHONE 16 PRO MAX LIQUID-GLASS INTERACTIVE ENGINE
   Features:
   1. Dynamic Liquid-Glass Mouse-Follow Spotlight & Refraction Physics
   2. Interactive Titanium Finish Switcher (Desert, Natural, White, Black)
   3. Real-time Capacity & Price Calculator (256GB, 512GB, 1TB)
   4. Liquid-Glass Laboratory Sliders (Blur, Saturation, Ambient Orb Opacity)
   5. Lineup Selector, Accessory Bag & Verified Apple Customer Testimonials
   ========================================================================== */

const AppleStoreApp = {
  cartCount: 0,
  currentStorage: '256GB',
  currentFinish: 'desert',
  activeView: 'landing',

  storagePrices: {
    '256GB': '34.990.000 ₫',
    '512GB': '40.990.000 ₫',
    '1TB': '46.990.000 ₫'
  },

  finishThemes: {
    desert: {
      name: 'Titan Sa Mạc (Desert Titanium)',
      stops: ['#E2D7C7', '#D4C8B8', '#B8A896'],
      stroke: '#B8A896',
      buttonColor: '#8C7D6E'
    },
    natural: {
      name: 'Titan Tự Nhiên (Natural Titanium)',
      stops: ['#C4BFB8', '#9C968F', '#7E7872'],
      stroke: '#807A73',
      buttonColor: '#6B6660'
    },
    white: {
      name: 'Titan Trắng (White Titanium)',
      stops: ['#FFFFFF', '#F5F5F7', '#E5E5EA'],
      stroke: '#D1D5DB',
      buttonColor: '#9CA3AF'
    },
    black: {
      name: 'Titan Đen (Black Titanium)',
      stops: ['#404044', '#28282B', '#161618'],
      stroke: '#1F1F22',
      buttonColor: '#1F2937'
    }
  },

  reviews: [
    {
      stars: '★★★★★',
      quote: `"Khung viền Titan Sa Mạc cầm nhẹ và đầm tay bất ngờ. Nút Camera Control mới mở camera tức thì, quay video 4K 120fps đẹp như phim rạp. Thật sự xứng đáng với đẳng cấp Pro Max!"`,
      author: 'Hoàng Long',
      role: 'Chủ sở hữu iPhone 16 Pro Max 512GB (Đã xác minh)',
      avatar: 'HL'
    },
    {
      stars: '★★★★★',
      quote: `"Chip Apple A18 Pro kết hợp tản nhiệt titan mát hơn hẳn bản 15 Pro Max. Render video 4K ProRes và chơi game Ray Tracing mượt mà không hề bị bóp xung. Quá đỉnh!"`,
      author: 'Minh Tuấn',
      role: 'Video Creator & Đạo Diễn Hình Ảnh',
      avatar: 'MT'
    },
    {
      stars: '★★★★★',
      quote: `"Màn hình 6.9 inch nhưng nhờ viền mỏng kỷ lục nên cảm giác cầm không hề bị thô. Hiệu ứng Liquid-Glass và hệ sinh thái Apple VN/A đem lại trải nghiệm sang trọng tuyệt đối."`,
      author: 'Thu Thảo',
      role: 'Senior Product Designer',
      avatar: 'TT'
    }
  ],
  currentReviewIdx: 0
};

document.addEventListener('DOMContentLoaded', () => {
  setupMasterViewSwitcher();
  setupFinishColorSwitcher();
  setupStorageCapacitySelector();
  setupLiquidMouseSpotlight();
  setupLiquidGlassLabSliders();
  setupReviewsCarousel();
  setupCartActions();
  setupMobileAppInteractions();
  updateDigitalClock();
  setInterval(updateDigitalClock, 30000);
});

// 1. Master View Switcher (Landing vs Mobile vs Tokens)
function setupMasterViewSwitcher() {
  const btnLanding = document.getElementById('btnKitLanding');
  const btnMobile = document.getElementById('btnKitMobile');
  const btnTokens = document.getElementById('btnKitTokens');

  const viewLanding = document.getElementById('view_landing');
  const viewMobile = document.getElementById('view_mobile');
  const viewTokens = document.getElementById('view_tokens');

  const switchView = (viewName) => {
    AppleStoreApp.activeView = viewName;

    btnLanding?.classList.toggle('active', viewName === 'landing');
    btnMobile?.classList.toggle('active', viewName === 'mobile');
    btnTokens?.classList.toggle('active', viewName === 'tokens');

    if (viewLanding) viewLanding.classList.toggle('active', viewName === 'landing');
    if (viewMobile) viewMobile.classList.toggle('active', viewName === 'mobile');
    if (viewTokens) viewTokens.classList.toggle('active', viewName === 'tokens');

    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  btnLanding?.addEventListener('click', () => switchView('landing'));
  btnMobile?.addEventListener('click', () => switchView('mobile'));
  btnTokens?.addEventListener('click', () => switchView('tokens'));
}

// 2. Interactive Titanium Finish Switcher
function setupFinishColorSwitcher() {
  const finishButtons = document.querySelectorAll('.color-circle-btn');
  const finishLabel = document.getElementById('heroFinishLabel');

  finishButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      finishButtons.forEach(b => b.classList.remove('selected'));
      btn.classList.add('selected');

      const finishKey = btn.getAttribute('data-finish');
      applyFinishToPhone(finishKey);
    });
  });
}

function applyFinishToPhone(finishKey) {
  const theme = AppleStoreApp.finishThemes[finishKey];
  if (!theme) return;

  AppleStoreApp.currentFinish = finishKey;

  // Update label
  const finishLabel = document.getElementById('heroFinishLabel');
  if (finishLabel) {
    finishLabel.textContent = `Màu sắc: ${theme.name}`;
  }

  // Crossfade real hero photograph
  const heroImg = document.getElementById('heroPhoneRealImage');
  if (heroImg) {
    heroImg.style.opacity = '0.35';
    heroImg.style.transform = 'scale(0.96)';
    setTimeout(() => {
      if (finishKey === 'desert') {
        heroImg.src = 'images/hero_iphone_rock.jpg';
      } else if (finishKey === 'natural') {
        heroImg.src = 'images/lineup_16_pro.jpg';
      } else if (finishKey === 'white') {
        heroImg.src = 'images/lineup_16_promax.jpg';
      } else if (finishKey === 'black') {
        heroImg.src = 'images/footer_phone_dark.jpg';
      }
      heroImg.style.opacity = '1';
      heroImg.style.transform = 'scale(1)';
    }, 180);
  }

  showToast(`Đã chọn màu thật: ${theme.name}`);
}

// 3. Storage Capacity Selector
function setupStorageCapacitySelector() {
  const pills = document.querySelectorAll('.storage-pill');
  const priceDisplay = document.getElementById('heroPriceValue');

  pills.forEach(pill => {
    pill.addEventListener('click', () => {
      pills.forEach(p => p.classList.remove('active'));
      pill.classList.add('active');

      const cap = pill.getAttribute('data-capacity');
      AppleStoreApp.currentStorage = cap;

      const price = AppleStoreApp.storagePrices[cap];
      if (priceDisplay && price) {
        priceDisplay.textContent = price;
        priceDisplay.style.transform = 'scale(1.1)';
        setTimeout(() => priceDisplay.style.transform = 'scale(1)', 180);
      }

      showToast(`iPhone 16 Pro Max dung lượng ${cap} (${price})`);
    });
  });
}

// 4. Liquid-Glass Mouse-Follow Spotlight (Visible Dynamic Sheen!)
function setupLiquidMouseSpotlight() {
  const cursorGlow = document.getElementById('liquidCursorGlow');
  if (!cursorGlow) return;

  let mouseX = window.innerWidth / 2;
  let mouseY = window.innerHeight / 2;
  let currentX = mouseX;
  let currentY = mouseY;

  window.addEventListener('mousemove', (e) => {
    mouseX = e.clientX;
    mouseY = e.clientY;
  });

  // Smooth lerp for liquid inertia
  function animateGlow() {
    currentX += (mouseX - currentX) * 0.08;
    currentY += (mouseY - currentY) * 0.08;

    cursorGlow.style.left = `${currentX}px`;
    cursorGlow.style.top = `${currentY}px`;

    requestAnimationFrame(animateGlow);
  }
  requestAnimationFrame(animateGlow);
}

// 5. Liquid-Glass Laboratory Sliders (Live Optical Physics Customization)
function setupLiquidGlassLabSliders() {
  const sliderBlur = document.getElementById('sliderBlur');
  const sliderSat = document.getElementById('sliderSat');
  const sliderOrb = document.getElementById('sliderOrb');

  const labelBlur = document.getElementById('labelBlurVal');
  const labelSat = document.getElementById('labelSatVal');
  const labelOrb = document.getElementById('labelOrbVal');

  sliderBlur?.addEventListener('input', (e) => {
    const val = e.target.value;
    if (labelBlur) labelBlur.textContent = `${val}px`;
    document.documentElement.style.setProperty('--liquid-blur', `${val}px`);
  });

  sliderSat?.addEventListener('input', (e) => {
    const val = e.target.value;
    if (labelSat) labelSat.textContent = `${val}%`;
    const glassCards = document.querySelectorAll('.liquid-glass-card, .liquid-glass-navbar');
    glassCards.forEach(c => {
      c.style.backdropFilter = `blur(var(--liquid-blur)) saturate(${val}%)`;
      c.style.webkitBackdropFilter = `blur(var(--liquid-blur)) saturate(${val}%)`;
    });
  });

  sliderOrb?.addEventListener('input', (e) => {
    const val = e.target.value / 100;
    if (labelOrb) labelOrb.textContent = `${e.target.value}%`;
    const orbs = document.querySelectorAll('.liquid-orb');
    orbs.forEach(orb => orb.style.opacity = val);
  });
}

// 6. Lineup Model Direct Selection
function selectModelFromLineup(modelName, price, imgSrc, finishHint) {
  showToast(`Đã chọn xem cấu hình ${modelName} (${price})`);
  const heroH1 = document.querySelector('.hero-h1');
  const heroPrice = document.getElementById('heroPriceValue');
  const heroImg = document.getElementById('heroPhoneRealImage');

  if (heroH1) {
    heroH1.innerHTML = `${modelName}<br>Titanium Siêu Bền.<br>Đẳng Cấp Pro.`;
  }
  if (heroPrice) {
    heroPrice.textContent = price;
  }
  if (heroImg && imgSrc) {
    heroImg.style.opacity = '0.35';
    heroImg.style.transform = 'scale(0.96)';
    setTimeout(() => {
      heroImg.src = imgSrc;
      heroImg.style.opacity = '1';
      heroImg.style.transform = 'scale(1)';
    }, 180);
  }

  // Scroll smoothly to hero
  document.getElementById('hero')?.scrollIntoView({ behavior: 'smooth' });
}

// 7. Add Accessory to Cart
function addAccessoryToCart(name, price) {
  AppleStoreApp.cartCount++;
  updateCartBadge();
  showToast(`✓ Đã thêm ${name} (${price}) vào túi hàng!`);
}

// 8. Reviews Carousel
function setupReviewsCarousel() {
  const prevBtn = document.getElementById('btnReviewPrev');
  const nextBtn = document.getElementById('btnReviewNext');

  if (prevBtn && nextBtn) {
    prevBtn.addEventListener('click', () => {
      AppleStoreApp.currentReviewIdx = (AppleStoreApp.currentReviewIdx - 1 + AppleStoreApp.reviews.length) % AppleStoreApp.reviews.length;
      renderCurrentReview();
    });

    nextBtn.addEventListener('click', () => {
      AppleStoreApp.currentReviewIdx = (AppleStoreApp.currentReviewIdx + 1) % AppleStoreApp.reviews.length;
      renderCurrentReview();
    });
  }
}

function renderCurrentReview() {
  const r = AppleStoreApp.reviews[AppleStoreApp.currentReviewIdx];
  const quoteEl = document.getElementById('reviewQuoteText');
  const nameEl = document.getElementById('reviewAuthorName');
  const roleEl = document.getElementById('reviewAuthorRole');
  const avatarEl = document.getElementById('reviewAuthorAvatar');

  if (quoteEl) quoteEl.textContent = r.quote;
  if (nameEl) nameEl.textContent = r.author;
  if (roleEl) roleEl.textContent = r.role;
  if (avatarEl) avatarEl.textContent = r.avatar;
}

// 9. Cart Actions & Counter
function setupCartActions() {
  const buyBtns = document.querySelectorAll('.trigger-buy-action');
  buyBtns.forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      AppleStoreApp.cartCount++;
      updateCartBadge();
      const finishName = AppleStoreApp.finishThemes[AppleStoreApp.currentFinish]?.name || 'Titan Sa Mạc';
      showToast(`✓ Đã thêm iPhone 16 Pro Max ${AppleStoreApp.currentStorage} (${finishName}) vào túi hàng!`);
    });
  });
}

function updateCartBadge() {
  const badge = document.getElementById('navCartCount');
  if (badge) {
    badge.textContent = AppleStoreApp.cartCount;
    badge.style.display = 'flex';
  }
}

// 10. Mobile App Interactions
function setupMobileAppInteractions() {
  const navTabs = document.querySelectorAll('.phone-nav-tab');
  navTabs.forEach(tab => {
    tab.addEventListener('click', () => {
      navTabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      const tabName = tab.querySelector('span')?.textContent || 'Mục';
      showToast(`Ứng dụng di động: Đã chuyển sang tab "${tabName}"`);
    });
  });
}

function updateDigitalClock() {
  const now = new Date();
  const timeStr = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
  const el = document.getElementById('phoneDigitalClock');
  if (el) el.textContent = timeStr;
}

// 11. Toast Notification
function showToast(message) {
  let toast = document.getElementById('nexoraGlobalToast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'nexoraGlobalToast';
    toast.className = 'nexora-toast';
    document.body.appendChild(toast);
  }
  toast.innerHTML = `<span style="color: #60A5FA;"></span> ${message}`;
  toast.classList.add('show');

  clearTimeout(window.__toastTimer);
  window.__toastTimer = setTimeout(() => {
    toast.classList.remove('show');
  }, 3400);
}
