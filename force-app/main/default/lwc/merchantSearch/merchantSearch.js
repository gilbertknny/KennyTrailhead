import { LightningElement, track } from 'lwc';
import makeCallout from '@salesforce/apex/SCC_MerchantCallout.makeCallout';
import getTransactionHistory from '@salesforce/apex/SCC_MerchantCallout.getTransactionHistory';
import getDetailTransaction from '@salesforce/apex/SCC_MerchantCallout.getDetailTransaction';



export default class MerchantSearch extends LightningElement {
    @track tid = '';
    @track mid = '';
    @track data;
    @track listdata;
    @track dataexist=false;
    @track error;
    @track error1;
    @track showDetailSection = false;
    @track parsedData;
    columnsInqueryTableData;
    @track midOrMpan = '';
    @track tidOrStoreId = '';
    @track trxDate = '';
    @track showresult = false;
    @track responseData = [];
    selectedData = null;
    @track parsedData1;
    @track parsedSettleDate;
    @track parsedPaymentDate;

  //  get isHandleSearchDisabled() {
  //     return !(this.tid || this.mid);
   // }

    get isHandleSearch1Disabled() {
        return !(this.midOrMpan && this.tidOrStoreId && this.trxDate);
    }

    handleTidChange(event) {
        this.tid = event.target.value;
        this.mid = '';
        this.toggleFields('tidNUmber');
       
        if (!this.tid) {
            this.clearInputFields();
        }
    }

    handleMidChange(event) {
        this.mid = event.target.value;
        this.tid = '';
        this.toggleFields('mid');
        if (!this.mid) {
            this.clearInputFields();
        }
    }
    toggleFields(inputField) {
        if (inputField === 'tidNUmber') {
            this.disableMidField = !!this.tid;
        } else if (inputField === 'mid') {
            this.disableTidField = !!this.mid;
        } 
    }
    clearInputFields() {
        this.tid='';//NUmber = '';
        this.mid = '';
       // this.disableMidField = false;
       // this.disableTidField = false;
       // this.data = null;
       // this.error1 = '';
    }

    clearSearchResults1() {
        this.data = null;
        this.error1 = '';
        this.showDetailSection=false;
        this.showresult = false;
        this.parsedData = [];
        this.error = '';
    }

    handleSearch() {
        this.disableMidField = false;
        this.disableTidField = false;
        this.clearSearchResults1();//Surya 15 July 2024
        makeCallout({
            tid: this.tid,
            mid: this.mid
        })
        .then(result => {
    
            if (result) {
                
              if(result.errorMessage=='')
                {
                 this.listdata=result.MERCHANT_PROFILE;
                 this.dataexist=true;
                 }
                 else
                 {
                     this.error1=result.errorMessage;
                     this.dataexist=false;
                 }
             /*   if (result.includes('Error:') || result.includes('No data found')) {
                    this.error1 = result; // Set error message
                    this.data = null; // Clear data
                } else {
                    try {
                        // Extracting the data from custom format
                        const startIndex = result.indexOf('MERCHANT_PROFILE=[');
                        const endIndex = result.indexOf(']');
                        const dataString = result.substring(startIndex + 52, endIndex);
    
                        // Using regular expression to match key-value pairs
                        const keyValueRegex = /(\w+)=((?:[^,=]+,?)+)(?=, \w+=|$)/g;
                        const data = {};
                        let match;
    
                        while ((match = keyValueRegex.exec(dataString)) !== null) {
                            const key = match[1].trim();
                            const value = match[2].trim();
                            data[key] = value;
                        }
    
                        if (Object.keys(data).length === 0) {
                            this.error1 = 'Data tidak ditemukan'; // Set error message if data is empty
                            this.data = null; // Clear data
                        } else {
                            this.data = data;
                            this.showresult = true;
                            this.error1 = null; // Clear error
                        }
                    } catch (error) {
                        this.error1 = 'Error extracting data from response';
                        this.data = null; // Clear data
                    }
                }*/
            } else {
                this.error1 = 'No response received';
                this.listdata = undefined // Clear data
                this.dataexist=false;
            }
    
            // Check if data is null or empty and display error message
            if (!this.listdata) {
                this.dataexist=false;
              //  this.error1 = 'Data tidak ditemukan';
            }
        })
        .catch(error => {
            this.error1 = 'Unknown error';
            this.dataexist=false;
            this.listdata = undefined; // Clear data
        });
    }
    
    
    
    showDetail(event) {
        //this.showDetailSection = true;
        this.showDetailSection = true;
        this.listdata.forEach(listdata=>{if(listdata.alamat_merchant==event.target.dataset.id)listdata.showSection=true; else listdata.showSection=false  });

    }
   

    handleTextChange(event) {
        this.midOrMpan = event.target.value;
        if (!this.midOrMpan) {
            this.clearSearchResults1()
        }
    }
    handleText1Change(event) {
        this.tidOrStoreId = event.target.value;
        if (!this.tidOrStoreId) {
            this.clearSearchResults1()
        }
    }

    handleEndDateChange(event) {
        this.trxDate = event.target.value;
        if (!this.trxDate) {
            this.clearSearchResults1()
        }
    }

    handleSearch1() {

        getTransactionHistory({ midOrMpan: this.midOrMpan, tidOrStoreId: this.tidOrStoreId, trxDate: this.trxDate })
            .then((result) => {
                if (result && result.data) {
                    this.parsedData = result.data;
                    this.error = undefined;
                } else {
                    this.error = 'Data tidak ditemukan';
                    this.parsedData = undefined;
                }
            })
            .catch((error) => {
                this.error = 'Error fetching transaction history';
                this.parsedData = undefined;
            });
        //    event.stopPropagation(); 
    }

    get hasParsedData() {
        return this.parsedData && this.parsedData.length > 0;
    }


    handleLihatClick(event) {
        const selectedItem = event.currentTarget.dataset.id;
    
        if (!this.parsedData || this.parsedData.length === 0) {
            this.error = 'Transaction history data not available';
            return;
        }
    
        const selectedTransaction = this.parsedData.find(item => item.appCodeReffNum === selectedItem);
    
        if (selectedTransaction) {
            getDetailTransaction({
                midOrMpan: selectedTransaction.midOrMpan,
                tidOrStoreId: selectedTransaction.tidOrStoreId,
                trxDate: selectedTransaction.trxDate,
                trxTime: selectedTransaction.trxTime,
                appCodeOrReffNum: selectedTransaction.appCodeReffNum
            })
            .then(result => {
                console.log('result' ,result);
                this.parsedData1 = result;
              
                // Reset error if detail transaction is fetched successfully
                this.error = null;
                // Handle the result accordingly
            })
            .catch(error => {
                this.error = 'Error fetching detail transaction';
                console.error('Error fetching detail transaction:', error);
                // Handle the error accordingly
            });
        } else {
            // Handle the scenario where the selected transaction is not found
        }
    }
    
    
  
}