# Toggle ai-ready tag on a work item to trigger the webhook
# Usage: ./toggle-ai-ready.ps1 -WorkItemId 123456 [-Pat "your-pat-token"]

param(
    [Parameter(Mandatory=$true)]
    [int]$WorkItemId,

    [Parameter(Mandatory=$false)]
    [string]$Pat = $env:AZURE_DEVOPS_PAT,

    [Parameter(Mandatory=$false)]
    [string]$Organization = "your-org",

    [Parameter(Mandatory=$false)]
    [string]$Project = "your-project"
)

if (-not $Pat) {
    Write-Error "PAT token required. Set AZURE_DEVOPS_PAT environment variable or use -Pat parameter."
    exit 1
}

$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
$headers = @{
    Authorization = "Basic $base64Auth"
    "Content-Type" = "application/json-patch+json"
}

$baseUrl = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems/$WorkItemId"

# Get current work item
Write-Host "Fetching work item $WorkItemId..."
$workItem = Invoke-RestMethod -Uri "$baseUrl`?api-version=7.0" -Headers @{ Authorization = "Basic $base64Auth" } -Method Get

$currentTags = $workItem.fields.'System.Tags'
Write-Host "Current tags: $currentTags"

# Remove ai-ready tag
if ($currentTags -match "ai-ready") {
    Write-Host "Removing ai-ready tag..."
    $tagsArray = $currentTags -split ";" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "ai-ready" -and $_ -ne "" }
    $newTags = $tagsArray -join "; "

    $body = "[{`"op`":`"replace`",`"path`":`"/fields/System.Tags`",`"value`":`"$newTags`"}]"

    Invoke-RestMethod -Uri "$baseUrl`?api-version=7.0" -Headers $headers -Method Patch -Body $body | Out-Null
    Write-Host "Removed ai-ready tag. Tags now: $newTags"

    Start-Sleep -Seconds 2
}

# Add ai-ready tag back
Write-Host "Adding ai-ready tag..."
$workItem = Invoke-RestMethod -Uri "$baseUrl`?api-version=7.0" -Headers @{ Authorization = "Basic $base64Auth" } -Method Get
$currentTags = $workItem.fields.'System.Tags'

# Build new tags, avoiding duplicates
[System.Collections.ArrayList]$tagsArray = @()
if ($currentTags) {
    $currentTags -split ";" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "ai-ready" -and $_ -ne "" } | ForEach-Object { $tagsArray.Add($_) | Out-Null }
}
$tagsArray.Add("ai-ready") | Out-Null
$newTags = $tagsArray -join "; "

$body = "[{`"op`":`"replace`",`"path`":`"/fields/System.Tags`",`"value`":`"$newTags`"}]"

Invoke-RestMethod -Uri "$baseUrl`?api-version=7.0" -Headers $headers -Method Patch -Body $body | Out-Null
Write-Host "Added ai-ready tag. Tags now: $newTags"

Write-Host "`nDone! Webhook should be triggered."
