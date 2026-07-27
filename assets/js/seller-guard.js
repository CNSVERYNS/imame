/* TesbihYol Satıcı Merkezi — panel sayfaları için ortak oturum/başvuru koruması.
   Her panel sayfasında supabase-client.js'ten SONRA yüklenmelidir. */
(async () => {
  const user = await DB.getUser();
  if (!user) { window.location.href = "/satici-merkezi/giris"; return; }

  const seller = await DB.getMySeller();
  if (!seller) { window.location.href = "/satici-merkezi/basvuru"; return; }

  window.CURRENT_SELLER = seller;

  document.querySelectorAll(".seller-mini").forEach(el => {
    const nameEl = el.querySelector("span");
    const ownerEl = el.querySelector("small");
    const avatarEl = el.querySelector(".avatar");
    if (nameEl) nameEl.textContent = seller.store_name;
    if (ownerEl) ownerEl.textContent = seller.owner_name;
    if (avatarEl) avatarEl.textContent = (seller.store_name || "?").charAt(0).toUpperCase() + ".";
  });

  if (seller.status !== "approved") {
    const main = document.querySelector(".panel-main");
    if (main) {
      const banner = document.createElement("div");
      banner.className = "panel-box";
      banner.style.cssText = "margin-bottom:20px; border-color: var(--gold-line-strong);";
      banner.innerHTML = seller.status === "pending"
        ? "<strong>Başvurunuz inceleniyor.</strong> Onaylanana kadar ürün yayınlayamazsınız; taslak olarak kaydedebilirsiniz."
        : "<strong>Başvurunuz reddedildi.</strong> Detaylı bilgi için bizimle iletişime geçin.";
      main.insertBefore(banner, main.firstChild.nextSibling);
    }
  }

  document.querySelectorAll('a[href="/satici-merkezi/giris"]').forEach(el => {
    if (el.textContent.trim() === "Çıkış Yap") {
      el.addEventListener("click", async (e) => {
        e.preventDefault();
        await DB.signOut();
        window.location.href = "/satici-merkezi/giris";
      });
    }
  });

  window.dispatchEvent(new CustomEvent("tesbihyol:seller-ready", { detail: seller }));
})();
