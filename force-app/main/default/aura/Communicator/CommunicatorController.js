({
    doInit: function(component, event, helper) { 
        const EXPECTED_ORIGIN = "https://crmconnectorlb.bri.co.id:8484";//"https://172.20.15.68:8484"; //"https://linpuby164.gl.avaya.com:8484"; 
        const EXPECTED_TARGET = window.location.origin; 
        let newMessageHandler = function(message) { 
            try { 
                console.log(message); 
                //let data = (message && message.data) ? JSON.parse(message.data) : undefined;                 
                let data = undefined;
                if (message && message.data && message.data.includes("AvayaEvent")) { 
                    data = JSON.parse(message.data); 
                } else { 
                    return; 
                } 
                //let data = (message && message.data &&  message.data.includes("AvayaEvent")) ? JSON.parse(message.data) : undefined; 
                if ((data.class) && (data.class === "AvayaEvent")) { 
                    console.log("%cSalesforce Received Message", "color:green", data); 
                    
                    if (message.origin !== EXPECTED_ORIGIN || data.origin  !== EXPECTED_ORIGIN || data.origin !== message.origin) { 
                        console.warn( "%cInvalid Origin","color:DarkRed", message.origin, data.origin); 
                        return; 
                    }  
                    if (message.currentTarget.location.origin !==  EXPECTED_TARGET || data.target !== EXPECTED_TARGET) { 
                        console.warn("%cInvalid Target", "color:DarkRed",   message.currentTarget.location.origin, data.target); 
                        return; 
                    } 
                    let avayaEvent = component.getEvent("avayaEvent"); 
                    avayaEvent.setParams({"payload": data }); 
                    avayaEvent.fire(); 
                    console.log("%cNew Avaya Message Aura Component Event Fired", "color:Navy", data); 
                } else { 
                    console.log("%cNot Avaya Mesasage", "color:DarkRed", data);    
                    return; 
                } 
            } catch (e){console.log(e);} 
        };
        window.addEventListener('message', newMessageHandler, false); 
    }, 
    handleAvayaEvent: function(component, event, helper) { 
        let data = event.getParam("payload");    
        let value = component.get("v.markedupText") || ""; 
        value += "<br>"+ JSON.stringify(data); 
        component.set("v.markedupText", value); 
        console.log("%cNew Avaya Message Aura Component Event Received by Handler", "color:#C00", data); 
    }
})