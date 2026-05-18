# Scripts

Create your private local runner from the example:

```powershell
Copy-Item scripts/run_dev.example.ps1 scripts/run_dev.ps1
```

Then edit `scripts/run_dev.ps1` with your Supabase URL and publishable key.

Run the app:

```powershell
.\scripts\run_dev.ps1
```

Use another device target when needed:

```powershell
.\scripts\run_dev.ps1 -Device chrome
.\scripts\run_dev.ps1 -Device windows
```

`scripts/run_dev.ps1` is ignored by Git so local credentials do not get committed.
