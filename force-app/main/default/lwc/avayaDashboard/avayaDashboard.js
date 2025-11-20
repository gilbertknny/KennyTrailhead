// avayaDashboard.js
import { LightningElement, api } from 'lwc';
import AVAYA_DASHBOARD_URL from '@salesforce/label/c.AvayaDashboardUrl';

export default class AvayaDashboard extends LightningElement {
    @api height = '600';
    @api width = '100%';
    
    // The URL of the Avaya dashboard
    // dashboardUrl = 'https://172.20.15.69/';
    dashboardUrl = AVAYA_DASHBOARD_URL;

    get frameStyle() {
        return `height:${this.height}px; width:${this.width};`;
    }
    
    renderedCallback() {
        // You might need to handle authentication or other initialization here
        console.log('Avaya Dashboard component rendered, ' + this.dashboardUrl);
    }
    
    handleFrameLoad() {
        console.log('Dashboard iframe loaded');
    }
    
    handleFrameError() {
        console.error('Error loading dashboard iframe');
    }
}