param(
  [string]$modelName = "tiny_face_detector_model",
  [string]$dest = "web/models"
)

$base = 'https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/'
$manifestUrl = $base + "$modelName-weights_manifest.json"

Write-Host "Downloading manifest from $manifestUrl ..."
if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }

try {
  $manifestJson = Invoke-RestMethod -Uri $manifestUrl -UseBasicParsing
} catch {
  Write-Error "Failed to download manifest: $_"
  exit 1
}

# Save manifest locally
$manifestPath = Join-Path $dest "$modelName-weights_manifest.json"
$manifestJson | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 $manifestPath

foreach ($entry in $manifestJson) {
  if ($null -ne $entry.paths) {
    foreach ($p in $entry.paths) {
      $fileUrl = $base + $p
      $destFile = Join-Path $dest $p
      if (!(Test-Path $destFile)) {
        Write-Host "Downloading $fileUrl -> $destFile"
        try {
          Invoke-RestMethod -Uri $fileUrl -OutFile $destFile -UseBasicParsing
        } catch {
          Write-Error "Failed to download $fileUrl: $_"
        }
      } else {
        Write-Host "Skipping existing $destFile"
      }
    }
  }
}

Write-Host "Done. Models placed in $dest"
