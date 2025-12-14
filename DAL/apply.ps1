param(
  [string]$Server = "localhost,1433",
  [string]$Database = "AirportServicesDB",
  [string]$User = "sa",
  [string]$Password = ""
)

$cmd = Get-Command sqlcmd -ErrorAction SilentlyContinue
if (-not $cmd) {
  Write-Host "sqlcmd not found. Please install SQL Server Command Line Tools or run manually."
  exit 1
}

$files = Get-ChildItem -Path "$PSScriptRoot\migrations" -Recurse -Filter *.sql | Sort-Object FullName
foreach ($f in $files) {
  Write-Host "Applying $($f.FullName)"
  if ([string]::IsNullOrWhiteSpace($Password)) {
    sqlcmd -S $Server -d $Database -U $User -C -i $f.FullName
  } else {
    sqlcmd -S $Server -d $Database -U $User -P $Password -C -i $f.FullName
  }
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed on $($f.Name)"
    exit $LASTEXITCODE
  }
}
Write-Host "Migrations applied."
