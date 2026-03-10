-- ============================================================
-- HostelHop — Supabase Schema
-- Run in: Supabase Dashboard → SQL Editor
-- ============================================================


-- ── Extensions ────────────────────────────────────────────────────────────────
create extension if not exists "uuid-ossp";


-- ============================================================
-- TABLES
-- ============================================================

-- ── profiles ──────────────────────────────────────────────────────────────────
-- Mirrors auth.users. Created on sign-up via auth_service.dart.
create table if not exists public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  full_name     text not null,
  phone         text not null,
  email         text not null default '',
  role          text not null default 'student'
                  check (role in ('student', 'owner', 'admin')),
  avatar_url    text,
  university    text,
  student_id    text,
  fcm_token     text,
  created_at    timestamptz not null default now()
);

-- ── hostels ───────────────────────────────────────────────────────────────────
create table if not exists public.hostels (
  id                  uuid primary key default uuid_generate_v4(),
  owner_id            uuid not null references public.profiles(id) on delete cascade,
  name                text not null,
  location            text not null,
  description         text not null default '',
  price_per_semester  integer not null,
  commitment_fee      integer not null,
  total_rooms         integer not null default 0,
  rooms_available     integer not null default 0,
  amenities           text[] not null default '{}',
  image_urls          text[] not null default '{}',
  rating              numeric(3,2) not null default 0.00,
  review_count        integer not null default 0,
  is_verified         boolean not null default false,
  is_active           boolean not null default true,
  primary_room_type   text not null default 'Single Room',
  semester_label      text,
  duration_label      text,
  latitude            numeric(9,6),
  longitude           numeric(9,6),
  distance_from_campus numeric(5,2),
  created_at          timestamptz not null default now()
);

-- ── rooms ─────────────────────────────────────────────────────────────────────
create table if not exists public.rooms (
  id                  uuid primary key default uuid_generate_v4(),
  hostel_id           uuid not null references public.hostels(id) on delete cascade,
  type                text not null default 'single'
                        check (type in ('single', 'double', 'triple', 'self_contained')),
  price_per_semester  integer not null,
  total_slots         integer not null default 1,
  available_slots     integer not null default 1,
  is_active           boolean not null default true,
  description         text,
  image_urls          text[] not null default '{}',
  amenities           text[] not null default '{}',
  floor_number        integer,
  room_number         text,
  created_at          timestamptz not null default now()
);

-- ── bookings ──────────────────────────────────────────────────────────────────
create table if not exists public.bookings (
  id                    uuid primary key default uuid_generate_v4(),
  user_id               uuid not null references public.profiles(id) on delete cascade,
  hostel_id             uuid not null references public.hostels(id) on delete cascade,
  room_id               uuid references public.rooms(id) on delete set null,
  hostel_name           text not null default '',
  room_type             text not null default 'Single Room',
  reference             text not null unique,
  status                text not null default 'pending'
                          check (status in ('pending', 'confirmed', 'completed', 'cancelled')),
  total_amount          integer not null,
  commitment_fee_amount integer not null,
  commitment_fee_paid   integer not null default 0,
  check_in_date         timestamptz not null,
  check_out_date        timestamptz not null,
  hostel_image_url      text,
  payment_method        text,
  payment_phone         text,
  notes                 text,
  created_at            timestamptz not null default now()
);

-- ── reviews ───────────────────────────────────────────────────────────────────
create table if not exists public.reviews (
  id               uuid primary key default uuid_generate_v4(),
  hostel_id        uuid not null references public.hostels(id) on delete cascade,
  user_id          uuid not null references public.profiles(id) on delete cascade,
  user_name        text not null default 'Anonymous',
  user_avatar_url  text,
  rating           numeric(3,1) not null check (rating >= 1 and rating <= 5),
  comment          text not null default '',
  owner_reply      text,
  owner_reply_at   timestamptz,
  is_verified_stay boolean not null default false,
  helpful_count    integer not null default 0,
  created_at       timestamptz not null default now(),
  unique (hostel_id, user_id)   -- one review per user per hostel
);


-- ============================================================
-- INDEXES
-- ============================================================
create index if not exists idx_hostels_owner    on public.hostels(owner_id);
create index if not exists idx_hostels_active   on public.hostels(is_active);
create index if not exists idx_rooms_hostel     on public.rooms(hostel_id);
create index if not exists idx_bookings_user    on public.bookings(user_id);
create index if not exists idx_bookings_hostel  on public.bookings(hostel_id);
create index if not exists idx_bookings_status  on public.bookings(status);
create index if not exists idx_reviews_hostel   on public.reviews(hostel_id);


-- ============================================================
-- FUNCTIONS / RPCs
-- ============================================================

-- ── decrement_rooms_available ─────────────────────────────────────────────────
-- Called by booking_service.dart after payment confirms.
-- Guards against going below 0.
create or replace function public.decrement_rooms_available(hostel_id uuid)
returns void
language plpgsql
security definer
as $$
begin
  update public.hostels
  set rooms_available = greatest(rooms_available - 1, 0)
  where id = hostel_id;
end;
$$;

-- ── decrement_room_slots ──────────────────────────────────────────────────────
-- Called by booking_service.dart after payment confirms.
-- Guards against going below 0.
create or replace function public.decrement_room_slots(room_id uuid)
returns void
language plpgsql
security definer
as $$
begin
  update public.rooms
  set available_slots = greatest(available_slots - 1, 0)
  where id = room_id;
