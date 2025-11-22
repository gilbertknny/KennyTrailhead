import { LightningElement, api } from 'lwc';

export default class RedirectToUrl extends LightningElement {
    @api url;

    connectedCallback() {
        if (this.url) {
            window.location.replace(this.url);
        }
    }
}