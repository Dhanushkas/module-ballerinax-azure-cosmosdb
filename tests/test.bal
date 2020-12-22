// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/test;
import ballerina/java;
import ballerina/config;
import ballerina/system;
import ballerina/log;
import ballerina/stringutils;

AzureCosmosConfiguration config = {
    baseUrl : getConfigValue("BASE_URL"), 
    keyOrResourceToken : getConfigValue("KEY_OR_RESOURCE_TOKEN"), 
    tokenType : getConfigValue("TOKEN_TYPE"), 
    tokenVersion : getConfigValue("TOKEN_VERSION")
};

Client AzureCosmosClient = new(config);

Database database = {};
Database manual = {};
Database auto = {};
Database ifexist = {};
Container container = {};
Document document = {};
StoredProcedure storedPrcedure = {};
UserDefinedFunction udf = {};
Trigger trigger = {};
User test_user = {};
Permission permission = {};

@test:Config{
    groups: ["database"]
}
function test_createDatabase(){
    log:printInfo("ACTION : createDatabase()");

    var uuid = createRandomUUIDBallerina();
    string createDatabaseId = string `database_${uuid.toString()}`;

    var result = AzureCosmosClient->createDatabase(createDatabaseId);
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        database = <@untainted>result;
        io:println(result);
    }
}

@test:Config{
    groups: ["database"]
}
function test_createDatabaseUsingInvalidId(){
    log:printInfo("ACTION : createDatabaseUsingInvalidId()");

    string createDatabaseId = "";

    var result = AzureCosmosClient->createDatabase(createDatabaseId);
    if (result is Database){
        test:assertFail(msg = "Database created with  '' id value");
    } else {
        var output = "";
        io:println(result);
    }
}

@test:Config{
    groups: ["database"], 
    dependsOn: ["test_createDatabase"]
}
function test_createDatabaseIfNotExist(){
    log:printInfo("ACTION : createDatabaseIfNotExist()");

    var uuid = createRandomUUIDBallerina();
    string createDatabaseId = string `databasee_${uuid.toString()}`;

    var result = AzureCosmosClient->createDatabaseIfNotExist(createDatabaseId);
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        ifexist = <@untainted><Database> result;
        io:println(result);
    }
}

@test:Config{
    groups: ["database"], 
    dependsOn: ["test_createDatabase"]
}
function test_createDatabaseIfExist(){
    log:printInfo("ACTION : createDatabaseIfExist()");

    var uuid = createRandomUUIDBallerina();
    string createDatabaseId = database.id;

    var result = AzureCosmosClient->createDatabaseIfNotExist(createDatabaseId);
    if (result is Database){
        test:assertFail(msg = "Database with non unique id is created");
    } else {
        var output = "";
        io:println(result);
    }
}

@test:Config{
    groups: ["database"]
}
function test_createDatabaseWithManualThroughput(){
    log:printInfo("ACTION : createDatabaseWithManualThroughput()");

    var uuid = createRandomUUIDBallerina();
    string createDatabaseManualId = string `databasem_${uuid.toString()}`;
    int throughput = 400;

    var result = AzureCosmosClient->createDatabase(createDatabaseManualId,  throughput);
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        manual = <@untainted>result;
        io:println(result);
    }
}

@test:Config{
    groups: ["database"]
}
function test_createDatabaseWithInvalidManualThroughput(){
    log:printInfo("ACTION : createDatabaseWithInvalidManualThroughput()");

    var uuid = createRandomUUIDBallerina();
    string createDatabaseManualId = string `databasem_${uuid.toString()}`;
    int throughput = 40;

    var result = AzureCosmosClient->createDatabase(createDatabaseManualId,  throughput);
    if (result is Database){
        test:assertFail(msg = "Database created without validating user input");
    } else {
        var output = "";
        io:println(result);
    }
}

@test:Config{
    groups: ["database"]
}
function test_createDBWithAutoscalingThroughput(){
    log:printInfo("ACTION : createDBWithAutoscalingThroughput()");

    var uuid = createRandomUUIDBallerina();
    string createDatabaseAutoId = string `databasea_${uuid.toString()}`;
    json maxThroughput = {"maxThroughput": 4000};

    var result = AzureCosmosClient->createDatabase(createDatabaseAutoId,  maxThroughput);
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        auto = <@untainted> result;
        io:println(result);
    }
}

@test:Config{
    groups: ["database"]
}
function test_listAllDatabases(){
    log:printInfo("ACTION : listAllDatabases()");

    var result = AzureCosmosClient->listDatabases(6);
    if (result is stream<Database>){
        var database = result.next();
        io:println(database?.value);
    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["database"], 
    dependsOn: ["test_createDatabase"]
}
function test_listOneDatabase(){
    log:printInfo("ACTION : listOneDatabase()");

    var result = AzureCosmosClient->getDatabase(database.id);
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }
}

