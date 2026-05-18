# Supabase Setup

Roads stores scenic drives as route geometries plus ordered route stops.

## Recommended workflow

Use Supabase CLI migrations as the source of truth for database changes.
Avoid making schema changes directly in the hosted dashboard once the project is linked.

From this repo on Windows:

```powershell
npx.cmd supabase login
npx.cmd supabase link --project-ref your-project-ref
npx.cmd supabase db push --dry-run
npx.cmd supabase db push
```

You can find `your-project-ref` in the Supabase dashboard URL:

```text
https://supabase.com/dashboard/project/your-project-ref
```

## First migration

Run `supabase/migrations/20260518120000_create_scenic_routes.sql` in your Supabase project SQL editor or through the Supabase CLI.

The migration creates:

- `public.scenic_routes`
- `public.route_stops`
- PostGIS spatial indexes
- read-only RLS policies for published routes
- `public.discover_routes()` for the mobile app
- a seeded `Tioga Pass Road` route using OpenStreetMap-based road geometry generated through OSRM

## App connection

The Flutter app currently uses `LocalRouteRepository`, so it can run before the Supabase project credentials exist.

To connect the live backend next, the app needs:

- Supabase project URL
- Supabase publishable/anon key
- `supabase_flutter` dependency
- `SupabaseRouteRepository` that calls `discover_routes()`

Do not commit private service-role keys to the mobile app.

Run the app against Supabase with:

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-or-anon-key
```

If either value is missing, the app uses the local route seed instead.
