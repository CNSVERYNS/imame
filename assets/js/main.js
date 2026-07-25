/* Danedane — mağaza ön yüz davranışları (sepet, menü, filtre, bildirimler) */

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
    const cards = document.querySelectorAll("[data-product-item]");
    if (!chipGroup || !cards.length) return;

    const chips = chipGroup.querySelectorAll(".chip");
    const sideInputs = document.querySelectorAll("[data-filter-input]");
    const applyBtn = document.querySelector(".filter-side .btn-block");

    function activeMaterial() {
      const active = chipGroup.querySelector(".chip.active");
      return active ? active.dataset.filter : "all";
    }

    function applyFilters() {
      const material = activeMaterial();
      const wantFreeShipping = document.querySelector('[data-filter-input="shipping-free"]')?.checked;
      const wantNew = document.querySelector('[data-filter-input="new"]')?.checked;
      const wantBestseller = document.querySelector('[data-filter-input="bestseller"]')?.checked;
      const checkedRatings = Array.from(document.querySelectorAll('[data-filter-input="rating"]:checked'))
        .map(el => parseFloat(el.value));
      const minRating = checkedRatings.length ? Math.min(...checkedRatings) : null;

      let visibleCount = 0;
      cards.forEach(card => {
        let show = material === "all" || card.dataset.material === material;
        if (show && wantFreeShipping) show = card.dataset.shipping === "ucretsiz";
        if (show && wantNew) show = card.dataset.new === "true";
        if (show && wantBestseller) show = card.dataset.bestseller === "true";
        if (show && minRating !== null) show = parseFloat(card.dataset.rating || "0") >= minRating;
        card.style.display = show ? "" : "none";
        if (show) visibleCount++;
      });
      return visibleCount;
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
  }

  document.addEventListener("DOMContentLoaded", init);

  return {
    getCart, saveCart, addToCart, removeFromCart, setQty, clearCart, cartTotal, cartCount, formatTL, toast,
    getWishlist, saveWishlist, isInWishlist, toggleWishlist, removeFromWishlist,
  };
})();