end;
$$;

-- ── increment_review_helpful ──────────────────────────────────────────────────
-- Called by review_repository.dart when a user marks a review helpful.
create or replace function public.increment_review_helpful(review_id uuid)
returns void
language plpgsql
security definer
as $$
begin
  update public.reviews
  set helpful_count = helpful_count + 1
  where id = review_id;
end;
$$;

-- ── update_hostel_rating ───────────────────────────────────────────────────────
-- Trigger function: recalculates rating + review_count on reviews INSERT/DELETE.
create or replace function public.update_hostel_rating()
returns trigger
language plpgsql
security definer
as $$
begin
  update public.hostels
  set
    rating       = (select coalesce(avg(rating), 0) from public.reviews where hostel_id = coalesce(NEW.hostel_id, OLD.hostel_id)),
    review_count = (select count(*) from public.reviews where hostel_id = coalesce(NEW.hostel_id, OLD.hostel_id))
  where id = coalesce(NEW.hostel_id, OLD.hostel_id);
  return NEW;
end;
$$;

-- Attach trigger to reviews table
drop trigger if exists trg_update_hostel_rating on public.reviews;
create trigger trg_update_hostel_rating
after insert or update or delete on public.reviews
for each row execute function public.update_hostel_rating();


-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

alter table public.profiles  enable row level security;
alter table public.hostels   enable row level security;
alter table public.rooms     enable row level security;
alter table public.bookings  enable row level security;
alter table public.reviews   enable row level security;


-- ── profiles ──────────────────────────────────────────────────────────────────
-- Users can only read/update their own profile.
create policy "profiles: select own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles: insert own"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "profiles: update own"
  on public.profiles for update
  using (auth.uid() = id);


-- ── hostels ───────────────────────────────────────────────────────────────────
-- Anyone (including anon) can read active hostels.
-- Only owners can insert/update/delete their own hostels.
create policy "hostels: public read active"
  on public.hostels for select
  using (is_active = true or auth.uid() = owner_id);

create policy "hostels: owner insert"
  on public.hostels for insert
  with check (auth.uid() = owner_id);

create policy "hostels: owner update"
  on public.hostels for update
  using (auth.uid() = owner_id);

create policy "hostels: owner delete"
  on public.hostels for delete
  using (auth.uid() = owner_id);


-- ── rooms ─────────────────────────────────────────────────────────────────────
-- Anyone can read active rooms; only hostel owner can mutate.
create policy "rooms: public read"
  on public.rooms for select
  using (
    is_active = true
    or exists (
      select 1 from public.hostels
      where hostels.id = rooms.hostel_id
        and hostels.owner_id = auth.uid()
    )
  );

create policy "rooms: owner insert"
  on public.rooms for insert
  with check (
    exists (
      select 1 from public.hostels
      where hostels.id = rooms.hostel_id
        and hostels.owner_id = auth.uid()
    )
  );

create policy "rooms: owner update"
  on public.rooms for update
  using (
    exists (
      select 1 from public.hostels
      where hostels.id = rooms.hostel_id
        and hostels.owner_id = auth.uid()
    )
  );

create policy "rooms: owner delete"
  on public.rooms for delete
  using (
    exists (
      select 1 from public.hostels
      where hostels.id = rooms.hostel_id
        and hostels.owner_id = auth.uid()
    )
  );


-- ── bookings ──────────────────────────────────────────────────────────────────
-- Students can read/create/cancel their own bookings.
-- Hostel owners can read bookings for their hostels.
create policy "bookings: student read own"
  on public.bookings for select
  using (
    auth.uid() = user_id
    or exists (
      select 1 from public.hostels
      where hostels.id = bookings.hostel_id
        and hostels.owner_id = auth.uid()
    )
  );

create policy "bookings: student insert"
  on public.bookings for insert
  with check (auth.uid() = user_id);

create policy "bookings: student update own"
  on public.bookings for update
  using (
    auth.uid() = user_id
    or exists (
      select 1 from public.hostels
      where hostels.id = bookings.hostel_id
        and hostels.owner_id = auth.uid()
    )
  );


-- ── reviews ───────────────────────────────────────────────────────────────────
-- Anyone can read reviews; only reviewer can insert; owner can update reply.
create policy "reviews: public read"
  on public.reviews for select
  using (true);

create policy "reviews: student insert"
  on public.reviews for insert
  with check (auth.uid() = user_id);

create policy "reviews: update own or owner reply"
  on public.reviews for update
  using (
    auth.uid() = user_id
    or exists (
      select 1 from public.hostels
      where hostels.id = reviews.hostel_id
        and hostels.owner_id = auth.uid()
    )
  );

create policy "reviews: student delete own"
  on public.reviews for delete
  using (auth.uid() = user_id);


-- ============================================================
-- STORAGE BUCKETS
-- Create in: Supabase Dashboard → Storage
-- (Cannot be created via SQL; listed here for reference)
-- ============================================================
-- Bucket: hostel-images   — public  — 10 MB limit — image/*
-- Bucket: avatars         — public  — 5 MB limit  — image/*
-- Bucket: documents       — private — 20 MB limit — application/pdf, image/*
