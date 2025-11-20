({
    helperMethod : function() {

    },
    parseErrorMsg: function(errors){
        console.log("errors",errors);
        var msg = '';
        if (errors[0] ) {
            for(var i=0;i<errors.length;i++){
                if(errors[i].message){
                    msg = msg+'\n'+errors[i].message;
                }
                else if(Object.keys(errors[i].fieldErrors).length>0){
                    console.log('fieldErrors',errors[i].fieldErrors);
                    msg = msg+'\n'+JSON.stringify(errors[i].fieldErrors);
                    msg = this.parseFieldErrors(msg);
                }
                else if(errors[i].pageErrors.length>0){
                    console.log('pageErrors',errors[i].pageErrors);
                    for(var j=0;j<errors[i].pageErrors.length;j++){
                        console.log('message',errors[i].pageErrors[j].message);
                        msg = msg+'\n'+errors[i].pageErrors[j].message;
                    }
                }
            }
            var toastEvent3 = $A.get("e.force:showToast");
            toastEvent3.setParams({
                "title": "Error",
                "message": msg,
                "type" : "error"
            });
            toastEvent3.fire();
        }
    },
    parseFieldErrors: function(msg){
        //msg = '[{"SCC_Drone_Remark_Update__c":[{"statusCode":"STRING_TOO_LONG","message":"Drone Remark Update: data value too large: uwu"}, {"SCC_Drone_Remark_Update__c":[{"statusCode":"STRING_TOO_LONG","message":"2 Drone Remark Update: data value too large: uwu"}]';                    
        const regex = new RegExp('"message":"([^"]+)"', 'g');
        const regexLimit = new RegExp('(.+) Update: data value too large: ');
        var listErr = [];
        var match;
        while((match = regex.exec(msg)) !== null){
            var errMsg = match[1];
            var match2;
            if((match2 = regexLimit.exec(errMsg)) !== null){
                listErr.push(match2[1] + ' melebihi limit karakter maksimum');
            }else if(match2 == null){
                listErr.push(errMsg);
            }
        }
        if(listErr.length > 0){
            console.log('listerr');
            console.log(listErr);
            msg = listErr.join(", ");
        }
        return msg;
    }
})