param resourcePrefix string = 'mortgage3'

var location = resourceGroup().location
var subscriptionId = subscription().id


/**************************************************************************/
// Create a storage account and a container
/**************************************************************************/
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${toLower(resourcePrefix)}storageaccount'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
// create blob service in the storage account
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storageAccount
  name: 'default'
}

// create a container named  mortgageapp in the storage account
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  parent: blobService
  name: 'mortgageapp'
  properties: {
    publicAccess: 'None'
  }
}

/**************************************************************************/
// Create a Form Recognizer resource
/**************************************************************************/
resource formRecognizer 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: '${resourcePrefix}FormRecognizer'
  location: location
  kind: 'FormRecognizer'
  sku: {
    name: 'S0'
  }
  properties: {}
}

/**************************************************************************/
// Create a Cosmos DB account
/**************************************************************************/
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: '${toLower(resourcePrefix)}cosmosdb'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
  }
}

// Create a database in the Cosmos DB account named LoanAppDatabase
resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/databases@2021-04-15' = {
  parent: cosmosDbAccount
  name: 'LoanAppDatabase'
}

// Create a container in the database named LoanAppDataContainer
resource cosmosDbContainer 'Microsoft.DocumentDB/databaseAccounts/databases/containers@2021-04-15' = {
  parent: cosmosDbDatabase
  name: 'LoanAppDataContainer'
  properties: {
    partitionKey: {
      paths: [
        '/id'
      ]
    }
  }
}


var cosmosDbEndpoint = cosmosDbAccount.properties.documentEndpoint
var formRecognizerEndpoint = formRecognizer.properties.endpoint
var formRecognizerKey = listKeys(formRecognizer.id, '2021-04-30').key1


/**************************************************************************/
// appConfig and appConfig Key Valye Pairs
/**************************************************************************/
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
  name: '${resourcePrefix}AppConfig'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
  dependsOn: [
    blobContainer
    formRecognizer
    cosmosDbContainer
  ]
}
/*****************************  Key Valu Pairs ***************************/
resource appConfigKeyAzureStorageName 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = {
  parent: appConfig
  name: 'azure-storage-account-name'
  properties: {
     value: storageAccount.name
  }
}
resource appConfigKeyBlobContainer 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = {
  parent: appConfig
  name: 'azure-storage-blob-container-name'
  properties: {
     value: blobContainer.name
  }
}
resource appConfigKeyCosmosDbEp 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = {
  parent: appConfig
  name: 'cosmos-db-endpoint'
  properties: {
     value: string(cosmosDbEndpoint)
  }
}
resource appConfigKeyCosmosDbName 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = {
  parent: appConfig
  name: 'cosmos-db-name'
  properties: {
     value: cosmosDbDatabase.name
  }
}
resource appConfigKeyCosmosDbContainer'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = {
  parent: appConfig
  name: 'cosmos-db-container-name'
  properties: {
     value: cosmosDbContainer.name
  }
}
resource appConfigKeyFormRecognizerEp'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = {
  parent: appConfig
  name: 'form-recognizer-endpoint'
  properties: {
     value: string(formRecognizerEndpoint)
  }
}
resource appConfigKeyFormRecognizerKey'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = {
  parent: appConfig
  name: 'form-recognizer-key'
  properties: {
     value: string(formRecognizerKey)
  }
}
resource appConfigKeyApiKey'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = {
  parent: appConfig
  name: 'x-api-key'
  properties: {
     value:'AppConfigApiKey'
  }
}


/**************************************************************************/
// App Service Plan and App Service
/**************************************************************************/
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${resourcePrefix}AppServicePlan'
  location: location
  sku: {
    name: 'P1v2'
    tier: 'PremiumV2'
  }
}

resource appService 'Microsoft.Web/sites@2021-02-01' = {
  name: '${resourcePrefix}AppService'
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
  }
  identity: {
    type: 'SystemAssigned'
  }
}


/**************************************************************************/
// Assign App Service Identity the Contributor role for the Resource Group
/**************************************************************************/
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appService.id, 'Contributor')
  properties: {
    roleDefinitionId: '${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalId: appService.identity.principalId
    principalType: 'ServicePrincipal'
    scope: resourceGroup().id
  }
}

output subscriptionIdValue string = subscriptionId
