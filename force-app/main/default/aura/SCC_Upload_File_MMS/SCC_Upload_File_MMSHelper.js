({
    getFileFormat:function(filename){
    
        const filenameSplit = filename.split('.');
        const format = filename.length > 1 ? filenameSplit[filenameSplit.length - 1 ] : 'no format';

        return format;
    },

    iconFormatFile: function (format){
        const availFormat  =  {
            // "docx" : "word",
            // "ppt" : "ppt",
            // "xlsx" : "excel",
            // "zip" : "zip",
            "png" : "image",
            "jpg" : "image",
            "jpeg" : "image",
            "pdf" : "pdf"
        }

        const formatIcon = availFormat[format];

        return formatIcon;
    },

    checkSize: function(component, event, file) {
        return new Promise((resolve, reject) => {
            var action = component.get("c.fileSize");
            action.setParams({
                "contentId": file.documentId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var size = response.getReturnValue();
                    resolve({
                        file: file,
                        size: size,
                        isValid: size <= 2 * 1024 * 1024 // 2MB limit
                    });
                } else {
                    reject(new Error("Failed to get file size"));
                }
            });
            $A.enqueueAction(action);
        });
    },

    deleteFiles: function(component, files) {
        return Promise.all(files.map(file => {
            var action = component.get("c.deleteFile");
            action.setParams({ "contentDocumentId": file.documentId });
            return new Promise((resolve, reject) => {
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        resolve();
                    } else {
                        reject(new Error("Failed to delete file"));
                    }
                });
                $A.enqueueAction(action);
            });
        }));
    },

    deleteFile: function(component, documentId) {
        return new Promise((resolve, reject) => {
            var action = component.get("c.deleteFile");
            action.setParams({
                "contentDocumentId": documentId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("success delete");
                    resolve();
                } else {
                    console.error('Error deleting file');
                    reject(new Error("Failed to delete file"));
                }
            });
            $A.enqueueAction(action);
        });
    },

    uploadFilesToAPI: function(component, files) {
        var recordId = component.get("v.recordId");
        var uploadPromises = files.map(file => this.uploadSingleFile(component, file.contentVersionId, recordId,file.documentId));
        
        return Promise.all(uploadPromises)
            .then(results => {
                return $A.getCallback(() => {
                    console.log("All files uploaded. Responses:", results);
                    return { success: true, responses: results };
                })();
            })
            .catch(error => {
                return $A.getCallback(() => {
                    console.error("Error uploading files:", error);
                    throw error;
                })();
            });
    },

    uploadSingleFile: function(component, contentVersionId, recordId, contentDocumentId) {
        return new Promise((resolve, reject) => {
            var action = component.get("c.uploadFile");
            action.setParams({
                "contentVersionId": contentVersionId,
                "recordId": recordId
            });

            action.setCallback(this, function(response) {
                $A.getCallback(() => {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        try {
                            var responseBody = response.getReturnValue();
                            var parsedResponse = JSON.parse(responseBody);
                            console.log('Parsed response:', parsedResponse);

                            if (parsedResponse.responseCode === "200") {
                                var filePath = parsedResponse.responseData.data;
                                var fileName = this.getOriginalFileName(filePath);
                                var format = this.getFileFormat(fileName);
                                var iconFormat = this.iconFormatFile(format);

                                console.log("filename", fileName);
                                console.log("format", format);
                                console.log("icon format", iconFormat);

                                var successBody = {
                                    fileName: fileName,
                                    isUpload: true,
                                    message: parsedResponse.responseMessage,
                                    icon: "doctype:" + iconFormat
                                };

                                resolve(successBody);
                            } else {
                                var failBody = {
                                    fileName: "Unknown file",
                                    isUpload: false,
                                    message: parsedResponse.responseMessage || "Upload failed",
                                    contentDocumentId: contentDocumentId,
                                    icon: "doctype:unknown"
                                };

                                resolve(failBody);
                            }
                        } catch (error) {
                            console.error("Error parsing response:", error);
                            console.error("Raw response:", responseBody);
                            
                            reject(new Error("Failed to parse server response: " + error.message));
                        }
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        console.error("Error uploading single file", errors);
                        if (errors && errors[0] && errors[0].message) {
                            reject(new Error("Error uploading to API: " + errors[0].message));
                        } else {
                            reject(new Error("Unknown error"));
                        }
                    }
                })();
            });

            $A.enqueueAction(action);
        });
    },

    handleUpload: function (component, event, uploadedFiles) {
        const successUpload = Array.isArray(uploadedFiles.files)
            ? uploadedFiles.files
            : [uploadedFiles.files];
    
        if (successUpload.length === 1) {
            component.set("v.isLoading", true);

            var checkSizePromises = successUpload.map((file) => {
                return this.checkSize(component, event, file);
            });

            Promise.all(checkSizePromises)
                .then((results) => {
                    var validFiles = results.filter((result) => result.isValid);
                    var invalidFiles = results.filter((result) => !result.isValid);

                    var uploadPromises = validFiles.map((result) =>
                        this.uploadSingleFile(
                            component,
                            result.file.contentVersionId,
                            component.get("v.recordId"),
                            result.file.documentId
                        )
                    );

                    var invalidFileResponses = invalidFiles.map((result) => ({
                        fileName: result.file.name,
                        isUpload: false,
                        message: "File melebihi 2MB",
                        contentDocumentId: result.file.documentId,
                        icon: "doctype:folder"
                    }));

                    return Promise.all(uploadPromises).then((uploadResults) => {
                        return uploadResults.concat(invalidFileResponses);
                    });
                })
                .then((results) => {
                    var listResponse = results;
                    component.set("v.files", listResponse);
                    
                    const deletePromises = listResponse
                        .filter(file => !file.isUpload)
                        .map(file => this.deleteFile(component, file.contentDocumentId));
                    
                    return Promise.all(deletePromises).then(() => listResponse);
                })
                .then((listResponse) => {
                    const successfulUploads = listResponse.filter(file => file.isUpload);
                    if (successfulUploads.length > 0) {
                        this.showToast(
                            "Success", 
                            "File berhasil diupload", 
                            "success"
                        );
                    }
                })
                .catch((error) => {
                    console.error("Error processing files:", error);
                    let errorMessage = "An error occurred while processing files";
                    if (error.message) {
                        errorMessage += ": " + error.message;
                    }
                    this.showToast("Error", errorMessage, "error");
                })
                .finally(() => {
                    component.set("v.isLoading", false);
                });
        } else {
            const deletePromises = successUpload.map(file => 
                this.deleteFile(component, file.documentId)
            );

            Promise.all(deletePromises)
                .then(() => {
                    this.showToast(
                        "Error",
                        "Hanya bisa upload 1 file",
                        "error"
                    );
                })
                .catch((error) => {
                    console.error("Error deleting files:", error);
                    this.showToast(
                        "Error",
                        "Error cleaning up multiple file upload",
                        "error"
                    );
                });

            component.set("v.files", []);
        }
    },

    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },

    getOriginalFileName: function(filepath) {
        const parts = filepath.split('_');
        
        if (parts.length >= 4) {
            parts.splice(0, 2); 
            parts.pop();       
            return parts.join('_');
        }   
        return filepath.split('/').pop();
    },
})