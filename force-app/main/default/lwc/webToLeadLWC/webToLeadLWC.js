import { LightningElement, wire, track } from 'lwc';
import findCities from '@salesforce/apex/LeadController.findCities';
import getZipCodes from '@salesforce/apex/LeadController.getZipCodes';
import getCustomerTypeOptions from '@salesforce/apex/LeadController.getCustomerTypeOptions';
import createLead from '@salesforce/apex/LeadController.createLead';

export default class WebToLeadLWC extends LightningElement {
  @track leadData = {};
  @track zipCodeOptions = [];
  @track customerTypeOptions = [];
  @track citySuggestions = [];

  @track isZipCodeDisabled = true;
  @track isEnterprise = false;
  @track isSubmitted = false;
  @track error;
  @track isSubmitting = false;

  @track provinceId  = null;
  @track cityName    = null;

  @track villageId   = null;

  // for lookup
  @track citySearchKey = null;
  @track selectedCityId = null;
  debounceTimer;

  // Fetch customer type picklist
  @wire(getCustomerTypeOptions)
  wiredCustomerTypes({ error, data }) {
    if (data) {
      this.customerTypeOptions = data;
    } else if (error) {
      this.error = 'Failed to load customer types.';
    }
  }

  connectedCallback() {
    console.log('Last updated 20-10-2025 10.45');
  }

  handlePhoneKeypress(event) {
    // Only digits, plus sign or dash
    const allowed = /[0-9+\-]/;
    if (!allowed.test(event.key)) {
      event.preventDefault();
    }
  }


  // Generic input handler
  handleInputChange(event) {
    this.leadData[event.target.name] = event.target.value;
  }

  // Handle Customer Type → toggle Enterprise
  handleCustomerTypeChange(event) {
    this.leadData[event.target.name] = event.target.value;
    this.isEnterprise = event.target.value === 'E';
  }

  // Debounced lookup: call Apex once 2+ chars typed
  handleCitySearchKeyChange(event) {
    const val = event.target.value;
    this.citySearchKey = val;
    this.leadData.City__c = null;       // clear previous pick
    this.selectedCityId = null;
    this.provinceId = null;
    clearTimeout(this.debounceTimer);

    if (val.length >= 2) {
      this.debounceTimer = setTimeout(() => {
        findCities({ searchKey: val })
          .then((cities) => {
            this.citySuggestions = cities.map((c) => ({
              label: c.Name,
              value: c.Id,
              province: c.Province
            }));
          })
          .catch(() => {
            this.citySuggestions = [];
          });
      }, 300);
      console.log('selected city='+this.selectedCityId);
    } else {
      this.citySuggestions = [];
    }
  }

  // User clicked a suggestion
  handleCitySelect(event) {
    const id   = event.currentTarget.dataset.value;
    const name = event.currentTarget.innerText.trim();
    const province  = event.currentTarget.dataset.province;

    this.provinceId          = province;
    this.leadData.Province__c = province;
    this.leadData.City__c = id;

    // Set the input’s value
    const inputEl = this.template.querySelector('[data-id="cityLookup"]');
    if (inputEl) {
        inputEl.value = name;
    }

    // Now clear suggestions
    this.citySuggestions = [];

    // now load zip codes for chosen city
    this.isZipCodeDisabled = true;
    this.zipCodeOptions = [];
    this.leadData.ZipCode__c = null;

    console.log('selected City, ID = '+id+' , Name = '+name+' | Province ID = '+province);

    getZipCodes({ cityId: id })
      .then((zips) => {
        this.zipCodeOptions = zips.map((z) => ({
          label:   z.Name,
          value:   z.Id,
          village: z.Village   // pick up the villageId here
        }));
        this.isZipCodeDisabled = false;
      });

  }

  // Disable Submit until all required fields are filled
  /*
  get isSubmitDisabled() {
    const req = [
      this.leadData.FirstName,
      this.leadData.LastName,
      this.leadData.Email,
      this.leadData.Phone,
      this.leadData.Customer_Type__c
    ];
    // if Enterprise, Company is mandatory
    if (this.isEnterprise) {
      req.push(this.leadData.Company);
    }
    return req.some((v) => !v) || this.isSubmitting;
  } */
  get isSubmitDisabled() {
    const req = [
        this.leadData.FirstName,
        this.leadData.LastName,
        this.leadData.Email,
        this.leadData.Phone,
        this.leadData.Customer_Type__c
    ];
    if (this.isEnterprise) {
        req.push(this.leadData.Company);
    }
    return req.some((v) => !v); // validation only
  }

  get isButtonDisabled() {
    // combine validation + submitting
    return this.isSubmitDisabled || this.isSubmitting;
  }

  handleZipCodeChange(event) {
    // 1) capture the raw zipCodeId
    const zipCodeId = event.target.value;
    this.leadData.ZipCode__c = zipCodeId;

    // 2) lookup the village on the mapped options
    const selected = this.zipCodeOptions.find(
      (opt) => opt.value === zipCodeId
    );
    this.villageId = selected?.village || null;

    // Optional: store on leadData for full JSON payload
    this.leadData.Village__c = this.villageId;

    console.log('selected Zip Code, ID = '+zipCodeId+' | Village ID = '+this.villageId);
  }

  // Submit the Lead
  handleSubmit() {
    this.error = undefined;

    // run validation check only
    if (this.isSubmitDisabled) {
        this.error = 'Please fill in all mandatory fields.';
        return;
    }

    this.isSubmitting = true; // lock the button

    createLead({
      firstName:     this.leadData.FirstName,
      lastName:      this.leadData.LastName,
      email:         this.leadData.Email,
      phone:         this.leadData.Phone,
      company:       this.leadData.Company,
      provinceId:    this.provinceId,
      cityId:        this.leadData.City__c,
      zipCodeId:     this.leadData.ZipCode__c,
      villageId:     this.leadData.Village__c,
      customerType:  this.leadData.Customer_Type__c,
      userDescription: this.leadData.User_Description__c
    })
      .then(() => {
        this.isSubmitted = true;
      })
      .catch((err) => {
        this.error = err?.body?.message || 'Lead creation failed.';
        this.isSubmitting = false;
      });
  }
}