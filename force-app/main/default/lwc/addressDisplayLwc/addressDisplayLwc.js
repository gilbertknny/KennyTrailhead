import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import searchLocations from '@salesforce/apex/addressDisplayController.searchLocations';

export default class AddressDisplayLwc extends OmniscriptBaseMixin(LightningElement) {
    @api param;
    @track country = '';
    @track province = '';
    @track city = '';
    @track zip = '';
    @track addressSearch = '';
    @track addressOptions = [];
    @track showDropdown = false;
    @track selectedAddressDesc = '';
    @track noResults = false;
    @track countryId = '';
    @track provinceId = '';
    @track cityId = '';
    @track zipId = '';

    connectedCallback() {
        this._outsideClickHandler = this._handleOutsideClick.bind(this);
        document.addEventListener('click', this._outsideClickHandler, true);
    }

    disconnectedCallback() {
        document.removeEventListener('click', this._outsideClickHandler, true);
    }

    _handleOutsideClick(evt) {
        if (!this.template.contains(evt.target)) {
            this.showDropdown = false;
        }
    }

    handleCountryChange(event) {
        this.countryId = event.detail.value[0]; 
    }

    handleProvinceChange(event) {
        this.provinceId = event.detail.value[0]; 
    }
    handleCityChange(event) {
        this.cityId = event.detail.value[0]; 
    }
    handleZipChange(event) {
        this.zipId = event.detail.value[0]; 
    }

    handleAddressSearch(event) {
        this.addressSearch = event.target.value;
        if (this.addressSearch && this.addressSearch.length >= 1) {
            this.runSearch();
        } else {
            this.addressOptions = [];
            this.noResults = false;
            this.showDropdown = false;
        }
    }

    runSearch() {
        if (!this.addressSearch && !this.countryId && !this.provinceId && !this.cityId && !this.zipId) {
            this.addressOptions = [];
            this.noResults = false;
            this.showDropdown = false;
            return;
        }

        searchLocations({
            searchKey: this.addressSearch,
            country: this.countryId,
            province: this.provinceId,
            city: this.cityId,
            zip: this.zipId,
            limitSize: 50
        })
        .then(result => {
            this.addressOptions = result.map(r => {
                const subParts = [];

                return {
                    label: r.Name,
                    value: r.Id,
                    data: r,
                    subLabel: subParts.join(' — ')
                };
            });
            this.noResults = this.addressOptions.length === 0;
            this.showDropdown = this.addressOptions.length > 0 || this.noResults;
        })
        .catch(err => {
            console.error('searchLocations error', err);
            this.addressOptions = [];
            this.showDropdown = false;
            this.noResults = false;
        });
    }

    handleSelectAddress(evt) {
        evt.preventDefault();
        evt.stopPropagation();

        const id = evt.currentTarget.dataset.id;
        const sel = this.addressOptions.find(it => it.value === id);
        if (!sel) return;

        this.selectedAddressDesc = sel.label;
        this.addressSearch = sel.label;
        let valJson = JSON.parse(JSON.stringify(sel.data));
        this.omniApplyCallResp({ [this.param] :{
            AddressId__c: sel.value,
            AddressName__c: sel.label,
            Country__c: sel.data.CountryId,
            Province__c: sel.data.ProvinceId,
            City__c: sel.data.CityId,
            Zip__c: sel.data.ZipId,
            BranchId__c: sel.data.BranchId,
            AddressDescription__c: this.selectedAddressDesc 
        }});

        this.showDropdown = false;
    }

    handleSearchFocus() {
        if (this.addressSearch || this.country || this.province || this.city || this.zip) {
            this.runSearch();
        }
    }

    checkValidity() {
        return true;
    }

    handleDescriptionChange(event) {
        console.log('Description changed:', event.target.value);
        
        this.omniApplyCallResp({ [this.param] :{
            AddressDescription__c: event.target.value 
        }});
   }

    get isTextareaDisabled() {
        return !this.selectedAddressDesc;
    }
}