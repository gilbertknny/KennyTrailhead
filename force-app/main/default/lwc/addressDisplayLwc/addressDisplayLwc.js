import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import searchLocations from '@salesforce/apex/addressDisplayController.searchLocations';
import getAddressById from '@salesforce/apex/addressDisplayController.getAddressById';

export default class AddressDisplayLwc extends OmniscriptBaseMixin(LightningElement) {
    @api param;
    @api jsondata;
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
    @track isLoading = false;

    connectedCallback() {
        this._outsideClickHandler = this._handleOutsideClick.bind(this);
        document.addEventListener('click', this._outsideClickHandler, true);
        
        // Load existing address data if available
        this.loadExistingAddress();
    }

    disconnectedCallback() {
        document.removeEventListener('click', this._outsideClickHandler, true);
    }

    _handleOutsideClick(evt) {
        if (!this.template.contains(evt.target)) {
            this.showDropdown = false;
        }
    }

loadExistingAddress() {
    const existingData = this.omniJsonData?.[this.param];
    
    const accountData = this.jsondata?.[0];
    const addressLuId = accountData?.Address_LU__c || accountData?.Address_LU__r?.Id;
    if (existingData) {
        if (existingData.Country__c) {
            this.countryId = existingData.Country__c;
            this.country = existingData.Country__c;
        }
        
        if (existingData.Province__c) {
            this.provinceId = existingData.Province__c;
            this.province = existingData.Province__c;
        }
        
        if (existingData.City__c) {
            this.cityId = existingData.City__c;
            this.city = existingData.City__c;
        }
        
        if (existingData.Zip__c) {
            this.zipId = existingData.Zip__c;
            this.zip = existingData.Zip__c;
        }
        
        if (existingData.AddressDescription__c) {
            this.selectedAddressDesc = existingData.AddressDescription__c;
        }
        
        // Jika ada AddressId, fetch detail lengkap dari server
        if (existingData.AddressId__c) {
            this.fetchAndLoadAddress(existingData.AddressId__c);
            return; // Stop di sini karena sudah ada AddressId
        } else if (existingData.AddressName__c) {
            // Jika tidak ada AddressId tapi ada AddressName
            this.addressSearch = existingData.AddressName__c;
        }
    }
    
    // Prioritas 2: Jika belum ada AddressId tapi ada Address_LU__c dari Account
    if (!existingData?.AddressId__c && addressLuId) {
        console.log('Loading address from Address_LU__c:', addressLuId);
        this.fetchAndLoadAddress(addressLuId);
    }
}

fetchAndLoadAddress(addressId) {
    this.isLoading = true;
    getAddressById({ addressId: addressId })
        .then(result => {
            if (result) {
                console.log('Loaded address:', result);
                this.addressSearch = result.Name;
                
                // Update semua field dari hasil
                this.countryId = result.CountryId;
                this.country = result.CountryId;
                
                this.provinceId = result.ProvinceId;
                this.province = result.ProvinceId;
                
                this.cityId = result.CityId;
                this.city = result.CityId;
                
                this.zipId = result.ZipId;
                this.zip = result.ZipId;
                
                // Set description jika belum ada
                if (!this.selectedAddressDesc) {
                    this.selectedAddressDesc = result.Name;
                }
                
                // PENTING: Save ke OmniScript JSON agar data tersimpan
                this.omniApplyCallResp({ [this.param]: {
                    AddressId__c: addressId,
                    AddressName__c: result.Name,
                    Country__c: result.CountryId,
                    Province__c: result.ProvinceId,
                    City__c: result.CityId,
                    Zip__c: result.ZipId,
                    BranchId__c: result.BranchId,
                    AddressDescription__c: this.selectedAddressDesc || result.Name
                }});
            }
        })
        .catch(error => {
            console.error('Error loading address:', error);
        })
        .finally(() => {
            this.isLoading = false;
        });
}

    handleCountryChange(event) {
        this.countryId = event.detail.value[0]; 
        this.country = event.detail.value[0];
        this.updateOmniData();
    }

    handleProvinceChange(event) {
        this.provinceId = event.detail.value[0]; 
        this.province = event.detail.value[0];
        this.updateOmniData();
    }
    
    handleCityChange(event) {
        this.cityId = event.detail.value[0]; 
        this.city = event.detail.value[0];
        this.updateOmniData();
    }
    
    handleZipChange(event) {
        this.zipId = event.detail.value[0]; 
        this.zip = event.detail.value[0];
        this.updateOmniData();
    }

    updateOmniData() {
        // Update OmniScript data ketika filter berubah
        const currentData = this.omniJsonData?.[this.param] || {};
        this.omniApplyCallResp({ [this.param]: {
            ...currentData,
            Country__c: this.countryId,
            Province__c: this.provinceId,
            City__c: this.cityId,
            Zip__c: this.zipId
        }});
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

        this.isLoading = true;
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
                if (r.CountryName) subParts.push(r.CountryName);
                if (r.ProvinceName) subParts.push(r.ProvinceName);
                if (r.CityName) subParts.push(r.CityName);
                if (r.ZipName) subParts.push(r.ZipName);

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
        })
        .finally(() => {
            this.isLoading = false;
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
        
        // Update local state
        this.countryId = sel.data.CountryId;
        this.provinceId = sel.data.ProvinceId;
        this.cityId = sel.data.CityId;
        this.zipId = sel.data.ZipId;
        
        this.country = sel.data.CountryId;
        this.province = sel.data.ProvinceId;
        this.city = sel.data.CityId;
        this.zip = sel.data.ZipId;
        
        // Save to OmniScript JSON
        this.omniApplyCallResp({ [this.param]: {
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
        if (this.addressSearch || this.countryId || this.provinceId || this.cityId || this.zipId) {
            this.runSearch();
        }
    }

    checkValidity() {
        return true;
    }

    handleDescriptionChange(event) {
        this.selectedAddressDesc = event.target.value;
        
        const currentData = this.omniJsonData?.[this.param] || {};
        this.omniApplyCallResp({ [this.param]: {
            ...currentData,
            AddressDescription__c: event.target.value 
        }});
    }

    get isTextareaDisabled() {
        return !this.selectedAddressDesc && !this.addressSearch;
    }
}