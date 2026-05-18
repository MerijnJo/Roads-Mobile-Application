create extension if not exists postgis with schema extensions;

create table if not exists public.scenic_routes (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  description text not null,
  distance_label text not null,
  duration_label text not null,
  geometry extensions.geometry(LineString, 4326) not null,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists scenic_routes_geometry_idx
  on public.scenic_routes
  using gist (geometry);

create table if not exists public.route_stops (
  id uuid primary key default gen_random_uuid(),
  route_id uuid not null references public.scenic_routes(id) on delete cascade,
  slug text not null,
  name text not null,
  description text not null,
  location extensions.geometry(Point, 4326) not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique(route_id, slug)
);

create index if not exists route_stops_location_idx
  on public.route_stops
  using gist (location);

alter table public.scenic_routes enable row level security;
alter table public.route_stops enable row level security;

drop policy if exists "Published routes are readable" on public.scenic_routes;
create policy "Published routes are readable"
  on public.scenic_routes
  for select
  to anon, authenticated
  using (is_published);

drop policy if exists "Stops for published routes are readable" on public.route_stops;
create policy "Stops for published routes are readable"
  on public.route_stops
  for select
  to anon, authenticated
  using (
    exists (
      select 1
      from public.scenic_routes
      where scenic_routes.id = route_stops.route_id
        and scenic_routes.is_published
    )
  );

create or replace function public.discover_routes()
returns table (
  id uuid,
  slug text,
  name text,
  description text,
  distance_label text,
  duration_label text,
  center_lat double precision,
  center_lng double precision,
  geometry_geojson jsonb,
  stops jsonb
)
set search_path = ''
language sql
stable
as $$
  select
    routes.id,
    routes.slug,
    routes.name,
    routes.description,
    routes.distance_label,
    routes.duration_label,
    extensions.st_y(extensions.st_centroid(routes.geometry)) as center_lat,
    extensions.st_x(extensions.st_centroid(routes.geometry)) as center_lng,
    extensions.st_asgeojson(routes.geometry)::jsonb as geometry_geojson,
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'id', stops.id,
          'slug', stops.slug,
          'name', stops.name,
          'description', stops.description,
          'lat', extensions.st_y(stops.location),
          'lng', extensions.st_x(stops.location),
          'sort_order', stops.sort_order
        )
        order by stops.sort_order
      ) filter (where stops.id is not null),
      '[]'::jsonb
    ) as stops
  from public.scenic_routes as routes
  left join public.route_stops as stops
    on stops.route_id = routes.id
  where routes.is_published
  group by routes.id
  order by routes.created_at desc;
$$;

