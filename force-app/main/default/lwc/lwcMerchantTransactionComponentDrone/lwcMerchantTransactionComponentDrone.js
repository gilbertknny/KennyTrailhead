import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMerchantTrx from '@salesforce/apex/SCC_CaseBRICare.getMerchantTrx';
import updateCase from '@salesforce/apex/SCC_DroneEDC.updateCase';
import queryCurrentPermissionSet from '@salesforce/apex/SCC_CaseResolution_UI.queryCurrentPermissionSet';


export default class LwcMerchantTransactionComponentDrone extends LightningElement {
    @api caseid;
    @api mid;
    @api tid;
    @track isLoadingData = false;
    @track isLoadingDetailData = false;
    @track isLoadingSaveData = false;
    @track isBOIssuer = false;
    @track transactionDate = this.getTodayDate();
    @track hasParsedData = true;
    @track parsedData1 = true;
    @track showSearchResults = false;
    @track transactionData = [];
    @track detailTrxData = [];
    @track showDetailSection = false;
    @track reffNumber;
    @track trxTime;
    @track remark;

    generateDummyData() {
        return [
            {
                trxDate: '2024-09-01',
                trxTime: '10:15 AM',
                midOrMpan: '123456789',
                tidOrStoreId: '987654321',
                appCodeReffNum: 'REF123456',
                jenisTrx: 'Pembayaran',
                trxAmount: '150000',
                mti: '0200',
                merchantName: 'Toko ABC',
            },
            {
                trxDate: '2024-09-02',
                trxTime: '11:45 AM',
                midOrMpan: '123456780',
                tidOrStoreId: '987654320',
                appCodeReffNum: 'REF123457',
                jenisTrx: 'Penarikan',
                trxAmount: '50000',
                mti: '0200',
                merchantName: 'Toko XYZ',
            },
            {
                trxDate: '2024-09-03',
                trxTime: '02:30 PM',
                midOrMpan: '123456781',
                tidOrStoreId: '987654319',
                appCodeReffNum: 'REF123458',
                jenisTrx: 'Transfer',
                trxAmount: '200000',
                mti: '0200',
                merchantName: 'Toko DEF',
            },
            {
                trxDate: '2024-09-04',
                trxTime: '04:00 PM',
                midOrMpan: '123456782',
                tidOrStoreId: '987654318',
                appCodeReffNum: 'REF123459',
                jenisTrx: 'Pembayaran',
                trxAmount: '75000',
                mti: '0200',
                merchantName: 'Toko GHI',
            },
            {
                trxDate: '2024-09-05',
                trxTime: '09:00 AM',
                midOrMpan: '123456783',
                tidOrStoreId: '987654317',
                appCodeReffNum: 'REF123460',
                jenisTrx: 'Pembelian',
                trxAmount: '300000',
                mti: '0200',
                merchantName: 'Toko JKL',
            }
        ];
    }

    getTodayDate() {
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0');
        const dd = String(today.getDate()).padStart(2, '0');
        return `${yyyy}-${mm}-${dd}`;
    }

    handleTransactionDateChange(event) {
        this.transactionDate = event.target.value;
        this.validateDateRange();
    }

    validateDateRange() {
        const today = this.getTodayDate();
        
        if (this.transactionDate > today) {
            this.showToast('Error', 'Tanggal Awal tidak boleh melebihi hari ini.', 'error', '','');
            this.transactionDate = today;
        }
    }

    connectedCallback() {
        console.log('tid from search Merchant : ', this.tid);
        console.log('mid from search Merchant : ', this.mid);
        console.log('case id from search merchant : ', this.caseid);
        this.getUserPermission();
    }

    getUserPermission(){
        queryCurrentPermissionSet({})
        .then(result => {
            if(result.includes('SCC_BO_NFT_ISSUER')){
                this.isBOIssuer = true;
            }
            console.log('result user permission' , result); 
        })
        .catch(error => {
            console.error('error' + error.message);
        })
        .finally(() => {
            console.log('end get permission');
        })
    }

