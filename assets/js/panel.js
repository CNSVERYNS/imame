/* İMAME Satıcı Merkezi — panel davranışları */

(() => {
  function initSidebar() {
    const toggle = document.querySelector(".panel-menu-toggle");
    const sidebar = document.querySelector(".panel-sidebar");
    if (!toggle || !sidebar) return;
    toggle.addEventListener("click", () => sidebar.classList.toggle("open"));
    document.addEventListener("click", (e) => {
      if (window.innerWidth > 900) return;
      if (!sidebar.contains(e.target) && !toggle.contains(e.target)) sidebar.classList.remove("open");
    });
  }

  function initUploadBox() {
    document.querySelectorAll(".upload-box").forEach(box => {
      box.addEventListener("click", () => {
        box.querySelector(".upload-box-text").textContent = "Görseller yüklendi (örnek)";
      });
    });
  }

  function initStatusSelects() {
    document.querySelectorAll("[data-status-select]").forEach(sel => {
      sel.addEventListener("change", () => {
        const row = sel.closest("tr");
        const pill = row && row.querySelector(".status-pill");
        if (!pill) return;
        const map = {
          hazirlaniyor: ["wait", "Hazırlanıyor"],
          kargoda: ["info", "Kargoya Verildi"],
          teslim: ["ok", "Teslim Edildi"],
          iptal: ["warn", "İptal Edildi"],
        };
        const [cls, text] = map[sel.value] || ["info", sel.value];
        pill.className = "status-pill " + cls;
        pill.textContent = text;
      });
    });
  }

  function initFormSteps() {
    // Ürün ekle formunda basit görsel geri bildirim: kaydet butonuna basınca toast benzeri mesaj
    document.querySelectorAll("[data-panel-save]").forEach(form => {
      form.addEventListener("submit", (e) => {
        e.preventDefault();
        const note = document.querySelector("[data-save-note]");
        if (note) {
          note.hidden = false;
          note.scrollIntoView({ behavior: "smooth", block: "center" });
        }
      });
    });
  }

  document.addEventListener("DOMContentLoaded", () => {
    initSidebar();
    initUploadBox();
    initStatusSelects();
    initFormSteps();
  });
})();
