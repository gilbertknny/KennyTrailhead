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

  // CAPTCHA properties
  @track isCaptchaVerified = false;
  @track captchaToken = null;
  @track pendingSubmission = false;
  @track captchaError = null;

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
    console.log('Last updated 20-10-2025 10.45 - with CAPTCHA integration');
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

  // Handle CAPTCHA verification
  handleCaptchaVerified(event) {
    console.log('CAPTCHA verification event received:', event.detail);
    
    const verified = event.detail.verified;
    this.isCaptchaVerified = verified;
    this.captchaToken = event.detail.token;
    this.captchaError = null;

    if (verified && this.pendingSubmission) {
      // CAPTCHA verified and we were waiting to submit
      console.log('CAPTCHA verified, proceeding with form submission');
      this.submitLead();
    } else if (!verified && this.pendingSubmission) {
      // CAPTCHA failed and we were waiting to submit
      this.error = 'CAPTCHA verification failed. Please try again.';
      this.isSubmitting = false;
      this.pendingSubmission = false;
      this.captchaError = 'CAPTCHA verification failed';
    }
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

  // Form validation only (without CAPTCHA check)
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

  // Button disabled state (includes validation + submitting state)
  get isButtonDisabled() {
    return this.isSubmitDisabled || this.isSubmitting;
  }

  // Main submit handler
  handleSubmit() {
    this.error = undefined;
    this.captchaError = null;

    // Run validation check
    if (this.isSubmitDisabled) {
        this.error = 'Please fill in all mandatory fields.';
        return;
    }

    this.isSubmitting = true;

    // Check CAPTCHA status
    if (!this.isCaptchaVerified) {
      console.log('CAPTCHA not verified, waiting for verification...');
      this.pendingSubmission = true;
      // The CAPTCHA component will automatically trigger verification
      // When verified, it will call submitLead() automatically
      return;
    }

    // If CAPTCHA is already verified, submit directly
    console.log('CAPTCHA already verified, submitting directly');
    this.submitLead();
  }

  // Extract lead submission logic
  submitLead() {
    console.log('Submitting lead with CAPTCHA token:', this.captchaToken);
    
    createLead({
      firstName: this.leadData.FirstName,
      lastName: this.leadData.LastName,
      email: this.leadData.Email,
      phone: this.leadData.Phone,
      company: this.leadData.Company,
      provinceId: this.provinceId,
      cityId: this.leadData.City__c,
      zipCodeId: this.leadData.ZipCode__c,
      villageId: this.leadData.Village__c,
      customerType: this.leadData.Customer_Type__c,
      userDescription: this.leadData.User_Description__c,
      captchaToken: this.captchaToken // Pass CAPTCHA token to Apex for verification
    })
    .then(() => {
      this.isSubmitted = true;
      this.isSubmitting = false;
      this.pendingSubmission = false;
      console.log('Lead submitted successfully');
    })
    .catch((err) => {
      this.error = err?.body?.message || 'Lead creation failed.';
      this.isSubmitting = false;
      this.pendingSubmission = false;
      console.error('Lead submission error:', err);
    });
  }
}