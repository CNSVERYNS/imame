/* Danedane — mağaza ön yüz davranışları (sepet, menü, filtre, bildirimler) */

/* Site genelinde arama için ürün kataloğu */
const DANEDANE_PRODUCTS = [
  { id: "p1", name: "Kehribar Sultani Tesbih", cat: "Tesbih", material: "Kehribar", price: 1450, rating: 5, img: "illus-tesbih.svg", seller: "Konya El Sanatları", url: "urun-detay.html" },
  { id: "p2", name: "Oltu Taşı 33'lü Tesbih", cat: "Tesbih", material: "Oltu Taşı", price: 890, rating: 5, img: "illus-tesbih.svg", seller: "Konya El Sanatları", url: "urun-detay.html" },
  { id: "p5", name: "Sedef İşlemeli Tesbih", cat: "Tesbih", material: "Sedef", price: 1120, rating: 5, img: "illus-tesbih.svg", seller: "Sedefkar Atölyesi", url: "urun-detay.html" },
  { id: "p6", name: "Sandal Ağacı Tesbih", cat: "Tesbih", material: "Sandal Ağacı", price: 640, rating: 4, img: "illus-tesbih.svg", seller: "Konya El Sanatları", url: "urun-detay.html" },
  { id: "p7", name: "Kehribar 99'lu Tesbih", cat: "Tesbih", material: "Kehribar", price: 2100, rating: 5, img: "illus-tesbih.svg", seller: "Konya El Sanatları", url: "urun-detay.html" },
  { id: "p8", name: "Oltu Taşı Şeffaf Tesbih", cat: "Tesbih", material: "Oltu Taşı", price: 950, rating: 4, img: "illus-tesbih.svg", seller: "Erzurum Oltu Sanatları", url: "urun-detay.html" },
  { id: "p9", name: "Ceviz Ağacı Tesbih", cat: "Tesbih", material: "Ceviz Ağacı", price: 380, rating: 4, img: "illus-tesbih.svg", seller: "Konya El Sanatları", url: "urun-detay.html" },
  { id: "p10", name: "Sedef Beyaz Tesbih", cat: "Tesbih", material: "Sedef", price: 990, rating: 5, img: "illus-tesbih.svg", seller: "Sedefkar Atölyesi", url: "urun-detay.html" },
  { id: "r1", name: "Akik Taşlı Gümüş Yüzük", cat: "Yüzük", material: "Akik", price: 780, rating: 5, img: "illus-yuzuk.svg", seller: "Konya El Sanatları", url: "urun-detay.html" },
  { id: "r2", name: "Oltu Taşı Yüzük", cat: "Yüzük", material: "Oltu Taşı", price: 690, rating: 4, img: "illus-yuzuk.svg", seller: "Erzurum Oltu Sanatları", url: "urun-detay.html" },
  { id: "r3", name: "Zümrüt Kesim Yüzük", cat: "Yüzük", material: "Zümrüt Kesim", price: 1290, rating: 5, img: "illus-yuzuk.svg", seller: "Konya El Sanatları", url: "urun-detay.html" },
  { id: "r4", name: "Sade Hat Yüzük", cat: "Yüzük", material: "Taşsız", price: 520, rating: 5, img: "illus-yuzuk.svg", seller: "Trabzon Gümüş Atölyesi", url: "urun-detay.html" },
  { id: "r5", name: "Yakut Taşlı Yüzük", cat: "Yüzük", material: "Yakut", price: 1450, rating: 5, img: "illus-yuzuk.svg", seller: "Trabzon Gümüş Atölyesi", url: "urun-detay.html" },
  { id: "r6", name: "Akik Kelebek Kesim Yüzük", cat: "Yüzük", material: "Akik", price: 850, rating: 4, img: "illus-yuzuk.svg", seller: "Trabzon Gümüş Atölyesi", url: "urun-detay.html" },
  { id: "r7", name: "Oval Oltu Yüzük", cat: "Yüzük", material: "Oltu Taşı", price: 610, rating: 4, img: "illus-yuzuk.svg", seller: "Erzurum Oltu Sanatları", url: "urun-detay.html" },
  { id: "r8", name: "Zeytin Yaprağı Yüzük", cat: "Yüzük", material: "Taşsız", price: 480, rating: 5, img: "illus-yuzuk.svg", seller: "Trabzon Gümüş Atölyesi", url: "urun-detay.html" },
];

