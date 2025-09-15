-- Supabase schema for Efallmò
-- Copy & paste this entire file into Supabase SQL Editor and RUN.

-- Extensions (uuid generation)
create extension if not exists "pgcrypto";

-- BONUSES
create table if not exists public.bonuses (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  title text not null,
  description text,
  -- Guide URL (webview)
  guide_url text,
  embed_url text, -- legacy/fallback
  total_steps integer not null default 50 check (total_steps >= 0),
  -- Legacy total bonus (fallback)
  bonus_amount text not null default '',
  -- Visuals
  company_logo_url text,
  image_url text, -- large cover image for cards
  -- Meta
  estimated_time text not null default '5 minuti',
  is_active boolean not null default true,
  -- New columns for Landing/Dashboard
  status text default 'ATTIVA',
  deposit_required text,
  registration_bonus_amount text,
  registration_bonus_type text,
  invite_bonus_amount text,
  invite_bonus_type text,
  referral_code_or_registration_link text,
  expiry_date_text text
);

-- Ensure columns exist for existing projects (safe migrations)
alter table public.bonuses add column if not exists guide_url text;
alter table public.bonuses add column if not exists embed_url text;
alter table public.bonuses add column if not exists image_url text;
alter table public.bonuses add column if not exists status text;
alter table public.bonuses add column if not exists deposit_required text;
alter table public.bonuses add column if not exists registration_bonus_amount text;
alter table public.bonuses add column if not exists registration_bonus_type text;
alter table public.bonuses add column if not exists invite_bonus_amount text;
alter table public.bonuses add column if not exists invite_bonus_type text;
alter table public.bonuses add column if not exists referral_code_or_registration_link text;
alter table public.bonuses add column if not exists expiry_date_text text;

-- Make sure total_steps default is 50 for all future inserts
do $$
begin
  alter table public.bonuses alter column total_steps set default 50;
exception
  when others then null;
end$$;

-- Backfill: set embed_url = guide_url where missing
update public.bonuses
set embed_url = guide_url
where embed_url is null and guide_url is not null;

-- Set total_steps to 50 where missing or <= 0
update public.bonuses
set total_steps = 50
where coalesce(total_steps, 0) <= 0;

-- Unique index on title for upserts
create unique index if not exists bonuses_title_uniq on public.bonuses (title);

alter table public.bonuses enable row level security;

-- Policies for bonuses
-- Allow ALL bonuses to authenticated (to also view expired/scaduti)
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'bonuses' and policyname = 'Allow read bonuses to authenticated'
  ) then
    create policy "Allow read bonuses to authenticated"
      on public.bonuses
      for select
      to authenticated
      using (true);
  end if;
end$$;

-- Allow anonymous users to read only active bonuses (Landing page)
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'bonuses' and policyname = 'Allow read active bonuses to anon'
  ) then
    create policy "Allow read active bonuses to anon"
      on public.bonuses
      for select
      to anon
      using (is_active = true);
  end if;
end$$;

-- PROFILES (public mirror of auth.users metadata)
create table if not exists public.profiles (
  id uuid primary key,
  full_name text,
  phone text,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- RLS: user can see/update own profile
do $$
begin
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='profiles' and policyname='Select own profile'
  ) then
    create policy "Select own profile"
      on public.profiles
      for select
      to authenticated
      using (auth.uid() = id or exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));
  end if;

  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='profiles' and policyname='Update own profile'
  ) then
    create policy "Update own profile"
      on public.profiles
      for update
      to authenticated
      using (auth.uid() = id or exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true))
      with check (auth.uid() = id or exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));
  end if;

  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='profiles' and policyname='Insert self profile'
  ) then
    create policy "Insert self profile"
      on public.profiles
      for insert
      to authenticated
      with check (auth.uid() = id or exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));
  end if;
end$$;

