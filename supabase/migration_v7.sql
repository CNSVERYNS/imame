-- TesbihYol — v7: ürün başına birden fazla görsel (galeri/slider)
-- SQL Editor'de çalıştırın.

-- image_url tek kapak görseli olarak kalmaya devam ediyor (ürün kartlarında
-- kullanılıyor); images ise ürün detay sayfasındaki galeri/slider için
-- ek görselleri tutuyor. Eski ürünlerde images boş olabilir — detay
-- sayfası bu durumda otomatik olarak sadece image_url'i gösterir.

alter table public.products add column if not exists images text[];
