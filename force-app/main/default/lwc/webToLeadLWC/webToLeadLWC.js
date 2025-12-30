import { LightningElement, wire, track } from 'lwc';
import findCities from '@salesforce/apex/LeadController.findCities';
import getZipCodes from '@salesforce/apex/LeadController.getZipCodes';
import getCustomerTypeOptions from '@salesforce/apex/LeadController.getCustomerTypeOptions';
import createLead from '@salesforce/apex/LeadController.createLead';
import ASWATA_LOGO from '@salesforce/resourceUrl/AswataLogo';
import backgroundUrl from '@salesforce/resourceUrl/AswataBackgroundWeb';

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

  // For storing original names (for Enterprise customer type)
  @track originalFirstName = '';
  @track originalLastName = '';

  // Static resource URLs
  aswataLogo = ASWATA_LOGO;

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
    console.log('Last updated 30/12/2025 16:09 by Marco');
  }

  get backgroundStyle() {
      return `background-image:url(${backgroundUrl})`;
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
    
    // Store original names separately
    if (event.target.name === 'FirstName') {
      this.originalFirstName = event.target.value;
    }
    if (event.target.name === 'LastName') {
      this.originalLastName = event.target.value;
    }
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

    // Set the input's value
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
  /* old code 
  handleSubmit() {
    this.error = undefined;

    // run validation check only
    if (this.isSubmitDisabled) {
        this.error = 'Mohon mengisi seluruh data yang diatas.';
        return;
    }

    this.isSubmitting = true; // lock the button

    // Prepare data based on customer type
    let firstName, lastName, company, leadReferralName;
    console.log('customer type = '+this.leadData.Customer_Type__c);
    if (this.leadData.Customer_Type__c === 'E') {
      // Enterprise: Company becomes First & Last Name
      // Original names go to Lead_Referral_Name__c
      firstName = this.leadData.Company || '';
      lastName = this.leadData.Company || '';
      company = this.leadData.Company || '';
      leadReferralName = `${this.originalFirstName || ''} ${this.originalLastName || ''}`.trim();
    } else {
      // Individual: Use original names
      firstName = this.originalFirstName || '';
      lastName = this.originalLastName || '';
      company = `${this.originalFirstName || ''} ${this.originalLastName || ''}`.trim();
      leadReferralName = null;
    }


    createLead({
      firstName:     firstName,
      lastName:      lastName,
      email:         this.leadData.Email,
      phone:         this.leadData.Phone,
      company:       company,
      provinceId:    this.provinceId,
      cityId:        this.leadData.City__c,
      zipCodeId:     this.leadData.ZipCode__c,
      villageId:     this.leadData.Village__c,
      customerType:  this.leadData.Customer_Type__c,
      userDescription: this.leadData.User_Description__c,
      leadReferralName: leadReferralName  // Add this parameter
    })
      .then(() => {
        this.isSubmitted = true;
      })
      .catch((err) => {
        this.error = err?.body?.message || 'Submit data gagal. Terjadi kesalahan.';
        this.isSubmitting = false;
      });
  } */ 
  handleSubmit() {
    this.error = undefined;

    // run validation check only
    if (this.isSubmitDisabled) {
        this.error = 'Mohon mengisi seluruh data yang diatas.';
        console.log('Submit blocked: Validation failed');
        return;
    }

    this.isSubmitting = true; // lock the button
    console.log('Submit button locked. Starting submission process...');

    // Prepare data based on customer type
    let firstName, lastName, company, leadReferralName;
    
    console.log('=== CUSTOMER TYPE PROCESSING ===');
    console.log('Customer Type = ' + this.leadData.Customer_Type__c);
    console.log('Original First Name = "' + this.originalFirstName + '"');
    console.log('Original Last Name = "' + this.originalLastName + '"');
    console.log('Company Name = "' + this.leadData.Company + '"');
    /*
    if (this.leadData.Customer_Type__c === 'E') {
        // Enterprise: Company becomes First & Last Name
        // Original names go to Lead_Referral_Name__c
        firstName = this.leadData.Company || '';
        lastName = this.leadData.Company || '';
        company = this.leadData.Company || '';
        leadReferralName = `${this.originalFirstName || ''} ${this.originalLastName || ''}`.trim();
        
        console.log('ENTERPRISE CUSTOMER DETECTED - TRANSFORMING DATA:');
        console.log('  FirstName will be set to: "' + firstName + '" (Company name)');
        console.log('  LastName will be set to: "' + lastName + '" (Company name)');
        console.log('  Company will be set to: "' + company + '"');
        console.log('  Lead_Referral_Name__c will be set to: "' + leadReferralName + '" (Original person name)');
    } else {
        // Individual: Use original names
        firstName = this.originalFirstName || '';
        lastName = this.originalLastName || '';
        //company = `${this.originalFirstName || ''} ${this.originalLastName || ''}`.trim();
        company = this.leadData.Company || '';
        leadReferralName = null;
        
        console.log('INDIVIDUAL CUSTOMER DETECTED - USING ORIGINAL NAMES:');
        console.log('  FirstName will be set to: "' + firstName + '"');
        console.log('  LastName will be set to: "' + lastName + '"');
        console.log('  Company will be set to: "' + company + '" (Combined names)');
        console.log('  Lead_Referral_Name__c will be set to: null');
    } */
    // Back to original
    firstName = this.originalFirstName || '';
    lastName = this.originalLastName || '';
    //company = `${this.originalFirstName || ''} ${this.originalLastName || ''}`.trim();
    company = this.leadData.Company || '';
    //leadReferralName = null;

    // Prepare the data object for Apex call
    const leadDataToSend = {
        firstName: firstName,
        lastName: lastName,
        email: this.leadData.Email,
        phone: this.leadData.Phone,
        company: company,
        provinceId: this.provinceId,
        cityId: this.leadData.City__c,
        zipCodeId: this.leadData.ZipCode__c,
        villageId: this.leadData.Village__c,
        customerType: this.leadData.Customer_Type__c,
        userDescription: this.leadData.User_Description__c
        //,leadReferralName: leadReferralName
    };

    console.log('=== FINAL DATA BEING SENT TO APEX ===');
    console.log('JSON payload:', JSON.stringify(leadDataToSend, null, 2));
    console.log('---------------------------------------');
    console.log('Key field mappings for Lead object:');
    console.log('  Lead.FirstName = "' + leadDataToSend.firstName + '"');
    console.log('  Lead.LastName = "' + leadDataToSend.lastName + '"');
    console.log('  Lead.Company = "' + leadDataToSend.company + '"');
    console.log('  Lead.Lead_Referral_Name__c = "' + leadDataToSend.leadReferralName + '"');
    console.log('  Lead.Account_Segment__c = "' + leadDataToSend.customerType + '"');
    console.log('=======================================');

    // For debugging: Compare with original form data
    console.log('=== ORIGINAL FORM DATA (for reference only) ===');
    console.log('Original FirstName field: "' + this.leadData.FirstName + '"');
    console.log('Original LastName field: "' + this.leadData.LastName + '"');
    console.log('Original Company field: "' + this.leadData.Company + '"');

    createLead(leadDataToSend)
    .then((leadId) => {
        console.log('✅ Lead created successfully!');
        console.log('Lead ID:', leadId);
        console.log('Data transformation completed:');
        console.log('  - For Enterprise (E): Company name becomes First/Last Name');
        console.log('  - Person name stored in Lead_Referral_Name__c');
        
        // Query the created lead to verify (this would be a separate call in real scenario)
        console.log('Note: To verify the actual saved data, query the Lead with ID:', leadId);
        
        this.isSubmitted = true;
    })
    .catch((err) => {
        console.error('❌ Lead creation failed:');
        console.error('Error details:', err);
        this.error = err?.body?.message || 'Submit data gagal. Terjadi kesalahan.';
        this.isSubmitting = false;
    });
  }
}