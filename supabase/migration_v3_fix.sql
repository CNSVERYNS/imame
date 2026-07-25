-- Danedane — v3 düzeltmesi: "infinite recursion detected in policy for relation profiles" hatasını giderir
-- migration_v3.sql'den SONRA, SQL Editor'de bunu çalıştırın.

-- profiles tablosundaki is_admin kontrolünü politika içinden değil,
-- RLS'i baypas eden (security definer) ayrı bir fonksiyondan yapıyoruz.
-- Böylece "profiles" politikası kendi kendini tekrar tetiklemiyor.
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce((select is_admin from public.profiles where id = auth.uid()), false);
$$;

drop policy if exists "sellers_select_admin" on public.sellers;
create policy "sellers_select_admin" on public.sellers for select using (public.is_admin());

drop policy if exists "sellers_update_admin" on public.sellers;
create policy "sellers_update_admin" on public.sellers for update using (public.is_admin());

drop policy if exists "profiles_select_admin" on public.profiles;
create policy "profiles_select_admin" on public.profiles for select using (public.is_admin());

drop policy if exists "profiles_update_admin" on public.profiles;
create policy "profiles_update_admin" on public.profiles for update using (public.is_admin());

drop policy if exists "id_documents_select_admin" on storage.objects;
create policy "id_documents_select_admin" on storage.objects for select to authenticated
using (bucket_id = 'id-documents' and public.is_admin());

create or replace function public.enforce_seller_status()
returns trigger as $$
begin
  if not public.is_admin() then
    if tg_op = 'INSERT' then
      new.status := 'pending';
    else
      new.status := old.status;
    end if;
  end if;
  return new;
end;
$$ language plpgsql security definer set search_path = public;