const IMAME = (() => {
  const CART_KEY = "imame_cart";
  const WISHLIST_KEY = "danedane_wishlist";

  /* ---------- Favoriler (wishlist) yardımcıları ---------- */
  function getWishlist() {
    try { return JSON.parse(localStorage.getItem(WISHLIST_KEY)) || []; }
    catch (e) { return []; }
  }
  function saveWishlist(list) {
    localStorage.setItem(WISHLIST_KEY, JSON.stringify(list));
    updateWishlistCount();
  }
  function isInWishlist(id) { return getWishlist().some(w => w.id === id); }
  function toggleWishlist(item) {
    const list = getWishlist();
    const idx = list.findIndex(w => w.id === item.id);
    let added;
    if (idx > -1) { list.splice(idx, 1); added = false; }
    else { list.push(item); added = true; }
    saveWishlist(list);
    return added;
  }
  function removeFromWishlist(id) { saveWishlist(getWishlist().filter(w => w.id !== id)); }
  function updateWishlistCount() {
    const n = getWishlist().length;
    document.querySelectorAll("[data-wishlist-count]").forEach(el => {
      el.textContent = n;
      el.style.display = n > 0 ? "flex" : "none";
    });
  }

  /* ---------- Sepet yardımcıları ---------- */
  function getCart() {
    try { return JSON.parse(localStorage.getItem(CART_KEY)) || []; }
    catch (e) { return []; }
  }
  function saveCart(cart) {
    localStorage.setItem(CART_KEY, JSON.stringify(cart));
    updateCartCount();
  }
  function addToCart(item) {
    const cart = getCart();
    const existing = cart.find(c => c.id === item.id);
    if (existing) existing.qty += item.qty || 1;
    else cart.push({ qty: 1, ...item });
    saveCart(cart);
    return cart;
  }
  function removeFromCart(id) {
    saveCart(getCart().filter(c => c.id !== id));
  }
  function setQty(id, qty) {
    const cart = getCart();
    const item = cart.find(c => c.id === id);
    if (item) item.qty = Math.max(1, qty);
    saveCart(cart);
  }
  function clearCart() { saveCart([]); }
  function cartTotal() { return getCart().reduce((s, c) => s + c.price * c.qty, 0); }
  function cartCount() { return getCart().reduce((s, c) => s + c.qty, 0); }

  function updateCartCount() {
    document.querySelectorAll("[data-cart-count]").forEach(el => {
      const n = cartCount();
      el.textContent = n;
      el.style.display = n > 0 ? "flex" : "none";
    });
  }

  function formatTL(n) {
    return n.toLocaleString("tr-TR", { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + " TL";
  }

  /* ---------- Bildirim (toast) ---------- */
  let toastTimer;
  function toast(message) {
    let el = document.querySelector(".toast");
    if (!el) {
      el = document.createElement("div");
      el.className = "toast";
      el.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M20 6L9 17l-5-5"/></svg><span></span>`;
      document.body.appendChild(el);
    }
    el.querySelector("span").textContent = message;
    el.classList.add("show");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => el.classList.remove("show"), 2600);
  }

  /* ---------- Mobil menü ---------- */
  function initMobileNav() {
    const toggle = document.querySelector(".nav-toggle");
    const nav = document.querySelector(".mobile-nav");
    const close = document.querySelector(".mobile-nav-close");
    if (!toggle || !nav) return;
    toggle.addEventListener("click", () => nav.classList.add("open"));
    close && close.addEventListener("click", () => nav.classList.remove("open"));
    nav.querySelectorAll("a").forEach(a => a.addEventListener("click", () => nav.classList.remove("open")));
    document.addEventListener("keydown", (e) => { if (e.key === "Escape") nav.classList.remove("open"); });
  }

  /* ---------- Sepete ekle butonları ---------- */
  function initAddToCart() {
    document.querySelectorAll("[data-add-cart]").forEach(btn => {
      btn.addEventListener("click", (e) => {
        e.preventDefault();
        const { id, name, price, cat, img } = btn.dataset;
        addToCart({ id, name, price: parseFloat(price), cat, img: img || "" });
        toast(`"${name}" sepete eklendi`);
      });
    });
  }

  /* ---------- Kaydırmada belirme animasyonu ---------- */
  function initFadeIn() {
    const items = document.querySelectorAll(".fade-in");
    if (!items.length) return;
    const io = new IntersectionObserver((entries) => {
      entries.forEach(en => { if (en.isIntersecting) { en.target.classList.add("is-visible"); io.unobserve(en.target); } });
    }, { threshold: 0.15 });
    items.forEach(i => io.observe(i));
  }

  /* ---------- Filtre çipleri + kenar çubuğu filtreleri (kargo, puan, öne çıkanlar) ---------- */
  function initFilterChips() {
    const chipGroup = document.querySelector("[data-filter-group]");
    const cards = Array.from(document.querySelectorAll("[data-product-item]"));
    if (!chipGroup || !cards.length) return;

    const PAGE_SIZE = 6;
    const chips = chipGroup.querySelectorAll(".chip");
    const sideInputs = document.querySelectorAll("[data-filter-input]");
    const applyBtn = document.querySelector(".filter-side .btn-block");
    const pager = document.getElementById("pagination");
    let currentPage = 1;

    function activeMaterial() {
      const active = chipGroup.querySelector(".chip.active");
      return active ? active.dataset.filter : "all";
    }

    function matchingCards() {
      const material = activeMaterial();
      const wantFreeShipping = document.querySelector('[data-filter-input="shipping-free"]')?.checked;
      const wantNew = document.querySelector('[data-filter-input="new"]')?.checked;
      const wantBestseller = document.querySelector('[data-filter-input="bestseller"]')?.checked;
      const checkedRatings = Array.from(document.querySelectorAll('[data-filter-input="rating"]:checked'))
        .map(el => parseFloat(el.value));
      const minRating = checkedRatings.length ? Math.min(...checkedRatings) : null;

      return cards.filter(card => {
        let show = material === "all" || card.dataset.material === material;
        if (show && wantFreeShipping) show = card.dataset.shipping === "ucretsiz";
        if (show && wantNew) show = card.dataset.new === "true";
        if (show && wantBestseller) show = card.dataset.bestseller === "true";
        if (show && minRating !== null) show = parseFloat(card.dataset.rating || "0") >= minRating;
        return show;
      });
    }

    function renderPagination(totalPages) {
      if (!pager) return;
      if (totalPages <= 1) { pager.innerHTML = ""; return; }
      let html = `<button class="pg-arrow" data-pg="prev" ${currentPage === 1 ? "disabled" : ""}>‹</button>`;
      for (let i = 1; i <= totalPages; i++) {
        html += `<button data-pg="${i}" class="${i === currentPage ? "active" : ""}">${i}</button>`;
      }
      html += `<button class="pg-arrow" data-pg="next" ${currentPage === totalPages ? "disabled" : ""}>›</button>`;
      pager.innerHTML = html;
      pager.querySelectorAll("[data-pg]").forEach(btn => {
        btn.addEventListener("click", () => {
          const val = btn.dataset.pg;
          if (val === "prev") currentPage = Math.max(1, currentPage - 1);
          else if (val === "next") currentPage = Math.min(totalPages, currentPage + 1);
          else currentPage = parseInt(val, 10);
          renderPage();
          document.querySelector(".filter-bar")?.scrollIntoView({ behavior: "smooth", block: "start" });
        });
      });
    }

    function renderPage() {
      const matches = matchingCards();
      const totalPages = Math.max(1, Math.ceil(matches.length / PAGE_SIZE));
      currentPage = Math.min(currentPage, totalPages);
      const start = (currentPage - 1) * PAGE_SIZE;
      const pageSet = new Set(matches.slice(start, start + PAGE_SIZE));
      cards.forEach(card => { card.style.display = pageSet.has(card) ? "" : "none"; });
      renderPagination(totalPages);
    }

    function applyFilters() {
      currentPage = 1;
      renderPage();
    }

    chips.forEach(chip => {
      chip.addEventListener("click", () => {
        chips.forEach(c => c.classList.remove("active"));
        chip.classList.add("active");
        applyFilters();
      });
    });

    sideInputs.forEach(input => input.addEventListener("change", applyFilters));
    if (applyBtn) applyBtn.addEventListener("click", (e) => { e.preventDefault(); applyFilters(); });

    applyFilters();
  }

  /* ---------- Arama kutusu ---------- */
  function initSearchOverlay() {
    const overlay = document.getElementById("search-overlay");
    const toggle = document.querySelector("[data-search-toggle]");
    if (!overlay || !toggle) return;
    const input = overlay.querySelector("input[name=q]");
    const close = document.getElementById("search-overlay-close");
    const open = () => { overlay.classList.add("open"); setTimeout(() => input && input.focus(), 50); };
    const shut = () => overlay.classList.remove("open");
    toggle.addEventListener("click", open);
    close && close.addEventListener("click", shut);
    document.addEventListener("keydown", (e) => { if (e.key === "Escape") shut(); });
  }

  /* ---------- Favori (kalp) butonları ---------- */
  function initWishlistButtons() {
    document.querySelectorAll(".product-card").forEach(card => {
      const wishBtn = card.querySelector(".product-wish");
      const addBtn = card.querySelector("[data-add-cart]");
      if (!wishBtn || !addBtn) return;
      bindWishBtn(wishBtn, addBtn.dataset);
    });
    const pdActions = document.querySelector(".pd-actions");
    if (pdActions) {
      const wishBtn = pdActions.querySelector('[aria-label="Favorilere ekle"]');
      const addBtn = pdActions.querySelector("[data-add-cart]");
      if (wishBtn && addBtn) bindWishBtn(wishBtn, addBtn.dataset);
    }
    updateWishlistCount();
  }
  function bindWishBtn(wishBtn, data) {
    const { id, name, price, cat } = data;
    if (!id) return;
    if (isInWishlist(id)) wishBtn.classList.add("active");
    wishBtn.addEventListener("click", (e) => {
      e.preventDefault();
      const added = toggleWishlist({ id, name, price: parseFloat(price), cat });
      wishBtn.classList.toggle("active", added);
      toast(added ? `"${name}" favorilere eklendi` : `"${name}" favorilerden çıkarıldı`);
    });
  }

  /* ---------- Form doğrulama geri bildirimi ---------- */
  function ensureErrorEl(field, msg) {
    if (field.querySelector(".field-error")) return field.querySelector(".field-error");
    const el = document.createElement("div");
    el.className = "field-error";
    el.textContent = msg;
    field.appendChild(el);
    return el;
  }
  function initFormValidation() {
    document.querySelectorAll('input[type="email"]').forEach(input => {
      const field = input.closest(".field");
      if (!field) return;
      ensureErrorEl(field, "Geçerli bir e-posta adresi girin.");
      input.addEventListener("blur", () => {
        if (!input.value) return;
        const valid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(input.value);
        field.classList.toggle("has-error", !valid);
      });
      input.addEventListener("input", () => field.classList.remove("has-error"));
    });

    const regPw = document.querySelector("#register-form input[type=password]");
    if (regPw) {
      const field = regPw.closest(".field");
      const bar = document.createElement("div");
      bar.className = "pw-strength";
      bar.innerHTML = '<div class="pw-strength-bar"></div>';
      const label = document.createElement("div");
      label.className = "pw-strength-label";
      field.append(bar, label);
      regPw.addEventListener("input", () => {
        const val = regPw.value;
        let score = 0;
        if (val.length >= 8) score++;
        if (/[A-Z]/.test(val)) score++;
        if (/[0-9]/.test(val)) score++;
        if (/[^A-Za-z0-9]/.test(val)) score++;
        const pct = [0, 25, 50, 75, 100][score];
        const colors = ["var(--oxblood-bright)", "var(--oxblood-bright)", "var(--gold-bright)", "var(--gold-bright)", "var(--ok)"];
        const labels = ["", "Zayıf şifre", "Orta güçte şifre", "İyi şifre", "Güçlü şifre"];
        bar.querySelector(".pw-strength-bar").style.width = pct + "%";
        bar.querySelector(".pw-strength-bar").style.background = colors[score];
        label.textContent = val ? labels[score] : "";
      });
    }

    document.querySelectorAll('input[placeholder*="TR00"]').forEach(input => {
      const field = input.closest(".field");
      if (!field) return;
      ensureErrorEl(field, 'IBAN "TR" ile başlamalı ve toplam 26 karakter olmalıdır.');
      input.addEventListener("blur", () => {
        if (!input.value) return;
        const cleaned = input.value.replace(/\s/g, "").toUpperCase();
        field.classList.toggle("has-error", !/^TR\d{24}$/.test(cleaned));
      });
      input.addEventListener("input", () => field.classList.remove("has-error"));
    });
  }

  /* ---------- Çerez onayı ---------- */
  function initCookieBar() {
    const bar = document.getElementById("cookie-bar");
    if (!bar) return;
    const KEY = "danedane_cookie_consent";
    if (!localStorage.getItem(KEY)) {
      setTimeout(() => bar.classList.add("show"), 700);
    }
    const accept = document.getElementById("cookie-accept");
    const decline = document.getElementById("cookie-decline");
    accept && accept.addEventListener("click", () => { localStorage.setItem(KEY, "accepted"); bar.classList.remove("show"); });
    decline && decline.addEventListener("click", () => { localStorage.setItem(KEY, "essential-only"); bar.classList.remove("show"); });
  }

  /* ---------- Bülten formu ---------- */
  function initNewsletter() {
    document.querySelectorAll("[data-newsletter]").forEach(form => {
      form.addEventListener("submit", (e) => {
        e.preventDefault();
        toast("Teşekkürler, listemize eklendiniz.");
        form.reset();
      });
    });
  }

  function init() {
    updateCartCount();
    initMobileNav();
    initAddToCart();
    initFadeIn();
    initFilterChips();
    initNewsletter();
    initCookieBar();
    initWishlistButtons();
    initSearchOverlay();
    initFormValidation();
  }

  document.addEventListener("DOMContentLoaded", init);

  return {
    getCart, saveCart, addToCart, removeFromCart, setQty, clearCart, cartTotal, cartCount, formatTL, toast,
    getWishlist, saveWishlist, isInWishlist, toggleWishlist, removeFromWishlist,
  };
})();
