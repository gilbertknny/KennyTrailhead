import { LightningElement } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseFeedToastMessage extends LightningElement {
    subscription = {};

    connectedCallback() {
        this.registerPlatformEventListener();
    }

    registerPlatformEventListener() {
        // Define the channel name and event filter
        const channelName = '/event/CaseFeedPostCreatedUpdated__e';
        const messageCallback = (response) => {
            this.handleEvent(response);
        };

        // Subscribe to the platform event channel
        subscribe(channelName, -1, messageCallback).then(response => {
            this.subscription = response;
        }).catch(error => {
            this.handleError(error);
        });
    }

    handleEvent(response) {
        // Handle the event data
        const toastEvent = new ShowToastEvent({
            title: 'Success!',
            message: response.data.payload.SCC_Message__c,
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
    }

    handleError(error) {
        // Handle subscription errors
        console.error('Error subscribing to platform event:', JSON.stringify(error));
    }

    disconnectedCallback() {
        // Unsubscribe from the platform event channel
        unsubscribe(this.subscription, response => {
            console.log('Unsubscribed from platform event channel');
        });
    }
}