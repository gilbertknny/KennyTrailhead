import { LightningElement, api } from 'lwc';

export default class JimSection extends LightningElement {
    @api title;
    @api iconName = "utility:switch";
    cl = null;

    clickHandler(e){
        let obj = e.currentTarget.closest(".slds-section"); //find parent
        
        if(obj){
            this.cl = obj.classList;
            //alert(JSON.stringify(cl));
            
            if(this.cl.contains("slds-is-open")){
                //alert("Ada : " + JSON.stringify(cl));
                this.cl.remove("slds-is-open");
                this.iconName = "utility:chevronright";
            }else{
                //alert("Gak : " + JSON.stringify(cl));
                this.cl.add("slds-is-open");
                this.iconName = "utility:switch";
            }
        }
    }
}