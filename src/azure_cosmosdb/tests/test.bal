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
    host : getConfigValue("HOST"), 
    tokenType : getConfigValue("TOKEN_TYPE"), 
    tokenVersion : getConfigValue("TOKEN_VERSION"), 
    secureSocketConfig :{
                            trustStore: {
                            path: getConfigValue("b7a_home") + "/bre/security/ballerinaTruststore.p12", 
                            password: getConfigValue("SSL_PASSWORD")
                            }
                        }
};

Client AzureCosmosClient = new(config);

Database db = new("", config);
Container con = new("","",config);
 
DatabaseResponse database = {};
DatabaseResponse manual = {};
DatabaseResponse auto = {};
DatabaseResponse ifexist = {};
ContainerResponse container = {};
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
    if(result is error){
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

    var uuid = createRandomUUIDBallerina();
    string createDatabaseId = "";
    var result = AzureCosmosClient->createDatabase(createDatabaseId);
    if(result is DatabaseResponse){
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
    if(result is error){
        test:assertFail(msg = result.message());
    } else {
        ifexist = <@untainted><DatabaseResponse> result;
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
    if(result is DatabaseResponse){
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
    ThroughputProperties manualThroughput = {
        throughput: 400
    };
    var result = AzureCosmosClient->createDatabase(createDatabaseManualId,  manualThroughput);
    if(result is error){
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
    ThroughputProperties manualThroughput = {
        throughput: 40
    };
    var result = AzureCosmosClient->createDatabase(createDatabaseManualId,  manualThroughput);
    if(result is DatabaseResponse){
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
    ThroughputProperties tp = {
        maxThroughput: {"maxThroughput": 4000}
    };
    var result = AzureCosmosClient->createDatabase(createDatabaseAutoId,  tp);
    if(result is error){
        test:assertFail(msg = result.message());
    } else {
        auto = <@untainted> result;
        io:println(result);
    }
}

@test:Config{
    groups: ["database"]
}
function test_createDatabaseWithBothHeaders(){
    log:printInfo("ACTION : createDatabaseWithBothHeaders()");

    var uuid = createRandomUUIDBallerina();
    string createDatabaseBothId = string `database_${uuid.toString()}`;
    ThroughputProperties tp = {
        maxThroughput: {"maxThroughput" : 4000}, 
        throughput: 600
    };
    var result = AzureCosmosClient->createDatabase(createDatabaseBothId,  tp);
    if(result is DatabaseResponse){
        test:assertFail(msg = "Created database with both throughput values!!");
    } else {
        var output = "";
        io:println(result);
    }
}

@test:Config{
    groups: ["database"]
}
function test_listAllDatabases(){
    log:printInfo("ACTION : listAllDatabases()");

    var result = AzureCosmosClient->getDatabases(6);
    if(result is stream<DatabaseResponse>){
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
    if(result is Database) {
        db = result;
        io:println(db);
    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["database"], 
    dependsOn: [
        "test_createDatabase", 
        "test_createDatabaseIfNotExist", 
        "test_createDBWithAutoscalingThroughput", 
        "test_createDatabaseWithBothHeaders", 
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
        "test_getCollection_Resource_Token",
        "test_getOffer",
        "test_replaceOffer",
        "test_replaceOfferWithOptionalParameter"
    ]
}
function test_deleteDatabase(){
    log:printInfo("ACTION : deleteDatabase()");

    var result1 = AzureCosmosClient->deleteDatabase(database.id);
    var result2 = AzureCosmosClient->deleteDatabase(manual.id);
    var result3 = AzureCosmosClient->deleteDatabase(auto.id);
    var result4 = AzureCosmosClient->deleteDatabase(ifexist.id);
    if(result1 is error){
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
    // @tainted ResourceProperties propertiesNewCollection = {
    //         databaseId: database.id, 
    //         containerId: string `container_${uuid.toString()}`
    // };
    string containerId = string `container_${uuid.toString()}`;
    PartitionKey pk = {
        paths: ["/AccountNumber"], 
        kind :"Hash", 
        keyVersion: 2
    };
    var result = db->createContainer(containerId, pk);
    if(result is ContainerResponse){
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

    ThroughputProperties tp = {
        throughput: 600
    };
    PartitionKey pk = {
        paths: ["/AccountNumber"], 
        kind : "Hash", 
        keyVersion : 2
    };
    var uuid = createRandomUUIDBallerina();
    // @tainted ResourceProperties getCollection = {
    //     databaseId: database.id, 
    //     containerId: string `container_${uuid.toString()}`
    // };
    string containerId = string `container_${uuid.toString()}`;
    var result = db->createContainer(containerId, pk, ip, tp);
    if(result is ContainerResponse){
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
    @tainted ResourceProperties propertiesNewCollectionIfNotExist = {
            databaseId: database.id, 
            containerId: string `containere_${uuid.toString()}`
    };
    string containerId = string `container_${uuid.toString()}`;
    PartitionKey pk = {
        paths: ["/AccountNumber"], 
        kind :"Hash", 
        keyVersion: 2
    };
    var result = db->createContainerIfNotExist(containerId, pk);
    if(result is ContainerResponse?){
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

    var result = db->getContainer(container.id);
    if(result is Container){
        con = result;
        io:println(db);
    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["container"], 
    dependsOn: ["test_createDatabase"]
}
function test_getAllContainers(){
    log:printInfo("ACTION : getAllContainers()");

    var result = db->getAllContainers();
    if(result is stream<ContainerResponse>){
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
        "test_getAllContainers"
    ]
}
function test_deleteContainer(){
    log:printInfo("ACTION : deleteContainer()");

    var result = db->deleteContainer(container.id);
    if(result is error){
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

    var result = con->getPartitionKeyRanges();
    if(result is error){
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
function test_createDocument(){
    log:printInfo("ACTION : createDocument()");

    var uuid = createRandomUUIDBallerina();
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

    var result = con->createDocument(createDoc);
    if(result is Document){
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
    RequestHeaderOptions options = {
        isUpsertRequest: true, 
        indexingDirective : "Include", 
        //sessionToken: "tag", - error handled in azure
        //no need
        consistancyLevel : "Eventual", 
        //changeFeedOption : "Incremental feed", 
        ifNoneMatch: "hhh"
        //partitionKeyRangeId:"0"- error handled in azure
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
    var result = con->createDocument(createDoc,  options);
    if(result is Document){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    var result = con->getDocumentList();
    if(result is error){
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

    RequestHeaderOptions options = {
        isUpsertRequest: true, 
        indexingDirective : "Include", 
        consistancyLevel : "Eventual", 
       // changeFeedOption : "Incremental feed", 
        sessionToken: "tag", 
        ifNoneMatch: "hhh", 
        partitionKeyRangeId:"0"
    };
    var result = con->getDocumentList(options);
    if(result is error){
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

    var result = con->getDocument(document.id, [1234]);
    if(result is error){
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

    @tainted Document getDoc = {
        id: document.id, 
        partitionKey : [1234]  
    };
    RequestHeaderOptions options = {
        consistancyLevel : "Eventual", 
        sessionToken: "tag", 
        ifNoneMatch: "hhh", 
//these are not needed
        isUpsertRequest: true, 
        indexingDirective : "Include", 
        changeFeedOption : "Incremental feed"
    };
    var result = con->getDocument(document.id, [1234], options);
    if(result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        io:println(result);
    }  
}

@test:Config{
    groups: ["document"], 
    dependsOn: ["test_createContainer", "test_createDocument", "test_GetOneDocument", "test_GetOneDocumentWithRequestOptions"]
}
function test_deleteDocument(){
    log:printInfo("ACTION : deleteDocument()");

    var result = con->deleteDocument(document.id, [1234]);  
    if(result is error){
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

    int[] partitionKey = [1234];
    Query sqlQuery = {
        query: string `SELECT * FROM ${container.id.toString()} f WHERE f.Address.City = 'Seattle'`, 
        parameters: []
    };
    var result = con->queryDocuments(partitionKey, sqlQuery);   
    if(result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        var doc = result.next();
        io:println(doc);
        error? e = result.forEach(function (json document){
            io:println(document);
        });

    }   
}

@test:Config{
    groups: ["document"], 
    dependsOn: ["test_createContainer"]
}
function test_queryDocumentsWithRequestOptions(){
    log:printInfo("ACTION : queryDocumentsWithRequestOptions()");

    int[] partitionKey = [1234];
    Query sqlQuery = {
        query: string `SELECT * FROM ${container.id.toString()} f WHERE f.Address.City = 'Seattle'`, 
        parameters: []
    };
    RequestHeaderOptions options = {
        consistancyLevel : "Eventual", 
        sessionToken: "tag", 
        enableCrossPartition: true, 
//these are not needed
        ifNoneMatch: "hhh", 
        isUpsertRequest: true, 
        indexingDirective : "Include", 
        changeFeedOption : "Incremental feed"
    };
    var result = con->queryDocuments(partitionKey, sqlQuery, options);   
    if(result is error){
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
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    string createSprocBody = "function (){\r\n    var context = getContext();\r\n    var response = context.getResponse();\r\n\r\n    response.setBody(\"Hello,  World\");\r\n}"; 
    StoredProcedure sp = {
        id: string `sproc_${uuid.toString()}`, 
        body:createSprocBody
    };
    var result = con->createStoredProcedure(sp);  
    if(result is StoredProcedure){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    string replaceSprocBody = "function heloo(personToGreet){\r\n    var context = getContext();\r\n    var response = context.getResponse();\r\n\r\n    response.setBody(\"Hello,  \" + personToGreet);\r\n}";
    StoredProcedure sp = {
        id: storedPrcedure.id, 
        body: replaceSprocBody
    }; 
    var result = con->replaceStoredProcedure(sp);  
    if(result is error){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    var result = con->listStoredProcedures();   
    if(result is error){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    string executeSprocId = storedPrcedure.id;
    string[] arrayofparameters = ["Sachi"];
    var result = con->executeStoredProcedure(executeSprocId, arrayofparameters);   
    if(result is error){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    string deleteSprocId = storedPrcedure.id;
    var result = con->deleteStoredProcedure(deleteSprocId);   
    if(result is error){
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
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    string udfId = string `udf_${uuid.toString()}`;
    string createUDFBody = "function tax(income){\r\n    if(income == undefined) \r\n        throw 'no input';\r\n    if((income < 1000) \r\n        return income * 0.1;\r\n    else if((income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}"; 
    UserDefinedFunction createUdf = {
        id: udfId, 
        body: createUDFBody
    };
    var result = con->createUserDefinedFunction(createUdf);  
    if(result is UserDefinedFunction){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    string replaceUDFBody = "function taxIncome(income){\r\n if(income == undefined) \r\n throw 'no input';\r\n if((income < 1000) \r\n return income * 0.1;\r\n else if((income < 10000) \r\n return income * 0.2;\r\n else\r\n return income * 0.4;\r\n}"; 
    UserDefinedFunction replacementUdf = {
        id: udf.id, 
        body:replaceUDFBody
    };
    var result = con->replaceUserDefinedFunction(replacementUdf);  
    if(result is error){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    var result = con->listUserDefinedFunctions();  
    if(result is error){
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
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    var result = con->deleteUserDefinedFunction(deleteUDFId);  
    if(result is error){
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
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    string triggerId = string `trigger_${uuid.toString()}`;
    string createTriggerBody = "function tax(income){\r\n    if(income == undefined) \r\n        throw 'no input';\r\n    if((income < 1000) \r\n        return income * 0.1;\r\n    else if((income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}";
    string createTriggerOperation = "All"; 
    string createTriggerType = "Post"; 
    Trigger createTrigger = {
        id:triggerId, 
        body:createTriggerBody, 
        triggerOperation:createTriggerOperation, 
        triggerType: createTriggerType
    };
    var result = con->createTrigger(createTrigger);  
    if(result is Trigger){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    string replaceTriggerBody = "function updateMetadata(){\r\n var context = getContext();\r\n var collection = context.getCollection();\r\n var response = context.getResponse();\r\n var createdDocument = response.getBody();\r\n\r\n // query for metadata document\r\n var filterQuery = 'SELECT * FROM root r WHERE r.id = \"_metadata\"';\r\n var accept = collection.queryDocuments(collection.getSelfLink(),  filterQuery, \r\n updateMetadataCallback);\r\n if(!accept) throw \"Unable to update metadata,  abort\";\r\n\r\n function updateMetadataCallback(err,  documents,  responseOptions){\r\n if(err) throw new Error(\"Error\" + err.message);\r\n if(documents.length != 1) throw 'Unable to find metadata document';\r\n var metadataDocument = documents[0];\r\n\r\n // update metadata\r\n metadataDocument.createdDocuments += 1;\r\n metadataDocument.createdNames += \" \" + createdDocument.id;\r\n var accept = collection.replaceDocument(metadataDocument._self, \r\n metadataDocument,  function(err,  docReplaced){\r\n if(err) throw \"Unable to update metadata,  abort\";\r\n });\r\n if(!accept) throw \"Unable to update metadata,  abort\";\r\n return; \r\n }";
    string replaceTriggerOperation = "All"; 
    string replaceTriggerType = "Post";
    Trigger replaceTrigger = {
        id: trigger.id, 
        body:replaceTriggerBody, 
        triggerOperation:replaceTriggerOperation, 
        triggerType: replaceTriggerType
    };
    var result = con->replaceTrigger(replaceTrigger);  
    if(result is error){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    var result = con->listTriggers();  
    if(result is error){
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
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id, 
        containerId: container.id
    };
    var result = con->deleteTrigger(deleteTriggerId);  
    if(result is error){
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
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id
    };
    string userId = string `user_${uuid.toString()}`;
    var result = db->createUser(userId);  
    if(result is User){
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
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id
    };
    string replaceUser = test_user.id;
    var result = db->replaceUserId(replaceUser, newReplaceId);  
    if(result is error){
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
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id
    };
    string getUserId = test_user.id;
    var result = db->getUser(getUserId);  
    if(result is error){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id
    };
    var result = db->listUsers();  
    if(result is error){
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
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id
    };
    var result = db->deleteUser(deleteUserId);  
    if(result is error){
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
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id
    };
    string permissionUserId = test_user.id;
    string permissionId = string `permission_${uuid.toString()}`;
    string permissionMode = "All";
    string permissionResource = string `dbs/${database?.resourceId.toString()}/colls/${container?.resourceId.toString()}`;
    Permission createPermission = {
        id: permissionId, 
        permissionMode: permissionMode, 
        resourcePath: permissionResource
    };

    var result = db->createPermission(permissionUserId, createPermission);  
    if(result is Permission){
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
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id
    };
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
    var result = db->createPermission(permissionUserId, createPermission, validityPeriod);  
    if(result is Permission){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id
    };
    string permissionUserId = test_user.id;
    string permissionId = permission.id;
    string permissionMode = "All";
    string permissionResource = string `dbs/${database.id}/colls/${container.id}`;
    Permission replacePermission = {
        id: permissionId, 
        permissionMode: permissionMode, 
        resourcePath: permissionResource
    };
    var result = db->replacePermission(permissionUserId, replacePermission);  
    if(result is error){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id
    };
    string permissionUserId = test_user.id;
    var result = db->listPermissions(permissionUserId);  
    if(result is error){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id
    };
    string permissionUserId = test_user.id;
    string permissionId = permission.id;
    var result = db->getPermission(permissionUserId, permissionId);  
    if(result is error){
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

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id
    };
    string permissionUserId = test_user.id;
    string permissionId = permission.id;
    var result = db->deletePermission(permissionUserId, permissionId);  
    if(result is error){
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

    var result = AzureCosmosClient->listOffers();  
    if(result is stream<Offer>){
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
    if(result is stream<Offer>){
        var doc = result.next();
        var result2 = AzureCosmosClient->getOffer(<string>doc["value"]["id"]);  
        if(result2 is error){
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
    if(result is stream<Offer>){
        var doc = result.next();
        Offer replaceOfferBody = {
            offerVersion: "V2", 
            offerType: "Invalid",    
            content: {  
                "offerThroughput": 600
            },  
            resourceSelfLink: string `dbs/${database?.resourceId.toString()}/colls/${container?.resourceId.toString()}/`,  
            offerResourceId: string `${container?.resourceId.toString()}`, 
            id: <string>doc["value"]["id"], 
            resourceId: <string>doc["value"]["resourceId"]
        };
        var result2 = AzureCosmosClient->replaceOffer(<@untainted>replaceOfferBody);  
        if(result2 is error){
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
    if(result is stream<Offer>){
        var doc = result.next();
        Offer replaceOfferBody = {
            offerVersion: "V2", 
            content: {  
                "offerThroughput": 600
            },  
            resourceSelfLink: string `dbs/${database?.resourceId.toString()}/colls/${container?.resourceId.toString()}/`,  
            offerResourceId: string `${container?.resourceId.toString()}`, 
            id: <string>doc["value"]["id"], 
            resourceId: <string>doc["value"]["resourceId"]
        };
        var result2 = AzureCosmosClient->replaceOffer(<@untainted>replaceOfferBody);  
        if(result2 is error){
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
    if(result is error){
        test:assertFail(msg = result.message());
    } else {
        var output = "";
        var offer = result.next();
        io:println(offer);    
    }  
}

@test:Config{
    groups: ["permission"], 
    dependsOn: ["test_createPermission"]
}
function test_getCollection_Resource_Token(){
    log:printInfo("ACTION : createCollection_Resource_Token()");

    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id
    };
    string permissionUserId = test_user.id;
    string permissionId = permission.id;
    var result = db->getPermission(permissionUserId, permissionId);  
    if(result is error){
        test:assertFail(msg = result.message());
    } else {
        if(result?.token is string){
            AzureCosmosConfiguration configdb = {
                baseUrl : getConfigValue("BASE_URL"), 
                keyOrResourceToken : result?.token.toString(), 
                host : getConfigValue("HOST"), 
                tokenType : "resource", 
                tokenVersion : getConfigValue("TOKEN_VERSION"), 
                secureSocketConfig :{
                                        trustStore: {
                                        path: getConfigValue("b7a_home") + "/bre/security/ballerinaTruststore.p12", 
                                        password: getConfigValue("SSL_PASSWORD")
                                        }
                                    }
            };

            Client AzureCosmosClientDatabase = new(configdb);

            var resultdb = db->getContainer(container.id);
            if(resultdb is error){
                test:assertFail(msg = resultdb.message());
            } else {
                var output = "";
                io:println(result);
            }
        }
    }
}

function getConfigValue(string key) returns string {
    return (system:getEnv(key) != "") ? system:getEnv(key) : config:getAsString(key);
}

function createRandomUUIDBallerina() returns string {
    string? stringUUID = java:toString(createRandomUUID());
    if(stringUUID is string){
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
