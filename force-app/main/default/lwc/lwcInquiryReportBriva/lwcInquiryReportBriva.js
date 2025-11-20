import getReportBriva from '@salesforce/apex/SCC_InquiryBriva.getReportBriva';
import { api, LightningElement, track } from 'lwc';

export default class LwcInquiryReportBriva extends LightningElement {

    @api recordId;
    @track data;
    @track hasError = false;
    sizeData = '50';
    @track currentPage = 1;
    @track isLastPage = false;
    @track totalPages = 1;
    @track showSearchResults = false;
    @track isLoading = false;
    @track corpCode ;
    @track tanggalAwal ;
    @track tanggalAkhir ;


    //handle request

    getIndex(index){
        return ((this.currentPage - 1) * parseInt(this.sizeData, 10)) + index + 1;
    }

    get isPrevDisabled() {
        return this.currentPage <= 1;
    }

    get optionSize() {
        return [
            {label : "50" , value : "50"},
            {label : "100" , value : "100"},
            {label : "200" , value : "200"}
        ]
    }

    handleSearchError(errorMessage){
        this.hasError = true;
        this.errorMessage = errorMessage;
        console.log("has error");
        
        //this.isLoading = false;
    }

    clearErrorFields(){
        this.hasError = false;
        this.errorMessage = '';
    }

    handleSizeData(event){
        console.log('value size : ' , event.detail.value)
        this.sizeData = event.detail.value
    }

    handleCorpCode(event){
        let nomorBriva = event.target.value;
       
        const isValid = /^[0-9]{15,18}$/.test(nomorBriva);

        if (!isValid) {
            event.target.setCustomValidity("Nomor Briva harus 15-18 digit angka");
            //this.isBrivaValid = false;
        } else {
            event.target.setCustomValidity("");
            //this.isBrivaValid = true;
            this.corpCode = nomorBriva;
        }
        event.target.reportValidity();
    }


    handleTrxDateAwal(event){
        this.tanggalAwal = this.formatedDate(event.target.value);
        console.log('tanggal awal format :' , this.tanggalAwal);
        
    }

    handleTrxDateAkhir(event){
        this.tanggalAkhir = this.formatedDate(event.target.value)
        console.log("tanggal akhir format :",this.tanggalAkhir);
        
    }


    handleSearch(){
        this.fetchReportData();
        console.log("cari report");
        
    }

    handleNext(){
        if(!this.isLastPage){
            this.currentPage++;
            this.fetchReportData();
        }
    }

    handlePrev(){
        if(this.currentPage > 1){
            this.currentPage--;
            this.fetchReportData();
        }
    }

    fetchReportData(){
        this.isLoading = true;
        this.showSearchResults = false;


        const reqReport = {
            corpCode : this.corpCode.substring(0,5) ,
            custCode : this.corpCode.substring(5),
            tanggalAwal: this.tanggalAwal, 
            tanggalAkhir : this.tanggalAkhir,
            uniqcode : "ALL",
            pageNumber : this.currentPage,
            rowsPerPage : this.sizeData
        }

        const menu = 'Drone';
        getReportBriva({
            reqReportBriva : reqReport,
            menu : menu,
            recordId : this.recordId
        })
        .then((result) => {
            if(result){

                this.isLoading = false;
                this.clearErrorFields();

                console.log('Response result Token received:', result);
                console.log('Response result Token received:', JSON.stringify(result));

                const responseData = result.data

                console.log('response data : ', responseData);
                console.log('response data : ', JSON.stringify(responseData)); 

                if(responseData){
                    this.showSearchResults = true;
                    this.data = responseData.map((item, index) => {
                        return {
                            ...item,
                            No: this.getIndex(index)
                        }
                    });

                    const getPages = responseData[0].pageShow;
                    const pagesTotal = getPages.split('/')[1].trim();
                    this.totalPages = parseInt(pagesTotal, 10);
                    console.log('jumlah halaman : ' , this.totalPages);
                    this.isLastPage = this.currentPage >= this.totalPages;

                } else{
                    const {responseCode, responseMessage} = result;
                    if(responseCode == '500' ){
                        this.handleSearchError('Terjadi Error ' + responseCode + " : " + responseMessage);
                    } else {
                        this.handleSearchError("No Data Found" );
                    }
                }
                
            }else{
                this.showSearchResults = false;
                this.handleSearchError("Error occured while fetching data")
            }
        })
        .catch((err) => {
            console.log("error : " , err.message)
            this.handleSearchError(err.message)
        })
        .finally(()=> {
            this.isLoading = false;
            console.log('Loading state set to false.');
            console.log('show result data : ' , this.showSearchResults  ) ;
        })

    }


    formatedDate(date){
        return date + " " + "00:00:00";
    }
}