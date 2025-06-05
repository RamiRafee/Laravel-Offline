# Prompt user to choose between online and offline mode
$mode = Read-Host "Run setup in (online/offline) mode?"

if ($mode -eq "online") {
    Write-Host "`n[INFO] Building Laravel app image..." -ForegroundColor Yellow
    docker build -t my-laravel-app .

    Write-Host "`n[INFO] Pulling required base images..." -ForegroundColor Yellow
    docker pull mysql:8.0
    docker pull node:18

    Write-Host "`n[INFO] Saving all images to disk..." -ForegroundColor Cyan
    docker save my-laravel-app -o my-laravel-app.tar
    docker save mysql:8.0 -o mysql.tar
    docker save node:18 -o node.tar

    Write-Host "`n[INFO] All images saved! Copy them to your offline machine." -ForegroundColor Green
    exit
}

if ($mode -eq "offline") {
    Write-Host "`n[INFO] Checking for saved Docker images..." -ForegroundColor Yellow

    $missingImages = $false

    if (Test-Path ".\my-laravel-app.tar") {
        docker load -i my-laravel-app.tar
    } else {
        Write-Host "[INFO] Missing: my-laravel-app.tar" -ForegroundColor Red
        $missingImages = $true
    }

    if (Test-Path ".\mysql.tar") {
        docker load -i mysql.tar
    } else {
        Write-Host "[INFO] Missing: mysql.tar" -ForegroundColor Red
        $missingImages = $true
    }

    if (Test-Path ".\node.tar") {
        docker load -i node.tar
    } else {
        Write-Host "[INFO] Missing: node.tar" -ForegroundColor Red
        $missingImages = $true
    }

    if ($missingImages) {
        Write-Host "`n[INFO] Some images are missing. Please ensure all tar files are in the same directory." -ForegroundColor Red
        exit
    }

    # Prompt user to choose local or remote database
    $dbMode = Read-Host "Use (local/remote) MySQL database?"

    if ($dbMode -eq "remote") {
        $dbHost = Read-Host "Enter remote DB host"
        $dbPort = Read-Host "Enter remote DB port (default 3306)"
        if (-not $dbPort) { $dbPort = "3306" }
        $dbUser = Read-Host "Enter DB username"
        $dbPass = Read-Host "Enter DB password"
        $dbName = Read-Host "Enter DB name"

        @"
DB_CONNECTION=mysql
DB_HOST=$dbHost
DB_PORT=$dbPort
DB_DATABASE=$dbName
DB_USERNAME=$dbUser
DB_PASSWORD=$dbPass
"@ | Set-Content .env
    } else {
        # Local DB mode: check if SQL file exists
    $sqlFilePath = ".\laravel.sql"
    if (-Not (Test-Path $sqlFilePath)) {
        Write-Host " SQL file '$sqlFilePath' not found!" -ForegroundColor Red
        Write-Host "Please provide the SQL dump file to initialize the local database." -ForegroundColor Yellow
        exit 1  # Stop the script or you can prompt to continue or abort
    } else {
        Write-Host " Found SQL file: $sqlFilePath" -ForegroundColor Green
    }
        # Default local DB values
        @"
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
"@ | Set-Content .env
    }

#     $envFilePath = ".\laravel\.env"

# if ($dbMode -eq "remote") {
#     $dbHost = Read-Host "Enter remote DB host"
#     $dbPort = Read-Host "Enter remote DB port (default 3306)"
#     if (-not $dbPort) { $dbPort = "3306" }
#     $dbUser = Read-Host "Enter DB username"
#     $dbPass = Read-Host "Enter DB password"
#     $dbName = Read-Host "Enter DB name"
# } else {
    ## Local DB mode: check if SQL file exists
    # $sqlFilePath = ".\laravel.sql"
    # if (-Not (Test-Path $sqlFilePath)) {
    #     Write-Host " SQL file '$sqlFilePath' not found!" -ForegroundColor Red
    #     Write-Host "Please provide the SQL dump file to initialize the local database." -ForegroundColor Yellow
    #     exit 1  # Stop the script or you can prompt to continue or abort
    # } else {
    #     Write-Host " Found SQL file: $sqlFilePath" -ForegroundColor Green
    # }
#     # Default local DB values
#     $dbHost = "db"
#     $dbPort = "3306"
#     $dbUser = "laravel"
#     $dbPass = "secret"
#     $dbName = "laravel"
# }

# if (Test-Path $envFilePath) {
#     # Replace existing DB-related lines
#     (Get-Content $envFilePath) -replace '^DB_HOST=.*', "DB_HOST=$dbHost" |
#         ForEach-Object { $_ -replace '^DB_PORT=.*', "DB_PORT=$dbPort" } |
#         ForEach-Object { $_ -replace '^DB_DATABASE=.*', "DB_DATABASE=$dbName" } |
#         ForEach-Object { $_ -replace '^DB_USERNAME=.*', "DB_USERNAME=$dbUser" } |
#         ForEach-Object { $_ -replace '^DB_PASSWORD=.*', "DB_PASSWORD=$dbPass" } |
#         Set-Content $envFilePath
# } else {
#     # Create .env file if it doesn't exist
#     @"
# DB_CONNECTION=mysql
# DB_HOST=$dbHost
# DB_PORT=$dbPort
# DB_DATABASE=$dbName
# DB_USERNAME=$dbUser
# DB_PASSWORD=$dbPass
# "@ | Set-Content $envFilePath
# }

    Write-Host "`n[INFO] Starting Docker Compose..." -ForegroundColor Cyan
    docker-compose --env-file .env up --build
}
else {
    Write-Host "`n[INFO] Invalid mode. Use 'online' or 'offline'." -ForegroundColor Red
}
