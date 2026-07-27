-- TesbihYol — v8: demo satıcılarını onaylı duruma getirir
-- SQL Editor'de, migration_v4.sql / v5.sql / v6.sql'den SONRA çalıştırın.
--
-- Neden gerekli: migration_v3.sql'deki trg_enforce_seller_status tetikleyicisi,
-- admin olmayan bir bağlamda (SQL Editor'de auth.uid() boş döner) eklenen/
-- güncellenen satıcıların durumunu otomatik olarak 'pending' yapar. seed_demo_data.sql
-- satırlarında status='approved' yazsak da, bu tetikleyici (eğer projenizde
-- zaten varsa) sessizce 'pending'e çevirmiş olabilir. Bu betik, tetikleyiciyi
-- geçici olarak devre dışı bırakıp 6 demo satıcıyı 'approved' yapar, sonra
-- tetikleyiciyi tekrar açar (projede böyle bir tetikleyici yoksa bu betik
-- zararsız şekilde hiçbir şey yapmaz).

do $$
begin
  if exists (select 1 from pg_trigger where tgname = 'trg_enforce_seller_status') then
    alter table public.sellers disable trigger trg_enforce_seller_status;
  end if;
end $$;

update public.sellers set status = 'approved'
where id in (
  'b2b2b2b2-0001-4000-8000-000000000001',
  'b2b2b2b2-0002-4000-8000-000000000002',
  'b2b2b2b2-0003-4000-8000-000000000003',
  'b2b2b2b2-0004-4000-8000-000000000004',
  'b2b2b2b2-0005-4000-8000-000000000005',
  'b2b2b2b2-0006-4000-8000-000000000006'
);

do $$
begin
  if exists (select 1 from pg_trigger where tgname = 'trg_enforce_seller_status') then
    alter table public.sellers enable trigger trg_enforce_seller_status;
  end if;
end $$;

-- Doğrulama: aşağıdaki sorgu 6 satır ve hepsinde status='approved' göstermeli.
select id, store_name, status from public.sellers where id::text like 'b2b2b2b2-%';
