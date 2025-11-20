({

    // getTotalSize: function(component,id){
    //     // var action = component.get('c.getSizeTotalFile');
    //     // action.setParams({
    //     //     'recordId' : id
    //     // });
    //     // action.setCallback(this,function(response){
    //     //     var state = response.getState();
    //     //     console.log('state', state);
    //     //     console.log('error', response.getError());
            
            
    //     //     if(state === 'SUCCESS'){
    //     //         var totalSize = response.getReturnValue();
    //     //         component.set("v.existingFileSize" , totalSize);
    //     //         console.log(totalSize);
                
    //     //     }else{
    //     //         console.log('error get total size');
    //     //     }
    //     // });
    //     // $A.enqueueAction(action);
    //     component.set('v.existingFileSize',10);
    // },

   
    getTotalFileSize: function (component, recordId) {
            return new Promise((resolve, reject) => {
                // Get the Apex method
                var action = component.get("c.getSizeTotalFile");
    
                // Set the parameters
                action.setParams({
                    recordId: recordId
                });
    
                // Set the callback for the Apex method
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        // Resolve the Promise with the result
                        var totalSize = response.getReturnValue();
                        console.log("Total file size:", totalSize);
                        resolve(totalSize);
                    } else if (state === "ERROR") {
                        // Handle errors and reject the Promise
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            console.error("Error message:", errors[0].message);
                            reject(errors[0].message);
                        } else {
                            console.error("Unknown error occurred.");
                            reject("Unknown error occurred.");
                        }
                    }
                });
    
                // Enqueue the action
                $A.enqueueAction(action);
            });
    },


    checkSize: function(component,event,file){
        return new Promise((resolve,reject) => {
            var action = component.get("c.fileSize");
            action.setParams({
                "contentId" : file.documentId
            });
            action.setCallback(this,function(response) {
                var state = response.getState();
                if(state === "SUCCESS"){
                    var size = response.getReturnValue();
                    resolve({
                        file: file,
                        size: size,
                        isValid:size <= 25 * 1024 * 1024 
                    })
                } else {
                    reject(new Error("Failed to get file size"));
                }
            });
            $A.enqueueAction(action);
        });
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

    deleteFiles: function(component, files) {
        return Promise.all(files.map(data => {
            var action = component.get("c.deleteFile");
            action.setParams({ "contentDocumentId": data.file.documentId });
            return new Promise((resolve, reject) => {
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('state all delet', state);
                    
                    if (state === "SUCCESS") {
                        resolve();
                        console.log('Success delete');
                        
                    } else {
                        reject(new Error("Failed to delete file"));
                    }
                });
                $A.enqueueAction(action);
            });
        }));
    },

    handleUpload : function(component,event,uploadedFiles) {
        const successUpload = Array.isArray(uploadedFiles.files) ? uploadedFiles.files : [uploadedFiles.files];
        var totalSize = 0;
        var maxSize = 25 * 1024 * 1024;
        var mapDataContent = [];
        var uploadedSize = component.get('v.totalFileSize');
     
        
        if(successUpload.length > 0){
            component.set("v.isLoading", true);

            console.log('size file',uploadedSize);
        

            var checkSizePromises = successUpload.map((file) => {
                return this.checkSize(component,event,file);
            });

            Promise.all(checkSizePromises)
                .then((results) => {
                    console.log('File size check result:' , JSON.stringify(results));

                    for(var i = 0; i < results.length; i++){
                        totalSize += results[i].size
                        mapDataContent.push(results[i].file.documentId);
                    }

                    console.log('Map content data :' , JSON.parse(JSON.stringify(mapDataContent)));
                    console.log('total size:' , totalSize);

                    var expectedsize = totalSize + uploadedSize;
                    console.log('expected size', expectedsize);
                    
            
                    if(expectedsize >= maxSize){
                        this.showToast('Error','Tidak boleh menambahkan file lagi total file anda sudah lebih dari 25mb',"error");
                        component.set("v.files",[]);
                        component.set("v.isLoading", false);
                        for(var i = 0; i < results.length; i++){
                            var fileDocumentId = results[i].file.documentId;
                            this.deleteFile(component,fileDocumentId)
                        }
                        return;
                    }
                    
                    if(totalSize >= maxSize){

                        this.showToast('Error','Jangan mengupload file lebih dari 25 mb',"error");
                        component.set("v.files",[]); 

                        for(var i = 0; i < results.length; i++){
                            var fileDocumentId = results[i].file.documentId;
                            this.deleteFile(component,fileDocumentId)
                        }
                      
                    } else{

                            var validFilesResponse = results.map((result) =>({
                                fileName: result.file.name,
                                message: "Success",
                                isUpload: true,
                                icon : "doctype:folder"
                            }))
                        component.set('v.files',validFilesResponse); 
                        this.refreshView();
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

    refreshView: function () {
        console.log('refresh');
        
        window.location.reload();
    },

    
})