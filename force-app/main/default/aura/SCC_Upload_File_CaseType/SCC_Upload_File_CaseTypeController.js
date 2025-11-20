({

    doInit:function(component,event,helper){
        var recordId = component.get('v.recordId')
        // console.log('record id',  recordId);
        
        // helper.getTotalSize(component,'v.recordId');
        console.log('do init');
        helper.getTotalFileSize(component, recordId)
            .then((totalSize) => {
                // Set the result in an attribute or use it
                component.set("v.totalFileSize", totalSize);
                console.log("File size successfully retrieved:", totalSize);
            })
            .catch((error) => {
                // Handle errors
                component.set("v.errorMessage", error);
                console.error("Error retrieving file size:", error);
            });
        
    },

    handleUploadFinished : function(component, event, helper) {
        var files = event.getParams("files");
        helper.handleUpload(component,event,files);
    }
})