@test:Config{
    groups: ["database"], 
    dependsOn: [
        "test_createDatabase", 
        "test_createDatabaseIfNotExist", 
        "test_createDBWithAutoscalingThroughput", 
        "test_listOneDatabase", 
        "test_createDatabase", 
        "test_getAllContainers", 
        "test_GetPartitionKeyRanges", 
        "test_getDocumentListWithRequestOptions", 
        "test_createDocumentWithRequestOptions", 
        "test_getDocumentList", 
        "test_createCollectionWithManualThroughputAndIndexingPolicy", 
        "test_deleteDocument", 
        "test_deleteOneStoredProcedure", 
        "test_getAllStoredProcedures", 
        "test_listUsers", 
        "test_deleteUDF", 
        "test_deleteTrigger", 
        "test_deleteUser", 
        "test_createContainerIfNotExist", 
        "test_deleteContainer", 
        "test_createPermissionWithTTL", 
        "test_getCollection_Resource_Token"
    ]
}
function test_deleteDatabase(){
    log:printInfo("ACTION : deleteDatabase()");

    var result1 = AzureCosmosClient->deleteDatabase(database.id);
    var result2 = AzureCosmosClient->deleteDatabase(manual.id);
    var result3 = AzureCosmosClient->deleteDatabase(auto.id);
    var result4 = AzureCosmosClient->deleteDatabase(ifexist.id);
    if (result1 is error){
        test:assertFail(msg = result1.message());
    } else {
        var output = "";
        io:println(result1);
    }
}

@test:Config{
    groups: ["container"], 
    dependsOn: ["test_createDatabase"]
}
function test_createContainer(){
    log:printInfo("ACTION : createContainer()");

    var uuid = createRandomUUIDBallerina();
    string databaseId = database.id;
    string containerId = string `container_${uuid.toString()}`;
    PartitionKey pk = {
        paths: ["/AccountNumber"], 
        keyVersion: 2
    };
    var result = AzureCosmosClient->createContainer(databaseId, containerId, pk);
    if (result is Container){
        container = <@untainted>result;
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    } 
}

@test:Config{
    groups: ["container"], 
    dependsOn: ["test_createContainer"]
}
function test_createCollectionWithManualThroughputAndIndexingPolicy(){
    log:printInfo("ACTION : createCollectionWithManualThroughputAndIndexingPolicy()");
    
    var uuid = createRandomUUIDBallerina();
    string databaseId = database.id;
    string containerId = string `container_${uuid.toString()}`;
    IndexingPolicy ip = {
        indexingMode : "consistent", 
        automatic : true, 
        includedPaths : [{
            path : "/*", 
            indexes : [{
                dataType: "String",  
                precision: -1,  
                kind: "Range"  
            }]
        }]
    };
    int throughput = 600;
    PartitionKey pk = {
        paths: ["/AccountNumber"], 
        kind : "Hash", 
        keyVersion : 2
    };
    
    var result = AzureCosmosClient->createContainer(databaseId, containerId, pk, ip, throughput);
    if (result is Container){
        var output = "";
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    } 
}
 
@test:Config{
    groups: ["container"], 
    dependsOn: ["test_createDatabase",  "test_getOneContainer"]
}
function test_createContainerIfNotExist(){
    log:printInfo("ACTION : createContainerIfNotExist()");

    var uuid = createRandomUUIDBallerina();
    string databaseId = database.id;
    string containerId = string `container_${uuid.toString()}`;
    PartitionKey pk = {
        paths: ["/AccountNumber"], 
        kind :"Hash", 
        keyVersion: 2
    };

    var result = AzureCosmosClient->createContainerIfNotExist(databaseId, containerId, pk);
    if (result is Container?){
        var output = "";
        io:println(result);    
    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["container"], 
    dependsOn: ["test_createContainer"]
}
function test_getOneContainer(){
    log:printInfo("ACTION : getOneContainer()");

    string databaseId = database.id;
    string containerId = container.id;

    var result = AzureCosmosClient->getContainer(databaseId, containerId);
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }
}