-- Trigger to auto-create profile on new auth user
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, phone)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'phone')
  on conflict (id) do update set
    full_name = excluded.full_name,
    phone = excluded.phone;
  return new;
end;
$$ language plpgsql security definer;

do $$
begin
  if not exists (
    select 1 from pg_trigger where tgname = 'on_auth_user_created'
  ) then
    create trigger on_auth_user_created
    after insert on auth.users
    for each row execute procedure public.handle_new_user();
  end if;
end$$;

-- USER BONUS PROGRESS
create table if not exists public.user_bonus_progress (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  bonus_id uuid not null references public.bonuses(id) on delete cascade,
  current_step integer not null default 0 check (current_step >= 0),
  completed boolean not null default false,
  updated_at timestamptz not null default now(),
  unique (user_id, bonus_id)
);

alter table public.user_bonus_progress enable row level security;

-- Policies: each user can CRUD only their own progress
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'user_bonus_progress' and policyname = 'Select own progress'
  ) then
    create policy "Select own progress"
      on public.user_bonus_progress
      for select
      to authenticated
      using (auth.uid() = user_id);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'user_bonus_progress' and policyname = 'Insert own progress'
  ) then
    create policy "Insert own progress"
      on public.user_bonus_progress
      for insert
      to authenticated
      with check (auth.uid() = user_id);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'user_bonus_progress' and policyname = 'Update own progress'
  ) then
    create policy "Update own progress"
      on public.user_bonus_progress
      for update
      to authenticated
      using (auth.uid() = user_id)
      with check (auth.uid() = user_id);
  end if;
end$$;

-- USER BONUS ACTIVITY (admin audit)
create table if not exists public.user_bonus_activity (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  bonus_id uuid not null references public.bonuses(id) on delete cascade,
  event text not null check (event in ('start','progress','complete')),
  step integer not null default 0 check (step >= 0),
  completed boolean not null default false,
  note text,
  created_at timestamptz not null default now()
);

alter table public.user_bonus_activity enable row level security;

-- Policies: user can insert own; admin can select all; user can see own
do $$
begin
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='user_bonus_activity' and policyname='Insert own activity'
  ) then
    create policy "Insert own activity"
      on public.user_bonus_activity
      for insert
      to authenticated
      with check (auth.uid() = user_id);
  end if;

  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='user_bonus_activity' and policyname='Select own or admin'
  ) then
    create policy "Select own or admin"
      on public.user_bonus_activity
      for select
      to authenticated
      using (
        auth.uid() = user_id
        or exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true)
      );
  end if;
end$$;

