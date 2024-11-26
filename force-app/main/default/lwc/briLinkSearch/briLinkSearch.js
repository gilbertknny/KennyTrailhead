import { LightningElement, track } from 'lwc';
import makeCallout from '@salesforce/apex/SCC_BriLinkCallout.makeCallout';


export default class BriLinkSearch extends LightningElement {
    @track tid = '';
    @track mid = '';
    @track data;
    @track listdata;
    @track dataexist=false;
    @track error;
    @track showDetailSection = false;

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
        this.tidNUmber = '';
        this.mid = '';
        //this.data = undefined;
    }

    handleSearch() {
        this.disableMidField = false;
        this.disableTidField = false;
        makeCallout({ 
            tid: this.tid,
            mid: this.mid
        })
        .then(result => {
            if (result) {
           
              if(result.errorMsg=='')
               {
                this.listdata=result.BRILINK_PROFILE;
                this.dataexist=true;
                this.error=undefined;
               
                }
                else
                {
                    this.dataexist=false;
                    this.error=result.errorMsg;
                  
                }
             /*
                if (result.includes('Error:')) {
                    this.error = result; // Set error message
                    this.data = undefined; // Clear data
                    this.showDetailSection = false;
                } else if (result.includes('No data found')) {
                    this.error = 'Data tidak ditemukan.'; // Set error message
                    this.data = undefined; // Clear data
                    this.showDetailSection = false;
                } else {
                    let data;
                    // Assuming telepon is the last field in the array
                    const startIndex = result.indexOf('[BRILINK_PROFILE='); // Adjust as per your response format
                    const endIndex = result.indexOf(')]');
                    if (startIndex !== -1 && endIndex !== -1) {
                        const dataString = result.substring(startIndex + 18, endIndex);
                        const dataArray = dataString.split(',');
                        data = {};
                        dataArray.forEach(item => {
                            const [key, value] = item.split('=');
                            let trimmedValue = value.trim();
                            // Check if the value ends with ']'
                            if (trimmedValue.endsWith(']')) {
                                trimmedValue = trimmedValue.slice(0, -1); // Remove the last character ']'
                            }
                            // Check if the value is 'null' or 'undefined'
                            data[key.trim()] = (trimmedValue === 'null' || trimmedValue === 'undefined') ? null : trimmedValue;
                        });
                    }
                    
                    if (data) {
                        this.data = data;
                        this.error = undefined; // Clear error
                    } else {
                        this.error = 'Data tidak ditemukan.';
                        this.data = undefined; // Clear data
                        this.showDetailSection = false;
                    }
                }*/
            } else {
                this.error = 'Tidak ada tanggapan yang diterima.';
                this.dataexist=false;
             
             //   this.data = undefined; // Clear data
             this.listdata=undefined;
            
            }
        })
        .catch(error => {
            this.error = error;
            this.dataexist=false;
           
        //    this.data = undefined; // Clear data
            this.listdata=undefined;
           
        });
      //  this.tid = '';
      //  this.mid = '';
    }
    
    showDetail(event) {
        console.log(event.target.dataset.id);
        this.showDetailSection = true;
        this.listdata.forEach(listdata=>{if(listdata.UniqueId==event.target.dataset.id)listdata.showSection=true; else listdata.showSection=false  });

       
        console.log(listdata[0].showSection);
       
    }
    
   
}