@test:Config{
    groups: ["container"], 
    dependsOn: ["test_createDatabase"]
}
function test_getAllContainers(){
    log:printInfo("ACTION : getAllContainers()");

    var result = AzureCosmosClient->listContainers(database.id);
    if (result is stream<Container>){
        var database = result.next();
        io:println(database?.value);
    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["container"], 
    dependsOn: [
        "test_getOneContainer", 
        "test_GetPartitionKeyRanges", 
        "test_getDocumentList", 
        "test_deleteDocument", 
        "test_queryDocuments", 
        "test_queryDocumentsWithRequestOptions", 
        "test_getAllStoredProcedures", 
        "test_deleteOneStoredProcedure", 
        "test_listAllUDF", 
        "test_deleteUDF", 
        "test_deleteTrigger", 
        "test_GetOneDocumentWithRequestOptions", 
        "test_createDocumentWithRequestOptions", 
        "test_getDocumentListWithRequestOptions", 
        "test_getCollection_Resource_Token",
        "test_getAllContainers",
        "test_replaceOfferWithOptionalParameter",
        "test_replaceOffer"
    ]
}
function test_deleteContainer(){
    log:printInfo("ACTION : deleteContainer()");

    string databaseId = database.id;
    string containerId = container.id;

    var result = AzureCosmosClient->deleteContainer(databaseId, containerId);
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }
}

@test:Config{
    groups: ["partitionKey"], 
    dependsOn: ["test_createContainer"]
}
function test_GetPartitionKeyRanges(){
    log:printInfo("ACTION : GetPartitionKeyRanges()");

    string databaseId = database.id;
    string containerId = container.id;

    var result = AzureCosmosClient->listPartitionKeyRanges(databaseId, containerId);
    if (result is stream<PartitionKeyRange>){
        var database = result.next();
        io:println(database?.value);
    } else {
        test:assertFail(msg = result.message());
    }  
}

@test:Config{
    groups: ["document"], 
    dependsOn: ["test_createContainer"]
}
function test_createDocument(){
    log:printInfo("ACTION : createDocument()");

    var uuid = createRandomUUIDBallerina();
    string databaseId = database.id;
    string containerId = container.id;
    Document createDoc = {
        id: string `document_${uuid.toString()}`, 
        documentBody :{
            "LastName": "keeeeeee",  
        "Parents": [  
            {  
            "FamilyName": null,  
            "FirstName": "Thomas"  
            },  
            {  
            "FamilyName": null,  
            "FirstName": "Mary Kay"  
            }  
        ],  
        "Children": [  
            {  
            "FamilyName": null,  
            "FirstName": "Henriette Thaulow",  
            "Gender": "female",  
            "Grade": 5,  
            "Pets": [  
                {  
                "GivenName": "Fluffy"  
                }  
            ]  
            }  
        ],  
        "Address": {  
            "State": "WA",  
            "County": "King",  
            "City": "Seattle"  
        },  
        "IsRegistered": true, 
        "AccountNumber": 1234
        }, 
        partitionKey : [1234]  
    };

    var result = AzureCosmosClient->createDocument(databaseId, containerId,  createDoc);
    if (result is Document){
        document = <@untainted>result;
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["document"], 
    dependsOn: ["test_createContainer"]
}
function test_createDocumentWithRequestOptions(){
    log:printInfo("ACTION : createDocumentWithRequestOptions()");

    var uuid = createRandomUUIDBallerina();
    string databaseId = database.id;
    string containerId = container.id;
    DocumentCreateOptions options = {
        isUpsertRequest : true, 
        indexingDirective : "Include", 
        ifMatchEtag : "hhh"
    };
    Document createDoc = {
        id: string `document_${uuid.toString()}`, 
        documentBody :{
            "LastName": "keeeeeee",  
        "Parents": [  
            {  
            "FamilyName": null,  
            "FirstName": "Thomas"  
            },  
            {  
            "FamilyName": null,  
            "FirstName": "Mary Kay"  
            }  
        ],  
        "Children": [  
            {  
            "FamilyName": null,  
            "FirstName": "Henriette Thaulow",  
            "Gender": "female",  
            "Grade": 5,  
            "Pets": [  
                {  
                "GivenName": "Fluffy"  
                }  
            ]  
            }  
        ],  
        "Address": {  
            "State": "WA",  
            "County": "King",  
            "City": "Seattle"  
        },  
        "IsRegistered": true, 
        "AccountNumber": 1234
        }, 
        partitionKey : [1234]  
    };
    var result = AzureCosmosClient->createDocument(databaseId, containerId,  createDoc,  options);
    if (result is Document){
        document = <@untainted>result;
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["document"], 
    dependsOn: ["test_createDocument"]
}
function test_getDocumentList(){
    log:printInfo("ACTION : getDocumentList()");

    string databaseId = database.id;
    string containerId = container.id;

    var result = AzureCosmosClient->getDocumentList(databaseId, containerId);
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
       var database = result.next();
        io:println(database?.value);
    }
}

@test:Config{
    groups: ["document"], 
    dependsOn: ["test_createDocument"]
}
function test_getDocumentListWithRequestOptions(){
    log:printInfo("ACTION : getDocumentListWithRequestOptions()");

    string databaseId = database.id;
    string containerId = container.id;

    DocumentListOptions options = {
        consistancyLevel : "Eventual", 
       // changeFeedOption : "Incremental feed", 
        sessionToken: "tag", 
        ifNoneMatchEtag: "hhh", 
        partitionKeyRangeId:"0"
    };
    var result = AzureCosmosClient->getDocumentList(databaseId, containerId, 10, options);
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }
}

