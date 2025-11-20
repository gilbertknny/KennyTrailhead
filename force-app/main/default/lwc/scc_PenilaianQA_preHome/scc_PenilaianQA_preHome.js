import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import getRecordTypes from '@salesforce/apex/SCC_PenilaianQA_ctrl.getQARecordType';
import getSubVoicePicklistValues from '@salesforce/apex/SCC_PenilaianQA_ctrl.getSubVoicePicklistValues';

export default class Scc_PenilaianQA_preHome extends LightningElement {
    @track recordTypeOptions = [];
    @track selectedValue; // Menyimpan nilai combobox
    @track redirect = false; // Kontrol untuk menampilkan redirect
    @track isSubVoiceVisible = false; // Kontrol untuk SubVoice
    @track subVoiceOptions = [];
    @track selectedSubVoice;
    @track showCategoryPicklist = true; // Menampilkan kategori awal
    @track isVoiceSelected = false; // Flag untuk Voice yang dipilih di awal

    @api recordId;

    // Menggunakan CurrentPageReference untuk mendapatkan recordId
    @wire(CurrentPageReference)
    getStateParameters(pageRef) {
        if (pageRef) {
            this.recordId = pageRef.state.c__recordId || null;
            console.log('Record ID (from CurrentPageReference):', this.recordId);

            if (!this.recordId) {
                this.fetchRecordIdFallback();
            }
        }
    }

    // Fallback method untuk mengambil recordId dari URL secara manual
    fetchRecordIdFallback() {
        this.recordId = new URLSearchParams(window.location.search).get('c__recordId');
        console.log('Fallback Record ID:', this.recordId);
    }

    // Mengambil record types saat komponen di-load
    @wire(getRecordTypes)
    wiredRecordTypes({ error, data }) {
        if (data) {
            this.recordTypeOptions = data.map((recordType) => ({
                label: recordType.Name,
                value: recordType.DeveloperName,
            }));
        } else if (error) {
            console.error('Error fetching record types: ', error);
        }
    }

    connectedCallback() {
        if (this.recordId) {
            this.loadSubVoicePicklist();
        }
    }

    loadSubVoicePicklist() {
        getSubVoicePicklistValues()
            .then((data) => {
                console.log('Sub-Voice Data:', data);
                this.subVoiceOptions = data.map((value) => ({
                    label: value,
                    value: value,
                }));
            })
            .catch((error) => {
                console.error('Error fetching sub-voice picklist values:', error);
            });
    }

    handleChange(event) {
        this.selectedValue = event.detail.value;
        console.log('Selected Record Type: ' + this.selectedValue);
    }

    handleSubVoiceChange(event) {
        this.selectedSubVoice = event.detail.value;
        console.log('Selected Sub-Voice: ' + this.selectedSubVoice);
    }

    handleCategoryNext() {
        if (this.selectedValue) {
            console.log('Selected Record Type: ' + this.selectedValue);
            if (this.selectedValue === 'Voice') {
                this.isVoiceSelected = true; // Tandai bahwa Voice dipilih
                this.isSubVoiceVisible = true;
                this.showCategoryPicklist = false;
            } else if (this.selectedValue === 'AL_Agent_Leader') {
                this.redirect = true;
                this.showCategoryPicklist = false;
                this.selectedSubVoice = null;
            } else {
                this.redirect = true;
                this.showCategoryPicklist = false;
                this.selectedSubVoice = null;
            }
        } else {
            this.showToast('Pilih kategori terlebih dahulu', 'Harap pilih salah satu kategori sebelum melanjutkan.', 'warning');
        }
    }

    handleSubVoiceNext() {
        if (this.selectedSubVoice) {
            this.redirect = true;
            this.isSubVoiceVisible = false;
        } else {
            this.showToast('Pilih Sub-Voice', 'Harap pilih salah satu sub-voice sebelum melanjutkan.', 'warning');
        }
    }

    handleSubVoicePrevious() {
        this.isSubVoiceVisible = false;
        this.showCategoryPicklist = true;
        this.isVoiceSelected = false; // Reset flag jika kembali ke kategori
    }

    handleRedirectPrevious() {
        if (this.isVoiceSelected) {
            // Kembali ke SubVoice jika sebelumnya Voice dipilih
            this.redirect = false;
            this.isSubVoiceVisible = true;
        } else {
            // Jika bukan Voice, kembali langsung ke kategori
            this.redirect = false;
            this.showCategoryPicklist = true;
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}