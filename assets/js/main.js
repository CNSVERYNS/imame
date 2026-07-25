/* İMAME — mağaza ön yüz davranışları (sepet, menü, filtre, bildirimler) */

const IMAME = (() => {
  const CART_KEY = "imame_cart";

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

  /* ---------- Filtre çipleri (görsel + basit kategori filtresi) ---------- */
  function initFilterChips() {
    document.querySelectorAll("[data-filter-group]").forEach(group => {
      const chips = group.querySelectorAll(".chip");
      chips.forEach(chip => {
        chip.addEventListener("click", () => {
          chips.forEach(c => c.classList.remove("active"));
          chip.classList.add("active");
          const val = chip.dataset.filter;
          document.querySelectorAll("[data-product-item]").forEach(card => {
            const show = val === "all" || card.dataset.material === val;
            card.style.display = show ? "" : "none";
          });
        });
      });
    });
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
  }

  document.addEventListener("DOMContentLoaded", init);

  return { getCart, saveCart, addToCart, removeFromCart, setQty, clearCart, cartTotal, cartCount, formatTL, toast };
})();