@test:Config{
    groups: ["document"], 
    dependsOn: ["test_createDocument"]
}
function test_GetOneDocument(){
    log:printInfo("ACTION : GetOneDocument()");

    string databaseId = database.id;
    string containerId = container.id;

    var result = AzureCosmosClient->getDocument(databaseId, containerId, document.id, [1234]);
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }  
}

@test:Config{
    groups: ["document"], 
    dependsOn: ["test_createDocument"]
}
function test_GetOneDocumentWithRequestOptions(){
    log:printInfo("ACTION : GetOneDocumentWithRequestOptions()");

    string databaseId = database.id;
    string containerId = container.id;
    @tainted Document getDoc = {
        id: document.id, 
        partitionKey : [1234]  
    };
    DocumentGetOptions options = {
        consistancyLevel : "Eventual", 
        sessionToken: "tag", 
        ifNoneMatchEtag: "hhh"
    };

    var result = AzureCosmosClient->getDocument(databaseId, containerId, document.id, [1234], options);
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }  
}

@test:Config{
    groups: ["document"], 
    dependsOn: [
        "test_createContainer", 
        "test_createDocument", 
        "test_GetOneDocument", 
        "test_GetOneDocumentWithRequestOptions", 
        "test_queryDocuments"
    ]
}
function test_deleteDocument(){
    log:printInfo("ACTION : deleteDocument()");

    string databaseId = database.id;
    string containerId = container.id;

    var result = AzureCosmosClient->deleteDocument(databaseId, containerId, document.id, [1234]);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }  
}

@test:Config{
    groups: ["document"], 
    dependsOn: ["test_createContainer"]
}
function test_queryDocuments(){
    log:printInfo("ACTION : queryDocuments()");

    string databaseId = database.id;
    string containerId = container.id;
    int[] partitionKey = [1234];
    Query sqlQuery = {
        query: string `SELECT * FROM ${container.id.toString()} f WHERE f.Address.City = 'Seattle'`, 
        parameters: []
    };
    
    var result = AzureCosmosClient->queryDocuments(databaseId, containerId, partitionKey, sqlQuery);   
    if (result is stream<Document>){
        var doc = result.next();
        io:println(doc);    
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["document"], 
    dependsOn: ["test_createContainer"]
}
function test_queryDocumentsWithRequestOptions(){
    log:printInfo("ACTION : queryDocumentsWithRequestOptions()");

    string databaseId = database.id;
    string containerId = container.id;
    int[] partitionKey = [1234];
    Query sqlQuery = {
        query: string `SELECT * FROM ${container.id.toString()} f WHERE f.Address.City = 'Seattle'`, 
        parameters: []
    };
    ResourceQueryOptions options = {
        //sessionToken: "tag", 
        enableCrossPartition: true
    };

    var result = AzureCosmosClient->queryDocuments(databaseId, containerId, partitionKey, sqlQuery, 10, options);   
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        var doc = result.next();
        io:println(doc);
    }   
}

@test:Config{
    groups: ["storedProcedure"], 
    dependsOn: ["test_createContainer"]
}
function test_createStoredProcedure(){
    log:printInfo("ACTION : createStoredProcedure()");

    var uuid = createRandomUUIDBallerina();
    string databaseId = database.id;
    string containerId = container.id;
    string createSprocBody = "function (){\r\n    var context = getContext();\r\n    var response = context.getResponse();\r\n\r\n    response.setBody(\"Hello,  World\");\r\n}"; 
    StoredProcedure sp = {
        id: string `sproc_${uuid.toString()}`, 
        body:createSprocBody
    };

    var result = AzureCosmosClient->createStoredProcedure(databaseId, containerId, sp);  
    if (result is StoredProcedure){
        storedPrcedure = <@untainted> result;
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["storedProcedure"], 
    dependsOn: ["test_createStoredProcedure"]
}
function test_replaceStoredProcedure(){
    log:printInfo("ACTION : replaceStoredProcedure()");

    string databaseId = database.id;
    string containerId = container.id;

    string replaceSprocBody = "function heloo(personToGreet){\r\n    var context = getContext();\r\n    var response = context.getResponse();\r\n\r\n    response.setBody(\"Hello,  \" + personToGreet);\r\n}";
    StoredProcedure sp = {
        id: storedPrcedure.id, 
        body: replaceSprocBody
    }; 
    var result = AzureCosmosClient->replaceStoredProcedure(databaseId, containerId, sp);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }   
}

