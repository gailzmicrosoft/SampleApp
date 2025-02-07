param databaseAccountName string = 'azurecosmodbaccountname'

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-09-01-preview' = {
  name: databaseAccountName
  location: 'Central US'
  tags: {
    defaultExperience: 'Core (SQL)'
    'hidden-cosmos-mmspecial': ''
  }
  kind: 'GlobalDocumentDB'
  identity: {
    type: 'None'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    disableKeyBasedMetadataWriteAccess: false
    enableFreeTier: false
    enableAnalyticalStorage: false
    analyticalStorageConfiguration: {
      schemaType: 'WellDefined'
    }
    databaseAccountOfferType: 'Standard'
    enableMaterializedViews: false
    capacityMode: 'Serverless'
    defaultIdentity: 'FirstPartyIdentity'
    networkAclBypass: 'None'
    disableLocalAuth: true
    enablePartitionMerge: false
    enablePerRegionPerPartitionAutoscale: false
    enableBurstCapacity: false
    enablePriorityBasedExecution: false
    defaultPriorityLevel: 'High'
    minimalTlsVersion: 'Tls12'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: 'Central US'
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    cors: []
    capabilities: []
    ipRules: []
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Local'
      }
    }
    networkAclBypassResourceIds: []
    diagnosticLogSettings: {
      enableFullTextQuery: 'None'
    }
  }
}

resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-09-01-preview' = {
  parent: cosmosDbAccount
  name: 'LoanAppDatabase'
  properties: {
    resource: {
      id: 'LoanAppDatabase'
    }
  }
}

resource cosmos_built_in_data_reader_role 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: cosmosDbAccount
  name: '00000000-0000-0000-0000-000000000001'
  properties: {
    roleName: 'Cosmos DB Built-in Data Reader'
    type: 'BuiltInRole'
    assignableScopes: [
      cosmosDbAccount.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
        ]
        notDataActions: []
      }
    ]
  }
}

resource Cosmos_built_in_data_contributor_role 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: cosmosDbAccount
  name: '00000000-0000-0000-0000-000000000002'
  properties: {
    roleName: 'Cosmos DB Built-in Data Contributor'
    type: 'BuiltInRole'
    assignableScopes: [
      cosmosDbAccount.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
        notDataActions: []
      }
    ]
  }
}

resource cosmos_data_plane_owner_role 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: cosmosDbAccount
  name: '4b74db1d-9691-49fa-93f7-18b61993f757'
  properties: {
    roleName: 'Azure Cosmos DB for NoSQL Data Plane Owner'
    type: 'CustomRole'
    assignableScopes: [
      cosmosDbAccount.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
        notDataActions: []
      }
    ]
  }
}

resource cosmosDbConatiner 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = {
  parent: cosmosDatabase
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
  dependsOn: [
    cosmosDbAccount
  ]
}


/****************************************************************************************************************/
// sample code to assign roles to the cosmos db account
/****************************************************************************************************************/
resource databaseAccountRole1 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: cosmosDbAccount
  name: 'databaseAccountRoleAssignment1'
  properties: {
    roleDefinitionId: cosmos_data_plane_owner_role.id
    principalId: 'IDHere'
    scope: cosmosDbAccount.id
  }
}

resource databaseAccountRole2 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: cosmosDbAccount
  name: 'databaseAccountRoleAssignment2'
  properties: {
    roleDefinitionId: cosmos_data_plane_owner_role.id
    principalId: 'IDHere'
    scope: cosmosDbAccount.id
  }
}

resource databaseAccountRole3 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: cosmosDbAccount
  name: 'databaseAccountRoleAssignment3'
  properties: {
    roleDefinitionId: cosmos_data_plane_owner_role.id
    principalId: 'IDHere'
    scope: cosmosDbAccount.id
  }
}
