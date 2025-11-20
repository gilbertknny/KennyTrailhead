import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavigateToRecord extends LightningElement {
    @api recordId;

    connectedCallback() {
        console.log('Redirecting to record:', this.recordId);
        console.log('Redirecting...');

        if (this.recordId) {
            setTimeout(() => {
                window.location.href = `/lightning/r/Case/${this.recordId}/view`; 
                // Ganti Opportunity dengan objek yang sesuai (misalnya Account, Case, dsb.)
            }, 500); // Delay 500ms agar Flow selesai dulu
        }
    }
}