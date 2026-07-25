-- Danedane — Supabase şema kurulumu
-- Bu dosyayı Supabase Dashboard → SQL Editor içine yapıştırıp "Run" ile çalıştır.
-- Sıra önemli: tablolar, sonra RLS, sonra politikalar.

-- ---------- Uzantılar ----------
create extension if not exists "pgcrypto";

-- ---------- profiles (auth.users'ı genişletir) ----------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  created_at timestamptz not null default now()
);

-- Yeni kullanıcı kaydolunca otomatik profil satırı oluştur
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$ language plpgsql security definer set search_path = public;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------- sellers (Satıcı Merkezi başvuruları) ----------
create table if not exists public.sellers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  store_name text not null,
  owner_name text not null,
  phone text,
  tc_no text,
  birth_date date,
  business_type text,
  category_pref text,
  iban text,
  bank_name text,
  bio text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamptz not null default now(),
  unique (user_id)
);

-- ---------- products ----------
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.sellers(id) on delete cascade,
  name text not null,
  category text not null check (category in ('Tesbih','Yüzük')),
  material text,
  description text,
  price numeric(10,2) not null check (price >= 0),
  stock integer not null default 0 check (stock >= 0),
  size_info text,
  weight_grams numeric(10,2),
  shipping_option text not null default 'ucretsiz' check (shipping_option in ('ucretsiz','alici')),
  shipping_fee numeric(10,2) default 0,
  rating numeric(2,1) default 0,
  image_url text,
  featured boolean not null default false,
  status text not null default 'draft' check (status in ('draft','published','rejected')),
  created_at timestamptz not null default now()
);

create index if not exists products_seller_id_idx on public.products(seller_id);
create index if not exists products_category_idx on public.products(category);
create index if not exists products_status_idx on public.products(status);

-- ---------- orders ----------
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  full_name text not null,
  email text not null,
  phone text not null,
  address text not null,
  city text not null,
  district text not null,
  shipping_method text not null,
  shipping_fee numeric(10,2) not null default 0,
  payment_method text not null,
  status text not null default 'hazirlaniyor' check (status in ('hazirlaniyor','kargoda','teslim','iptal')),
  tracking_number text,
  carrier text,
  total numeric(10,2) not null,
  created_at timestamptz not null default now()
);

create index if not exists orders_user_id_idx on public.orders(user_id);

-- ---------- order_items ----------
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  seller_id uuid not null references public.sellers(id),
  name text not null,
  price numeric(10,2) not null,
  qty integer not null check (qty > 0),
  image_url text
);

create index if not exists order_items_order_id_idx on public.order_items(order_id);
create index if not exists order_items_seller_id_idx on public.order_items(seller_id);

-- ==================== ROW LEVEL SECURITY ====================

alter table public.profiles enable row level security;
alter table public.sellers enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- profiles: herkes kendi profilini okur/günceller
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);

-- sellers: kullanıcı kendi başvurusunu oluşturur/okur/günceller
create policy "sellers_select_own" on public.sellers for select using (auth.uid() = user_id);
create policy "sellers_insert_own" on public.sellers for insert with check (auth.uid() = user_id);
create policy "sellers_update_own" on public.sellers for update using (auth.uid() = user_id);

-- products: herkes yayınlanmış ürünleri görür; satıcı kendi ürünlerini tam yönetir
create policy "products_select_published" on public.products for select using (status = 'published');
create policy "products_select_own_seller" on public.products for select using (
  exists (select 1 from public.sellers s where s.id = seller_id and s.user_id = auth.uid())
);
create policy "products_insert_own_seller" on public.products for insert with check (
  exists (select 1 from public.sellers s where s.id = seller_id and s.user_id = auth.uid() and s.status = 'approved')
);
create policy "products_update_own_seller" on public.products for update using (
  exists (select 1 from public.sellers s where s.id = seller_id and s.user_id = auth.uid())
);
create policy "products_delete_own_seller" on public.products for delete using (
  exists (select 1 from public.sellers s where s.id = seller_id and s.user_id = auth.uid())
);

-- orders: alıcı sadece kendi siparişlerini görür/oluşturur; satıcı kendi ürünü olan siparişleri görüp kargo durumunu günceller
create policy "orders_select_own" on public.orders for select using (auth.uid() = user_id);
create policy "orders_insert_own" on public.orders for insert with check (auth.uid() = user_id);
create policy "orders_select_seller" on public.orders for select using (
  exists (
    select 1 from public.order_items oi
    join public.sellers s on s.id = oi.seller_id
    where oi.order_id = orders.id and s.user_id = auth.uid()
  )
);
create policy "orders_update_seller" on public.orders for update using (
  exists (
    select 1 from public.order_items oi
    join public.sellers s on s.id = oi.seller_id
    where oi.order_id = orders.id and s.user_id = auth.uid()
  )
);

-- order_items: alıcı kendi siparişinin kalemlerini görür; satıcı kendine ait kalemleri görüp durumunu günceller
create policy "order_items_select_buyer" on public.order_items for select using (
  exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid())
);
create policy "order_items_select_seller" on public.order_items for select using (
  exists (select 1 from public.sellers s where s.id = seller_id and s.user_id = auth.uid())
);
create policy "order_items_insert_buyer" on public.order_items for insert with check (
  exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid())
);
