# deploy_code.ps1

# how to run: 
# cd Deployment 
# .\deploy_code.ps1

# set up path
$projectDir = "..\RestAPIs\src"
$outputDir = "..\RestAPIs\publish"
$scriptPath = (Get-Location).Path

$zipFile = Read-Host -Prompt "Enter the name of the zip file to build and deploy (e.g. sample_app.zip)"

# Remove $zipFile if it exists
$zipFilePath = "$scriptPath\$zipFile"
if (Test-Path $zipFilePath) {
    Remove-Item -Force $zipFilePath
}

# Step 1: Build the project
dotnet publish $projectDir -c Release -o $outputDir

# Step 2: Create a .zip file
Set-Location $outputDir
Compress-Archive -Path * -DestinationPath $zipFilePath

Set-Location $scriptPath 

# Step 3: Login and Deploy to Azure App Services

az login

# get user input
$resourceGroup = Read-Host -Prompt "Enter your resource group name"
$appServiceName = Read-Host -Prompt "Enter your app service name"

az webapp deploy --resource-group $resourceGroup --name $appServiceName --src-path $zipFile --type zip