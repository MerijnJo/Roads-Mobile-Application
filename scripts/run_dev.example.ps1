param(
  [string]$Device = "edge"
)

$supabaseUrl = "https://your-project-ref.supabase.co"
$supabasePublishableKey = "your-publishable-or-anon-key"

flutter run -d $Device `
  --dart-define=SUPABASE_URL=$supabaseUrl `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=$supabasePublishableKey
