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
    'amalfi-coast',
    'Amalfi Coast Drive',
    'A cliffside Mediterranean route linking Sorrento, Positano, Amalfi, Ravello, and Salerno above turquoise coves and lemon terraces.',
    '42 mi',
    '2-3 hr',
    extensions.st_setsrid(
      extensions.st_makeline(array[
        extensions.st_makepoint(14.375798, 40.626292),
        extensions.st_makepoint(14.400054, 40.620409),
        extensions.st_makepoint(14.422462, 40.615879),
        extensions.st_makepoint(14.448945, 40.61851),
        extensions.st_makepoint(14.484981, 40.628052),
        extensions.st_makepoint(14.524137, 40.612669),
        extensions.st_makepoint(14.550471, 40.611084),
        extensions.st_makepoint(14.574391, 40.617915),
        extensions.st_makepoint(14.602681, 40.634002),
        extensions.st_makepoint(14.611846, 40.649158),
        extensions.st_makepoint(14.637645, 40.648203),
        extensions.st_makepoint(14.681322, 40.650271),
        extensions.st_makepoint(14.728641, 40.670136),
        extensions.st_makepoint(14.768096, 40.682441)
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
    ('sorrento', 'Sorrento', 'Historic gateway town above the Bay of Naples.', 14.375798, 40.626292, 10),
    ('positano', 'Positano', 'Stacked pastel houses dropping toward the sea.', 14.484981, 40.628052, 20),
    ('amalfi', 'Amalfi', 'Coastal town with a cathedral square and harbor.', 14.602681, 40.634002, 30),
    ('ravello', 'Ravello', 'Hilltop gardens with sweeping coast views.', 14.611846, 40.649158, 40),
    ('salerno', 'Salerno', 'Eastern endpoint with a long waterfront promenade.', 14.768096, 40.682441, 50)
) as stop(slug, name, description, lng, lat, sort_order)
on conflict (route_id, slug) do update set
  name = excluded.name,
  description = excluded.description,
  location = excluded.location,
  sort_order = excluded.sort_order;

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
    'great-ocean-road',
    'Great Ocean Road',
    'A southern Australia coastal drive from surf towns to rainforest bends and the limestone stacks of the Twelve Apostles.',
    '151 mi',
    '4-5 hr',
    extensions.st_setsrid(
      extensions.st_makeline(array[
        extensions.st_makepoint(144.3261, -38.3333),
        extensions.st_makepoint(144.1884, -38.4056),
        extensions.st_makepoint(144.0253, -38.4078),
        extensions.st_makepoint(143.9762, -38.5401),
        extensions.st_makepoint(143.7925, -38.5393),
        extensions.st_makepoint(143.6724, -38.6367),
        extensions.st_makepoint(143.6691, -38.755),
        extensions.st_makepoint(143.4351, -38.7545),
        extensions.st_makepoint(143.383, -38.6987),
        extensions.st_makepoint(143.1042, -38.6633),
        extensions.st_makepoint(142.9955, -38.6191),
        extensions.st_makepoint(142.4833, -38.3833)
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
    ('torquay', 'Torquay', 'Surf coast starting point near Bells Beach.', 144.3261, -38.3333, 10),
    ('lorne', 'Lorne', 'Beach town backed by fern gullies and waterfalls.', 143.9762, -38.5401, 20),
    ('apollo-bay', 'Apollo Bay', 'Harbor town between the ocean and Otway ranges.', 143.6691, -38.755, 30),
    ('twelve-apostles', 'Twelve Apostles', 'Limestone sea stacks rising from the Southern Ocean.', 143.1042, -38.6633, 40),
    ('warrnambool', 'Warrnambool', 'Western endpoint near beaches and whale viewpoints.', 142.4833, -38.3833, 50)
) as stop(slug, name, description, lng, lat, sort_order)
on conflict (route_id, slug) do update set
  name = excluded.name,
  description = excluded.description,
  location = excluded.location,
  sort_order = excluded.sort_order;

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
    'garden-route',
    'Garden Route',
    'A South African coastal route through bays, forests, lagoons, and dramatic bridges between Mossel Bay and Storms River.',
    '126 mi',
    '3-4 hr',
    extensions.st_setsrid(
      extensions.st_makeline(array[
        extensions.st_makepoint(22.1461, -34.1831),
        extensions.st_makepoint(22.2241, -34.0363),
        extensions.st_makepoint(22.5769, -33.993),
        extensions.st_makepoint(22.7926, -34.0152),
        extensions.st_makepoint(23.0471, -34.0363),
        extensions.st_makepoint(23.3716, -34.0527),
        extensions.st_makepoint(23.5786, -34.0395),
        extensions.st_makepoint(23.8959, -34.0219),
        extensions.st_makepoint(23.8867, -33.9707)
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
    ('mossel-bay', 'Mossel Bay', 'Harbor town and western gateway to the route.', 22.1461, -34.1831, 10),
    ('wilderness', 'Wilderness', 'Lakes, beaches, and forested viewpoints.', 22.5769, -33.993, 20),
    ('knysna', 'Knysna', 'Lagoon town framed by the famous Knysna Heads.', 23.0471, -34.0363, 30),
    ('plettenberg-bay', 'Plettenberg Bay', 'Wide beaches and marine wildlife viewpoints.', 23.3716, -34.0527, 40),
    ('storms-river', 'Storms River', 'Forest village near Tsitsikamma cliffs and bridges.', 23.8867, -33.9707, 50)
) as stop(slug, name, description, lng, lat, sort_order)
on conflict (route_id, slug) do update set
  name = excluded.name,
  description = excluded.description,
  location = excluded.location,
  sort_order = excluded.sort_order;
