# Requires PowerShell 5.1 or later for some features like `Read-Host -Prompt`.

function Test-CommandExists {
    param (
        [string]$CommandName
    )
    # Check if a command exists in the system's PATH.
    Write-Host "Checking for '$CommandName'..."
    if (Get-Command $CommandName -ErrorAction SilentlyContinue) {
        Write-Host "'$CommandName' found." -ForegroundColor Green
        return $true
    } else {
        Write-Host "'$CommandName' not found. Please install it and ensure it's in your system's PATH." -ForegroundColor Red
        return $false
    }
}

function Run-OnlineMachineTasks {
    Write-Host "`n--- Running Online Machine Tasks ---" -ForegroundColor Cyan

    # 1. Check if all required tools are installed and in PATH
    $requiredCommands = @("php", "composer", "npm", "mysql")
    foreach ($cmd in $requiredCommands) {
        if (-not (Test-CommandExists -CommandName $cmd)) {
            Write-Error "Missing prerequisite: $cmd. Aborting online machine setup."
            Read-Host "Press Enter to exit..."
	    exit 1
        }
    }

    # Get Laravel project directory
    $projectPath = Read-Host "Enter the full path to your Laravel project directory (e.g., C:\Projects\MyLaravelApp)"
    if (-not (Test-Path $projectPath -PathType Container)) {
        Write-Error "The specified project path does not exist or is not a directory: $projectPath"
        Read-Host "Press Enter to exit..."
	exit 1
    }

    Set-Location $projectPath
    Write-Host "Changed directory to: $projectPath" -ForegroundColor Green

    # 2. Run composer install
    Write-Host "`n--- Running 'composer install' ---" -ForegroundColor Yellow
    try {
        composer install --no-dev --optimize-autoloader
        if ($LASTEXITCODE -ne 0) {
            throw "Composer install failed with exit code $LASTEXITCODE"
        }
        Write-Host "'composer install' completed successfully." -ForegroundColor Green
    } catch {
        Write-Error "Failed to run 'composer install': $($_.Exception.Message)"
        Read-Host "Press Enter to exit..."
	exit 1
    }

    # 3. Run npm install
    Write-Host "`n--- Running 'npm install' ---" -ForegroundColor Yellow
    try {
        npm install
        if ($LASTEXITCODE -ne 0) {
            throw "NPM install failed with exit code $LASTEXITCODE"
        }
        Write-Host "'npm install' completed successfully." -ForegroundColor Green
    } catch {
        Write-Error "Failed to run 'npm install': $($_.Exception.Message)"
        Read-Host "Press Enter to exit..."
	exit 1
    }

    # 4. Run npm build
    Write-Host "`n--- Running 'npm run build' ---" -ForegroundColor Yellow
    try {
        npm run build
        if ($LASTEXITCODE -ne 0) {
            throw "NPM build failed with exit code $LASTEXITCODE"
        }
        Write-Host "'npm run build' completed successfully." -ForegroundColor Green
    } catch {
        Write-Error "Failed to run 'npm run build': $($_.Exception.Message)"
	Read-Host "Press Enter to exit..."        
	exit 1
    }

    # 5. Perform MySQL database dump
    Write-Host "`n--- Performing MySQL Database Dump ---" -ForegroundColor Yellow
    $dbName = Read-Host "Enter your database name (e.g., laravel_db)"
    $dbUser = Read-Host "Enter your database user (e.g., root)"
    $dbPasswordSecure = Read-Host -AsSecureString "Enter your database password (will not be displayed)"
    $dbPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPasswordSecure))
    $outputFileName = Read-Host "Enter desired output SQL dump file name (e.g., database_dump.sql). It will be saved in your project root."

    $dumpFilePath = Join-Path $projectPath $outputFileName

    try {
        Write-Host "Dumping database '$dbName' to '$dumpFilePath'..."
        # Using command line arguments for password can be insecure. For automation, consider environment variables or secure credential management.
        # This example uses direct password for simplicity as requested, but be aware of security implications.
        # For sensitive operations, it's better to pipe the password securely or use a config file.
        # Note: -p without a space immediately following it is how mysqldump expects a password.
        mysqldump "-u$dbUser" "-p$dbPassword" "$dbName" > "$dumpFilePath"
        if ($LASTEXITCODE -ne 0) {
            throw "MySQL dump failed with exit code $LASTEXITCODE"
        }
        Write-Host "Database dump completed successfully to: $dumpFilePath" -ForegroundColor Green
    } catch {
        Write-Error "Failed to perform MySQL database dump: $($_.Exception.Message)"
        Write-Host "Please ensure your MySQL credentials are correct and you have permission to dump the database." -ForegroundColor Red
        Read-Host "Press Enter to exit..."
	exit 1
    }

    Write-Host "`n--- Online Machine Setup Complete! ---" -ForegroundColor Green
    Write-Host "Next Steps for Offline Machine:" -ForegroundColor Green
    Write-Host "1. Compress your entire Laravel project folder (including the '$outputFileName' file)." -ForegroundColor Green
    Write-Host "2. Transfer the compressed file to your offline machine." -ForegroundColor Green
    Write-Host "3. On the offline machine, extract the project and run this script in 'offline' mode." -ForegroundColor Green
}

