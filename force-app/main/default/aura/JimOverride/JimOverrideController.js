({
    handleShowModal: function(component, evt, helper) {
        $A.createComponents([
                ["lightning:card",
                    {
                        "title" : "Dynamic Components"
                    }
                ],
                ["lightning:button",
                    {
                        "label":"Tutup",
                        "name" : "cancel",
                        "iconName" : "utility:success",
                        "alternativeText": "Icon that represents a successful step",
                        "variant": "success",
                        "class": "slds-m-around_small",
                        "onclick" : component.getReference("c.handleCancel")
                    }
                ]
            ],
            function(arrCompos, status, errorMessages){
                if (status === "SUCCESS") {
                    const card = arrCompos[0];
                    const btn = arrCompos[1];

                    var body = card.get("v.body");
                        body.push(btn);
                    card.set("v.body", body);

                    const modalBody = card;
                    var modalPromise = component.find('overlayLib').showCustomModal({
                        header: "Application 3 Jimmy",
                        body: modalBody,
                        showCloseButton: true,
                        cssClass: "slds-modal_medium", // Ukuran modal
                        closeCallback: function() {
                            alert('You closed the alert! = 3 ');
                        }
                    });
                    component.set("v.modalPromise", modalPromise);

                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error message: " + errorMessages[0].message);
                }
            }
        );

    },
    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        alert('cancel di panggil 9');
        component.get('v.modalPromise').then(
            function (modal) {
                modal.close();
            }
        );
    },
    handleOK : function(component, event, helper) {
        alert('OKE');
    }
})