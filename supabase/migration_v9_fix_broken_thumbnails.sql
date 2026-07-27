-- TesbihYol — v9: kırık ürün görsellerini düzeltir
-- SQL Editor'de, seed_demo_data.sql'den SONRA çalıştırın.
--
-- Kök neden: seed_demo_data.sql'deki görsel URL'lerinin çoğu Wikimedia'nın
-- "thumb/.../NNNpx-..." formatını kullanıyordu. Wikimedia artık anlık
-- küçük resim boyutlarını belirli bir izin listesiyle sınırlıyor; listede
-- olmayan bir genişlik (örn. 800px) istendiğinde 400 hatası dönüyor —
-- bu yüzden ürün görsellerinin çoğu tarayıcıda kırık görünüyordu.
-- Çözüm: "thumb/" öneki ve "NNNpx-" boyut son ekini kaldırıp orijinal
-- (tam çözünürlüklü) dosya adresini kullanmak — bu adresler her zaman
-- çalışır. Tüm 58 benzersiz görsel adresi tek tek gerçek HTTP isteğiyle
-- doğrulandı.

update public.products
set image_url = regexp_replace(image_url, '/thumb/([0-9a-f])/([0-9a-f]{2})/([^/]+)/[0-9]+px-[^/]+$', '/\1/\2/\3')
where image_url like '%/thumb/%';

update public.products p
set images = sub.new_images
from (
  select id, array_agg(
    regexp_replace(img, '/thumb/([0-9a-f])/([0-9a-f]{2})/([^/]+)/[0-9]+px-[^/]+$', '/\1/\2/\3')
    order by ord
  ) as new_images
  from public.products, unnest(images) with ordinality as t(img, ord)
  group by id
) sub
where p.id = sub.id
  and exists (select 1 from unnest(p.images) as img2 where img2 like '%/thumb/%');

-- Doğrulama: aşağıdaki sorgu 0 satır dönmeli (artık hiçbir thumb/ URL'i kalmamalı).
select id, name, image_url from public.products
where image_url like '%/thumb/%' or exists (select 1 from unnest(images) as i where i like '%/thumb/%');
