-- Inventory RLS policies for Supabase
-- Fixes: PostgrestException(code: 42501) "new row violates row-level security policy for table inventory"
--
-- Run in Supabase: SQL Editor

-- Ensure RLS is enabled (if it's already enabled, this is safe)
alter table if exists public.inventory enable row level security;

-- Allow authenticated users to read inventory
create policy "inventory_select_authenticated"
  on public.inventory
  for select
  to authenticated
  using (true);

-- Allow authenticated users to insert inventory rows
-- Needed when your stock-movement trigger performs an UPSERT that inserts a new inventory row.
create policy "inventory_insert_authenticated"
  on public.inventory
  for insert
  to authenticated
  with check (true);

-- Allow authenticated users to update inventory rows
create policy "inventory_update_authenticated"
  on public.inventory
  for update
  to authenticated
  using (true)
  with check (true);

-- Note:
-- If you want stricter security, a common pattern is:
-- - keep inventory locked down
-- - perform inventory updates inside a SECURITY DEFINER trigger/function owned by a privileged role
-- That way, app clients never need direct write access to inventory.
