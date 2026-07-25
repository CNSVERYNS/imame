-- Danedane — v3 düzeltmesi 2: eksik profil satırlarını onarır + tetikleyiciyi garantiye alır
-- migration_v3_fix.sql'den SONRA, SQL Editor'de bunu çalıştırın.

-- Var olan tüm auth.users kayıtları için eksik profiles satırlarını oluştur
insert into public.profiles (id, full_name, email)
select u.id, u.raw_user_meta_data->>'full_name', u.email
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null;

-- İlk yönetici hesabı (bu kez satır kesin var)
update public.profiles set is_admin = true where email = 'yunuscansever@proton.me';

-- Tetikleyicinin ileride yeni kayıtlarda kesin çalışması için yeniden oluştur
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Doğrulama: bu sorgu artık senin satırını is_admin=true ile göstermeli
select id, email, is_admin from public.profiles;
