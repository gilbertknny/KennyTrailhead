import { LightningElement, api, track } from 'lwc';
import getCalloutPhoneNo from '@salesforce/apex/SSC_FetchCustomerFinancialInformation.getCalloutPhoneNo';
import fetchDataFromAPI from '@salesforce/apex/SSC_FetchCustomerFinancialInformation.fetchDataFromAPI';

export default class CustomerFinancialInfo extends LightningElement {
    @api recordId;
    @track cifno;
    @track caseMobilePhoneNo;
    @track calloutPhoneNo;
    @track infos;
    @track newinfos = {};
    @track errMsg;
    @track showError;

    connectedCallback() {
        getCalloutPhoneNo({ accountid: this.recordId }).then(result => {
            this.calloutPhoneNo = result;
            if (this.calloutPhoneNo == null) {
                this.showError = true;
                this.errMsg = 'Missing phone number to make an API call';
            } else {
                fetchDataFromAPI({ phoneNumber: this.calloutPhoneNo, accountId: this.recordId }).then(result => {
                    this.infos = result;
                    let newsimpanan = [];
                    let newpinjaman = [];
                    let newinvestasi = [];
                    let newcardlink = [];
                    for (let indexout = 0; indexout < this.infos.length; indexout++) {

                        let elements = this.infos[indexout];

                        for (let index = 0; index < elements.portofolioPerbankan.pinjaman.length; index++) {
                            let pinjamanElement = {};
                            let element = elements.portofolioPerbankan.pinjaman[index];

                            pinjamanElement.rownum = index + 1;

                            pinjamanElement.accountNumber = element.accountNumber;

                            pinjamanElement.product = element.product;

                            newpinjaman.push(pinjamanElement);
                        }
                        for (let i = 0; i < elements.portofolioPerbankan.simpanan.length; i++) {
                            let simpananElement = {};
                            let ielement = elements.portofolioPerbankan.simpanan[i];
                            simpananElement.accountNumber = ielement.accountNumber;
                            simpananElement.product = ielement.product;
                            simpananElement.rownum = i + 1;
                            if (ielement.status == '1') {
                                simpananElement.status = 'Aktif';
                            } else {
                                simpananElement.status = 'Tidak Aktif';
                            }

                            newsimpanan.push(simpananElement);

                        }
                        for (let k = 0; k < elements.portofolioPerbankan.investasi.length; k++) {
                            let investasiElement = {};
                            let kelement = elements.portofolioPerbankan.investasi[k];
                            investasiElement.accountNumber = kelement.accountNumber;
                            investasiElement.product = kelement.product;
                            investasiElement.rownum = k + 1;
                            if (kelement.status == '1') {
                                investasiElement.status = 'Aktif';
                            } else {
                                investasiElement.status = 'Tidak Aktif';
                            }
                            newinvestasi.push(investasiElement);
                        }
                        for (let j = 0; j < elements.portofolioPerbankan.cardlink.length; j++) {
                            let cardlinkElement = {};
                            let jelement = elements.portofolioPerbankan.cardlink[j];
                            cardlinkElement.cardNumber = jelement.cardNumber;
                            cardlinkElement.product = jelement.product;
                            cardlinkElement.rownum = j + 1;
                            if (jelement.status == '1') {
                                cardlinkElement.status = 'Aktif';
                            } else {
                                cardlinkElement.status = 'Tidak Aktif';
                            }
                            newcardlink.push(cardlinkElement);
                        }

                    }
                    this.newinfos.pinjaman = newpinjaman;
                    this.newinfos.simpanan = newsimpanan;
                    this.newinfos.investasi = newinvestasi;
                    this.newinfos.cardlink = newcardlink;
                }).catch(error => {
                    this.errorFromImperative = error;
                    console.error('error.body.message line => ' + error.body.message);
                    this.showError = true;
                    if(error.body.message.includes('Data Not Found')){
                        this.errMsg = 'Data tidak ditemukan.';
                    }else{
                        this.errMsg = 'Data tidak ditemukan.';
                    }
                });
            }
        }).catch(error => {
            this.errorFromImperative = error;
            console.error('error.body.message line => ' + error.body.message);
            this.showError = true;
            this.errMsg = 'System error occurred ,please contact the System Administrator for detail';
        });
    }
}