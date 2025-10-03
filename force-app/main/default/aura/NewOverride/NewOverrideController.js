({
    doInit: function(component, event, helper) {
        //alert('Hebat5 : '+component.get('v.sObjectName')+'|'+component.get('v.recordId'));
        var UserId =  $A.get("$SObjectType.CurrentUser.Id");
        const sPageURL = decodeURIComponent(window.location.search.substring(1)); 
        const searchParams = new URLSearchParams(sPageURL);
        const params = [...searchParams.entries()].reduce((a, [k, v]) => (a[k] = v, a), {});
        //console.log(params);
        //alert('Dapat = ' + params.recordTypeId);
        
        const sObjectName = component.get('v.sObjectName');
        const namaFlow = "Scr_Editor_" + sObjectName;
        const recordTypeId = params.recordTypeId;

        // Secara otomatis tampilkan modal saat komponen di-load
        $A.createComponent(
            "lightning:flow", 
            {
                "aura:id" : "flowData",
                "onstatuschange" : component.getReference("c.closeModalOnFinish")
            },
            function(modalBody, status, errorMessage) {
                if (status === "SUCCESS") {
                    const flow = modalBody;
                    
                    var inputVariables;
                    if(recordTypeId){
                        inputVariables= [
                            {
                                name: "recordTypeId",
                                type: "String",
                                value: recordTypeId // Pass the record ID to the Flow
                            }
                        ];                        
                    }
                    
                    // Start the Flow
                    flow.startFlow(namaFlow, inputVariables);

                    const modalPromise = component.find('overlayLib').showCustomModal({
                            header: "Buat "+ sObjectName + " Baru",
                            body: modalBody,
                            showCloseButton: true, // Tombol close
                            cssClass: "slds-modal_medium", // Ukuran modal
                            closeCallback: function(){
                                const recordId = component.get('v.recordId');

                                if(recordId){
                                    const urlEvent = $A.get("e.force:navigateToSObject");
                                    urlEvent.setParams({
                                        "recordId": recordId,
                                        "isredirect": "true"
                                    });
                                    urlEvent.fire();

                                }else{
                                    const navService = component.find("navService");
                                    if(UserId == "005F9000009eQvJIAU"){
                                        navService.navigate({
                                            type: 'standard__navItemPage',
                                            attributes: {
                                                apiName: 'Lead_PBF'
                                            },
                                            state: {
                                                //filterName: 'AllAccounts' // Opsional: Filter List View
                                            }
                                        });
                                    }else{
                                        navService.navigate({
                                        type: 'standard__objectPage',
                                        attributes: {
                                            objectApiName: sObjectName,
                                            actionName: 'list'
                                        },
                                        state: {
                                            //filterName: 'AllAccounts' // Opsional: Filter List View
                                        }
                                    });
                                    }
                                }
                                
                            }
                    });
                    component.set("v.modalPromise", modalPromise);

                }else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },

    closeModalOnFinish : function(component, event, helper) {
        const status = event.getParam('status');
        if (status === 'FINISHED' || status === 'CANCELED') {

            // Get the output variables and iterate over them
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                // Pass the values to the component's attributes
                if(outputVar.name === "recordId") {
                    component.set("v.recordId", outputVar.value);
                }
            }

            //close Modal
            component.get('v.modalPromise').then(
                function (modal) {
                    modal.close();
                }
            );

        }
    }
    
})