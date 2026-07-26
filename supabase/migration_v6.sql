-- TesbihYol — v6: sipariş numarasıyla doğrulanan yorum (review) sistemi
-- SQL Editor'de çalıştırın.

-- Bir siparişin sahibi olduğunu ve o siparişte gerçekten bu ürünü satın
-- aldığını doğrulamadan hiç kimse yorum ekleyemez. Doğrudan insert/update/
-- delete RLS ile tamamen kapatılır; tek giriş noktası aşağıdaki
-- submit_review() fonksiyonudur (SECURITY DEFINER, tüm kontrolleri kendisi
-- yapar). Her sipariş numarası yalnızca bir kez yorum için kullanılabilir
-- (unique(order_id)) — bir siparişte birden çok ürün olsa bile.

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  order_id uuid not null references public.orders(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  rating smallint not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),
  unique (order_id)
);

create index if not exists reviews_product_id_idx on public.reviews(product_id);

alter table public.reviews enable row level security;

-- Herkes reviews tablosunu (view üzerinden) okuyabilir ama doğrudan
-- insert/update/delete her zaman reddedilir — yazma yalnızca aşağıdaki
-- submit_review() fonksiyonu (postgres sahipliğiyle RLS'i atlar) üzerinden.
create policy "reviews_select_all" on public.reviews for select using (true);
create policy "reviews_no_direct_insert" on public.reviews for insert with check (false);
create policy "reviews_no_direct_update" on public.reviews for update using (false);
create policy "reviews_no_direct_delete" on public.reviews for delete using (false);

-- Yorum yapan kişinin tam adını değil, gizlilik için kısaltılmış halini
-- (ör. "Ahmet Y.") döndüren yardımcı fonksiyon.
create or replace function public.short_display_name(full_name text)
returns text as $$
  select case
    when full_name is null or btrim(full_name) = '' then 'TesbihYol Müşterisi'
    when position(' ' in btrim(full_name)) = 0 then btrim(full_name)
    else split_part(btrim(full_name), ' ', 1) || ' ' || upper(left(split_part(btrim(full_name), ' ', 2), 1)) || '.'
  end;
$$ language sql immutable;

grant execute on function public.short_display_name(text) to anon, authenticated;

-- Herkese açık, hassas veri içermeyen yorum görünümü (order_id/user_id yok).
create or replace view public.product_reviews as
  select r.id, r.product_id, r.rating, r.comment, r.created_at,
         public.short_display_name(p.full_name) as reviewer_name
  from public.reviews r
  left join public.profiles p on p.id = r.user_id
  order by r.created_at desc;

grant select on public.product_reviews to anon, authenticated;

-- Yorum eklendikçe/silindikçe ürünün ortalama puanını güncel tutar.
create or replace function public.refresh_product_rating()
returns trigger as $$
declare
  target_product uuid := coalesce(new.product_id, old.product_id);
begin
  update public.products
    set rating = coalesce((select round(avg(rating)::numeric, 1) from public.reviews where product_id = target_product), 0)
    where id = target_product;
  return null;
end;
$$ language plpgsql security definer set search_path = public;

drop trigger if exists on_review_change on public.reviews;
create trigger on_review_change
  after insert or update or delete on public.reviews
  for each row execute procedure public.refresh_product_rating();

-- Sipariş numarasını doğrulayıp yorum ekleyen tek giriş noktası.
-- p_order_code: "TY-3FA1C2D4" gibi kısa gösterim ya da tam UUID kabul eder
-- (harf/rakam dışındaki her şey ayıklanır, tire'siz karşılaştırılır).
create or replace function public.submit_review(p_order_code text, p_product_id uuid, p_rating smallint, p_comment text)
returns public.reviews as $$
declare
  v_clean text;
  v_match_count int;
  v_order public.orders;
  v_has_item boolean;
  v_review public.reviews;
begin
  if auth.uid() is null then
    raise exception 'Yorum eklemek için giriş yapmalısınız.';
  end if;
  if p_rating is null or p_rating < 1 or p_rating > 5 then
    raise exception 'Puan 1 ile 5 arasında olmalıdır.';
  end if;

  v_clean := lower(regexp_replace(coalesce(p_order_code, ''), '[^0-9a-fA-F]', '', 'g'));
  if length(v_clean) < 6 then
    raise exception 'Geçerli bir sipariş numarası girin.';
  end if;

  select count(*) into v_match_count
    from public.orders
    where replace(id::text, '-', '') ilike v_clean || '%' and user_id = auth.uid();

  if v_match_count = 0 then
    raise exception 'Bu sipariş numarasına ait hesabınızda bir sipariş bulunamadı.';
  elsif v_match_count > 1 then
    raise exception 'Sipariş numarası birden fazla siparişle eşleşti, lütfen tam numarayı girin.';
  end if;

  select * into v_order
    from public.orders
    where replace(id::text, '-', '') ilike v_clean || '%' and user_id = auth.uid();

  if v_order.status <> 'teslim' then
    raise exception 'Yalnızca teslim edilmiş siparişler için değerlendirme yapabilirsiniz.';
  end if;

  select exists(
    select 1 from public.order_items where order_id = v_order.id and product_id = p_product_id
  ) into v_has_item;
  if not v_has_item then
    raise exception 'Bu sipariş numarası, bu ürünü içeren bir siparişe ait değil.';
  end if;

  if exists (select 1 from public.reviews where order_id = v_order.id) then
    raise exception 'Bu sipariş numarası daha önce bir değerlendirme için kullanılmış.';
  end if;

  insert into public.reviews (product_id, order_id, user_id, rating, comment)
  values (p_product_id, v_order.id, auth.uid(), p_rating, nullif(btrim(p_comment), ''))
  returning * into v_review;

  return v_review;
end;
$$ language plpgsql security definer set search_path = public;

grant execute on function public.submit_review(text, uuid, smallint, text) to authenticated;