function Run-OfflineMachineTasks {
    Write-Host "`n--- Running Offline Machine Tasks ---" -ForegroundColor Cyan

    # 1. Check if php and mysql are installed and in PATH
    $requiredCommands = @("php", "mysql")
    foreach ($cmd in $requiredCommands) {
        if (-not (Test-CommandExists -CommandName $cmd)) {
            Write-Error "Missing prerequisite: $cmd. Please install it and ensure it's in your system's PATH."
            Write-Host "Cannot proceed without $cmd. Please install it and re-run this script." -ForegroundColor Red
	    Read-Host "Press Enter to exit..."
            exit 1
        }
    }

    Write-Host "`n--- Database Import Instructions ---" -ForegroundColor Yellow
    Write-Host "Please ensure you have created a new MySQL database on this offline machine." -ForegroundColor Yellow
    Write-Host "Example SQL command to create a database (run in MySQL client):" -ForegroundColor Gray
    Write-Host "   CREATE DATABASE your_offline_db_name;" -ForegroundColor Gray
    Write-Host "   CREATE USER 'your_offline_user'@'localhost' IDENTIFIED BY 'your_offline_password';" -ForegroundColor Gray
    Write-Host "   GRANT ALL PRIVILEGES ON your_offline_db_name.* TO 'your_offline_user'@'localhost';" -ForegroundColor Gray
    Write-Host "   FLUSH PRIVILEGES;" -ForegroundColor Gray
    Write-Host "`n"

    $dbDumpFile = Read-Host "Enter the full path to the SQL database dump file (e.g., C:\path\to\your_project\database_dump.sql)"
    if (-not (Test-Path $dbDumpFile -PathType Leaf)) {
        Write-Error "The specified database dump file does not exist: $dbDumpFile"
        Write-Host "Please ensure the dump file is present and you have provided the correct path." -ForegroundColor Red
        Read-Host "Press Enter to exit..."
	exit 1
    }

    $offlineDbName = Read-Host "Enter the name of the database you created on this offline machine (e.g., your_offline_db_name)"
    $offlineDbUser = Read-Host "Enter the database user for the offline database (e.g., your_offline_user)"
    $offlineDbPasswordSecure = Read-Host -AsSecureString "Enter the database password for the offline database"
    $offlineDbPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($offlineDbPasswordSecure))

    Write-Host "`n"
    Write-Host "To import the database, open a PowerShell or Command Prompt and run:" -ForegroundColor Yellow
    Write-Host "   mysql -u$offlineDbUser -p$offlineDbPassword $offlineDbName < ""$dbDumpFile""" -ForegroundColor Green
    Write-Host "`n"

    Write-Host "`n--- .env File Configuration Instructions ---" -ForegroundColor Yellow
    Write-Host "You need to update your Laravel project's '.env' file with the correct database credentials for this offline machine." -ForegroundColor Yellow
    Write-Host "Navigate to your Laravel project directory (e.g., C:\path\to\your_project)." -ForegroundColor Yellow
    Write-Host "Open the '.env' file in a text editor and modify the following lines:" -ForegroundColor Green
    Write-Host "   DB_DATABASE=your_offline_db_name" -ForegroundColor Green
    Write-Host "   DB_USERNAME=your_offline_user" -ForegroundColor Green
    Write-Host "   DB_PASSWORD=your_offline_password" -ForegroundColor Green
    Write-Host "`n"
    Write-Host "Also, consider setting your application environment for production:" -ForegroundColor Yellow
    Write-Host "   APP_ENV=production" -ForegroundColor Green
    Write-Host "   APP_DEBUG=false" -ForegroundColor Green
    Write-Host "`n"

    Write-Host "After updating the .env file and importing the database, you can test your Laravel application:" -ForegroundColor Green
    Write-Host "   1. Navigate to your Laravel project directory." -ForegroundColor Green
    Write-Host "   2. Run 'php artisan key:generate' (if you haven't already)." -ForegroundColor Green
    Write-Host "   3. Run 'php artisan config:clear'." -ForegroundColor Green
    Write-Host "   4. Run 'php artisan serve' to start the development server." -ForegroundColor Green
    Write-Host "`n--- Offline Machine Setup Instructions Provided! ---" -ForegroundColor Green
}

# Main script logic
Write-Host "--- Laravel Project Offline Deployment Script ---" -ForegroundColor White -BackgroundColor DarkBlue

$mode = Read-Host "Are you setting up the [O]nline Machine or the o[F]fline Machine? (O/F)"
$mode = $mode.Trim().ToUpper()

if ($mode -eq "O") {
    Run-OnlineMachineTasks
} elseif ($mode -eq "F") {
    Run-OfflineMachineTasks
} else {
    Write-Error "Invalid choice. Please enter 'O' for Online or 'F' for Offline."
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host "`nScript Finished." -ForegroundColor White -BackgroundColor DarkBlue
Read-Host "Press Enter to exit..."