@test:Config{
    groups: ["storedProcedure"], 
    dependsOn: ["test_createContainer"]
}
function test_getAllStoredProcedures(){
    log:printInfo("ACTION : getAllStoredProcedures()");

    string databaseId = database.id;
    string containerId = container.id;

    var result = AzureCosmosClient->listStoredProcedures(databaseId, containerId);   
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        var doc = result.next();
        io:println(doc);    
    }  
}

@test:Config{
    groups: ["storedProcedure"], 
    dependsOn: ["test_replaceStoredProcedure"]
}
function test_executeOneStoredProcedure(){
    log:printInfo("ACTION : executeOneStoredProcedure()");

    string databaseId = database.id;
    string containerId = container.id;
    string executeSprocId = storedPrcedure.id;
    string[] arrayofparameters = ["Sachi"];

    var result = AzureCosmosClient->executeStoredProcedure(databaseId, containerId, executeSprocId, arrayofparameters);   
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }        
}

@test:Config{
    groups: ["storedProcedure"], 
    dependsOn: ["test_createStoredProcedure", "test_executeOneStoredProcedure", "test_getAllStoredProcedures"]
}
function test_deleteOneStoredProcedure(){
    log:printInfo("ACTION : deleteOneStoredProcedure()");

    string databaseId = database.id;
    string containerId = container.id;
    string deleteSprocId = storedPrcedure.id;
    
    var result = AzureCosmosClient->deleteStoredProcedure(databaseId, containerId, deleteSprocId);   
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }   
}

@test:Config{
    groups: ["userDefinedFunction"], 
    dependsOn: ["test_createContainer"]
}
function test_createUDF(){
    log:printInfo("ACTION : createUDF()");

    var uuid = createRandomUUIDBallerina();
    string databaseId = database.id;
    string containerId = container.id;
    string udfId = string `udf_${uuid.toString()}`;
    string createUDFBody = "function tax(income){\r\n    if (income == undefined) \r\n        throw 'no input';\r\n    if ((income < 1000) \r\n        return income * 0.1;\r\n    else if ((income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}"; 
    UserDefinedFunction createUdf = {
        id: udfId, 
        body: createUDFBody
    };

    var result = AzureCosmosClient->createUserDefinedFunction(databaseId, containerId, createUdf);  
    if (result is UserDefinedFunction){
        udf = <@untainted> result;
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["userDefinedFunction"], 
    dependsOn: ["test_createContainer", "test_createUDF"]
}
function test_replaceUDF(){
    log:printInfo("ACTION : replaceUDF()");

    string databaseId = database.id;
    string containerId = container.id;
    string replaceUDFBody = "function taxIncome(income){\r\n if (income == undefined) \r\n throw 'no input';\r\n if ((income < 1000) \r\n return income * 0.1;\r\n else if ((income < 10000) \r\n return income * 0.2;\r\n else\r\n return income * 0.4;\r\n}"; 
    UserDefinedFunction replacementUdf = {
        id: udf.id, 
        body:replaceUDFBody
    };

    var result = AzureCosmosClient->replaceUserDefinedFunction(databaseId, containerId, replacementUdf);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }   
}

@test:Config{
    groups: ["userDefinedFunction"], 
    dependsOn: ["test_createContainer",  "test_createUDF"]
}
function test_listAllUDF(){
    log:printInfo("ACTION : listAllUDF()");

    string databaseId = database.id;
    string containerId = container.id;

    var result = AzureCosmosClient->listUserDefinedFunctions(databaseId, containerId);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        var doc = result.next();
        io:println(doc);    
    }  
}

@test:Config{
    groups: ["userDefinedFunction"], 
    dependsOn: ["test_replaceUDF", "test_listAllUDF"]
}
function test_deleteUDF(){
    log:printInfo("ACTION : deleteUDF()");

    string deleteUDFId = udf.id;
    string databaseId = database.id;
    string containerId = container.id;

    var result = AzureCosmosClient->deleteUserDefinedFunction(databaseId, containerId, deleteUDFId);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }
}

