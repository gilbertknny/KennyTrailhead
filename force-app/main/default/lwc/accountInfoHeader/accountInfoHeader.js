import { LightningElement, wire, api } from 'lwc';
import DPLK from '@salesforce/label/c.DPLK';
import BRILink from '@salesforce/label/c.BRILink';
import RegularBanking from '@salesforce/label/c.Regular_Banking';
import CreditDigitalLanding from '@salesforce/label/c.Credit_Digital_Landing';
import Merchant from '@salesforce/label/c.Merchant';
import Wholesale from '@salesforce/label/c.Wholesale';
import { getRecord } from 'lightning/uiRecordApi';
import { getRecordId } from 'lightning/uiRecordApi';

const fields = ['Case.Id'];

export default class TabExample extends LightningElement {

    @api recordId;
    label = {
        DPLK,
        BRILink,
        RegularBanking,
        CreditDigitalLanding,
        Merchant,
        Wholesale
    };

   
    toggleSection() {
        const accordionSection = this.template.querySelector('lightning-accordion-section');
        accordionSection.toggle();
    }
}