-- Seed/Upsert provided bonuses (using ON CONFLICT on unique title)
insert into public.bonuses (
  title, description, guide_url, embed_url, total_steps, bonus_amount,
  company_logo_url, image_url, estimated_time, is_active,
  status, deposit_required, registration_bonus_amount, registration_bonus_type,
  invite_bonus_amount, invite_bonus_type, referral_code_or_registration_link, expiry_date_text
) values
  (
    'Robinhood',
    $$🚀 Robinhood: Guadagna in soli 5 Minuti! 🚀
Grazie alla nostra guida step-by-step è facilissimo: 👉 https://link.efallmo.it/Guidarobinhood

✅ Cosa ottieni con Robinhood?
25€ di bonus** in Bitcoin garantiti 🤑
+100€ per ogni amico invitato** (con alcune condizioni)
Deposito richiesto:** Solo 25€, immediatamente prelevabili! 💶

📜 Cosa serve per iniziare?
Solo carta d’identità e un selfie 📸

👉 Inizia subito con il mio link: https://join.robinhood.com/eu_crypto/aniellc-0e8f2b/

📢 Note Importanti:
1️⃣ Il bonus da 25€ sarà prelevabile dopo 180 giorni, un piccolo sforzo che vale assolutamente la pena! 😉
2️⃣ Il bonus di invito da 100€ potrebbe variare da persona a persona, quindi non è garantito a tutti. Tuttavia, il bonus da 25€ è sempre assicurato al 100%! 🥇
3️⃣ Per le persone affidabili, posso anticipare il deposito di 25€. Non farti problemi a chiedere! 💬

Con Robinhood il guadagno è semplice, veloce e sicuro! 🎉$$,
    'https://link.efallmo.it/Guidarobinhood',
    'https://link.efallmo.it/Guidarobinhood',
    50,
    '',
    null,
    'https://wbiztool-static.s3.ap-southeast-1.amazonaws.com/media/org_10455/media_10455_1749656665_0.jpg',
    '5 minuti',
    true,
    'ATTIVA',
    '25',
    '25', '€',
    '100', '€',
    'https://join.robinhood.com/eu_crypto/aniellc-0e8f2b/',
    null
  ),
  (
    'Tinaba',
    $$🚨 RITORNA TINABA MA SCADE FRA 2 GIORNI! : BONUS IMMEDIATO 20€ + 20€ PER INVITO! 🚨

🌟 CARATTERISTICHE:  
- Difficoltà: FACILE  
- Deposito minimo: 20€ (recuperabile al 100%)  
- Bonus immediato: 20€  
- Bonus per invito: 20€ (o 40€ se diventi Premium!)  

📱 COME OTTENERE IL BONUS (STEP-BY-STEP):  
💡 Inizia subito dalla guida e non perdere tempo! 💨

1️⃣ Segui la nostra guida dettagliata 👉 https://link.efallmo.it/GuidaTinaba 
   Scarica l’app Tinaba da qui ➡️ https://link.efallmo.it/ScaricaTinaba

2️⃣ Inserisci il codice: Y9LWFX durante la registrazione! 🧾  senza non riceverai il bonus 

3️⃣ Carica i documenti richiesti:  
   🔍 Documento d’identità (C.I.) + Tessera Sanitaria (❓ Non ce l’hai? Usa questa guida 👉 https://link.efallmo.it/Tesserasanitaria  

4️⃣ Effettua il primo deposito minimo di 20€ 💸 (che potrai recuperare al 100%)  

5️⃣ Ricevi subito il tuo bonus: 🎁 20€ accreditati direttamente sul tuo conto Tinaba!  

🌀 COME RECUPERARE IL DEPOSITO:  
Il deposito è TOTALMENTE recuperabile usando Verse, Revolut o un altro conto senza alcuna commissione! 💰  

💡 COME SPENDERE IL BONUS:  
- 👩‍💻 Pagamenti bollette (inquadrando il codice PagoPA)  
- 📶 Ricariche telefoniche  
- ⛽️ Benzina nei distributori IP convenzionati Tinaba  
- 🛍️ Shopping nei moltissimi negozi convenzionati  

⚡ BONUS EXTRA:  
👉 Invita amici con il tuo codice e ottieni 20€ per ogni invito!  
👑 Novità: Diventa Premium e ricevi 40€ per invito!$$,
    'https://link.efallmo.it/GuidaTinaba',
    'https://link.efallmo.it/GuidaTinaba',
    50,
    '',
    null,
    'https://wbiztool-static.s3.ap-southeast-1.amazonaws.com/media/org_10455/media_10455_1749898298_0.png',
    '8 minuti',
    true,
    'ATTIVA',
    '20',
    '10', '€',
    '10', '€',
    'Y9LWFX',
    null
  ),
  (
    'BBVA',
    $$🚨 NUOVA PROMO BBVA ITALIA 🇮🇹  

Facile, veloce e super conveniente! Non perdere tempo, scade presto! ⏳  

✅ Bonus: 10€ 💰  
🟢 Deposito richiesto: Solo 5€ 🪙  
📑 Documenti: Qualsiasi tipo!  
🚀 Limite inviti: 10 inviti = 200€ massimo!  

Guida completa: https://link.efallmo.it/bbvaguida$$,
    'https://link.efallmo.it/bbvaguida',
    'https://link.efallmo.it/bbvaguida',
    50,
    '',
    null,
    'https://wbiztool-static.s3.ap-southeast-1.amazonaws.com/media/org_10455/media_10455_1749978005_0.jpg',
    '5 minuti',
    true,
    'ATTIVA',
    '5',
    '10', '€',
    '20', '€',
    '77660036857843',
    null
  ),
  (
    'REVOLUT',
    $$🔥 Promo Revolut: Guadagna Fino a 300€! 🔥  

Segui la guida: https://link.efallmo.it/Guidarevolut
Chiedi il link su WhatsApp: https://wa.me/3664600605?text=bonusrevolut$$,
    'https://link.efallmo.it/Guidarevolut',
    'https://link.efallmo.it/Guidarevolut',
    50,
    '',
    null,
    'https://wbiztool-static.s3.ap-southeast-1.amazonaws.com/media/org_10455/media_10455_1749978640_0.jpg',
    '10 minuti',
    true,
    'ATTIVA',
    '22',
    '15', 'In Buoni',
    '50', '€',
    'https://wa.me/3664600605?text=Ciao%20Nello%20Potresti%20darmi%20un%20codice%20di%20Revolut%3F',
    null
  ),
  (
    'BUDDYBANK',
    $$🎉 NUOVO BONUS BUDDYBANK - SUPER FACILE! 🎉

Guida: https://link.efallmo.it/Guidabuddy
Codice: 26E27C (obbligatorio)$$,
    'https://link.efallmo.it/Guidabuddy',
    'https://link.efallmo.it/Guidabuddy',
    50,
    '',
    null,
    'https://wbiztool-static.s3.ap-southeast-1.amazonaws.com/media/org_10455/media_10455_1749979081_0.jpg',
    '7 minuti',
    true,
    'ATTIVA',
    '10',
    '50', '€',
    '50', '€',
    '26E27C',
    '30/09/2025'
  ),
  (
    'SKRILL',
    $$🎉 Altro giro, altro BONUS con Skrill! 💸  

Registrazione: https://link.efallmo.it/RegistrazioneSkrill  
Guida: https://link.efallmo.it/GuidaSKrill$$,
    'https://link.efallmo.it/GuidaSKrill',
    'https://link.efallmo.it/GuidaSKrill',
    50,
    '',
    null,
    'https://wbiztool-static.s3.ap-southeast-1.amazonaws.com/media/org_10455/media_10455_1749980434_0.jpg',
    '10 minuti',
    true,
    'ATTIVA',
    '150',
    '15', '$',
    '15', '$',
    'https://link.efallmo.it/RegistrazioneSkrill',
    null
  ),
  (
    'AMERICAN EXPRESS',
    $$Promo American Express - invita e guadagna!$$,
    'https://link.efallmo.it/Registrazioneamex',
    'https://link.efallmo.it/Registrazioneamex',
    50,
    '',
    null,
    'https://wbiztool-static.s3.ap-southeast-1.amazonaws.com/media/org_10455/media_10455_1757853369_0.jpg',
    '5 minuti',
    true,
    'ATTIVA',
    '0',
    '20', '€',
    '140', '€',
    'https://link.efallmo.it/Formamerican',
    null
  )
on conflict (title) do update set
  description = excluded.description,
  guide_url = excluded.guide_url,
  embed_url = excluded.embed_url,
  image_url = excluded.image_url,
  status = excluded.status,
  deposit_required = excluded.deposit_required,
  registration_bonus_amount = excluded.registration_bonus_amount,
  registration_bonus_type = excluded.registration_bonus_type,
  invite_bonus_amount = excluded.invite_bonus_amount,
  invite_bonus_type = excluded.invite_bonus_type,
  referral_code_or_registration_link = excluded.referral_code_or_registration_link,
  expiry_date_text = excluded.expiry_date_text,
  total_steps = 50,
  is_active = true;