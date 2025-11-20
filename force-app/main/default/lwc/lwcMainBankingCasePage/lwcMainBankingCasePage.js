/** 
    LWC Name    : lwcMainBankingCasePage.js
    Created Date       : 10 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   10/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   01/10/2024   Rakeyan Nuramria                  Adjust for Blokir Kartu (BL/PL)
    release 3
    1.0   25/02/2025   Rakeyan Nuramria                  Add condition showing component based on custom permission blokir
**/

import { LightningElement, api, track, wire } from 'lwc';
import getBukaBlokirPermission from '@salesforce/customPermission/Buka_Blokir_Saldo';
import getBlokirPermission from '@salesforce/customPermission/Blokir_Saldo';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';


export default class LwcMainBankingCasePage extends LightningElement {
    @api recordId;
    @track forBlokir = '';
    isCustomerPortfolioExpanded = false;
    isCustomerSearchExpanded = false;

    @track isVisible = true;

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            const profileName = data.fields.Profile.value.fields.Name.value;
            
            // Check if the user has the "Back Office" profile
            if (profileName.includes('Back Office')) {
                // Check if neither permission is true
                if (getBukaBlokirPermission || getBlokirPermission) {
                    this.isVisible = false;
                } 
                // else {
                //     this.isVisible = true;
                // }
            } else {
                // If profile is not "Back Office", make it visible
                this.isVisible = true;
            }
        } else if (error) {
            console.error('Error loading user profile:', error);
            // Fallback to just custom permission check if profile load fails
            this.isVisible = true;
        }
    }

    connectedCallback() {
        // Check if the user has either of the permissions and set isVisible accordingly
        if (getBukaBlokirPermission || getBlokirPermission) {
            this.isVisible = false;
        } else {
            this.isVisible = true;
        }
    }


    handleAccordionSectionToggle(event) {
        this.isCustomerPortfolioExpanded = event.detail.openSections.includes('customerPortfolio');
        if (this.isCustomerPortfolioExpanded) {
            if (this.recordId) {
                console.log('recordId : ', this.recordId);
            }
            this.forBlokir = 'BL';
        }
        this.isCustomerSearchExpanded = event.detail.openSections.includes('customerSearch');
        if (this.isCustomerSearchExpanded) {
            this.forBlokir = 'PL';
        }
    }
}