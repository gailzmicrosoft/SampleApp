param resourceGroupName string
param resourcePrefix string
param subscriptionId string

var resourceToken = toLower(uniqueString(subscription().id, resourcePrefix, resourceGroupName))

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${resourcePrefix}StorageAccouparam resourceGroupName string
param resourcePrefix string
param subscriptionId string
param location string

var resourceToken = toLower(uniqueString(subscription().id, resourcePrefix, resourceGroupName))

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${resourcePrefix}StorageAccount'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    hierarchicalNamespace: true
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
    roleDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/<role-definition-id>'
    principalId: appService.identity.principalId
    principalType: 'ServicePrincipal'
    scope: resourceGroup().id
  }
}

output formRecognizerEndpoint string = formRecognizer.properties.endpoint
nt'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    hierarchicalNamespace: true
  }
}

resource formRecognizer 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: '${resourcePrefix}FormRecognizer'
  location: resourceGroup().location
  kind: 'FormRecognizer'
  sku: {
    name: 'S0'
  }
  properties: {}
}

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
  name: '${resourcePrefix}AppConfig'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {}
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${resourcePrefix}AppServicePlan'
  location: resourceGroup().location
  sku: {
    name: 'P1v2'
    tier: 'PremiumV2'
  }
}

resource appService 'Microsoft.Web/sites@2021-02-01' = {
  name: '${resourcePrefix}AppService'
  location: resourceGroup().location
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
    roleDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/<role-definition-id>'
    principalId: appService.identity.principalId
    principalType: 'ServicePrincipal'
    scope: resourceGroup().id
  }
}

output formRecognizerEndpoint string = formRecognizer.properties.endpoint
