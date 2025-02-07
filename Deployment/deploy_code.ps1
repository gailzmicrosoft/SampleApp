# deploy_code.ps1

#how to run: 
# cd Deployment 
# .\deploy_code.ps1

# update the values with your own 
$resourceGroup = "your-resource-rg-name"
$appServiceName = "my-app-service-name"

# set up path
$projectDir = "..\RestAPIs\src"
$outputDir = "..\RestAPIs\publish"
$zipFile = "sample_app.zip"
$scriptPath = (Get-Location).Path


# Step 1: Log in to Azure
az login

# Step 2: Build the project
dotnet publish $projectDir -c Release -o $outputDir

# Step 3: Create a .zip file
Set-Location $outputDir
Compress-Archive -Path * -DestinationPath "$scriptPath\$zipFile"

Set-Location $scriptPath 

# Step 4: Deploy to Azure App Services
az webapp deploy --resource-group $resourceGroup --name $appServiceName --src-path $zipFile --type zip

