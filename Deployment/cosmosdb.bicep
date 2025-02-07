/**************************************************************************/
// If you experience Cosmos DB creation failure in main.bicep, 
// you can try to create Cosmos DB account using this file.
// After successful creation of customer db resources, you will need 
// to manually update the configuration in the appConfiguration instance 
// created with main.bicep. Refer to the main.bicep file for more details.
/**************************************************************************/
@description('Prefix to use for all resources.')
param resourcePrefixUser string = 'cosmos'

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
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-03-15' = {
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
     capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

// Create a database in the Cosmos DB account named LoanAppDatabase
resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/databases@2023-03-15' = {
  parent: cosmosDbAccount
  name: 'LoanAppDatabase'
}

// Create a container in the database named LoanAppDataContainer with partition key id
resource cosmosDbContainer 'Microsoft.DocumentDB/databaseAccounts/databases/containers@2023-03-15' = {
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