with route as (
  insert into public.scenic_routes (
    slug,
    name,
    description,
    distance_label,
    duration_label,
    geometry,
    is_published
  )
  values (
    'tioga-pass',
    'Tioga Pass Road',
    'A high Sierra drive across Yosemite, linking granite domes, meadows, lakes, and the eastern escarpment near Lee Vining.',
    '68 mi',
    '2-3 hr',
    extensions.st_setsrid(
      extensions.st_makeline(array[
        extensions.st_makepoint(-119.872007, 37.808873),
        extensions.st_makepoint(-119.876539, 37.788871),
        extensions.st_makepoint(-119.861371, 37.776026),
        extensions.st_makepoint(-119.859451, 37.766754),
        extensions.st_makepoint(-119.834116, 37.762304),
        extensions.st_makepoint(-119.824642, 37.75201),
        extensions.st_makepoint(-119.817391, 37.755981),
        extensions.st_makepoint(-119.80349, 37.747342),
        extensions.st_makepoint(-119.797557, 37.752483),
        extensions.st_makepoint(-119.80486, 37.758188),
        extensions.st_makepoint(-119.802353, 37.760689),
        extensions.st_makepoint(-119.791591, 37.756866),
        extensions.st_makepoint(-119.779188, 37.759428),
        extensions.st_makepoint(-119.772158, 37.755414),
        extensions.st_makepoint(-119.770966, 37.769072),
        extensions.st_makepoint(-119.752391, 37.775295),
        extensions.st_makepoint(-119.735325, 37.788849),
        extensions.st_makepoint(-119.724364, 37.789682),
        extensions.st_makepoint(-119.713226, 37.811122),
        extensions.st_makepoint(-119.714091, 37.819605),
        extensions.st_makepoint(-119.704908, 37.821587),
        extensions.st_makepoint(-119.701719, 37.831222),
        extensions.st_makepoint(-119.671426, 37.849911),
        extensions.st_makepoint(-119.653716, 37.850127),
        extensions.st_makepoint(-119.64346, 37.85764),
        extensions.st_makepoint(-119.625977, 37.849833),
        extensions.st_makepoint(-119.597175, 37.84873),
        extensions.st_makepoint(-119.59221, 37.839037),
        extensions.st_makepoint(-119.57468, 37.851922),
        extensions.st_makepoint(-119.571751, 37.848289),
        extensions.st_makepoint(-119.581353, 37.828113),
        extensions.st_makepoint(-119.580558, 37.815459),
        extensions.st_makepoint(-119.568936, 37.808365),
        extensions.st_makepoint(-119.544601, 37.806785),
        extensions.st_makepoint(-119.516124, 37.81796),
        extensions.st_makepoint(-119.508083, 37.816703),
        extensions.st_makepoint(-119.50843, 37.811146),
        extensions.st_makepoint(-119.497524, 37.81717),
        extensions.st_makepoint(-119.484735, 37.810956),
        extensions.st_makepoint(-119.477029, 37.823749),
        extensions.st_makepoint(-119.449844, 37.840304),
        extensions.st_makepoint(-119.425161, 37.873547),
        extensions.st_makepoint(-119.406742, 37.876577),
        extensions.st_makepoint(-119.400699, 37.881493),
        extensions.st_makepoint(-119.386834, 37.873745),
        extensions.st_makepoint(-119.36919, 37.87194),
        extensions.st_makepoint(-119.324009, 37.882131),
        extensions.st_makepoint(-119.276647, 37.879333),
        extensions.st_makepoint(-119.260041, 37.893334),
        extensions.st_makepoint(-119.256228, 37.925991),
        extensions.st_makepoint(-119.249297, 37.937759),
        extensions.st_makepoint(-119.240474, 37.940243),
        extensions.st_makepoint(-119.231663, 37.935899),
        extensions.st_makepoint(-119.225535, 37.952533),
        extensions.st_makepoint(-119.189323, 37.947828),
        extensions.st_makepoint(-119.176691, 37.932612),
        extensions.st_makepoint(-119.168711, 37.930409),
        extensions.st_makepoint(-119.134136, 37.940229),
        extensions.st_makepoint(-119.120144, 37.940226),
        extensions.st_makepoint(-119.113095, 37.950419),
        extensions.st_makepoint(-119.120209, 37.9575)
      ]),
      4326
    ),
    true
  )
  on conflict (slug) do update set
    name = excluded.name,
    description = excluded.description,
    distance_label = excluded.distance_label,
    duration_label = excluded.duration_label,
    geometry = excluded.geometry,
    is_published = excluded.is_published,
    updated_at = now()
  returning id
)
insert into public.route_stops (
  route_id,
  slug,
  name,
  description,
  location,
  sort_order
)
select
  route.id,
  stop.slug,
  stop.name,
  stop.description,
  extensions.st_setsrid(extensions.st_makepoint(stop.lng, stop.lat), 4326),
  stop.sort_order
from route
cross join (
  values
    ('crane-flat', 'Crane Flat', 'Western gateway toward Tioga Road and high country.', -119.872007, 37.808873, 10),
    ('tenaya-lake', 'Tenaya Lake', 'Clear alpine water framed by granite slopes.', -119.59221, 37.839037, 20),
    ('tuolumne-meadows', 'Tuolumne Meadows', 'Broad subalpine meadows in Yosemite high country.', -119.386834, 37.873745, 30),
    ('tioga-pass', 'Tioga Pass', 'The eastern pass and Yosemite entrance area.', -119.2082, 37.944485, 40),
    ('lee-vining', 'Lee Vining', 'Eastern endpoint near Mono Lake and US 395.', -119.120209, 37.9575, 50)
) as stop(slug, name, description, lng, lat, sort_order)
on conflict (route_id, slug) do update set
  name = excluded.name,
  description = excluded.description,
  location = excluded.location,
  sort_order = excluded.sort_order;