@test:Config{
    groups: ["trigger"], 
    dependsOn: ["test_createContainer"]
}
function test_createTrigger(){
    log:printInfo("ACTION : createTrigger()");

    var uuid = createRandomUUIDBallerina();
    string databaseId = database.id;
    string containerId = container.id;
    string triggerId = string `trigger_${uuid.toString()}`;
    string createTriggerBody = "function tax(income){\r\n    if (income == undefined) \r\n        throw 'no input';\r\n    if ((income < 1000) \r\n        return income * 0.1;\r\n    else if ((income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}";
    string createTriggerOperation = "All"; 
    string createTriggerType = "Post"; 
    Trigger createTrigger = {
        id:triggerId, 
        body:createTriggerBody, 
        triggerOperation:createTriggerOperation, 
        triggerType: createTriggerType
    };

    var result = AzureCosmosClient->createTrigger(databaseId, containerId, createTrigger);  
    if (result is Trigger){
        trigger = <@untainted>result;
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["trigger"], 
    dependsOn: ["test_createTrigger"]
}
function test_replaceTrigger(){
    log:printInfo("ACTION : replaceTrigger()");

    string databaseId = database.id;
    string containerId = container.id;
    string replaceTriggerBody = "function updateMetadata(){\r\n var context = getContext();\r\n var collection = context.getCollection();\r\n var response = context.getResponse();\r\n var createdDocument = response.getBody();\r\n\r\n // query for metadata document\r\n var filterQuery = 'SELECT * FROM root r WHERE r.id = \"_metadata\"';\r\n var accept = collection.queryDocuments(collection.getSelfLink(),  filterQuery, \r\n updateMetadataCallback);\r\n if (!accept) throw \"Unable to update metadata,  abort\";\r\n\r\n function updateMetadataCallback(err,  documents,  responseOptions){\r\n if (err) throw new Error(\"Error\" + err.message);\r\n if (documents.length != 1) throw 'Unable to find metadata document';\r\n var metadataDocument = documents[0];\r\n\r\n // update metadata\r\n metadataDocument.createdDocuments += 1;\r\n metadataDocument.createdNames += \" \" + createdDocument.id;\r\n var accept = collection.replaceDocument(metadataDocument._self, \r\n metadataDocument,  function(err,  docReplaced){\r\n if (err) throw \"Unable to update metadata,  abort\";\r\n });\r\n if (!accept) throw \"Unable to update metadata,  abort\";\r\n return; \r\n }";
    string replaceTriggerOperation = "All"; 
    string replaceTriggerType = "Post";
    Trigger replaceTrigger = {
        id: trigger.id, 
        body:replaceTriggerBody, 
        triggerOperation:replaceTriggerOperation, 
        triggerType: replaceTriggerType
    };

    var result = AzureCosmosClient->replaceTrigger(databaseId, containerId, replaceTrigger);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }   
}

@test:Config{
    groups: ["trigger"], 
    dependsOn: ["test_createTrigger"]
}
function test_listTriggers(){
    log:printInfo("ACTION : listTriggers()");

    string databaseId = database.id;
    string containerId = container.id;

    var result = AzureCosmosClient->listTriggers(databaseId, containerId);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        var doc = result.next();
        io:println(doc);
    } 
}

@test:Config{
    groups: ["trigger"], 
    dependsOn: ["test_replaceTrigger", "test_listTriggers"]
}
function test_deleteTrigger(){
    log:printInfo("ACTION : deleteTrigger()");

    string deleteTriggerId = trigger.id;
    string databaseId = database.id;
    string containerId = container.id;

    var result = AzureCosmosClient->deleteTrigger(databaseId, containerId, deleteTriggerId);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    } 
}

@test:Config{
    groups: ["user"], 
    dependsOn: ["test_createDatabase"]
}
function test_createUser(){
    log:printInfo("ACTION : createUser()");

    var uuid = createRandomUUIDBallerina();
    string databaseId = database.id;
    string userId = string `user_${uuid.toString()}`;

    var result = AzureCosmosClient->createUser(databaseId, userId);  
    if (result is User){
        test_user = <@untainted>result;
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["user"], 
    dependsOn: ["test_createUser", "test_getUser"]
}
function test_replaceUserId(){
    log:printInfo("ACTION : replaceUserId()");

    var uuid = createRandomUUIDBallerina();
    string newReplaceId = string `user_${uuid.toString()}`;
    string databaseId = database.id;
    string replaceUser = test_user.id;

    var result = AzureCosmosClient->replaceUserId(databaseId, replaceUser, newReplaceId);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        test_user = <@untainted>result;
        io:println(result);
    }  
}

@test:Config{
    groups: ["user"], 
    dependsOn: ["test_createUser"]
}
function test_getUser(){
    log:printInfo("ACTION : getUser()");

    Client AzureCosmosClient = new(config);
    string databaseId = database.id;
    string getUserId = test_user.id;

    var result = AzureCosmosClient->getUser(databaseId, getUserId);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }  
}

