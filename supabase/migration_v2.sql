-- Danedane — v2 ek alanlar (satıcı başvuru detayları + kargo takip)
-- Eğer supabase/schema.sql'i DAHA ÖNCE çalıştırdıysanız, o dosyayı tekrar çalıştırmayın
-- (politikalar zaten var olduğu için hata verir) — SADECE bu dosyayı SQL Editor'de çalıştırın.
-- Hiç çalıştırmadıysanız bu dosyayı atlayıp doğrudan schema.sql'i çalıştırmanız yeterli.

alter table public.sellers add column if not exists tc_no text;
alter table public.sellers add column if not exists birth_date date;
alter table public.sellers add column if not exists business_type text;
alter table public.sellers add column if not exists category_pref text;
alter table public.sellers add column if not exists iban text;
alter table public.sellers add column if not exists bank_name text;
alter table public.sellers add column if not exists bio text;

alter table public.orders add column if not exists tracking_number text;
alter table public.orders add column if not exists carrier text;

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
