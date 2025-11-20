/** 
    LWC Name    : lwcBankingPortofolioComponent.js
    Created Date       : 11 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   11/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   ??/09/2024   Suherbing                         Adjust for Blockir component
    1.0   23/09/2024   Rakeyan Nuramria                  Add API Functionality
    1.0   27/09/2024   Rakeyan Nuramria                  [FROM SIT] Bug fixing no data in detail data
    1.0   30/09/2024   Rakeyan Nuramria                  [FROM SIT] Bug fixing not showing data & empty string
    1.0   01/10/2024   Rakeyan Nuramria                  [FROM SIT] Bug fixing detail data shown even no data
    1.0   01/10/2024   Rakeyan Nuramria                  Adjust logic for blokir kartu
    1.0   02/10/2024   Rakeyan Nuramria                  Adjust logic for return message from blokir kartu to refresh data
    1.0   07/10/2024   Rakeyan Nuramria                  Adjust logic to send card status to the blokir component
    1.0   07/10/2024   Rakeyan Nuramria                  Adjust logic if the button data kartu being clicked when the data kartu is being open(bug because when click again it show undefined/change data)

**/

import { LightningElement, api, track, wire } from 'lwc';
import getCardDetailDebit from '@salesforce/apex/SCC_CaseBRICare.getCardDetailDebit';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CASE_OBJECT from '@salesforce/schema/Case';
import SCC_TERMINAL_ID_FIELD from '@salesforce/schema/Case.SCC_Terminal_ID__c';

const FIELDS = ['User.EmployeeNumber'];

export default class LwcDataKartuBankingComponent extends LightningElement {
    @track employeeNumber;

    @api recordId
    @api forBlokir;
    @api isCloseHidden;
    @api caseId;
    @api noKartu;
    @api noRekening;
    isModalOpen = false;
    @track showHistoryKartu = false;
    @track selectedNomorKartu;
    @track terminalId;
    isBlokir = 'BL'
    @track detailData = [];
    @track historyData = [];
    @track cardInfo = {
        cardNumber: '5221-2912-9189-3821',
        cardType: 'CHIP',
        accountName: 'Andi Hafiidh',
        issueDate: '2023-07-01',
        expiredDate: '07/28',
        tanggalAktivitas: '2023-06-20',
        cardStatus: 'AA',
        ketStatusKartu: 'Kartu Aktif',
        lastDateMaintenance: '2023-07-01',
        lastMaintenanceUser: '123123',
        historyUpdateKartu: 'History Update Kartu'
    };
    @track isLoading = false;
    @track hasError= false;
    @track hasErrorTst= false;
    @track errorMessage;
    @track errorMsg;
    @track errorMsgTst;
    @track detailDataHasValues = false;
    @track cardStatus;

    // Getter to determine if the button should be disabled
    get isBlokirDisabled() {
        return this.cardInfo?.cardStatus !== 'BL'; // Disable button if cardStatus is not 'BL'
    }
    
