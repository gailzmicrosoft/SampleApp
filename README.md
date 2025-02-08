

## Sample Rest API App (.NET 8 and C#)

#### Basic features 

Secure Rest APIs hosted in Azure App Service. This is a sample architecture that you can use as your foundational architectural components: Azure Storage, Azure App Services, Azure Document Intelligence, Azure Cosmos DB. More components will be added later such as integration with Azure Open AI or 3rd party LLMs running in Azure. 

#### Current functionality: 

(1) Mortgage Calculation and Estimates

(2) Extract information from Documents using Azure Document Intelligence 

(3) Save mortgage loan application into Azure Blob Storage and Azure Cosmos DB

#### How to Deploy and Test 

Step 1: Deploy azure solution components 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgailzmicrosoft%2FSampleApp%2Fmain%2FDeployment%2Fmain.json)

Step 2: Publish Code to the App Server created in step 1.

Download the code to your local directory.  Change directory to Deployment. Execute PowerShell script `deploy_code.ps1` 

