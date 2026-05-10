-- Profiles table
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  username text unique not null,
  display_name text,
  bio text,
  avatar_url text,
  links jsonb default '[]'::jsonb,
  theme jsonb default '{ "bg_type": "color", "bg_value": "#0A0A0A", "text_color": "#FFFFFF", "accent_color": "#00FFB2", "button_style": "rounded-2xl" }'::jsonb,
  seo jsonb default '{ "title": "", "description": "" }'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Analytics table
create table public.analytics (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade not null,
  link_id text,
  event_type text default 'click', -- 'click' or 'view'
  user_agent text,
  created_at timestamptz default now()
);

-- RLS for analytics
alter table public.analytics enable row level security;

create policy "Users can view their own analytics."
  on analytics for select
  using ( auth.uid() = profile_id );

create policy "Anyone can insert analytics (for tracking)."
  on analytics for insert
  with check ( true );

-- Rest of the file...

-- Set up Row Level Security (RLS)
alter table public.profiles enable row level security;

-- Create policies
create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update their own profile."
  on profiles for update
  using ( auth.uid() = id );

-- Handle updated_at
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger on_profiles_updated
  before update on public.profiles
  for each row
  execute procedure public.handle_updated_at();

-- Set up storage
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true);

create policy "Avatar images are publicly accessible."
  on storage.objects for select
  using ( bucket_id = 'avatars' );

create policy "Users can upload their own avatar."
  on storage.objects for insert
  with check ( bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1] );

create policy "Users can update their own avatar."
  on storage.objects for update
  using ( bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1] );

create policy "Users can delete their own avatar."
  on storage.objects for delete
  using ( bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1] );
