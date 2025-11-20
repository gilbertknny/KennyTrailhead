({
    openFileUploadDialog: function(component, event, helper) {
        // Tidak perlu implementasi khusus karena lightning:fileUpload secara otomatis menampilkan dialog
    },

    handleUploadFinished: function(component, event, helper) {
        // Mendapatkan daftar file yang diupload
        var uploadedFiles = event.getParam("files");

        var totalSize = 0;
        uploadedFiles.forEach(function(file) {
            totalSize += file.size; 
        });

        var maxSize = 5 * 1024 * 1024; 
        if (totalSize > maxSize) {
            var toastEventError = $A.get("e.force:showToast");
            toastEventError.setParams({
                "title": "Gagal Upload",
                "message": "Total ukuran file tidak boleh lebih besar dari bumi.", 
                "type": "error"
            });
            toastEventError.fire();
            return; 
        }

        // Simpan file yang diupload ke attribute
        component.set("v.uploadedFiles", uploadedFiles);

        // Mempersiapkan data untuk dikirim ke Apex
        var lcvid = [];
        var lcdid = [];
        uploadedFiles.forEach(function(file) {
            if (file.contentVersionId) {
                lcvid.push(file.contentVersionId);
                //console.log('content version Id : ' + file.contentVersionId);
            }
            if (file.documentId) {
                lcdid.push(file.documentId);
               // console.log('content document id : ' + file.documentId);
            }
        });
        var recId = component.get("v.recordId");

        // Panggil metode Apex uploadFilesToITSM
        var action = component.get("c.uploadFiles");
        action.setParams({
            "contentVersionIds": lcvid,
            "recordId": recId
        });
        console.log("action", action);

        // Callback untuk menangani response dari Apex
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state : ',state);
            for(let i = 0 ; i < response.getReturnValue().length; i++){
                console.log(`response : ${i}` + response.getReturnValue()[i]);
            }

            console.log('length' , response.getReturnValue().length);

            if(response.getReturnValue()[0].includes('ERROR')){
                console.log('error file size');
                    var toastEventError = $A.get("e.force:showToast");
                    toastEventError.setParams({
                        "title": "Gagal Upload",
                        "message":"Total ukuran file tidak boleh lebih dari 5MB",
                        "type": "error"
                    });
                    toastEventError.fire();
            }
            if (state === "SUCCESS") {
                var apexResponse = response.getReturnValue();
                var parsedResponse = JSON.parse(apexResponse);

                console.log('res', apexResponse);
                console.log('parse' , parsedResponse);

                if (Array.isArray(parsedResponse) && parsedResponse.length > 0) {
                    console.log(parsedResponse.length);
                    parsedResponse.forEach(fileValue => {
                        var fileName = fileValue.FileName;
                        var isUpload = fileValue.IsUploaded;
                        var message = fileValue.Message;

                        console.log('filename', fileName);
                        console.log('isUpload', isUpload);
                        console.log('message', message);

                        if (isUpload) {
                            var toastEventSuccess = $A.get("e.force:showToast");
                            toastEventSuccess.setParams({
                                "title": "Berhasil Upload",
                                "message": "File '" + fileName + "' berhasil untuk diupload",
                                "type": "success"
                            });
                            toastEventSuccess.fire();
                        }

                        if (!isUpload) {
                            var toastEventError = $A.get("e.force:showToast");
                            toastEventError.setParams({
                                "title": "Gagal Upload",
                                "message": message,
                                "type": "error"
                            });
                            toastEventError.fire();
                        }
                    });
                } else {
                    console.log('Response value kosong');
                }

            } else if (state === "ERROR") {
                var errors = response.getError();
                var message = 'Unknown error'; // Pesan error default
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                var toastEventError = $A.get("e.force:showToast");
                toastEventError.setParams({
                    "title": "Error",
                    "message": message,
                    "type": "error"
                });
                toastEventError.fire();
            }
        });

        // Enqueue action untuk memprosesnya
        $A.enqueueAction(action);
    }
})