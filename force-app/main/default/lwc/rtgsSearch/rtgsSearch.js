import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import searchRtgs from '@salesforce/apex/SCC_CaseResolution_RTGS_Ctrl.searchRtgs';
import updateCaseRemittance from '@salesforce/apex/SCC_CaseResolution_RTGS_Ctrl.updateCaseRemittance';


export default class RtgsSearch extends LightningElement {
    @api recordId; // Untuk menerima Case Id
    @track kodePembayaran = '01';
    @track idTransaksi = '';
    @track transactionData = null;
    @track dataExist = false;
    @track error;
    @track kodePembayaranOptions = [
        { label: 'Pilih Tipe ...', value: '' },
        { label: 'RTGS', value: '01' },
        { label: 'Kliring', value: '02' }
    ];

    connectedCallback() {
        // Debug: Cek recordId saat komponen diinisialisasi
        console.log('Debug - Connected Callback - Case Id:', this.recordId);
    }

    handleKodePembayaranChange(event) {
        this.kodePembayaran = event.target.value;
    }

    handleIdTransaksiChange(event) {
        this.idTransaksi = event.target.value;
    }

    async handleSearch() {
        try {
            // Reset error state
            this.error = undefined;
            this.dataExist = false;

            // Debug: Log sebelum memanggil Apex
            console.log('Debug - Calling searchRtgs Apex method');

            // Panggil Apex method searchRtgs
            const result = await searchRtgs({
                idTransaction: this.idTransaksi,
                kd: this.kodePembayaran,
                csId: this.recordId
            });

            // Debug: Log hasil dari Apex
            console.log('Debug - searchRtgs result:', JSON.stringify(result));

            if (result && result.response && result.response.responseCode == '00') {
                // Debug: Log struktur data yang diterima
                console.log('Debug - Response data structure:', JSON.stringify(result.response));
                console.log('Debug - Transaction data:', JSON.stringify(result.response.data));
                
                this.transactionData = result.response.data;
                this.dataExist = true;
                
                // Debug: Log reference transaction
                console.log('Debug - Reference Transaction:', this.transactionData.referenceTransaction);
                
                // Update Case dengan reference transaction dan billing number
                this.updateCaseWithRemittance(this.recordId, this.transactionData.referenceTransaction, this.idTransaksi);
            } else {
                // Debug: Log saat data tidak ditemukan
                console.warn('Debug - No data found in response:', JSON.stringify(result));
                
                this.error = result.response.responseMessage;
                this.dataExist = false;
                
                // Jika data tidak ditemukan, tetap simpan billing number
                this.updateCaseWithRemittance(this.recordId, null, this.idTransaksi);
                this.showToast('Info', 'Data tidak ditemukan. Billing Number telah disimpan.', 'info');
            }
        } catch (error) {
            // Debug: Log error detail saat pencarian gagal
            console.error('Debug - Search error:', JSON.stringify(error));
            console.error('Debug - Error stack:', error.stack);
            console.error('Debug - Error body:', error.body ? JSON.stringify(error.body) : 'No error body');
            
            this.error = error.body?.message || 'An error occurred while searching for the transaction.';
            this.dataExist = false;
            
            // Jika terjadi error pada pencarian, tetap simpan billing number
            // this.updateCaseWithRemittance(this.recordId, null, this.idTransaksi);
            // this.showToast('Info', 'Terjadi kesalahan saat pencarian. Billing Number telah disimpan.', 'info');
        }
    }

    updateCaseWithRemittance(caseId, remittanceNo, billingNumber) {
        // Debug: Log sebelum update case
        console.log('Debug - Updating case with remittance number:', remittanceNo);
        console.log('Debug - Updating case with billing number:', billingNumber);
        
        updateCaseRemittance({
            caseId: caseId,
            remittanceNo: remittanceNo,
            billingNumber: billingNumber
        })
        .then(() => {
            // Debug: Log setelah update sukses
            console.log('Debug - Case update successful');
            
            // Tampilkan toast message sukses hanya jika remittanceNo ada
            if (remittanceNo) {
                this.showToast('Success', 'Case has been updated with remittance number and billing number', 'success');
            }
            
            // Refresh record data
            getRecordNotifyChange([{recordId: this.recordId}]);
        })
        .catch(updateError => {
            // Debug: Log error saat update
            console.error('Debug - Case update error:', JSON.stringify(updateError));
            console.error('Debug - Error details:', updateError.body ? JSON.stringify(updateError.body) : updateError.message);
            
            // Tampilkan error jika update gagal
            this.showToast('Error', 'Failed to update case: ' + updateError.body?.message, 'error');
        });
    }

    handleClose() {
        this.dataExist = false;
        this.transactionData = null;
    }

    get isSearchDisabled() {
        return !this.kodePembayaran || !this.idTransaksi;
    }

    // Method untuk menampilkan toast message
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}