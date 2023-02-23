import wso2/choreo.sendemail;
import ballerina/http;
import ballerina/log;
import ballerina/lang.'int;

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

type UserEmailRecord record {
    readonly string userID;
    string emailAddress;
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
            userID: "19ef6598-c7c1-4586-acee-1a8be0426899",
            itemID: 1
        },
        {
            userID: "19ef6598-c7c1-4586-acee-1a8be0426899",
            itemID: 3
        },
        {
            userID: "test",
            itemID: 1
        }
    ];

table<UserEmailRecord> key(userID) userEmailRecords = table [
        {
            userID: "19ef6598-c7c1-4586-acee-1a8be0426899",
            emailAddress: "dinikasen@gmail.com"
        },
        {
            userID: "123",
            emailAddress: "dinikasen@gmail.com"
        }
    ];

service /petstore on new http:Listener(9090) {

    resource function get items() returns ItemsPayload|error {

        log:printInfo("Received request to GET all items: ");

        // mysql:Client mysqlEp = check new (host = dbHost, port = 3306, user = dbUser, password = dbPassword, database = dbName);
        // sql:ParameterizedQuery getItemsPerStateQuery = `SELECT * FROM Items WHERE state = ${state}`;
        // int fetchedRecords = check mysqlEp->queryRow(getItemsPerStateQuery);

        ItemDetails[] itemDetails = from var i in itemsTable
            select i;

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

        ItemFollows[] dataFromDB = from var i in itemFolowsTable
            where i.userID == itemTobeFollowed.userID
            select i;
        return dataFromDB;

    }

    resource function get itemsFollowedBy/[string userID]() returns ItemFollows[]|error {

        log:printInfo("Received request to GET items followed for user : " + userID);

        ItemFollows[] dataFromDB = from var i in itemFolowsTable
            where i.userID == userID
            select i;

        return dataFromDB;
    }

    resource function post addItem(@http:Payload ItemDetails addPayload)
                                    returns ItemDetails|error|http:BadRequest {

        if (itemsTable.hasKey(addPayload.itemID)) {
            return http:BAD_REQUEST;
        }
        itemsTable.add(addPayload);
        return itemsTable.get(addPayload.itemID);
    }

    resource function put updateItem/[string itemID](@http:Payload ItemDetails updatePayload)
                                    returns ItemDetails|error|http:NotFound {

        // DB Query part here
        // ballerina string to int code
        int itemIDInt = check int:fromString(itemID);
        if (!itemsTable.hasKey(itemIDInt)) {
            return http:NOT_FOUND;
        }
        ItemDetails _ = itemsTable.remove(itemIDInt);
        itemsTable.add(updatePayload);
        //ItemFollows[] dataFromDB = from var i in itemFolowsTable where i.userID == itemTobeFollowed.userID select i;
        return itemsTable.get(updatePayload.itemID);
    }

    resource function delete deleteItem/[string itemID]()
                                    returns http:NoContent|error|http:NotFound {

        // DB Query part here
        // ballerina string to int code
        int itemIDInt = check int:fromString(itemID);
        if (!itemsTable.hasKey(itemIDInt)) {
            return http:NOT_FOUND;
        }
        ItemDetails _ = itemsTable.remove(itemIDInt);
        return http:NO_CONTENT;
    }

    resource function patch updateItemV2(@http:Payload ItemDetails updatePayload)
                                    returns ItemDetails|error|http:NotFound {

        if (itemsTable.hasKey(updatePayload.itemID)) {
            ItemDetails itemToBeUpdated = itemsTable.get(updatePayload.itemID);
            if (itemToBeUpdated.itemName != updatePayload.itemName) {
                itemToBeUpdated.itemName = updatePayload.itemName;
            }
            if (itemToBeUpdated.itemDescription != updatePayload.itemDescription) {
                itemToBeUpdated.itemDescription = updatePayload.itemDescription;
            }
            if (itemToBeUpdated.itemImage != updatePayload.itemImage) {
                itemToBeUpdated.itemImage = updatePayload.itemImage;
            }
            if (itemToBeUpdated.itemPrice != updatePayload.itemPrice) {
                itemToBeUpdated.itemPrice = updatePayload.itemPrice;
                notifyAllItemSubscribers(updatePayload.itemID, updatePayload.itemPrice);
            }
            if (itemToBeUpdated.stockDetails != updatePayload.stockDetails) {
                itemToBeUpdated.stockDetails = updatePayload.stockDetails;
            }
            ItemDetails _ = itemsTable.remove(updatePayload.itemID);
            itemsTable.add(itemToBeUpdated);
        } else {
            return http:NOT_FOUND;
        }
        return itemsTable.get(updatePayload.itemID);
    }
}

function notifyAllItemSubscribers(int itemID, float itemPrice) {

    do {
	    sendemail:Client sendemailEp = check new ();
        string[] usersList = from var item in itemFolowsTable
        join var user in userEmailRecords
                on item.userID equals user.userID
        where item.itemID == itemID
        select item.userID;
        string subject = "Item Price Update";
        string body = "The price of the item with ID " + itemID.toString() + " has been updated to " + itemPrice.toString();
        foreach var user in usersList {
            string email = userEmailRecords.get(user).emailAddress;
            string|error sendEmailResult = sendemailEp->sendEmail(email, subject, body);
            if sendEmailResult is error {
                log:printError("Error sending email to " + email, sendEmailResult);
            }
        }
    } on fail var e {
    	log:printError("Error creating mail client", e);
    }
}