    //MAIN LOGIC

    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    loadUser({ error, data }) {
        if (data) {
            this.employeeNumber = data.fields.EmployeeNumber.value;
            console.log('employee number : ', this.employeeNumber);
        } else if (error) {
            console.error('Error retrieving Employee Number:', error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [SCC_TERMINAL_ID_FIELD] })
    wiredCase({ error, data }) {
        if (data) {
            this.terminalId = data.fields.SCC_Terminal_ID__c.value;
            console.log('Terminal ID:', this.terminalId);
        } else if (error) {
            console.error('Error retrieving case data:', error);
        }
    }

    connectedCallback(){
        console.log('nomor kartu from parent : ', this.noKartu);
        console.log('forBlokir from portofolio : ', this.forBlokir);

        this.selectedNomorKartu = this.noKartu;
        this.fetchCardDetailDebit();

    }

    renderedCallback(){

    }

    // async fetchCardDetailDebit(){
    //     console.log('Function fetchCardDetailDebit called..');
    
    //     const requestPayload = {
    //         cardNo:this.selectedNomorKartu,
    //         idcs: this.caseId
    //     };
    
    //     console.log('Request card detail Payload:', JSON.stringify(requestPayload));
    
    //     getCardDetailDebit(requestPayload)
    //         .then(result => {
    //             console.log('Response card detail received:', result);
    //             console.log('response.data : ', JSON.stringify(response.data));
    
    //             // if (result && result.length > 0) {
    //             if (result) {
    //                 const response = Array.isArray(result) ? result[0] : result;
    
    //                 if (response) {
    //                     // Always set simpananData to an array
    //                     this.detailData = Array.isArray(result) ? result : [response];

    //                     this.errorMsg = '';
    //                     this.hasError = false;
    //                 } else {
    //                     this.handleSearchError(response.responseMessage || 'Data tidak ditemukan');
    //                 }
    //             } else { 
    //                 this.handleSearchError('Data tidak ditemukan');
    //             }
    //         })
    //         .catch(error => {
    //             console.error('Error occurred during search:', error.message);
    //             // this.handleSearchError('Data tidak ditemukan');
    //         })
    //         // .finally(() => {
    //         //     this.isLoadingBanking = false;
    //         //     console.log('Loading state set to false.');
    //         // });
    // }

    fetchCardDetailDebit() {

        this.isLoading = true;

        console.log('Function fetchCardDetailDebit called..');
    
        const requestPayload = {
            cardNo: this.selectedNomorKartu,
            idcs: this.caseId
        };
    
        console.log('Request card detail Payload:', JSON.stringify(requestPayload));
    
        getCardDetailDebit(requestPayload)
            .then(result => {
                console.log('Response card detail received:', result);
    
                // Safely navigate to the data object
                const response = result?.chmGraphql?.inquiryCardData?.data;
                if (response) {
                    // Set detailData to the historyAccount response data
                    // this.detailData = response;
                    this.detailData = {
                        ...response,
                        cardNo: response.cardNo || 'N/A',
                        type: response.type || 'N/A',
                        name: response.name || 'N/A',
                        issueDate: response.issueDate || 'N/A',
                        expDate: response.expDate || 'N/A',
                        activeDate: response.activeDate || 'N/A',
                        cardStatus: response.cardStatus || 'N/A',
                        statusDesc: response.statusDesc || 'N/A',
                        lastMaint: response.lastMaint || 'N/A',
                        userMaint: response.userMaint || 'N/A',
                    };

                    this.cardStatus = this.detailData.cardStatus;
                    this.detailDataHasValues = Object.keys(this.detailData).length > 0;

                    console.log('detailData : ', JSON.stringify(this.detailData));
                    // this.historyData = response.historyAccount.responseData.data.map((item, index) => ({
                    //     ...item,
                    //     index: index + 1
                    // }));
                    
                    // console.log('historyData : ', JSON.stringify(this.historyData));

                    if (response.historyAccount && response.historyAccount.responseData && response.historyAccount.responseData.data) {
                        this.historyData = response.historyAccount.responseData.data.map((item, index) => ({
                            ...item,
                            branchCode: item.branchCode || '-',
                            cardNo: item.cardNo || '-',
                            cardStatus: item.cardStatus || '-',
                            issueDate: item.issueDate || '-',
                            activeDate: item.activeDate || '-',
                            lastMaint: item.lastMaint || '-',
                            typeCode: item.typeCode || '-',
                            expDate: item.expDate || '-',
                            renewalDate: item.renewalDate || '-',
                            blockDate: item.blockDate || '-',
                            userBlock: item.userBlock || '-',
                            accNo: item.accNo || '-',
                            index: index + 1 // Optional: if you want to include index
                        }));

                        this.errorMsgTst = '';
                        this.hasErrorTst = false;
                        
                        console.log('historyData : ', JSON.stringify(this.historyData));
                    } else {
                        this.handleSearchHstError('Informasi history update kartu kosong.');
                    }
    
                    this.errorMsg = '';
                    this.hasError = false;
                } else {
                    this.handleSearchError('Tidak ada informasi data kartu.');
                    // this.detailDataHasValues = false;
                }
            })
            .catch(error => {
                console.error('Error occurred during search:', error.message);
                this.handleSearchError('Data tidak ditemukan');
            })
            .finally(() => {
                this.isLoading = false;
                console.log('Loading state set to false.');
            });
    }

    get processedDetailData() {
        return this.detailData.map((result, index) => {
            const simpananArray = result?.data?.[0]?.portofolioPerbankan?.simpanan || [];
            const demografiData = result?.data?.[0]?.demografi || {};
    
            // Log the entire result.data for debugging
            console.log('result.data:', JSON.stringify(result.data));
    
            // Process each simpanan
            const processedSimpanan = simpananArray.map(simpanan => {
                // Log the entire simpanan object
                console.log('simpanan:', JSON.stringify(simpanan));
                console.log('simpanan cardList:', JSON.stringify(simpanan.cardList));
    
                // const cardList = simpanan.cardlink || []; // Verify if 'cardlink' is correct
                // console.log('cardList:', JSON.stringify(cardList));
    
                return {
                    ...simpanan,
                    cardList: simpanan.cardList, // Include the cardList array from the simpanan
                };
            });
    
            console.log('simpananArray : ', JSON.stringify(simpananArray));
            console.log('processedSimpanan : ', JSON.stringify(processedSimpanan));
            console.count('Processed Simpanan Data Called');
    
            return {
                ...result,
                no: index + 1,
                simpanan: processedSimpanan,
                demografi: demografiData
            };
        });
    }
    

    handleCloseDataKartu() {
        const closeEvent = new CustomEvent('close', {
            detail: { message: 'Close button clicked' }
        });
        this.handleClear();
        this.handleSearchError();
        this.dispatchEvent(closeEvent);
    }

    hendleCloseHistoryKartu(){
        this.showHistoryKartu = false;
        // this.handleClear();
        this.handleSearchTrxError();
        this.historyData = [];
    }

    handleOpenHistoryKartu(){
        this.showHistoryKartu = true;
    }

    @api handleClear() {
        // this.noKartu = '';
        // this.noRekening = '';

        // this.detailData = [];
        // this.historyData = [];
        this.isLoading = false;
        this.errorMsg = '';
        this.hasError = false;

    }

    @api updateCardDetails() {
        // Only update if the card number is different
        if (this.noKartu && this.noKartu !== this.selectedNomorKartu) {
            this.selectedNomorKartu = this.noKartu;
            this.fetchCardDetailDebit(); // Fetch new card details
        }
    }

    handleSearchError(errorMessage) {
        this.detailDataHasValues = false;
        this.errorMsg = errorMessage;
        this.detailData = [];
        this.hasError = true;
        console.log('Error Message:', errorMessage);
    }

    handleSearchHstError(errorMessage) {
        this.errorMsgTst = errorMessage;
        this.historyData = [];
        this.hasErrorTst = true;
        console.log('Error Message:', errorMessage);
    }

    //END MAIN LOGIC

    // LOGIC FOR MODAL

    handleBlokir() {
        console.log('handleBlokir called..');
        console.log('handleBlokir update');
        const blokirHandler = this.template.querySelector('c-lwc-blokir-kartu-handler');
        blokirHandler.cardNumber = this.selectedNomorKartu
        blokirHandler.terminalId = this.terminalId;
        blokirHandler.isBlokir = this.isBlokir;
        blokirHandler.showModal();
        if(blokirHandler){
            blokirHandler.handleClear();
        }
    }

    handleBlokirSuccess(event) {
        console.log('handleBlokirSuccess called..');
        const { cardNumber, newStatus, newStatusDescription } = event.detail;
        // this.cardInfo.cardStatus = newStatus;
        // this.cardInfo.ketStatusKartu = newStatusDescription;
        console.log('carNumber from BlockKartu : ', cardNumber);
        console.log('newStatus from BlockKartu : ', newStatus);
        console.log('newStatusDescription from BlockKartu : ', newStatusDescription);

        this.fetchCardDetailDebit();
    }

    handleBlokirError(event) {
        console.log('handleBlokirError called..');
        console.error('Error blocking card:', event.detail.error);
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }

    // handleConfirmationBlock() {
    //     this.isModalOpen = false;
    //     this.showToast('success', 'Data kartu anda sudah diblokir','success');
    // }

    // END LOGIC FOR MODAL

    //MISC
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }
}