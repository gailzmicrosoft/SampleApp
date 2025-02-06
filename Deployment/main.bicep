param resourceGroupName string
param resourcePrefix string
param subscriptionId string
param location string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${resourcePrefix}StorageAccount'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource mortgageAppContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageAccount.name}/mortgage'
  properties: {
    publicAccess: 'None'
  }
}

resource formRecognizer 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: '${resourcePrefix}FormRecognizer'
  location: location
  kind: 'FormRecognizer'
  sku: {
    name: 'S0'
  }
  properties: {}
}

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
  name: '${resourcePrefix}AppConfig'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
}

// Need to create Azure cosmos DB None SQL API account
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: '${resourcePrefix}CosmosDb'
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

/*
output cosmosDbEndpoint string = listKeys(cosmosDbAccount.id, '2021-04-15').documentEndpoint
output formRecognizerEndpoint string = formRecognizer.properties.endpoint
output formRecognizerKey string = listKeys(formRecognizer.id, '2021-04-30').key1


var cosmosDbEndpoint = listKeys(cosmosDbAccount.id, '2021-04-15').documentEndpoint
var formRecognizerEndpoint = formRecognizer.properties.endpoint
var formRecognizerKey string = listKeys(formRecognizer.id, '2021-04-30').key1
*/

var cosmosDbEndpoint = listKeys(cosmosDbAccount.id, '2021-04-15').documentEndpoint

var formRecognizerEndpoint = formRecognizer.properties.endpoint
var formRecognizerKey = listKeys(formRecognizer.id, '2021-04-30').key1


/*
resource appConfigKeys 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-03-01-preview' = [for key in [
  {
    name: 'azure-storage-account-name'
    value: storageAccount.name
  }
  {
    name: 'azure-storage-blob-container-name'
    value: 'mortgageapp'
  }
  {
    name: 'cosmos-db-endpoint'
    value: cosmosDbEndpoint
  }
  {
    name: 'cosmos-db-name'
    value: 'LoanAppDatabase'
  }
  {
    name: 'cosmos-db-container-name'
    value: 'LoanAppDataContainer'
  }
  {
    name: 'form-recognizer-end-point'
    value: formRecognizerEndpoint.value
  }
  {
    name: 'form-recognizer-key'
    value: formRecognizerKey.value
  }
  {
    name: 'x-api-key'
    value: 'AppConfigApiKey'
  }
]: {
  parent: appConfig
  name: key.name
  properties: {
    value: key.value
  }
  dependsOn: [
    cosmosDbAccount
    formRecognizer
  ]
}]


*/

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

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appService.id, 'Contributor')
  properties: {
    roleDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalId: appService.identity.principalId
    principalType: 'ServicePrincipal'
    scope: resourceGroup().id
  }
}
