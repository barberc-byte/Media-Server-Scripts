# Debug: announce the script start
Write-Host "Starting CleanTvShows script..." -ForegroundColor Cyan

# Define the base TV shows directory (UNC path)
$tvShowsDirectory = "\\ELIZABETH\Plex\Tv shows"

# Optional: If network authentication is required, uncomment the following block and set your credentials.
<# 
$username = "YourUsername"
$password = "YourPassword" | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $password)
Write-Host "Mapping network drive P: to \\ELIZABETH\Plex\Tv shows..." -ForegroundColor Cyan
New-PSDrive -Name "P" -PSProvider FileSystem -Root "\\ELIZABETH\Plex\Tv shows" -Credential $credential -Persist
$tvShowsDirectory = "P:\"
Write-Host "Using mapped drive at $tvShowsDirectory" -ForegroundColor Cyan
#>

# Test if the directory is accessible
if (-Not (Test-Path $tvShowsDirectory)) {
    Write-Host "Error: The directory '$tvShowsDirectory' could not be found or accessed." -ForegroundColor Red
    exit 1
} else {
    Write-Host "Access confirmed to '$tvShowsDirectory'" -ForegroundColor Green
}

# Define allowed subtitle and video file extensions
$allowedSubtitleExtensions = @(".srt", ".sub", ".ass")
$allowedVideoExtensions = @(".mp4", ".mkv", ".avi", ".mov", ".wmv", ".flv")

# Function to decide if a PNG file is allowed
function IsAllowedPng($fileName) {
    $lowerName = $fileName.ToLower()
    if ($lowerName -eq "poster.png") { return $true }
    if ($lowerName -match "^season\s+\d+\.png$") { return $true }
    return $false
}

# Get all files recursively from the TV shows directory
try {
    $files = Get-ChildItem -Path $tvShowsDirectory -Recurse -File -ErrorAction Stop
    Write-Host "Found $($files.Count) files in '$tvShowsDirectory'" -ForegroundColor Cyan
} catch {
    Write-Host "Error: Unable to access '$tvShowsDirectory'. $_" -ForegroundColor Red
    exit 1
}

# Loop through each file and remove unwanted files
foreach ($file in $files) {
    $extension = $file.Extension.ToLower()
    $fileName = $file.Name
    $removeFile = $false

    # If the file is a PNG, only allow if it's "poster.png" or "Season X.png"
    if ($extension -eq ".png") {
        if (-not (IsAllowedPng $fileName)) {
            $removeFile = $true
        }
    }
    # Keep subtitle files
    elseif ($allowedSubtitleExtensions -contains $extension) {
        $removeFile = $false
    }
    # Keep video files
    elseif ($allowedVideoExtensions -contains $extension) {
        $removeFile = $false
    }
    # For any other file types (e.g. .jpg, .txt, .nfo, etc.) mark for removal
    else {
        $removeFile = $true
    }

    if ($removeFile) {
        try {
            Remove-Item -Path $file.FullName -Force -ErrorAction Stop
            Write-Host "Removed: $($file.FullName)" -ForegroundColor Yellow
        } catch {
            Write-Host "Failed to remove: $($file.FullName). Error: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Kept: $($file.FullName)" -ForegroundColor Green
    }
}

Write-Host "Cleanup complete!" -ForegroundColor Cyan
