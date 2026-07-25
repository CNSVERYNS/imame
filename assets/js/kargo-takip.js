/* Danedane — canlı kargo takibi (örnek/mock veri motoru) */

(() => {
  const form = document.querySelector("#tracking-form");
  const result = document.querySelector("#tracking-result");
  if (!form || !result) return;

  const STEPS = [
    { key: "alindi", label: "Siparişiniz Alındı", desc: "Ödemeniz onaylandı, siparişiniz satıcıya iletildi." },
    { key: "hazirlaniyor", label: "Özenle Hazırlanıyor", desc: "Ürününüz kontrol edilip özel kutusuna yerleştiriliyor." },
    { key: "kargoda", label: "Kargoya Verildi", desc: "Paketiniz anlaşmalı kargo firmasına teslim edildi." },
    { key: "transfer", label: "Transfer Merkezinde", desc: "Paketiniz bölge aktarma merkezinde işleniyor." },
    { key: "dagitim", label: "Dağıtıma Çıktı", desc: "Paketiniz bulunduğunuz şehirde, dağıtım aracında." },
    { key: "teslim", label: "Teslim Edildi", desc: "Paketiniz alıcıya teslim edildi. Bereketli olsun." },
  ];

  function hashCode(str) {
    let h = 0;
    for (let i = 0; i < str.length; i++) h = (h * 31 + str.charCodeAt(i)) >>> 0;
    return h;
  }

  function fmtDate(d) {
    return d.toLocaleDateString("tr-TR", { day: "2-digit", month: "long" }) + " · " +
      d.toLocaleTimeString("tr-TR", { hour: "2-digit", minute: "2-digit" });
  }

  function render(code) {
    const h = hashCode(code.toUpperCase());
    const activeIndex = 2 + (h % 4); // en az "kargoda" adımına gelmiş kabul edilir, canlı his için
    const now = new Date();

    const carrierList = ["Sabır Kargo", "Vefa Kargo Taşımacılık", "Nur Ekspres Lojistik"];
    const carrier = carrierList[h % carrierList.length];
    const city = ["İstanbul", "Ankara", "Bursa", "Konya", "Kayseri", "İzmir"][h % 6];

    let stepsHtml = "";
    STEPS.forEach((s, i) => {
      const state = i < activeIndex ? "done" : i === activeIndex ? "active" : "pending";
      const stepDate = new Date(now.getTime() - (activeIndex - i) * 5 * 3600 * 1000);
      stepsHtml += `
        <li class="track-step track-step--${state}">
          <div class="track-dot"></div>
          <div class="track-content">
            <div class="track-row">
              <strong>${s.label}</strong>
              ${i <= activeIndex ? `<time>${fmtDate(stepDate)}</time>` : ""}
            </div>
            <p>${s.desc}</p>
          </div>
        </li>`;
    });

    result.innerHTML = `
      <div class="track-summary">
        <div>
          <span class="eyebrow">Takip No</span>
          <h3>${code.toUpperCase()}</h3>
        </div>
        <div>
          <span class="eyebrow">Kargo Firması</span>
          <h3>${carrier}</h3>
        </div>
        <div>
          <span class="eyebrow">Şu An</span>
          <h3>${activeIndex === STEPS.length - 1 ? "Teslim Edildi" : city + " bölgesinde"}</h3>
        </div>
      </div>
      <ul class="track-steps">${stepsHtml}</ul>
      <p class="track-live"><span class="live-dot"></span> Canlı takip — son güncelleme az önce yapıldı.</p>
    `;
    result.hidden = false;
    result.scrollIntoView({ behavior: "smooth", block: "nearest" });
  }

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const input = form.querySelector("input[name=tracking-code]");
    const code = (input.value || "").trim();
    if (!code) { input.focus(); return; }
    const btn = form.querySelector("button");
    btn.disabled = true;
    btn.textContent = "Sorgulanıyor...";
    setTimeout(() => {
      render(code);
      btn.disabled = false;
      btn.textContent = "Kargomu Sorgula";
    }, 650);
  });

  // demo kolaylığı için otomatik doldurulmuş örnek varsa göster
  const params = new URLSearchParams(location.search);
  if (params.get("no")) {
    form.querySelector("input[name=tracking-code]").value = params.get("no");
    render(params.get("no"));
  }
})();
