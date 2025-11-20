// avayaDashboard.js
import { LightningElement, api } from 'lwc';

export default class AvayaDashboard extends LightningElement {
    @api height = '600';
    @api width = '100%';
    
    // The URL of the Avaya dashboard
    dashboardUrl = 'https://172.20.15.69/';
    
    get frameStyle() {
        return `height:${this.height}px; width:${this.width};`;
    }
    
    renderedCallback() {
        // You might need to handle authentication or other initialization here
        console.log('Avaya Dashboard component rendered');
    }
    
    handleFrameLoad() {
        console.log('Dashboard iframe loaded');
    }
    
    handleFrameError() {
        console.error('Error loading dashboard iframe');
    }
}