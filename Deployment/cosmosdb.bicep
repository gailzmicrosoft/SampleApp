/**************************************************************************/
// If you experience Cosmos DB creation failure in main.bicep, 
// you can try to create Cosmos DB account using this file.
// After successful creation of customer db resources, you will need 
// to manually update the configuration in the appConfiguration instance 
// created with main.bicep. Refer to the main.bicep file for more details.
/**************************************************************************/
@description('Prefix to use for all resources.')
param resourcePrefixUser string = 'sam27'

var trimmedResourcePrefixUser = length(resourcePrefixUser) > 5 ? substring(resourcePrefixUser, 0, 5) : resourcePrefixUser
var uniString = toLower(substring(uniqueString(subscription().id, resourceGroup().id), 0, 5))

var resourcePrefix = '${trimmedResourcePrefixUser}${uniString}'
//var location = resourceGroup().location
//var location = 'East US' // 'West US' 
//var location = 'East US 2' // 'Central US'
var location = 'Central US'

/**************************************************************************/
// Create a Cosmos DB account
/**************************************************************************/
//resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-09-01-preview'
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-09-01-preview' = {
  name: '${toLower(resourcePrefix)}cosmosdbaccount'
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
//Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-09-01-preview
resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-09-01-preview' = {
  parent: cosmosDbAccount
  name: 'LoanAppDatabase'
  properties: {
    resource: {
      id: 'LoanAppDatabase'
    }
  }
}

resource cosmosDbConatiner 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = {
  parent: cosmosDbDatabase
  name: 'LoanAppDataContainer'
  properties: {
    resource: {
      id: 'LoanAppDataContainer'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/LoanAppDataId'
        ]
        kind: 'Hash'
        version: 2
      }
      uniqueKeyPolicy: {
        uniqueKeys: []
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
      computedProperties: []
    }
  }
}

