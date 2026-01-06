import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

const COLUMNS = [
    { label: 'Registration Number', fieldName: 'registration_number', type: 'text', initialWidth: 240 },
    { label: 'Registration Date', fieldName: 'registration_date', type: 'date-local' },
    { label: 'Policy Number', fieldName: 'policy_number', type: 'text', initialWidth: 220 },
    { label: 'Insured Name', fieldName: 'insured_name', type: 'text', initialWidth: 150, wrapText: true },
    { label: 'BSN', fieldName: 'bsn_name', type: 'text', initialWidth: 80 },
    { 
        label: 'Claim Amount', 
        fieldName: 'amount', 
        type: 'currency', 
        typeAttributes: { currencyCode: { fieldName: 'currency' } }, 
        initialWidth: 150
    },
    { label: 'Status', fieldName: 'status', type: 'text' }
];

export default class GlobalClaimHistory extends OmniscriptBaseMixin(LightningElement) {
    @track columns = COLUMNS;
    @track processedData = [];
    @track hasData = false;
    _tabledata;

    @api
    get tabledata() {
        return this._tabledata;
    }

    set tabledata(value) {
        this._tabledata = value;
        this.formatData(value);
    }

    connectedCallback() {
        if (this._tabledata) {
            this.formatData(this._tabledata);
        }
    }

    formatData(rawValue) {
        console.log('DEBUG: [ClaimTable] Raw Data diterima:', JSON.stringify(rawValue));
        
        let targetFieldData = null;
        let finalArray = [];

        // --- TAHAP 1: Navigasi ke field SFAWT914__c (Claim Data) ---
        // Cek apakah input adalah Array Acc
        if (Array.isArray(rawValue) && rawValue.length > 0) {
            let firstItem = rawValue[0];
            if (firstItem && firstItem.SFAWT914__c) {
                targetFieldData = firstItem.SFAWT914__c;
            } else {
                console.warn('DEBUG: Field SFAWT914__c tidak ditemukan di index 0');
            }
        } 
        // Fallback: Jika input sudah berupa object tunggal (bukan array Acc)
        else if (rawValue && rawValue.SFAWT914__c) {
            targetFieldData = rawValue.SFAWT914__c;
        }
        else {
            targetFieldData = rawValue;
        }

        // --- TAHAP 2: Parsing JSON String ---
        let parsedObj = null;
        if (targetFieldData) {
            try {
                if (typeof targetFieldData === 'string') {
                    parsedObj = JSON.parse(targetFieldData);
                } else {
                    parsedObj = JSON.parse(JSON.stringify(targetFieldData));
                }
            } catch (error) {
                console.error('DEBUG: Error parsing claim JSON:', error);
            }
        }

        // --- TAHAP 3: Ambil Array .data ---
        // Struktur JSON: { "data": [ ...array claim... ] }
        if (parsedObj && Array.isArray(parsedObj.data)) {
            finalArray = parsedObj.data;
        } else if (Array.isArray(parsedObj)) {
            finalArray = parsedObj;
        }

        console.log('DEBUG: [ClaimTable] Total Claim Rows:', finalArray.length);

        this.processedData = finalArray;
        this.hasData = finalArray.length > 0;
    }
}