# deploy_code.ps1

#how to run: 
# cd Deployment 
# .\deploy_code.ps1

# Variables
$resourceGroup = "<YourResourceGroup>"
$appServiceName = "<YourAppServiceName>"
$projectDir = "../src"
$outputDir = "$projectDir/publish"
$zipFile = "myapp.zip"

# Function to list subscriptions and prompt user to select one
function Select-Subscription {
    Write-Host "Fetching Azure subscriptions..."
    $subscriptions = az account list --output table
    Write-Host $subscriptions

    $subscriptionId = Read-Host "Please enter the subscription ID you want to use"
    Write-Host "Setting the selected subscription..."
    az account set --subscription $subscriptionId
}

# Step 1: Log in to Azure
az login

# Step 2: List subscriptions and select one
Select-Subscription

# Step 3: Build the project
dotnet publish $projectDir -c Release -o $outputDir

# Step 4: Create a .zip file
Set-Location $outputDir
Compress-Archive -Path * -DestinationPath "../../Deployment/$zipFile"
Set-Location "../../Deployment"

# Step 5: Deploy to Azure App Services
az webapp deploy --resource-group $resourceGroup --name $appServiceName --src-path $zipFile --type zip
