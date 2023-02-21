import ballerina/graphql;
import ballerina/log;
// import ballerinax/mysql;
// import ballerina/sql;
// import ballerinax/mysql.driver as _;

type ItemDetails record {
    readonly int itemID;
    string itemName;
    string itemImage?;
    string itemDescription?;
    float itemPrice;
    boolean is_followed;
};

type ItemsPayload record {
    ItemDetails[] itemDetails;
};

type Item record {
    int itemID;
    string itemName;
    string itemImage?;
    string itemDescription?;
    float itemPrice;
};

type ItemDetailsDBEntry record {
    readonly int itemID;
    string itemName;
    string itemImage?;
    string itemDescription?;
    float itemPrice;
    boolean is_followed;
    string state?;
};

// configurable string dbHost = ?;
// configurable string dbUser = ?;
// configurable string dbPassword = ?;
// configurable string dbName = ?;

table<ItemDetailsDBEntry> key(itemID) itemsTable = table [
    {
        itemID: 1, 
        itemName: "Top Paw® Valentine's Day Single Dog Sweater", 
        itemDescription: "Description", 
        itemPrice: 115.99,
        is_followed: true,
        state:"in_cart"
    },
    {
        itemID: 2, 
        itemName: "Arcadia Trail™ Dog Windbreaker", 
        itemDescription: "Description", 
        itemPrice: 200.00,
        is_followed: false,
        state:"in_cart"
    },
    {
        itemID: 3, 
        itemName: "Top Paw® Valentine's Day Kisses Dog Tee and Bandana", 
        itemDescription: "Description", 
        itemPrice: 999.99,
        is_followed: true,
        state:"not_in_cart"
    },
    {
        itemID: 4, 
        itemName: "Item 4 name", 
        itemDescription: "Item 4 Description", 
        itemPrice: 10.00,
        is_followed: false,
        state:"not_in_cart"
    }
];


service /items on new graphql:Listener(9090) {

    resource function get all() returns ItemsPayload|error {

        log:printInfo("Received request to GET all items: ");

        // mysql:Client mysqlEp = check new (host = dbHost, port = 3306, user = dbUser, password = dbPassword, database = dbName);
        // sql:ParameterizedQuery getItemsPerStateQuery = `SELECT * FROM Items WHERE state = ${state}`;
        // int fetchedRecords = check mysqlEp->queryRow(getItemsPerStateQuery);

        ItemDetailsDBEntry[] dataFromDB = from var i in itemsTable select i;
        
        // if (fetchedRecords == 0) {
        //     check mysqlEp.close();
        //     return response;
        // }
        
        //stream<patientDetails, sql:Error?> resultStream = mysqlEp->query(detailsQuery);

        ItemDetails[] itemDetails = [];
        check from ItemDetailsDBEntry entry in dataFromDB
            do {
                ItemDetails item = {
                    itemID: entry.itemID,
                    itemName: entry.itemName,
                    itemDescription: <string> entry.itemDescription,
                    itemPrice: entry.itemPrice,
                    is_followed: entry.is_followed
                };
                itemDetails.push(item);
            };

        ItemsPayload response = {itemDetails};
        // check mysqlEp.close();
        return response;
    }

    resource function get state(string state) returns ItemsPayload|error {

        log:printInfo("Received request to GET items with state: " + state);

        // mysql:Client mysqlEp = check new (host = dbHost, port = 3306, user = dbUser, password = dbPassword, database = dbName);
        // sql:ParameterizedQuery getItemsPerStateQuery = `SELECT * FROM Items WHERE state = ${state}`;
        // int fetchedRecords = check mysqlEp->queryRow(getItemsPerStateQuery);

        ItemDetailsDBEntry[] dataFromDB = from var i in itemsTable where i.state == state select i;
        
        // if (fetchedRecords == 0) {
        //     check mysqlEp.close();
        //     return response;
        // }
        
        //stream<patientDetails, sql:Error?> resultStream = mysqlEp->query(detailsQuery);

        ItemDetails[] itemDetails = [];
        check from ItemDetailsDBEntry entry in dataFromDB
            do {
                ItemDetails item = {
                    itemID: entry.itemID,
                    itemName: entry.itemName,
                    itemDescription: <string> entry.itemDescription,
                    itemPrice: entry.itemPrice,
                    is_followed: entry.is_followed
                };
                itemDetails.push(item);
            };

        ItemsPayload response = {itemDetails};
        // check mysqlEp.close();
        return response;
    }
}