-- Danedane/TesbihYol — v4: herkese açık mağaza vitrini (magaza.html?seller=<id>)
-- SQL Editor'de çalıştırın.

-- sellers tablosunda tc_no, iban, bank_name, phone gibi hassas alanlar var —
-- bu yüzden mağaza sayfası için tabloyu doğrudan herkese açmıyoruz.
-- Bunun yerine sadece güvenli/genel alanları döndüren bir view oluşturuyoruz.
-- View, sahibi (postgres) yetkisiyle çalıştığından, altındaki tabloya anon/authenticated
-- rollerinin doğrudan erişimi olmasa bile sadece bu sınırlı sütunları görebilirler.

create or replace view public.seller_storefronts as
  select id, store_name, owner_name, bio, category_pref, created_at
  from public.sellers
  where status = 'approved';

grant select on public.seller_storefronts to anon, authenticated;
