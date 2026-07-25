-- Danedane — v3: admin paneli + kimlik belgesi yükleme
-- Bu dosyayı Supabase Dashboard → SQL Editor'de tek seferde çalıştır.

-- ---------- profiles: email + is_admin ----------
alter table public.profiles add column if not exists email text;
alter table public.profiles add column if not exists is_admin boolean not null default false;

-- Yeni kullanıcılarda profiles.email otomatik dolsun
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, email)
  values (new.id, new.raw_user_meta_data->>'full_name', new.email);
  return new;
end;
$$ language plpgsql security definer set search_path = public;

-- Daha önce oluşmuş profillerde email boşsa doldur
update public.profiles p
set email = u.email
from auth.users u
where p.id = u.id and p.email is null;

-- İlk yönetici hesabı
update public.profiles set is_admin = true where email = 'yunuscansever@proton.me';

-- ---------- sellers: kimlik belgesi yolu ----------
alter table public.sellers add column if not exists id_document_path text;

-- sellers_update_own / sellers_insert_own politikaları "status" sütununu
-- kısıtlamıyor — bu, bir satıcının kendi başvurusunu API üzerinden doğrudan
-- 'approved' yapabilmesi anlamına gelir. Bu tetikleyici, admin olmayan
-- kullanıcıların status değerini değiştirmesini/ayarlamasını engeller.
create or replace function public.enforce_seller_status()
returns trigger as $$
begin
  if not exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin) then
    if tg_op = 'INSERT' then
      new.status := 'pending';
    else
      new.status := old.status;
    end if;
  end if;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

drop trigger if exists trg_enforce_seller_status on public.sellers;
create trigger trg_enforce_seller_status
  before insert or update on public.sellers
  for each row execute procedure public.enforce_seller_status();

-- ---------- admin RLS: sellers ve profiles üzerinde tam erişim ----------
create policy "sellers_select_admin" on public.sellers for select using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
);
create policy "sellers_update_admin" on public.sellers for update using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
);
create policy "profiles_select_admin" on public.profiles for select using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
);
create policy "profiles_update_admin" on public.profiles for update using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
);

-- ---------- Storage: kimlik belgeleri (özel bucket) ----------
insert into storage.buckets (id, name, public)
values ('id-documents', 'id-documents', false)
on conflict (id) do nothing;

create policy "id_documents_insert_own" on storage.objects for insert to authenticated
with check (bucket_id = 'id-documents' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "id_documents_select_own" on storage.objects for select to authenticated
using (bucket_id = 'id-documents' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "id_documents_select_admin" on storage.objects for select to authenticated
using (
  bucket_id = 'id-documents'
  and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
);