    fetchMerchantTransaction(){
        console.log('function fetchMerchantTransaction called..');
        this.isLoadingData = true;
    
        const requestPayload = {
            tidOrStoreId: this.tid,
            midOrMpan: this.mid,
            trxDate: this.transactionDate
            // idPangkalan: this.idPangkalan,
        };
        const idcs = this.recordId
    
        console.log('Request Merchant Trx payload:', JSON.stringify(requestPayload));
    
        getMerchantTrx({ cdh: requestPayload, idcs: idcs })
        .then(result => {
            console.log('Response result Merchant Trx received:', result);
            console.log('Response result Merchant Trx received:', JSON.stringify(result));
    
            if (result) {
                const responseTrx = result?.data;
                console.log('responseTrx ', responseTrx);
                this.errorMsg = '';
                this.hasError = false;
                // this.isLoading = false;
    
                if (responseTrx && responseTrx.length > 0) {
                    this.transactionData = responseTrx.map(item => ({
                        ...item,
                        trxAmount: this.formatNumber(item.trxAmount)
                    }));

                    this.showSearchResults=true;
                    
                    console.log('Formatted responseTrx Data:', JSON.stringify(this.transactionData));
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            } else {
                this.handleSearchError('Data tidak ditemukan');
            }
        })
        .catch(error => {
            console.error('Error occurred during search Merchant Trx:', error.message);
            this.handleSearchError('Data tidak ditemukan');
        })
        .finally(() => {
            this.isLoadingData = false;
            console.log('Loading state set to false.');
        });
    }

    fetchMerchantDetailTransaction(){
        console.log('function fetchMerchantDetailTransaction called..');
        this.isLoadingDetailData = true;
    
        const requestPayload = {
            tidOrStoreId: this.tid,
            midOrMpan: this.mid,
            trxDate: this.transactionDate,
            trxTime: this.trxTime,
            appCodeOrReffNum: this.reffNumber
            // idPangkalan: this.idPangkalan,
        };
        const idcs = this.recordId
    
        console.log('Request Detail Merchant Trx payload:', JSON.stringify(requestPayload));
    
        getMerchantTrx({ cdh: requestPayload, idcs: idcs })
        .then(result => {
            console.log('Response result Detail Merchant Trx received:', result);
            console.log('Response result Detail Merchant Trx received:', JSON.stringify(result));
    
            if (result) {
                const responseDetailTrx = result?.data;
                console.log('responseTrx ', responseDetailTrx);
                this.errorMsg = '';
                this.hasError = false;
                // this.isLoading = false;
    
                if (responseDetailTrx && responseDetailTrx.length > 0) {
                    this.detailTrxData = responseDetailTrx.map(item => ({
                        ...item,
                        trxDate: item.trxDate || 'N/A',
                        trxTime: item.trxTime || 'N/A',
                        noKartuCpan: item.noKartuCpan || 'N/A',
                        midOrMpan: item.midOrMpan || 'N/A',
                        tidOrStoreId: item.tidOrStoreId || 'N/A',
                        merchantName: item.merchantName || 'N/A',
                        appCodeReffNum: item.appCodeReffNum || 'N/A',
                        batchNo: item.batchNo || 'N/A',
                        jenisTrx: item.jenisTrx || 'N/A',
                        trxAmount: this.formatNumber(item.trxAmount) || 'N/A',
                        mdr: item.mdr || 'N/A',
                        channelID: item.channelID || 'N/A',
                        proccode: item.proccode || 'N/A',
                        namaFitur: item.namaFitur || 'N/A',
                        localCrossBorder: item.localCrossBorder || 'N/A',
                        onUsNotOnUs: item.onUsNotOnUs || 'N/A',
                        cardType: item.cardType || 'N/A',
                        rc: item.rc || 'N/A',
                        status: item.status || 'N/A',
                        trxStatus: item.trxStatus || 'N/A',
                        trxType: item.trxType || 'N/A',
                        mti: item.mti || 'N/A',
                        traceNum: item.traceNum || 'N/A',
                        mcc: item.mcc || 'N/A',
                        location: item.location || 'N/A',
                        acqBank: item.acqBank || 'N/A',
                        posEntryMode: item.posEntryMode || 'N/A',
                        settleAmount: this.formatNumber(item.settleAmount) || 'N/A',
                        settleDate: item.settleDate || 'N/A',
                        paymentDate: item.paymentDate || 'N/A',
                        noRekMerchant: item.noRekMerchant || 'N/A',
                        paymentRemark: item.paymentRemark || 'N/A',
                        switchs: item.switchs || 'N/A'

                    }));

                    this.showDetailSection=true;
                    
                    console.log('Formatted Detail responseDetailTrx Data:', JSON.stringify(this.detailTrxData));
                } else {
                    this.handleSearchError('Data Detail tidak ditemukan');
                }
            } else {
                this.handleSearchError('Data Detail tidak ditemukan');
            }
        })
        .catch(error => {
            console.error('Error occurred during search Detail Merchant Trx:', error.message);
            this.handleSearchError('Data Detail tidak ditemukan');
        })
        .finally(() => {
            this.isLoadingDetailData = false;
            console.log('Loading state set to false.');
        });
    }

    saveDataRemark(){
        console.log('click save data remark');
        this.isLoadingSaveData = true
        
        this.remark = this.detailTrxData.map(item => 
                        '\n' +
                        'MID : ' + item.midOrMpan + '\n' +
                        'TID : ' + item.tidOrStoreId + '\n' +
                        'TRX Date : ' + item.trxDate + '\n' +
                        'App Code : ' + item.appCodeReffNum + '\n' +
                        'Status Transaksi : ' + item.status + '\n' +
                        'Transaction Time : ' + item.trxTime + '\n' +
                        'Nomor Kartu : ' + item.noKartuCpan + '\n' +
                        'Settle Date : ' + item.settleDate + '\n' +
                        'Payment Remark : ' + item.paymentRemark
                      ).join('\n\n');   

        updateCase({caseId: this.caseid , rmk : this.remark})
        .then(result => {
            console.log('result updates : ' , result);
            console.log('result drone remark update : ' , result.SCC_Drone_Remark_Update__c);

            if(result != null){
                this.dispatchEvent(new CustomEvent('caseupdated', {
                    detail: { data: result },
                    bubbles : true,
                    composed : true

                }));
            }
        })
        .catch(error => {
            console.error('Error Ketika mengupdate remark', error.message);
            this.handleSearchError('Gagal mengupdate remark');
        })
        .finally(() => {
            this.isLoadingSaveData = false;
            //this.refreshPage();
            console.log('Loading state set to false.');
        })
                      
    }

    refreshPage() {
        window.location.reload();
    }


    handleSearch(){
        this.fetchMerchantTransaction();
    }

    showDetail(event) {

        console.log('showDetail clicked..');
    
        // Get the MID from the button's data-id attribute
        const appCodeReffNum = event.target.dataset.id;
        const trxTime = event.target.dataset.trxtime;

        this.reffNumber = appCodeReffNum;
        this.trxTime = trxTime;
        
        // Find the specific data item by TID
        // const selectedData = this.transactionData.find(item => item.appCodeReffNum === appCodeReffNum);
        
        // if (selectedData) {
        //     // Set showSection for each data item
        //     this.transactionData.forEach(data => {
        //         data.showSection = data.appCodeReffNum === appCodeReffNum; // Show the selected section
        //     });
            
        //     this.showDetailSection = true; // Show the detail section
            
        //     console.log('Detail data to show:', JSON.stringify(selectedData));
        // } else {
        //     console.log('No data found for the provided appCodeReffNum.');
        //     this.showDetailSection = false; // Hide detail section if no data found
        // }

        //testing
        this.fetchMerchantDetailTransaction();
    }

    handleCloseComponent(){

        const closeEvent = new CustomEvent('close', {
            detail: { message: 'Close button clicked' }
        });
        // this.handleClear();
        this.clearInputFields();
        this.clearSearchResults();
        this.dispatchEvent(closeEvent);

        // Optionally, if want to hide all detail sections
        // this.data.forEach(item => item.showSection = false);
    }

    clearSearchResults() {
        this.transactionData = null;
        this.errorMessage = '';
        this.showSearchResults = false;
        this.showDetailSection=false;
        this.errorMsg = '';
        this.hasError = false;
    }

    clearInputFields() {
        this.transactionData = [];
        this.tid='';
        this.mid = '';
        this.errorMessage = '';
        this.errorMsg = '';
        this.hasError = false;
        this.showDetailSection=false;
        this.showSearchResults = false;
    }
    

    handleCloseDetail(event){

        this.showDetailSection = false;
        this.detailTrxData = [];

        // const appCodeReffNum = event.target.dataset.id;

        // const selectedData = this.transactionData.find(item => item.appCodeReffNum === appCodeReffNum);
        // if (selectedData) {
        //     selectedData.showSection = false; // Hide the detail section
        // }

        // Optionally, if want to hide all detail sections
        // this.data.forEach(item => item.showSection = false);
    }

    handleSearchError(errorMessage) {
        this.hasError = true;
        this.errorMsg = errorMessage;
        this.isLoadingData = false;
        this.isLoadingDetailData = false;
        console.log('Error Message:', errorMessage);
    }
    
    showToast(title, message, variant, recordId = null, objectApiName = null) {
        // Check if both recordId and objectApiName are provided for generating a link
        if (recordId && objectApiName) {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    objectApiName: objectApiName,
                    actionName: 'view',
                },
            }).then((url) => {
                const event = new ShowToastEvent({
                    title: title,
                    message: message + '{0}',
                    // message: message + ' <a href="' + url + '" target="_blank">Klik disini untuk melihat data</a>',
                    // message: message + '. Tekan Ctrl + Klik untuk membuka tab baru.',
                    variant: variant,
                    messageData: [
                        {
                            url: url,
                            label: 'Klik disini untuk melihat data.',
                        }
                    ],
                    duration: 5000
                });
                this.dispatchEvent(event);
                // // Open the link in a new tab after the toast is shown
                // setTimeout(() => {
                //     window.open(url, '_blank');
                // }, 5000); // Delay to give the user time to click the toast link
            }).catch((error) => {
                console.error('Error generating URL:', error);
            });
        } else {
            // Just show a basic toast without a link
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                duration:5000,
            });
            this.dispatchEvent(event);
        }
    }

    formatNumber(numberString) {
        // Parse the input string to a float
        const parsedNumber = parseFloat(numberString);
        if (isNaN(parsedNumber)) return '0';
    
        // Convert to string with two decimal places
        const fixedNumber = parsedNumber.toFixed(2);
        
        // Split into integer and decimal parts
        const [integerPart, decimalPart] = fixedNumber.split('.');
    
        // Format the integer part with dots as thousands separators
        const formattedIntegerPart = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    
        // If decimal part is zero, return just the integer part
        if (decimalPart === '00') {
            return formattedIntegerPart;
        }
    
        // Return formatted currency string with comma for the decimal part
        return `${formattedIntegerPart},${decimalPart}`;
    }
}