@test:Config{
    groups: ["user"], 
    dependsOn: ["test_createUser"]
}
function test_listUsers(){
    log:printInfo("ACTION : listUsers()");

    string databaseId = database.id;

    var result = AzureCosmosClient->listUsers(databaseId);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        var doc = result.next();
        io:println(doc);    
    } 
}

@test:Config{
    groups: ["user"], 
    dependsOn: [
        "test_replaceUserId", 
        "test_deletePermission", 
        "test_createPermissionWithTTL", 
        "test_getCollection_Resource_Token"
    ]
}
function test_deleteUser(){
    log:printInfo("ACTION : deleteUser()");

    string deleteUserId = test_user.id;
    string databaseId = database.id;

    var result = AzureCosmosClient->deleteUser(databaseId, deleteUserId);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    } 
}

@test:Config{
    groups: ["permission"], 
    dependsOn: ["test_createDatabase", "test_createUser"]
}
function test_createPermission(){
    log:printInfo("ACTION : createPermission()");

    var uuid = createRandomUUIDBallerina();
    string databaseId = database.id;
    string permissionUserId = test_user.id;
    string permissionId = string `permission_${uuid.toString()}`;
    string permissionMode = "All";
    string permissionResource = string `dbs/${database?.resourceId.toString()}/colls/${container?.resourceId.toString()}`;
    Permission createPermission = {
        id: permissionId, 
        permissionMode: permissionMode, 
        resourcePath: permissionResource
    };

    var result = AzureCosmosClient->createPermission(databaseId, permissionUserId, createPermission);  
    if (result is Permission){
        permission = <@untainted>result;
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["permission"], 
    dependsOn: ["test_createDatabase", "test_createUser"]
}
function test_createPermissionWithTTL(){
    log:printInfo("ACTION : createPermission()");

    var uuid = createRandomUUIDBallerina();
    string databaseId = database.id;
    string permissionUserId = test_user.id;
    string permissionId = string `permission_${uuid.toString()}`;
    string permissionMode = "All";
    string permissionResource = string `dbs/${database?.resourceId.toString()}/colls/${container?.resourceId.toString()}`;
    int validityPeriod = 9000;
    Permission createPermission = {
        id: permissionId, 
        permissionMode: permissionMode, 
        resourcePath: permissionResource
    };

    var result = AzureCosmosClient->createPermission(databaseId, permissionUserId, createPermission, validityPeriod);  
    if (result is Permission){
        permission = <@untainted>result;
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["permission"], 
    dependsOn: ["test_createPermission"]
}
function test_replacePermission(){
    log:printInfo("ACTION : replacePermission()");

    string databaseId = database.id;
    string permissionUserId = test_user.id;
    string permissionId = permission.id;
    string permissionMode = "All";
    string permissionResource = string `dbs/${database.id}/colls/${container.id}`;
    Permission replacePermission = {
        id: permissionId, 
        permissionMode: permissionMode, 
        resourcePath: permissionResource
    };

    var result = AzureCosmosClient->replacePermission(databaseId, permissionUserId, replacePermission);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }  
}

@test:Config{
    groups: ["permission"], 
    dependsOn: ["test_createPermission"]
}
function test_listPermissions(){
    log:printInfo("ACTION : listPermissions()");

    string databaseId = database.id;
    string permissionUserId = test_user.id;

    var result = AzureCosmosClient->listPermissions(databaseId, permissionUserId);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        var doc = result.next();
        io:println(doc);     
    } 
}

@test:Config{
    groups: ["permission"], 
    dependsOn: ["test_createPermission"]
}
function test_getPermission(){
    log:printInfo("ACTION : getPermission()");

    string databaseId = database.id;
    string permissionUserId = test_user.id;
    string permissionId = permission.id;

    var result = AzureCosmosClient->getPermission(databaseId, permissionUserId, permissionId);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }
}

@test:Config{
    groups: ["permission"], 
    dependsOn: [ "test_getPermission", "test_listPermissions", "test_replacePermission"]
}
function test_deletePermission(){
    log:printInfo("ACTION : deletePermission()");

    string databaseId = database.id;
    string permissionUserId = test_user.id;
    string permissionId = permission.id;

    var result = AzureCosmosClient->deletePermission(databaseId, permissionUserId, permissionId);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    } 
}

