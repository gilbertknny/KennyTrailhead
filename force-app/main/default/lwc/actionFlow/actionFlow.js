import { LightningElement, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";

export default class ActionFlow extends LightningElement {
    recId='woke';
    @api objectApiName;

    @wire(CurrentPageReference) pageRef;

    get pageRefString() {
        return JSON.stringify(this.pageRef);
    }
}