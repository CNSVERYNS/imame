-- TesbihYol — v5: gerçek "çok satan" verisi için satış sayısı view'ı
-- SQL Editor'de çalıştırın.

-- order_items + orders tablolarına anon/authenticated'ın doğrudan erişimi yok
-- (siparişlerde adres/telefon gibi kişisel veri var). Bu view sadece
-- ürün başına toplam satılan adedi döndürür, hiçbir kişisel veri içermez,
-- bu yüzden herkese açık ürün listeleme/sıralama için güvenle kullanılabilir.
-- İptal edilen siparişler ('iptal') sayıma dahil edilmez.

create or replace view public.product_sales_counts as
  select oi.product_id, sum(oi.qty)::int as total_sold
  from public.order_items oi
  join public.orders o on o.id = oi.order_id
  where o.status <> 'iptal'
  group by oi.product_id;

grant select on public.product_sales_counts to anon, authenticated;
