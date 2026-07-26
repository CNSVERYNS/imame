/* TesbihYol — mağaza ön yüz davranışları (sepet, menü, filtre, bildirimler) */

const IMAME = (() => {
  const CART_KEY = "imame_cart";
  const WISHLIST_KEY = "tesbihyol_wishlist";

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

  /* ---------- Supabase ürün kataloğu ---------- */
  const MATERIAL_SLUG = {
    "Kehribar": "kehribar", "Oltu Taşı": "oltu", "Sedef": "sedef",
    "Sandal Ağacı": "sandal", "Ceviz Ağacı": "ceviz", "Akik": "akik",
    "Zümrüt Kesim": "zumrut", "Yakut": "yakut", "Taşsız": "sade",
  };
  function materialSlug(material) {
    return MATERIAL_SLUG[material] || (material || "").toLocaleLowerCase("tr").replace(/[^a-z0-9]+/g, "-");
  }
  function escapeHtml(str) {
    return String(str ?? "").replace(/[&<>"']/g, ch => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[ch]));
  }
  function starsHtml(rating) {
    const r = Math.round(rating || 0);
    return "★".repeat(r) + "☆".repeat(5 - r);
  }
  function fallbackImg(category) {
    return category === "Yüzük" ? "assets/img/illus-yuzuk.svg" : "assets/img/illus-tesbih.svg";
  }
  function productCardHtml(p) {
    const isNew = p.created_at && (Date.now() - new Date(p.created_at).getTime()) < 14 * 24 * 3600 * 1000;
    const isBestseller = (p.total_sold || 0) >= 3;
    const img = p.image_url || fallbackImg(p.category);
    const sellerName = (p.sellers && p.sellers.store_name) || "TesbihYol Satıcısı";
    const badge = p.featured
      ? '<span class="product-badge">Öne Çıkan</span>'
      : (isBestseller ? '<span class="product-badge">Çok Satan</span>' : (isNew ? '<span class="product-badge product-badge--new">Yeni</span>' : ""));
    return `
      <div class="product-card fade-in" data-product-item data-material="${materialSlug(p.material)}" data-rating="${p.rating || 0}" data-shipping="${p.shipping_option}" data-price="${p.price}" data-created="${p.created_at || ""}" data-sold="${p.total_sold || 0}"${p.featured ? ' data-featured="true"' : ""}${isBestseller ? ' data-bestseller="true"' : ""}${isNew ? ' data-new="true"' : ""}>
        <div class="product-media">
          ${badge}
          <button type="button" class="product-wish" aria-label="Favorilere ekle"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M12 21s-7-4.5-9.5-9C1 8 2 4 6 4c2 0 4 1.5 6 4 2-2.5 4-4 6-4 4 0 5 4 3.5 8-2.5 4.5-9.5 9-9.5 9z"/></svg></button>
          <img src="${escapeHtml(img)}" alt="${escapeHtml(p.name)}" loading="lazy">
        </div>
        <div class="product-info">
          <span class="product-cat">${escapeHtml(p.material || p.category || "")}${p.size_info ? " · " + escapeHtml(p.size_info) : ""}</span>
          <span class="product-seller">Satıcı: <a href="magaza.html?seller=${p.seller_id}">${escapeHtml(sellerName)}</a></span>
          <h3 class="product-name"><a href="urun-detay.html?id=${p.id}">${escapeHtml(p.name)}</a></h3>
          <div class="product-meta"><span class="stars">${starsHtml(p.rating)}</span></div>
          <div class="product-row">
            <span class="price">${formatTL(p.price)}</span>
            <button class="add-btn" aria-label="Sepete ekle" data-add-cart data-id="${p.id}" data-name="${escapeHtml(p.name)}" data-price="${p.price}" data-cat="${escapeHtml(p.category)}" data-img="${escapeHtml(img)}">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M12 5v14M5 12h14"/></svg>
            </button>
          </div>
        </div>
      </div>`;
  }
  async function initDynamicCatalog() {
    const grid = document.querySelector("[data-dynamic-grid]");
    if (!grid || typeof DB === "undefined") return;
    const category = grid.dataset.category || undefined;
    const limit = grid.dataset.limit ? parseInt(grid.dataset.limit, 10) : undefined;
    try {
      const products = await DB.fetchProducts({ category, limit });
      grid.innerHTML = products.length
        ? products.map(productCardHtml).join("")
        : '<p class="muted">Bu kategoride henüz ürün yok.</p>';
    } catch (err) {
      console.error("[TesbihYol] Ürünler yüklenemedi:", err);
      grid.innerHTML = '<p class="muted">Ürünler yüklenirken bir sorun oluştu.</p>';
    }
  }

  /* ---------- Supabase ürün detay sayfası ---------- */
  async function initProductDetail() {
    const root = document.querySelector("[data-product-detail]");
    if (!root || typeof DB === "undefined") return;
    const id = new URLSearchParams(location.search).get("id");
    if (!id) { root.innerHTML = '<p class="muted">Ürün bulunamadı.</p>'; return; }

    let p;
    try {
      p = await DB.fetchProductById(id);
    } catch (err) {
      console.error("[TesbihYol] Ürün yüklenemedi:", err);
      root.innerHTML = '<p class="muted">Ürün bulunamadı ya da yayından kaldırılmış.</p>';
      return;
    }

    const img = p.image_url || fallbackImg(p.category);
    const sellerName = (p.sellers && p.sellers.store_name) || "TesbihYol Satıcısı";
    const set = (id2, text) => { const el = document.getElementById(id2); if (el) el.textContent = text; };

    document.title = `${p.name} — TesbihYol`;
    const catLink = document.getElementById("pd-breadcrumb-cat");
    if (catLink) { catLink.href = p.category === "Yüzük" ? "yuzuk.html" : "tesbih.html"; catLink.textContent = p.category; }
    set("pd-breadcrumb-name", p.name);
    set("pd-cat", `${p.category} · ${p.material || ""}`);
    set("pd-title", p.name);
    set("pd-stars", starsHtml(p.rating));
    set("pd-stock", p.stock > 0 ? "Stokta var" : "Stokta yok");
    const stockEl = document.getElementById("pd-stock");
    if (stockEl) stockEl.style.color = p.stock > 0 ? "var(--ok)" : "var(--oxblood-bright)";
    set("pd-price", formatTL(p.price));
    set("pd-desc", p.description || "");
    set("pd-desc-full", p.description || "Bu ürün için henüz açıklama eklenmedi.");
    set("pd-seller-name", sellerName);
    set("pd-seller-avatar", sellerName.charAt(0).toUpperCase() + ".");
    const sellerLink = document.getElementById("pd-seller-link");
    if (sellerLink) sellerLink.href = `magaza.html?seller=${p.seller_id}`;
    set("pd-stock-note", p.stock > 0 && p.stock <= 10 ? `Son ${p.stock} adet kaldı` : "");

    const mainImg = document.getElementById("pd-main-img");
    if (mainImg) { mainImg.src = img; mainImg.alt = p.name; }

    const addBtn = document.getElementById("pd-add-cart");
    if (addBtn) {
      if (p.stock <= 0) { addBtn.disabled = true; addBtn.textContent = "Stokta Yok"; }
    }

    const specBody = document.getElementById("pd-specs");
    if (specBody) {
      const rows = [
        ["Kategori", p.category],
        ["Malzeme", p.material || "-"],
        p.size_info ? ["Ölçü / Boncuk Sayısı", p.size_info] : null,
        p.weight_grams ? ["Ağırlık", `${p.weight_grams} gram`] : null,
        ["Stok", `${p.stock} adet`],
      ].filter(Boolean);
      specBody.innerHTML = rows.map(([k, v]) => `<tr><td>${escapeHtml(k)}</td><td>${escapeHtml(String(v))}</td></tr>`).join("");
    }

    const ld = document.getElementById("product-jsonld");
    if (ld) {
      ld.textContent = JSON.stringify({
        "@context": "https://schema.org", "@type": "Product", name: p.name, description: p.description || "",
        image: location.origin + "/" + img, brand: { "@type": "Brand", name: "TesbihYol" },
        offers: {
          "@type": "Offer", url: location.href, priceCurrency: "TRY", price: String(p.price),
          availability: p.stock > 0 ? "https://schema.org/InStock" : "https://schema.org/OutOfStock",
          seller: { "@type": "Organization", name: sellerName },
        },
      });
    }

    const breadcrumbLd = document.createElement("script");
    breadcrumbLd.type = "application/ld+json";
    breadcrumbLd.textContent = JSON.stringify({
      "@context": "https://schema.org", "@type": "BreadcrumbList",
      itemListElement: [
        { "@type": "ListItem", position: 1, name: "Anasayfa", item: location.origin + "/index.html" },
        { "@type": "ListItem", position: 2, name: p.category, item: location.origin + "/" + (p.category === "Yüzük" ? "yuzuk.html" : "tesbih.html") },
        { "@type": "ListItem", position: 3, name: p.name, item: location.href },
      ],
    });
    document.head.appendChild(breadcrumbLd);

    const similarGrid = document.querySelector("[data-similar-grid]");
    if (similarGrid) {
      try {
        const similar = await DB.fetchProducts({ category: p.category, excludeId: p.id, limit: 4 });
        similarGrid.innerHTML = similar.length ? similar.map(productCardHtml).join("") : "";
        if (!similar.length) document.getElementById("pd-similar-wrap").style.display = "none";
      } catch (err) {
        console.error("[TesbihYol] Benzer ürünler yüklenemedi:", err);
      }
    }

    window.dispatchEvent(new CustomEvent("tesbihyol:product-loaded", { detail: p }));
  }

  /* ---------- Supabase satıcı mağaza vitrini (magaza.html?seller=) ---------- */
  async function initSellerStorefront() {
    const root = document.querySelector("[data-seller-storefront]");
    if (!root || typeof DB === "undefined") return;
    const sellerId = new URLSearchParams(location.search).get("seller");
    if (!sellerId) { root.innerHTML = '<p class="muted">Mağaza bulunamadı.</p>'; return; }

    let seller, products;
    try {
      seller = await DB.fetchSellerStorefront(sellerId);
      products = await DB.fetchProducts({ sellerId, limit: 100 });
    } catch (err) {
      console.error("[TesbihYol] Mağaza yüklenemedi:", err);
      root.innerHTML = '<p class="muted">Mağaza bulunamadı ya da henüz onaylanmadı.</p>';
      return;
    }

    document.title = `${seller.store_name} — TesbihYol Satıcısı`;
    const set = (id, text) => { const el = document.getElementById(id); if (el) el.textContent = text; };

    set("seller-breadcrumb-name", seller.store_name);
    set("seller-avatar", seller.store_name.charAt(0).toUpperCase() + ".");
    set("seller-name", seller.store_name);
    set("seller-since", `TesbihYol'da ${new Date(seller.created_at).getFullYear()}'den beri satış yapıyor`);
    set("seller-bio", seller.bio || `${seller.store_name}, TesbihYol üzerinde el yapımı tesbih ve yüzük satan bağımsız bir satıcıdır.`);
    set("seller-product-count", String(products.length));

    const grid = document.getElementById("seller-product-grid");
    if (grid) {
      grid.innerHTML = products.length
        ? products.map(productCardHtml).join("")
        : '<p class="muted">Bu satıcının henüz yayınlanmış ürünü yok.</p>';
    }

    const ld = document.getElementById("seller-jsonld");
    if (ld) {
      ld.textContent = JSON.stringify({
        "@context": "https://schema.org", "@type": "BreadcrumbList",
        itemListElement: [
          { "@type": "ListItem", position: 1, name: "Anasayfa", item: location.origin + "/index.html" },
          { "@type": "ListItem", position: 2, name: seller.store_name, item: location.href },
        ],
      });
    }
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
    const sortSelect = document.querySelector(".sort-select");
    const pager = document.getElementById("pagination");
    let currentPage = 1;

    function activeMaterial() {
      const active = chipGroup.querySelector(".chip.active");
      return active ? active.dataset.filter : "all";
    }

    /* Sponsorlu (öne çıkan) ürünler, gerçek satış adedi ve puan bir arada
       ağırlıklandırılır; yorum sistemi devreye girdikçe puan bileşeni daha
       belirleyici hale gelecek. */
    function recommendedScore(card) {
      const featured = card.dataset.featured === "true";
      const bestseller = card.dataset.bestseller === "true";
      const rating = parseFloat(card.dataset.rating || "0");
      const isNewItem = card.dataset.new === "true";
      return (featured ? 3 : 0) + (bestseller ? 1.5 : 0) + rating * 0.6 + (isNewItem ? 0.4 : 0);
    }

    function sortCards(list) {
      const mode = sortSelect ? sortSelect.value : "recommended";
      const sorted = list.slice();
      if (mode === "price-asc") {
        sorted.sort((a, b) => parseFloat(a.dataset.price || "0") - parseFloat(b.dataset.price || "0"));
      } else if (mode === "price-desc") {
        sorted.sort((a, b) => parseFloat(b.dataset.price || "0") - parseFloat(a.dataset.price || "0"));
      } else if (mode === "newest") {
        sorted.sort((a, b) => new Date(b.dataset.created || 0) - new Date(a.dataset.created || 0));
      } else if (mode === "top-rated") {
        sorted.sort((a, b) => parseFloat(b.dataset.rating || "0") - parseFloat(a.dataset.rating || "0"));
      } else {
        sorted.sort((a, b) => recommendedScore(b) - recommendedScore(a));
      }
      return sorted;
    }

    function matchingCards() {
      const material = activeMaterial();
      const wantFreeShipping = document.querySelector('[data-filter-input="shipping-free"]')?.checked;
      const wantNew = document.querySelector('[data-filter-input="new"]')?.checked;
      const wantBestseller = document.querySelector('[data-filter-input="bestseller"]')?.checked;
      const checkedRatings = Array.from(document.querySelectorAll('[data-filter-input="rating"]:checked'))
        .map(el => parseFloat(el.value));
      const minRating = checkedRatings.length ? Math.min(...checkedRatings) : null;
      const priceMinRaw = document.querySelector('[data-filter-input="price-min"]')?.value;
      const priceMaxRaw = document.querySelector('[data-filter-input="price-max"]')?.value;
      const priceMin = priceMinRaw ? parseFloat(priceMinRaw) : null;
      const priceMax = priceMaxRaw ? parseFloat(priceMaxRaw) : null;

      const filtered = cards.filter(card => {
        let show = material === "all" || card.dataset.material === material;
        if (show && wantFreeShipping) show = card.dataset.shipping === "ucretsiz";
        if (show && wantNew) show = card.dataset.new === "true";
        if (show && wantBestseller) show = card.dataset.bestseller === "true";
        if (show && minRating !== null) show = parseFloat(card.dataset.rating || "0") >= minRating;
        if (show && priceMin !== null) show = parseFloat(card.dataset.price || "0") >= priceMin;
        if (show && priceMax !== null) show = parseFloat(card.dataset.price || "0") <= priceMax;
        return show;
      });
      return sortCards(filtered);
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
      const pageItems = matches.slice(start, start + PAGE_SIZE);
      const pageSet = new Set(pageItems);
      cards.forEach(card => { card.style.display = pageSet.has(card) ? "" : "none"; });
      const grid = cards[0] && cards[0].parentElement;
      if (grid) pageItems.forEach(card => grid.appendChild(card));
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
    if (sortSelect) sortSelect.addEventListener("change", applyFilters);
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
    const KEY = "tesbihyol_cookie_consent";
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

  async function init() {
    updateCartCount();
    initMobileNav();
    await initDynamicCatalog();
    await initProductDetail();
    await initSellerStorefront();
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
    productCardHtml, escapeHtml, starsHtml, fallbackImg, materialSlug,
  };
})();
