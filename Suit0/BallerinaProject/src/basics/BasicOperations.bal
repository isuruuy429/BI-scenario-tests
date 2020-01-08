import ballerina/config;
import ballerina/http;
import ballerina/log;
import wso2/ftp;
import ballerina/io;

const string remoteLocation = "/home/ftp-user/in/account.json";

ftp:ClientEndpointConfig ftpConfig = {
    protocol: ftp:FTP,
    host: config:getAsString("ftp.host"),
    port: config:getAsInt("ftp.port"),
    secureSocket: {
        basicAuth: {
            username: config:getAsString("ftp.username"),
            password: config:getAsString("ftp.password")
        }
    }
};
ftp:Client ftp = new (ftpConfig);

@http:ServiceConfig {
    basePath: "company"
}

service company on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/addJsonFile"
    }

    resource function addJsonFile(http:Caller caller, http:Request request) returns error? {
        http:Response response = new ();
        json jsonPayload = check request.getJsonPayload();
        var ftpResult = ftp->put(remoteLocation, jsonPayload);

        if (ftpResult is error) {
            log:printError("Error", ftpResult);
            response.setJsonPayload({Message: "Error occurred uploading file to FTP.", Resason: ftpResult.reason()});
        } else {
            response.setJsonPayload({Message: "Employee records uploaded successfully."});
        }
        var httpResult = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/readFile/{fileName}"
    }
        resource function readFile(http:Caller caller, http:Request request, string fileName) returns error? {
        http:Response response = new ();
        var ftpResult = ftp->get("/home/ftp-user/in/" + fileName);
        if (ftpResult is io:ReadableByteChannel) {
            io:ReadableCharacterChannel? characters = new io:ReadableCharacterChannel(ftpResult, "utf-8");
            if (characters is io:ReadableCharacterChannel) {
                var output = characters.read(1000);
                if (output is json | xml | string | byte) {
                    response.setPayload(<@untained>(output));
                } else {
                    response.setJsonPayload(<@untained>({
                        Message: "Error occured in retrieving content",
                        Reason: output.reason()
                    }));
                    log:printError("Error occured in retrieving content", output);
                }
                var closeResult = characters.close();
                if (closeResult is error) {
                    log:printError("Error occurred while closing the channel", closeResult);
                }
            }
        } else {
            response.setJsonPayload({Message: "Error occured in retrieving content", Reason: ftpResult.reason()});
        }
        var httpResult = caller->respond(response);

    }

     @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/deleteFile/{fileName}"
    }

    resource function deleteFile(http:Caller caller, http:Request request, string fileName) returns error? {
        http:Response response = new ();
        var ftpResult = ftp->delete("/home/ftp-user/in/" +fileName);

        if (ftpResult is error) {
            response.setJsonPayload({Message: "Error occurred deleting file.", Resason: ftpResult.reason()});
            log:printError("Error occurred while deleting a file", ftpResult);
        }
        else {
            response.setJsonPayload({Message: "Employee records deleted successfully."});
            log:printInfo("Successfully deleted file");
        }

        var httpResult = caller->respond(response);
    }

    @http:ResourceConfig {
        path: "/createFolder/{folderName}"
    }

    resource function createFolder(http:Caller caller, http:Request request, string folderName) returns error? {
        http:Response response = new ();
        var ftpResult = ftp->mkdir("/home/in/" + folderName);

        if (ftpResult is error) {
            response.setJsonPayload({Message: "Error occurred creating folder.", Resason: ftpResult.reason()});
            log:printError("Error occurred while creating a folder", ftpResult);
        }
        else {
            response.setJsonPayload({Message: "The folder is created successfully."});
            log:printInfo("The folder is created successfully.");
        }

        var httpResult = caller->respond(response);

    }

     @http:ResourceConfig {
        path: "/removeFolder/{folderName}"
    }

    resource function removeFolder(http:Caller caller, http:Request request, string folderName) returns error? {
        http:Response response = new ();
        var ftpResult = ftp->rmdir("/home/in/" + folderName);

        if (ftpResult is error) {
            response.setJsonPayload({Message: "Error occurred deleting the folder.", Reason: ftpResult.reason()});
            log:printError("Error occurred while deleting the folder", ftpResult);
        }
        else {
            response.setJsonPayload({Message: "The folder is deleted successfully."});
            log:printInfo("The folder is deleted successfully.");
        }

        var httpResult = caller->respond(response);

    }

     @http:ResourceConfig {
        path: "/renameFile/{fileName}"
    }

    resource function renameFile(http:Caller caller, http:Request request, string fileName) returns error? {
        http:Response response = new ();
        var ftpResult = ftp->rename(remoteLocation, "/home/ftp-user/in/"+fileName);

        if (ftpResult is error) {
            response.setJsonPayload({Message: "Error occurred renaming the file.", Reason: ftpResult.reason()});
            log:printError("Error occurred while renaming the file", ftpResult);
        }
        else {
            response.setJsonPayload({Message: "The file is renamed successfully."});
            log:printInfo("The file is renamed successfully.");
        }
        var httpResult = caller->respond(response);
    }

     @http:ResourceConfig {
        path: "/retreiveFileSize"
    }

    resource function retreiveFileSize(http:Caller caller, http:Request request) returns error? {
        http:Response response = new ();
        var ftpResponse = ftp->size("/home/ftp-user/student.txt");
        if (ftpResponse is int) {
            response.setJsonPayload("File size: " + ftpResponse.toString());
        } else {
            response.setJsonPayload({Message: "Error occured in retrieving size", Reason: ftpResponse.reason()});
            log:printError("Error occured in retrieving size", ftpResponse);
        }
        var httpResult = caller->respond(response);
    }



}
