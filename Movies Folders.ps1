# Define the main movie directory as a UNC path
$movieDirectory = "\\ELIZABETH\Plex\Movies"

# Define allowed extensions (add more as needed)
$allowedExtensions = @(".mp4", ".mkv", ".avi", ".srt", ".sub", ".ass")

# Optional: If authentication is required to access the network share,
# uncomment and configure the following lines with appropriate credentials.
# $username = "YourUsername"
# $password = "YourPassword" | ConvertTo-SecureString -AsPlainText -Force
# $credential = New-Object System.Management.Automation.PSCredential ($username, $password)
# New-PSDrive -Name "P" -PSProvider FileSystem -Root "\\ELIZABETH\Plex\Moves" -Credential $credential -Persist

# Function to check access to the network share
function Test-NetworkPath {
    param (
        [string]$Path
    )
    try {
        $null = Get-ChildItem -Path $Path -ErrorAction Stop
        return $true
    } catch {
        Write-Host "Error: Cannot access the path '$Path'. Please ensure you have the necessary permissions." -ForegroundColor Red
        return $false
    }
}

# Verify access to the network share
if (-not (Test-NetworkPath -Path $movieDirectory)) {
    exit 1
}

# Get all files in the main movie directory (non-recursive)
try {
    $files = Get-ChildItem -Path $movieDirectory -File -ErrorAction Stop
} catch {
    Write-Host "Error: Failed to retrieve files from '$movieDirectory'. $_" -ForegroundColor Red
    exit 1
}

foreach ($file in $files) {
    $extension = $file.Extension.ToLower()

    if ($allowedExtensions -contains $extension) {
        # Extract movie title without extension
        $movieTitle = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

        # Define the target movie folder path
        $movieFolder = Join-Path -Path $movieDirectory -ChildPath $movieTitle

        # Check if the target folder already exists
        if (-not (Test-Path -Path $movieFolder)) {
            try {
                New-Item -Path $movieFolder -ItemType Directory -ErrorAction Stop | Out-Null
                Write-Host "Created folder: '$movieFolder'" -ForegroundColor Green
            } catch {
                Write-Host "Error: Failed to create folder '$movieFolder'. $_" -ForegroundColor Red
                continue
            }
        }

        # Define the destination path for the file
        $destinationPath = Join-Path -Path $movieFolder -ChildPath $file.Name

        # Move the file to the target folder
        try {
            Move-Item -Path $file.FullName -Destination $destinationPath -Force -ErrorAction Stop
            Write-Host "Moved: '$($file.Name)' to '$movieFolder'" -ForegroundColor Cyan
        } catch {
            Write-Host "Error: Failed to move '$($file.Name)' to '$movieFolder'. $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Skipped (unwanted extension): '$($file.Name)'" -ForegroundColor Yellow
    }
}

# Optional: Remove unwanted file types from all movie folders
# Uncomment the following section if you also want to clean up unwanted files within individual movie folders.


# Define unwanted extensions (add more as needed)
$unwantedExtensions = @(".txt", ".jpg", ".jpeg", ".nfo", ".gif", ".docx")

#Get all files in the movie directory and subdirectories
try {
    $allFiles = Get-ChildItem -Path $movieDirectory -Recurse -File -ErrorAction Stop
} catch {
    Write-Host "Error: Failed to retrieve files for cleanup. $_" -ForegroundColor Red
    exit 1
}

foreach ($file in $allFiles) {
    $extension = $file.Extension.ToLower()

    if ($unwantedExtensions -contains $extension) {
        try {
            Remove-Item -Path $file.FullName -Force -ErrorAction Stop
            Write-Host "Removed unwanted file: '$($file.FullName)'" -ForegroundColor Magenta
        } catch {
            Write-Host "Error: Failed to remove '$($file.FullName)'. $_" -ForegroundColor Red
        }
    }
}