@test:Config{
    groups: ["offer"]
}
function test_listOffers(){
    log:printInfo("ACTION : listOffers()");

    var result = AzureCosmosClient->listOffers(6);  
    if (result is stream<Offer>){
        var doc = result.next();
        io:println(doc);    
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["offer"], 
    dependsOn: ["test_listOffers"]
}
function test_getOffer(){
    log:printInfo("ACTION : getOffer()");

    //these fuctions can be depending on the list Offers
    var result = AzureCosmosClient->listOffers();  
    if (result is stream<Offer>){
        var doc = result.next();
        var result2 = AzureCosmosClient->getOffer(<string>doc["value"]["id"]);  
        if (result2 is error){
            test:assertFail(msg = result2.message());
        } else {
            var output = "";
            io:println(result2);
        }  
    }  

}

@test:Config{
    groups: ["offer"]
}
function test_replaceOffer(){
    log:printInfo("ACTION : replaceOffer()");

    //these fuctions can be depending on the list Offers
    var result = AzureCosmosClient->listOffers();  
    if (result is stream<Offer>){
        var doc = result.next();
        Offer replaceOfferBody = {
            offerVersion: "V2", 
            offerType: "Invalid",    
            content: {  
                "offerThroughput": 600
            },  
            resourceSelfLink: string `dbs/${database?.resourceId.toString()}/colls/${container?.resourceId.toString()}/`,  
            resourceResourceId: string `${container?.resourceId.toString()}`, 
            id: <string>doc["value"]["id"], 
            resourceId: <string>doc["value"]["resourceId"]
        };
        var result2 = AzureCosmosClient->replaceOffer(<@untainted>replaceOfferBody);  
        if (result2 is error){
            test:assertFail(msg = result2.message());
        } else {
            var output = "";
            io:println(result2);
        }  
    }  
}

@test:Config{
    groups: ["offer"]
}
function test_replaceOfferWithOptionalParameter(){
    log:printInfo("ACTION : replaceOfferWithOptionalParameter()");

    var result = AzureCosmosClient->listOffers();  
    if (result is stream<Offer>){
        var doc = result.next();
        Offer replaceOfferBody = {
            offerVersion: "V2", 
            content: {  
                "offerThroughput": 600
            },  
            resourceSelfLink: string `dbs/${database?.resourceId.toString()}/colls/${container?.resourceId.toString()}/`,  
            resourceResourceId: string `${container?.resourceId.toString()}`, 
            id: <string>doc["value"]["id"], 
            resourceId: <string>doc["value"]["resourceId"]
        };
        var result2 = AzureCosmosClient->replaceOffer(<@untainted>replaceOfferBody);  
        if (result2 is error){
            test:assertFail(msg = result2.message());
        } else {
            var output = "";
            io:println(result2);
        }  
    }  
}

@test:Config{
    groups: ["offer"], 
    dependsOn: ["test_createDatabase",  "test_createContainer"]
}
function test_queryOffer(){
    log:printInfo("ACTION : queryOffer()");

    Query offerQuery = {
    query: string `SELECT * FROM ${container.id} f WHERE (f["_self"]) = "${container?.selfReference.toString()}"`
    };
    var result = AzureCosmosClient->queryOffer(offerQuery);   
    if (result is stream<Offer>){
        var doc = result.next();
        io:println(doc);    
    } else {
        test:assertFail(msg = result.message());
    }     
}

@test:Config{
    groups: ["permission"], 
    dependsOn: ["test_createPermission"]
}
function test_getCollection_Resource_Token(){
    log:printInfo("ACTION : createCollection_Resource_Token()");

    string databaseId = database.id;
    string permissionUserId = test_user.id;
    string permissionId = permission.id;

    var result = AzureCosmosClient->getPermission(databaseId, permissionUserId, permissionId);  
    if (result is error){
        test:assertFail(msg = result.message());
    } else {
        if (result?.token is string){
            AzureCosmosConfiguration configdb = {
                baseUrl : getConfigValue("BASE_URL"), 
                keyOrResourceToken : result?.token.toString(), 
                tokenType : "resource", 
                tokenVersion : getConfigValue("TOKEN_VERSION")
            };

            Client AzureCosmosClientDatabase = new(configdb);

            string containerId = container.id;

            var resultdb = AzureCosmosClientDatabase->getContainer(databaseId, containerId);
            if (resultdb is error){
                test:assertFail(msg = resultdb.message());
            } else {
                var output = "";
                io:println(result);
            }
        }
    }
}

isolated function getConfigValue(string key) returns string {
    return (system:getEnv(key) != "") ? system:getEnv(key) : config:getAsString(key);
}

function createRandomUUIDBallerina() returns string {
    string? stringUUID = java:toString(createRandomUUID());
    if (stringUUID is string){
        stringUUID = stringutils:replace(stringUUID, "-", "");
        return stringUUID;
    } else {
        return "";
    }
}

function createRandomUUID() returns handle = @java:Method {
    name : "randomUUID", 
    'class : "java.util.UUID"
} external;
