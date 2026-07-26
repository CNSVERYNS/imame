/* TesbihYol — Supabase bağlantısı ve veri erişim yardımcıları
   Kullanmadan önce: Supabase Dashboard → Settings → API'den
   Project URL ve anon public key değerlerini aşağıya yapıştır. */

const SUPABASE_URL = "https://akjiuuagzjgxpkyzpudv.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFraml1dWFnempneHBreXpwdWR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ5OTQwNjksImV4cCI6MjEwMDU3MDA2OX0.kYO9uvYJFvC2n0_uN4-toZ03kQdsJyMOuIxHYPEt9_0";

const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const DB = (() => {
  /* ---------- Auth ---------- */
  async function signUp(email, password, fullName) {
    return sb.auth.signUp({
      email,
      password,
      options: { data: { full_name: fullName } },
    });
  }
  async function signIn(email, password) {
    return sb.auth.signInWithPassword({ email, password });
  }
  async function signOut() {
    return sb.auth.signOut();
  }
  async function getUser() {
    const { data } = await sb.auth.getUser();
    return data.user || null;
  }
  function onAuthStateChange(cb) {
    return sb.auth.onAuthStateChange((_event, session) => cb(session ? session.user : null));
  }
  async function getMyProfile() {
    const user = await getUser();
    if (!user) return null;
    const { data, error } = await sb.from("profiles").select("*").eq("id", user.id).maybeSingle();
    if (error) throw error;
    return data;
  }
  async function updateMyProfile(changes) {
    const user = await getUser();
    if (!user) throw new Error("Giriş yapmalısınız.");
    const { data, error } = await sb.from("profiles").update(changes).eq("id", user.id).select().single();
    if (error) throw error;
    return data;
  }
  async function updatePassword(newPassword) {
    return sb.auth.updateUser({ password: newPassword });
  }
  async function verifySignupOtp(email, token) {
    return sb.auth.verifyOtp({ email, token, type: "signup" });
  }
  async function resendSignupOtp(email) {
    return sb.auth.resend({ type: "signup", email });
  }
  async function isAdmin() {
    const user = await getUser();
    if (!user) return false;
    const { data, error } = await sb.from("profiles").select("is_admin").eq("id", user.id).maybeSingle();
    if (error) throw error;
    return !!(data && data.is_admin);
  }

  /* ---------- Ürünler (alıcı tarafı, herkese açık) ---------- */
  async function withSalesCounts(products) {
    if (!products.length) return products;
    const ids = products.map(p => p.id);
    const { data, error } = await sb.from("product_sales_counts").select("product_id, total_sold").in("product_id", ids);
    if (error || !data) return products.map(p => ({ ...p, total_sold: 0 }));
    const counts = new Map(data.map(row => [row.product_id, row.total_sold]));
    return products.map(p => ({ ...p, total_sold: counts.get(p.id) || 0 }));
  }
  async function fetchProducts({ category, material, excludeId, sellerId, limit } = {}) {
    let q = sb.from("products").select("*, sellers(store_name)").eq("status", "published").order("created_at", { ascending: false });
    if (category) q = q.eq("category", category);
    if (material) q = q.eq("material", material);
    if (excludeId) q = q.neq("id", excludeId);
    if (sellerId) q = q.eq("seller_id", sellerId);
    if (limit) q = q.limit(limit);
    const { data, error } = await q;
    if (error) throw error;
    return withSalesCounts(data);
  }
  async function fetchSellerStorefront(sellerId) {
    const { data, error } = await sb.from("seller_storefronts").select("*").eq("id", sellerId).single();
    if (error) throw error;
    return data;
  }
  async function searchProducts(term) {
    const { data, error } = await sb
      .from("products")
      .select("*, sellers(store_name)")
      .eq("status", "published")
      .or(`name.ilike.%${term}%,material.ilike.%${term}%,category.ilike.%${term}%`)
      .order("created_at", { ascending: false });
    if (error) throw error;
    return withSalesCounts(data);
  }
  async function fetchProductById(id) {
    const { data, error } = await sb.from("products").select("*, sellers(store_name)").eq("id", id).single();
    if (error) throw error;
    return data;
  }

  /* ---------- Satıcı başvurusu / profili ---------- */
  async function applyAsSeller(fields) {
    const user = await getUser();
    if (!user) throw new Error("Başvuru için giriş yapmalısınız.");
    const { data, error } = await sb.from("sellers").insert({ ...fields, user_id: user.id }).select().single();
    if (error) throw error;
    return data;
  }
  async function getMySeller() {
    const user = await getUser();
    if (!user) return null;
    const { data, error } = await sb.from("sellers").select("*").eq("user_id", user.id).maybeSingle();
    if (error) throw error;
    return data;
  }
  async function updateMySeller(changes) {
    const user = await getUser();
    if (!user) throw new Error("Giriş yapmalısınız.");
    const { data, error } = await sb.from("sellers").update(changes).eq("user_id", user.id).select().single();
    if (error) throw error;
    return data;
  }
  async function uploadIdDocument(file) {
    const user = await getUser();
    if (!user) throw new Error("Giriş yapmalısınız.");
    const ext = (file.name.split(".").pop() || "jpg").toLowerCase();
    const path = `${user.id}/kimlik-${Date.now()}.${ext}`;
    const { error } = await sb.storage.from("id-documents").upload(path, file);
    if (error) throw error;
    return path;
  }
  async function getSignedIdDocumentUrl(path) {
    const { data, error } = await sb.storage.from("id-documents").createSignedUrl(path, 300);
    if (error) throw error;
    return data.signedUrl;
  }

  /* ---------- Satıcı ürün yönetimi ---------- */
  async function fetchMyProducts() {
    const seller = await getMySeller();
    if (!seller) return [];
    const { data, error } = await sb.from("products").select("*").eq("seller_id", seller.id).order("created_at", { ascending: false });
    if (error) throw error;
    return data;
  }
  async function createProduct(product) {
    const seller = await getMySeller();
    if (!seller || seller.status !== "approved") throw new Error("Ürün eklemek için onaylı satıcı hesabı gerekli.");
    const { data, error } = await sb.from("products").insert({ ...product, seller_id: seller.id }).select().single();
    if (error) throw error;
    return data;
  }
  async function updateProduct(id, changes) {
    const { data, error } = await sb.from("products").update(changes).eq("id", id).select().single();
    if (error) throw error;
    return data;
  }
  async function deleteProduct(id) {
    const { error } = await sb.from("products").delete().eq("id", id);
    if (error) throw error;
  }

  /* ---------- Siparişler (alıcı) ---------- */
  async function createOrder(order, items) {
    const user = await getUser();
    if (!user) throw new Error("Sipariş için giriş yapmalısınız.");
    const { data: createdOrder, error: orderErr } = await sb
      .from("orders")
      .insert({ ...order, user_id: user.id })
      .select()
      .single();
    if (orderErr) throw orderErr;

    const rows = items.map(it => ({
      order_id: createdOrder.id,
      product_id: it.id,
      seller_id: it.seller_id,
      name: it.name,
      price: it.price,
      qty: it.qty,
      image_url: it.img || null,
    }));
    const { error: itemsErr } = await sb.from("order_items").insert(rows);
    if (itemsErr) throw itemsErr;

    return createdOrder;
  }
  async function fetchMyOrders() {
    const { data, error } = await sb
      .from("orders")
      .select("*, order_items(*)")
      .order("created_at", { ascending: false });
    if (error) throw error;
    return data;
  }

  /* ---------- Satıcı sipariş görünümü ---------- */
  async function fetchSellerOrderItems() {
    const seller = await getMySeller();
    if (!seller) return [];
    const { data, error } = await sb
      .from("order_items")
      .select("*, orders(id, full_name, city, district, status, created_at)")
      .eq("seller_id", seller.id)
      .order("id", { ascending: false });
    if (error) throw error;
    return data;
  }
  async function fetchSellerOrders() {
    const seller = await getMySeller();
    if (!seller) return [];
    const { data, error } = await sb
      .from("orders")
      .select("*, order_items(*)")
      .order("created_at", { ascending: false });
    if (error) throw error;
    return data.filter(o => o.order_items.some(it => it.seller_id === seller.id));
  }
  async function updateOrderStatus(orderId, changes) {
    const { data, error } = await sb.from("orders").update(changes).eq("id", orderId).select().single();
    if (error) throw error;
    return data;
  }

  /* ---------- Değerlendirmeler (sipariş numarasıyla doğrulanmış) ---------- */
  async function fetchProductReviews(productId) {
    const { data, error } = await sb.from("product_reviews").select("*").eq("product_id", productId);
    if (error) throw error;
    return data;
  }
  async function submitReview({ orderCode, productId, rating, comment }) {
    const { data, error } = await sb.rpc("submit_review", {
      p_order_code: orderCode, p_product_id: productId, p_rating: rating, p_comment: comment || null,
    });
    if (error) throw error;
    return data;
  }

  /* ---------- Admin ---------- */
  async function fetchAllSellers() {
    const { data, error } = await sb.from("sellers").select("*").order("created_at", { ascending: false });
    if (error) throw error;
    return data;
  }
  async function setSellerStatus(id, status) {
    const { data, error } = await sb.from("sellers").update({ status }).eq("id", id).select().single();
    if (error) throw error;
    return data;
  }
  async function grantAdminByEmail(email) {
    const { data, error } = await sb.from("profiles").update({ is_admin: true }).eq("email", email).select();
    if (error) throw error;
    if (!data || !data.length) throw new Error("Bu e-postayla kayıtlı bir kullanıcı bulunamadı.");
    return data[0];
  }

  return {
    signUp, signIn, signOut, getUser, onAuthStateChange, getMyProfile, updateMyProfile, updatePassword,
    verifySignupOtp, resendSignupOtp, isAdmin,
    fetchProducts, searchProducts, fetchProductById, fetchSellerStorefront,
    applyAsSeller, getMySeller, updateMySeller, uploadIdDocument, getSignedIdDocumentUrl,
    fetchMyProducts, createProduct, updateProduct, deleteProduct,
    createOrder, fetchMyOrders,
    fetchSellerOrderItems, fetchSellerOrders, updateOrderStatus,
    fetchProductReviews, submitReview,
    fetchAllSellers, setSellerStatus, grantAdminByEmail,
  };
})();
