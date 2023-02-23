import ballerina/http;
import ballerina/log;
// import ballerinax/mysql;
// import ballerina/sql;
// import ballerinax/mysql.driver as _;

type stockDetails record {
    string includes;
    string intendedFor;
    string color;
    string material;
};

type ItemDetails record {
    readonly int itemID;
    string itemName;
    string itemImage;
    string itemDescription;
    float itemPrice;
    stockDetails stockDetails;
};

type ItemsPayload record {
    ItemDetails[] itemDetails;
};

type ItemFollows record {
    readonly string userID;
    readonly int itemID;
};

type Item record {
    int itemID;
    string itemName;
    string itemImage?;
    string itemDescription?;
    float itemPrice;
};

// configurable string dbHost = ?;
// configurable string dbUser = ?;
// configurable string dbPassword = ?;
// configurable string dbName = ?;

table<ItemDetails> key(itemID) itemsTable = table [
    {
        itemID: 1, 
        itemName: "Top Paw® Valentine's Day Single Dog Sweater", 
        itemImage: "https://user-images.githubusercontent.com/25479743/220543717-b02a11ec-ce58-42dd-a650-33a33c8ebd9a.png",
        itemDescription: "Dress your pup up appropriately for Valentine's Day with this Top Paw Valentine's Day Kisses Dog Sweater. This sweet sweater slips on and off easily while offering a comfortable fit, and lets it be known that your pup is single and ready to mingle", 
        itemPrice: 115.99,
        stockDetails: {
            includes: "1 Sweater",
            intendedFor: "Dogs",
            color: "Blue, Red, Yellow",
            material: "100% Acrylic"
        }
    },
    {
        itemID: 2, 
        itemName: "Item 2", 
        itemImage: "https://user-images.githubusercontent.com/25479743/220543717-b02a11ec-ce58-42dd-a650-33a33c8ebd9a.png",
        itemDescription: "Dress your pup up appropriately for Valentine's Day with this Top Paw Valentine's Day Kisses Dog Sweater. This sweet sweater slips on and off easily while offering a comfortable fit, and lets it be known that your pup is single and ready to mingle", 
        itemPrice: 100,
        stockDetails: {
            includes: "1 Sweater",
            intendedFor: "Dogs",
            color: "Blue, Red, Yellow",
            material: "100% Acrylic"
        }
    },
    {
        itemID: 3, 
        itemName: "Item 3", 
        itemImage: "https://user-images.githubusercontent.com/25479743/220543717-b02a11ec-ce58-42dd-a650-33a33c8ebd9a.png",
        itemDescription: "Dress your pup up appropriately for Valentine's Day with this Top Paw Valentine's Day Kisses Dog Sweater. This sweet sweater slips on and off easily while offering a comfortable fit, and lets it be known that your pup is single and ready to mingle", 
        itemPrice: 299.99,
        stockDetails: {
            includes: "1 Sweate",
            intendedFor: "Dogs",
            color: "Blue, Red, Yellow",
            material: "100% Acrylic"
        }
    }
];

table<ItemFollows> key(userID, itemID) itemFolowsTable = table [
    {
        userID:"19ef6598-c7c1-4586-acee-1a8be0426899",
        itemID: 1
    },
    {
        userID:"19ef6598-c7c1-4586-acee-1a8be0426899",
        itemID: 3
    },
    {
        userID:"test",
        itemID: 1
    }
];

service /petstore on new http:Listener(9090) {

    resource function get items() returns ItemsPayload|error {

        log:printInfo("Received request to GET all items: ");

        // mysql:Client mysqlEp = check new (host = dbHost, port = 3306, user = dbUser, password = dbPassword, database = dbName);
        // sql:ParameterizedQuery getItemsPerStateQuery = `SELECT * FROM Items WHERE state = ${state}`;
        // int fetchedRecords = check mysqlEp->queryRow(getItemsPerStateQuery);

        ItemDetails[] itemDetails = from var i in itemsTable select i;
        
        // if (fetchedRecords == 0) {
        //     check mysqlEp.close();
        //     return response;
        // }
        
        //stream<patientDetails, sql:Error?> resultStream = mysqlEp->query(detailsQuery);

        ItemsPayload response = {itemDetails};
        
        return response;
    }

    resource function post followItem(@http:Payload ItemFollows itemTobeFollowed)
                                    returns ItemFollows[]|error {

        // ADD part here

        ItemFollows[] dataFromDB = from var i in itemFolowsTable where i.userID == itemTobeFollowed.userID select i;
        return dataFromDB;
        
    }

    resource function get itemsFollowedBy/[string userID]() returns ItemFollows[]|error {

        log:printInfo("Received request to GET items followed for user : " + userID);

        ItemFollows[] dataFromDB = from var i in itemFolowsTable where i.userID == userID select i;

        return dataFromDB;
    }
}