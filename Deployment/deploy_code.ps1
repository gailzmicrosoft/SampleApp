# deploy_code.ps1

#how to run: 
# cd Deployment 
# .\deploy_code.ps1

# update the values with your own 
$resourceGroup = "your-resource-group-name"
$appServiceName = "your-app-services-name"

# set up path
$projectDir = "..\RestAPIs\src"
$outputDir = "..\RestAPIs\publish"
$zipFile = "sample_app.zip"
$scriptPath = (Get-Location).Path

# Remove $outputDir if it exists
if (Test-Path $outputDir) {
    Remove-Item -Recurse -Force $outputDir
}

# Remove $zipFile if it exists
$zipFilePath = "$scriptPath\$zipFile"
if (Test-Path $zipFilePath) {
    Remove-Item -Force $zipFilePath
}

# Step 1: Log in to Azure
az login

# Step 2: Build the project
dotnet publish $projectDir -c Release -o $outputDir

# Step 3: Create a .zip file
Set-Location $outputDir
Compress-Archive -Path * -DestinationPath $zipFilePath

Set-Location $scriptPath 

# Step 4: Deploy to Azure App Services
az webapp deploy --resource-group $resourceGroup --name $appServiceName --src-path $zipFile --type zip
