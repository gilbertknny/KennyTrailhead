({
    
    // checkSize: function(component, event, file) {
    //     return new Promise((resolve, reject) => {
    //         var action = component.get("c.fileSize");
    //         action.setParams({
    //             "contentId": file.documentId
    //         });
    //         action.setCallback(this, function(response) {
    //             var state = response.getState();
    //             if (state === "SUCCESS") {
    //                 resolve(response.getReturnValue());
    //             } else {
    //                 reject(new Error("Failed to get file size"));
    //             }
    //         });
    //         $A.enqueueAction(action);
    //     });
    // },

//     Pdf 

// docx 

// ppt 

// xlsx 

// png 

// jpg 

// jpeg 

// zip

    getFileFormat:function(filename){
    
        const filenameSplit = filename.split('.');
        const format = filename.length > 1 ? filenameSplit[filenameSplit.length - 1 ] : 'no format';

        return format;
    },

    iconFormatFile: function (format){
        const availFormat  =  {
            "docx" : "word",
            "ppt" : "ppt",
            "xlsx" : "excel",
            "png" : "image",
            "jpg" : "image",
            "jpeg" : "image",
            "zip" : "zip",
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
                        isValid: size <= 4 * 1024 * 1024 // 4MB limit
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

    deleteFile: function(component, documentId){
        var action = component.get("c.deleteFile");
        action.setParams(
            {
                "contentDocumentId": documentId
            }
        );
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success delete")
            } else {
                console.error('"Error');
            }
        });
        $A.enqueueAction(action);

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

    uploadSingleFile: function(component, contentVersionId, recordId,contentDocumentId) {
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
                        var responseBody = response.getReturnValue();
                        var parsedResponse = JSON.parse(responseBody);

                        if(Array.isArray(parsedResponse) && parsedResponse.length > 0){
                            var file = parsedResponse[0];
                            console.log('file response :' , file);
                            var fileName = file.FileName;
                            var isUpload = file.IsUploaded;
                            var message = file.Message;
                            var format = this.getFileFormat(fileName);
                            var iconFormat = this.iconFormatFile(format);

                            console.log("filename" , fileName);
                            console.log("isupload" , isUpload);
                            console.log("message" , message);
                            console.log('format' , format);
                            console.log('icon format', iconFormat)
                            

                            if(isUpload){
                                var scssBody = {
                                    fileName,
                                    isUpload,
                                    message, 
                                    icon  : "doctype:"+iconFormat
                                }

                                resolve(scssBody);
                            }

                            if(!isUpload){
                                var failBody = {
                                    fileName,
                                    isUpload,
                                    message,
                                    contentDocumentId,
                                    icon : "doctype:"+iconFormat
                                }

                                resolve(failBody);
                            }
                        }

                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        console.log("Error uploading single file" ,  errors);
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
        const maxSizeFile = 4 * 1024 * 1024;
        const successUpload = Array.isArray(uploadedFiles.files)
          ? uploadedFiles.files
          : [uploadedFiles.files];
    
        if (successUpload.length > 0 && successUpload.length <= 3) {
            component.set("v.isLoading", true);

          console.log(uploadedFiles);
    
          var checkSizePromises = successUpload.map((file) => {
            return this.checkSize(component, event, file);
          });

          console.log('promise file' , JSON.stringify(checkSizePromises));
    
          Promise.all(checkSizePromises)
            .then((results) => {
              console.log("File size check results:", JSON.stringify(results));
    
              var validFiles = results.filter((result) => result.isValid);
              var invalidFiles = results.filter((result) => !result.isValid);

              console.log('valid files',JSON.stringify(validFiles));
              console.log('invalid files',JSON.stringify(invalidFiles));
    
              var uploadPromises = validFiles.map((result) =>
                this.uploadSingleFile(
                  component,
                  result.file.contentVersionId,
                  component.get("v.recordId"),
                  result.file.documentId
                )
              );
    
              console.log('upload on api : ' , JSON.stringify(uploadPromises))

              var invalidFileResponses = invalidFiles.map((result) => ({
                fileName: result.file.name,
                isUpload: false,
                message: "File size exceeds 4MB limit",
                contentDocumentId: result.file.documentId,
                icon : "doctype:folder"
              }));

              console.log('invalid upload : ' , JSON.stringify(invalidFileResponses));
    
              return Promise.all(uploadPromises).then((uploadResults) => {
                return uploadResults.concat(invalidFileResponses);
              });
            })
            .then((results) => {
              var listResponse = results;
              component.set("v.files", listResponse);
              for (var i = 0; i < listResponse.length; i++) {
                if (!listResponse[i].isUpload) {
                  console.log("document id :", listResponse[i].contentDocumentId);
                  console.log("isUpload :", listResponse[i].isUpload);
                  console.log("message:", listResponse[i].message);
                  // We're not deleting files that exceed the size limit anymore
                  this.deleteFile(component, listResponse[i].contentDocumentId);
                }
              }

              component.set("v.isLoading", false);
              

            })
            .catch((error) => {
                console.error("Error processing files: 1", error);
                
                if (error instanceof Error) {
                    console.error("Error name:", error.name);
                    console.error("Error message:", error.message);
                    console.error("Error stack:", error.stack);
                }

                if (error.body) {
                    console.error("Error body:", JSON.stringify(error.body));
                }

                let errorMessage = "An error occurred while processing files";
                if (error.message) {
                    errorMessage += ": " + error.message;
                }
                this.showToast("Error", errorMessage, "error");

                component.set("v.isLoading", false);
            });
        } else {
          this.showToast(
            "Error",
            "Cannot upload more than 3 files at once",
            "error"
          );
        }
      },


    // handleUpload: function(component, event, uploadedFiles) {
    //     const maxSizeFile = 4 * 1024 * 1024;
    //     const successUpload = uploadedFiles.files;
    //     var uploadFileSize = 0;
        
    //     if (successUpload.length > 0 && successUpload.length <= 3) {

    //         console.log(uploadedFiles);

    //         var checkSizepromises = successUpload.map(file => {
    //             return this.checkSize(component, event, file)
    //         });

    //         console.log("promise" , checkSizepromises);
            
    //         Promise.all(checkSizepromises)
    //             .then(sizes => {
    //                 console.log('list size : ' , sizes);
    //                 uploadFileSize = sizes.reduce((total, size) => total + size, 0);
    //                 console.log('size : ', uploadFileSize);
    //                 component.set('v.totalSize', uploadFileSize);
                    
    //                 if (uploadFileSize > maxSizeFile) {
    //                     this.showToast("Error", "Total file melebihi 4MB", "error");
    //                     return this.deleteFiles(component, successUpload);
    //                 } else {
    //                     //this.showToast("Success", "Files uploaded successfully", "success");
    //                     return this.uploadFilesToAPI(component, successUpload);
    //                 }
    //             })
    //             .then((result) => {
    //                 if (result && result.success) {
    //                     var listResponse = result.responses;
    //                     component.set("v.files", listResponse);
    //                     for(var i = 0 ; i < listResponse.length ; i++){
    //                         if(!listResponse[i].isUpload){
    //                             console.log('document id : ' , listResponse[i].contentDocumentId );
    //                             console.log('isUpload : ' , listResponse[i].isUpload);
    //                             console.log('message :' , listResponse[i].message );
    //                             this.deleteFile(component,listResponse[i].contentDocumentId);
    //                             //tambahkan method untuk delete dari sf
    //                         }
    //                     }

    //                     //this.showToast("Success", "Files uploaded successfully", "success");
    //                 }
    //             })
    //             .catch(error => {
    //                 console.error("Error processing files:", error);
    //                 this.showToast("Error", "An error occurred while processing files", "error");
    //             });
    //     } else {
    //         this.showToast("Error", 'Tidak boleh mengupload lebih dari 3 file secara bersamaan' , "error");
    //         return this.deleteFiles(component, successUpload);
    //     }
    // },
    
    
    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },

})