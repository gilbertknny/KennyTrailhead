import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';  // Add this line

import getOpportunity from '@salesforce/apex/OpportunityController.getOpportunityInsurancePeriod';
import getTransactions from '@salesforce/apex/OpportunityController.getTransactionDataInsurancePeriod';
import saveInsuranceDetails from '@salesforce/apex/OpportunityController.saveInsuranceDetails';

export default class InsurancePeriode extends NavigationMixin(LightningElement) {
    @api recordId;

    // Wire results
    wiredOppResult;
    wiredTxnResult;

    // Form properties
    periodType = null;
    years = null;
    shortBasis = null;
    percentage = null;
    periodRate = null;
    startDate = null;
    endDate = null;
    calculatedRate = null;
    @track schemaType = null;
    @track stage = null;
    @track cob = null;
    @track isOwner = false;
    premiumCalculation = null;

    // State management
    @track oppRecord;
    @track transactions = [];
    @track error;
    @track isLoading = true;
    @track isTypeLocked = false;
    @track isEditing = false;

    // Validation properties
    @track showPeriodTypeValidationError = false;
    @track periodTypeValidationMessage = '';
    @track expectedPeriodType = null;

    // Reactive calculated values
    @track dayCount = null;
    @track yearsMonthsInfo = null;
    @track adjustmentRows = [];

    // Private properties for calculations
    _computedYears = 0;
    _computedMonths = 0;

    // Original state for reset
    originalForm = null;

    // ------ Template getters ------
    get isLongTerm() { return (this.cob === '201' && this.periodType === '3'); }
    get isAnnual() { return this.periodType === '1'; }
    get isShort() { return this.periodType === '2'; }
    get isPercentageBasis() { return this.shortBasis === '1'; }
    get isProRataBasis() { return this.shortBasis === '2'; }

    // Add this getter for periodType combobox disabled state
    get isPeriodTypeComboboxDisabled() {
        // If form is read-only, always disabled
        if (this.isReadOnly) {
            return true;
        }
        
        // For auto-determined COBs (201-204) when in edit mode, also disable
        if (this.isAutoDeterminePeriodType && this.isEditing) {
            return true;
        }
        
        return false;
    }
    
    get showInfo() { 
        // For COB 301/302/303, show info based on premium calculation
        if (['301', '302', '303'].includes(this.cob)) {
            return this.premiumCalculation && this.premiumCalculation !== '1';
        }
        // Original logic for COB 201
        return (this.cob === '201' && !this.isAnnual); 
    }
    
    // New getters for premium calculation types
    get isPremiumProRata() {
        return ['301', '302', '303'].includes(this.cob) && this.premiumCalculation === '4';
    }

    get isPremiumPercentage() {
        return ['301', '302', '303'].includes(this.cob) && this.premiumCalculation === '5';
    }

    get isPremiumLongTerm() {
        return ['301', '302', '303'].includes(this.cob) && 
               (this.premiumCalculation === '6' || this.premiumCalculation === '2' || this.premiumCalculation === '3');
    }

    get isPremiumPercentageInput() {
        return ['301', '302', '303'].includes(this.cob) && this.premiumCalculation === '5';
    }

    // Add this getter for auto-determined COBs
    get isAutoDeterminePeriodType() {
        return ['201', '202', '203', '204'].includes(this.cob);
    }

    // Getter for formatted calculated rate with 6 decimals
    get formattedCalculatedRate() {
        return this.calculatedRate !== null && this.calculatedRate !== undefined 
            ? this.calculatedRate.toFixed(6)
            : '0.000000';
    }

    // Getter to show insurance type combobox
    get showInsuranceType() {
        // Show insurance type for:
        // 1. All COBs except limited forms
        // 2. Except premium calculation COBs (301/302/303)
        return !this.isLimitedForm && !this.showPremiumCalculation;
    }
    
    // Getter for limited form (only show dates)
    get isLimitedForm() {
        return ['101', '602', '851', '852'].includes(this.cob);
    }
    
    // Getter to check if end date is required
    get isEndDateRequired() {
        return this.cob !== '101';
    }
    
    get insuranceTypeOptions() {
        return [
            { label: 'Annual', value: '1' },
            { label: 'Short-Period', value: '2' },
            { label: 'Long Term', value: '3' }
        ];
    }

    get shortBasisOptions() {
        return [
            { label: 'Pro-Rata Basis', value: '2' },
            { label: 'Percentage', value: '1' }
        ];
    }
    
    // Getter for allowed insurance type options based on date range
    get allowedInsuranceTypeOptions() {
        // If we don't have dates, return all options
        if (!this.startDate || !this.endDate) {
            return this.insuranceTypeOptions;
        }
        
        // Calculate duration
        const start = new Date(this.startDate);
        const end = new Date(this.endDate);
        const yearDiff = end.getFullYear() - start.getFullYear();
        const monthDiff = end.getMonth() - start.getMonth();
        const dayDiff = end.getDate() - start.getDate();
        
        let actualYearDiff = yearDiff;
        if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
            actualYearDiff--;
        }
        
        // Filter options based on duration
        if (actualYearDiff === 0) {
            // Less than 1 year - Only allow "Short-Period" (value: '2')
            return this.insuranceTypeOptions.filter(option => option.value === '2');
        } else if (actualYearDiff === 1 && monthDiff === 0 && dayDiff === 0) {
            // Exactly 1 year - Only allow "Annual" (value: '1')
            return this.insuranceTypeOptions.filter(option => option.value === '1');
        } else {
            // More than 1 year - Only allow "Long Term" (value: '3')
            return this.insuranceTypeOptions.filter(option => option.value === '3');
        }
    }
    
    // Premium Calculation Options
    get premiumCalculationOptions() {
        return [
            { label: 'Flat', value: '1' },
            { label: 'Decreasing Sum Insured', value: '2' },
            { label: 'Discount Rate', value: '3' },
            { label: 'Pro Rata', value: '4' },
            { label: 'Percentage', value: '5' },
            { label: 'Long Period', value: '6' }
        ];
    }
    
    // Restricted Premium Calculation Options based on duration
    get allowedPremiumCalculationOptions() {
        if (!this.startDate || !this.endDate) {
            return this.premiumCalculationOptions;
        }
        
        const start = new Date(this.startDate);
        const end = new Date(this.endDate);
        const yearDiff = end.getFullYear() - start.getFullYear();
        const monthDiff = end.getMonth() - start.getMonth();
        const dayDiff = end.getDate() - start.getDate();
        
        let actualYearDiff = yearDiff;
        if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
            actualYearDiff--;
        }
        
        if (actualYearDiff === 0) {
            return this.premiumCalculationOptions.filter(option => 
                option.value === '4' || option.value === '5'
            );
        } else if (actualYearDiff === 1 && monthDiff === 0 && dayDiff === 0) {
            return this.premiumCalculationOptions.filter(option => option.value === '1');
        } else {
            return this.premiumCalculationOptions.filter(option => 
                option.value === '6' || option.value === '2' || option.value === '3'
            );
        }
    }
    
    schemaOptions = [
        { label: '--None--', value: null },
        { label: 'Sum Insured Adjustment', value: 'Sum Insured Adjustment' },
        { label: 'Discounted Premium', value: 'Discounted Premium' }
    ];
    
    get displayRows() {
        return this.adjustmentRows.filter(r => r.year !== 1);
    }
    
    get hasSchemaType() {
        return this.schemaType !== null && this.schemaType !== undefined && String(this.schemaType).trim() !== '';
    }
    
    get formattedErrors() {
        if (this.error) {
            if (Array.isArray(this.error)) {
                return this.error.map(e => e.message || e);
            } else if (typeof this.error === 'object') {
                return [this.error.message || JSON.stringify(this.error)];
            }
            return [this.error];
        }
        return [];
    }

    get showPremiumCalculation() {
        return this.cob === '301' || this.cob === '302' || this.cob === '303';
    }

    get isReadOnly() {
        return this.stage === 'Closed Won' || this.stage === 'Closed Lost' || this.stage === 'Cancel' || this.isEditing == false || this.isOwner == false;
    }

    get isNotOwner(){
        return !this.isOwner;
    }

    connectedCallback() {
        console.log('last update 23/12/2025 16.59');
        console.log('opptyId: ' + this.recordId);
        console.log('isOwner: ' + this.isOwner);
    }

    // ------ Lifecycle & Data ------
    @wire(getOpportunity, { recordId: '$recordId' })
    wiredOpportunity(result) {
        try {
            this.wiredOppResult = result;
            const { data, error } = result;
            
            console.log('📥 ======== OPPORTUNITY DATA WIRE ========');
            console.log('   Status:', result.data ? '✅ Data received' : result.error ? '❌ Error' : '⏳ Loading');
            console.log('   Loading:', result.loading);
            
            if (data) {
                console.log('   📊 OPPORTUNITY DATA OBJECT:');
                console.log(JSON.stringify(data, null, 2));
                
                console.log('   🔍 KEY OPPORTUNITY FIELDS:');
                console.log('      - Insurance_Period_Type__c:', data.Insurance_Period_Type__c);
                console.log('      - Short_Period_Basis__c:', data.Short_Period_Basis__c);
                console.log('      - Start_Date_Periode__c:', data.Start_Date_Periode__c);
                console.log('      - End_Date_Periode__c:', data.End_Date_Periode__c);
                console.log('      - Percentage__c:', data.Percentage__c);
                console.log('      - StageName:', data.StageName);
                console.log('      - COB__c:', data.COB__c);
                console.log('      - premium_calculation__c:', data.premium_calculation__c);
                console.log('      - isOwner__c:', data.isOwner__c);
                console.log('      - Total fields received:', Object.keys(data).length);
                
                this.error = undefined;
                this.oppRecord = data;
                this.periodType = data.Insurance_Period_Type__c;
                this.shortBasis = data.Short_Period_Basis__c;
                this.startDate = data.Start_Date_Periode__c;
                this.endDate = data.End_Date_Periode__c;
                this.percentage = data.Percentage__c;
                this.stage = data.StageName;
                this.cob = data.COB__c;
                this.premiumCalculation = data.premium_calculation__c;
                this.isOwner = data.isOwner__c;
                
                console.log('   🏷️ COMPONENT STATE AFTER OPPORTUNITY LOAD:');
                console.log('      - periodType:', this.periodType);
                console.log('      - cob:', this.cob);
                console.log('      - stage:', this.stage);
                console.log('      - isOwner:', this.isOwner);
                console.log('      - premiumCalculation:', this.premiumCalculation);
                console.log('      - percentage:', this.percentage);
                
                this.calculateDuration();
                this.calculateExpectedPeriodType();
                
                // For auto-determined COBs, set period type based on dates
                if (this.isAutoDeterminePeriodType && this.startDate && this.endDate) {
                    console.log('   🔄 Auto-determining period type for COB:', this.cob);
                    this.calculateExpectedPeriodType();
                }
                
                if (this.premiumCalculation === null || this.premiumCalculation === undefined) {
                    console.log('   ⚙️ Premium calculation is null, adjusting based on duration');
                    this.adjustPremiumCalculationBasedOnDuration();
                }
                
                this.originalForm = {
                    periodType: this.periodType,
                    years: this.years,
                    shortBasis: this.shortBasis,
                    startDate: this.startDate,
                    endDate: this.endDate,
                    percentage: this.percentage,
                    premiumCalculation: this.premiumCalculation
                };
                this.isTypeLocked = true;
                
                console.log('   📝 ORIGINAL FORM SNAPSHOT:');
                console.log(JSON.stringify(this.originalForm, null, 2));
                
            } else if (error) {
                console.error('❌ OPPORTUNITY LOAD ERROR DETAILS:');
                console.error('   Error object:', error);
                console.error('   Error body:', error.body);
                console.error('   Error message:', error.message);
                console.error('   Stack trace:', error.stack);
                
                this.error = error;
                this.isLoading = false;
            }
            
            console.log('===========================================');
            
        } catch (err) {
            console.error('❌ UNEXPECTED ERROR in wiredOpportunity:');
            console.error(err);
            this.error = err;
            this.isLoading = false;
        }
    }

    @wire(getTransactions, { opportunityId: '$recordId' })
    wiredTransactions(result) {
        this.wiredTxnResult = result;
        
        console.log('📥 ======== TRANSACTIONS DATA WIRE ========');
        console.log('   Status:', result.data ? '✅ Data received' : result.error ? '❌ Error' : '⏳ Loading');
        console.log('   Loading:', result.loading);
        
        const { data, error } = result;

        if (data) {
            console.log('   📊 TRANSACTIONS DATA ARRAY:');
            console.log(JSON.stringify(data, null, 2));
            
            console.log('   🔍 TRANSACTIONS SUMMARY:');
            console.log('      - Number of transactions:', data.length);
            
            if (data.length > 0) {
                console.log('      - First transaction:', JSON.stringify(data[0], null, 2));
                console.log('      - Schema_Type__c from first transaction:', data[0].Schema_Type__c);
                this.schemaType = data[0].Schema_Type__c;
                console.log('      - schemaType set to:', this.schemaType);
            } else {
                console.log('      - No transactions found');
                this.schemaType = null;
            }
            
            this.transactions = data;
            this.error = undefined;

            this.adjustmentRows = [];
            
            // Format existing values to 6 decimals for display
            if (this.schemaType === 'Sum Insured Adjustment' && data.length > 0) {
                console.log('   ⚙️ Sum Insured Adjustment schema detected, formatting data');
            }

            if (this.oppRecord) {
                console.log('   🔄 Calculating duration after transactions loaded');
                this.calculateDuration();
                this.calculateExpectedPeriodType();
            }
            
            this.isLoading = false;
            console.log('   ✅ Component loading complete, isLoading set to false');
            
        } else if (error) {
            console.error('❌ TRANSACTIONS LOAD ERROR DETAILS:');
            console.error('   Error object:', error);
            console.error('   Error body:', error.body);
            console.error('   Error message:', error.message);
            console.error('   Stack trace:', error.stack);
            
            this.error = error;
            this.isLoading = false;
        }
        
        console.log('============================================');
        
        // Log final component state
        console.log('🎯 ======== FINAL COMPONENT STATE ========');
        console.log('   Basic Properties:');
        console.log('      - recordId:', this.recordId);
        console.log('      - periodType:', this.periodType);
        console.log('      - cob:', this.cob);
        console.log('      - stage:', this.stage);
        console.log('      - isOwner:', this.isOwner);
        console.log('      - isLoading:', this.isLoading);
        console.log('      - isEditing:', this.isEditing);
        console.log('      - isReadOnly:', this.isReadOnly);
        console.log('      - isLimitedForm:', this.isLimitedForm);
        
        console.log('   Date Properties:');
        console.log('      - startDate:', this.startDate);
        console.log('      - endDate:', this.endDate);
        console.log('      - dayCount:', this.dayCount);
        
        console.log('   Calculation Properties:');
        console.log('      - premiumCalculation:', this.premiumCalculation);
        console.log('      - percentage:', this.percentage);
        console.log('      - shortBasis:', this.shortBasis);
        console.log('      - calculatedRate:', this.calculatedRate);
        console.log('      - yearsMonthsInfo:', this.yearsMonthsInfo);
        
        console.log('   Schema Properties:');
        console.log('      - schemaType:', this.schemaType);
        console.log('      - transaction count:', this.transactions.length);
        console.log('      - adjustmentRows count:', this.adjustmentRows.length);
        
        console.log('   UI State:');
        console.log('      - showInsuranceType:', this.showInsuranceType);
        console.log('      - showPremiumCalculation:', this.showPremiumCalculation);
        console.log('      - isAnnual:', this.isAnnual);
        console.log('      - isShort:', this.isShort);
        console.log('      - isLongTerm:', this.isLongTerm);
        console.log('      - showInfo:', this.showInfo);
        console.log('      - showPeriodTypeValidationError:', this.showPeriodTypeValidationError);
        
        console.log('==========================================');
    }

    // ------ NEW: Period Type Handler (ComboBox) ------
    handlePeriodTypeChange(event) {
        const newType = event.detail.value;
        
        // For auto-determined COBs, block manual changes
        if (this.isAutoDeterminePeriodType && this.isEditing) {
            const allowedValues = this.allowedInsuranceTypeOptions.map(opt => opt.value);
            if (!allowedValues.includes(newType)) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Selection Not Allowed',
                    message: `For COB ${this.cob}, insurance type is automatically determined based on the date range.`,
                    variant: 'warning'
                }));
                return;
            }
        }
        
        if (this.originalForm?.periodType === newType) {
            Object.assign(this, this.originalForm);
            this.calculateDuration();
            this.calculateExpectedPeriodType();
            return;
        }
        
        this.periodType = newType;
        
        // Check if the selected type is 'Short-Period'
        if (newType === '2') {
            this.shortBasis = '2';
        } else {
            this.shortBasis = null;
        }

        this.percentage = null; 
        this.startDate = null; 
        this.endDate = null;
        this.calculatedRate = null; 
        this.adjustmentRows = []; 
        this.dayCount = null; 
        this.yearsMonthsInfo = null;
        this.years = (newType === '1') ? 1 : null;

        this.calculateDuration();
        this.calculateExpectedPeriodType();
    }

    // ------ NEW: Premium Calculation Handler ------
    handlePremiumCalculationChange(event) {
        const newValue = event.detail.value;
        this.premiumCalculation = newValue;
        
        if (newValue !== '5' && this.isPremiumPercentageInput) {
            this.percentage = null;
        }
        
        this.calculateDuration();
    }

    // Method to adjust premium calculation value when dates change
    adjustPremiumCalculationBasedOnDuration() {
        if (!this.showPremiumCalculation || !this.startDate || !this.endDate) {
            return;
        }
        
        const start = new Date(this.startDate);
        const end = new Date(this.endDate);
        const yearDiff = end.getFullYear() - start.getFullYear();
        const monthDiff = end.getMonth() - start.getMonth();
        const dayDiff = end.getDate() - start.getDate();
        
        let actualYearDiff = yearDiff;
        if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
            actualYearDiff--;
        }
        
        if (this.premiumCalculation === null || this.premiumCalculation === undefined) {
            let newPremiumCalculation = null;
            
            if (actualYearDiff === 0) {
                newPremiumCalculation = '4';
            } else if (actualYearDiff === 1 && monthDiff === 0 && dayDiff === 0) {
                newPremiumCalculation = '1';
            } else {
                newPremiumCalculation = '6';
            }
            
            if (newPremiumCalculation !== null && this.premiumCalculation !== newPremiumCalculation) {
                this.premiumCalculation = newPremiumCalculation;
            }
        }
    }

    // ------ Period Type Validation Methods ------
    calculateExpectedPeriodType() {
        if (!this.startDate || !this.endDate) {
            this.expectedPeriodType = null;
            this.showPeriodTypeValidationError = false;
            return;
        }

        const start = new Date(this.startDate);
        const end = new Date(this.endDate);
        
        // Calculate difference in years, months, days
        let yearDiff = end.getFullYear() - start.getFullYear();
        let monthDiff = end.getMonth() - start.getMonth();
        let dayDiff = end.getDate() - start.getDate();
        
        // Adjust for negative days
        if (dayDiff < 0) {
            monthDiff--;
            // Get days in the previous month
            const prevMonth = new Date(end.getFullYear(), end.getMonth(), 0);
            dayDiff = prevMonth.getDate() - start.getDate() + end.getDate();
        }
        
        // Adjust for negative months
        if (monthDiff < 0) {
            yearDiff--;
            monthDiff += 12;
        }
        
        console.log('calculateExpectedPeriodType: yearDiff=' + yearDiff + ', monthDiff=' + monthDiff + ', dayDiff=' + dayDiff);
        
        // Determine expected period type
        if (yearDiff === 0 && monthDiff === 0 && dayDiff === 0) {
            // Same day
            this.expectedPeriodType = '1'; // Annual (0 years but considered 1 day)
        } else if (yearDiff === 0) {
            // Less than 1 year
            this.expectedPeriodType = '2';
        } else if (yearDiff === 1 && monthDiff === 0 && dayDiff === 0) {
            // Exactly 1 year
            this.expectedPeriodType = '1';
        } else {
            // More than 1 year
            this.expectedPeriodType = '3';
        }
        
        console.log('expectedPeriodType: ' + this.expectedPeriodType);
        
        // For auto-determined COBs, automatically set the period type
        if (this.isAutoDeterminePeriodType && this.isEditing) {
            // Only set if different from current
            if (this.periodType !== this.expectedPeriodType) {
                console.log('Auto-setting periodType from ' + this.periodType + ' to ' + this.expectedPeriodType);
                this.periodType = this.expectedPeriodType;
                
                // If period type becomes Short, set default short basis if not set
                if (this.periodType === '2' && !this.shortBasis) {
                    this.shortBasis = '2'; // Default to Pro-Rata Basis
                }
            }
        }
        
        this.validatePeriodType();
    }

    validatePeriodType() {
        // Skip validation for auto-determined COBs and premium calculation COBs
        if (this.isAutoDeterminePeriodType || this.showPremiumCalculation) {
            this.showPeriodTypeValidationError = false;
            return;
        }
        
        if (!this.expectedPeriodType || !this.periodType) {
            this.showPeriodTypeValidationError = false;
            return;
        }
        
        if (this.periodType !== this.expectedPeriodType) {
            this.showPeriodTypeValidationError = true;
            
            const expectedTypeLabel = this.insuranceTypeOptions.find(
                opt => opt.value === this.expectedPeriodType
            )?.label || 'the expected type';
            
            const currentTypeLabel = this.insuranceTypeOptions.find(
                opt => opt.value === this.periodType
            )?.label || 'the selected type';
                    
            this.periodTypeValidationMessage = 
                `Berdasarkan tanggal yang dipilih, seharusnya Insurance Period Type adalah "${expectedTypeLabel}", namun Anda memilih type "${currentTypeLabel}". Mohon periksa kembali pilihan Insurance Period Type Anda.`;
        } else {
            this.showPeriodTypeValidationError = false;
        }
    }

    async confirmSaveWithValidationError() {
        return new Promise((resolve) => {
            const userConfirmed = confirm(
                'The selected Insurance Type does not match the expected type based on your dates. Do you want to continue saving anyway?'
            );
            resolve(userConfirmed);
        });
    }

    // ------ Event handlers ------
    handleEdit() {
        this.isEditing = true;
        if(this.isOwner == false){
            alert('Anda tidak memiliki akses/diperbolehkan merubah Opportunity ini!');
            this.isEditing = false;
            return;
        }
        if(this.stage === 'Closed Won' || this.stage === 'Closed Lost' || this.stage === 'Cancel'){
            alert('Tidak dapat melakukan perubahan pada stage Closed atau Cancel');
            this.isEditing = false;
            return;
        }
        
        this.originalForm = {
            periodType: this.periodType,
            years: this.years,
            shortBasis: this.shortBasis,
            startDate: this.startDate,
            endDate: this.endDate,
            percentage: this.percentage,
            premiumCalculation: this.premiumCalculation
        };
        
        if (this.startDate && this.endDate) {
            this.calculateExpectedPeriodType();
        }
    }

    handleCancel() {
        if (this.originalForm) {
            this.periodType = this.originalForm.periodType;
            this.years = this.originalForm.years;
            this.shortBasis = this.originalForm.shortBasis;
            this.startDate = this.originalForm.startDate;
            this.endDate = this.originalForm.endDate;
            this.percentage = this.originalForm.percentage;
            this.premiumCalculation = this.originalForm.premiumCalculation;
        }
        this.isEditing = false;
        
        this.calculateDuration();
        this.calculateExpectedPeriodType();
    }

    handleSchemaChange(event) { 
        this.schemaType = event.detail.value; 
        this.calculateDuration(); 
    }

    handleYearsChange(event) { 
        this.years = this.isAnnual ? 1 : event.detail.value; 
        this.calculateDuration(); 
    }

    handleShortBasisChange(event) { 
        this.shortBasis = event.detail.value; 
        this.calculateDuration(); 
    }

    handlePercentageChange(event) { 
        this.percentage = event.detail.value; 
        this.calculateDuration(); 
    }

    handleStartDateChange(event) {
        console.log('handleStartDateChange called with value: ' + event.detail.value);
        this.startDate = event.detail.value;
        if (this.isAnnual && this.startDate) {
            const dt = new Date(this.startDate);
            dt.setFullYear(dt.getFullYear() + 1);
            this.endDate = dt.toISOString().slice(0, 10);
            console.log('Auto-set endDate for Annual: ' + this.endDate);
        }
        this.calculateDuration();
        this.calculateExpectedPeriodType();
        
        if (this.isAutoDeterminePeriodType && this.isEditing && this.originalForm) {
            if (this.periodType !== this.originalForm.periodType) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Insurance Type Updated',
                    message: `Insurance type has been automatically changed to ${this.insuranceTypeOptions.find(opt => opt.value === this.periodType)?.label} based on the new date range.`,
                    variant: 'info'
                }));
            }
        }
        
        this.adjustPremiumCalculationBasedOnDuration();
    }

    handleEndDateChange(event) { 
        console.log('handleEndDateChange called with value: ' + event.detail.value);
        this.endDate = event.detail.value; 
        this.calculateDuration();
        this.calculateExpectedPeriodType();
        
        if (this.isAutoDeterminePeriodType && this.isEditing && this.originalForm) {
            if (this.periodType !== this.originalForm.periodType) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Insurance Type Updated',
                    message: `Insurance type has been automatically changed to ${this.insuranceTypeOptions.find(opt => opt.value === this.periodType)?.label} based on the new date range.`,
                    variant: 'info'
                }));
            }
        }
        
        this.adjustPremiumCalculationBasedOnDuration();
    }

    handleRowTypeChange(event) {
        const year = parseInt(event.target.dataset.year, 10);
        const type = event.detail.value;
        this.adjustmentRows = this.adjustmentRows.map(r => {
            if (r.year === year) {
                let newPct = (type === '2') ? this.calculatedRate : r.percentage;
                return { 
                    ...r, 
                    type, 
                    percentage: newPct,
                    showBasisPicklist: r.showBasisPicklist
                };
            }
            return r;
        });
        this.updateYearsMonthsInfo();
    }

    // Sanitizer used by multiple handlers
    sanitizePercentageString(raw) {
        if (raw == null) return '';
        let s = String(raw);

        s = s.replace(/,/g, '.');
        s = s.replace(/[^0-9.]/g, '');

        const parts = s.split('.');
        if (parts.length > 1) {
            s = parts.shift() + (parts.length ? '.' + parts.join('') : '');
        }

        if (s.startsWith('.')) {
            s = '0' + s;
        }

        return s;
    }

    // Live input enforcement to improve UX
    handleRowPercentageInput(event) {
        const input = event.target;
        const original = input.value;
        const sanitized = this.sanitizePercentageString(original);

        if (sanitized !== original) {
            input.value = sanitized;
        }

        // Keep local model in sync while typing WITHOUT formatting
        const year = parseInt(input.dataset.year, 10);
        const percentage = sanitized;
        this.adjustmentRows = this.adjustmentRows.map(r =>
            r.year === year ? { ...r, percentage: percentage } : r
        );
    }

    // Sanitize pasted content and apply immediately
    handleRowPercentagePaste(event) {
        event.preventDefault();
        const paste = (event.clipboardData || window.clipboardData).getData('text') || '';
        const sanitized = this.sanitizePercentageString(paste);
        const input = event.target;
        input.value = sanitized;

        // Sync model to reflect paste immediately WITHOUT formatting
        const year = parseInt(input.dataset.year, 10);
        this.adjustmentRows = this.adjustmentRows.map(r =>
            r.year === year ? { ...r, percentage: sanitized } : r
        );
    }

    handleRowPercentageKeyDown(event) {
        const key = event.key;

        // allow control/navigation keys
        if (
            key === 'Backspace' || key === 'Delete' ||
            key === 'ArrowLeft' || key === 'ArrowRight' ||
            key === 'Home' || key === 'End' ||
            event.ctrlKey || event.metaKey || event.altKey
        ) {
            return;
        }

        // we only care about inserting a dot character
        if (key !== '.' && key !== ',') return;

        const input = event.target;
        const value = input.value || '';
        const selStart = input.selectionStart ?? value.length;
        const selEnd = input.selectionEnd ?? value.length;

        // compute what the value would become after inserting the key
        const before = value.slice(0, selStart);
        const after = value.slice(selEnd);
        const wouldBe = before + '.' + after;

        // allow if resulting value contains at most one dot; otherwise block
        const dotCount = (wouldBe.match(/\./g) || []).length;
        if (dotCount > 1) {
            event.preventDefault();
        } else {
            // if user typed comma, convert it to dot for immediate insertion
            if (key === ',') {
                event.preventDefault();
                const newValue = wouldBe; // already uses dot above
                input.value = newValue;
                // move caret after inserted dot
                const newPos = before.length + 1;
                input.setSelectionRange(newPos, newPos);

                // sync model immediately WITHOUT formatting
                const year = parseInt(input.dataset.year, 10);
                const percentage = this.sanitizePercentageString(newValue);
                this.adjustmentRows = this.adjustmentRows.map(r =>
                    r.year === year ? { ...r, percentage: percentage } : r
                );
            }
        }
    }

    // Integrate with existing change handler but sanitize input first
    handleRowPercentageChange(event) {
        const year = parseInt(event.target.dataset.year, 10);

        // lightning-input 'change' gives value in event.detail.value, fallback to target.value
        const raw = event?.detail?.value ?? event.target.value;
        const percentage = this.sanitizePercentageString(raw);

        // Update the adjustmentRows with the sanitized percentage
        // DO NOT format to 6 decimals here - only store the raw value
        this.adjustmentRows = this.adjustmentRows.map(r =>
            r.year === year ? { ...r, percentage: percentage } : r
        );

        this.updateYearsMonthsInfo();
    }

    // ------ Core calculation ------
    calculateDuration() {
        if (!this.startDate || !this.endDate) {
            this.dayCount = null; 
            this.yearsMonthsInfo = null; 
            this.calculatedRate = null; 
            this.adjustmentRows = [];
            this.expectedPeriodType = null;
            this.showPeriodTypeValidationError = false;
            return;
        }
        
        console.log('calculateDuration start');
        const start = new Date(this.startDate);
        const end = new Date(this.endDate);
        this.dayCount = Math.floor((end - start) / (1000 * 60 * 60 * 24));
        let y = end.getFullYear() - start.getFullYear();
        let m = end.getMonth() - start.getMonth();
        let d = end.getDate() - start.getDate();
        
        if (d < 0) {
            m--;
            const prevMonth = new Date(end.getFullYear(), end.getMonth(), 0);
            d = prevMonth.getDate() - start.getDate() + end.getDate();
        }
        
        if (m < 0) {
            y--;
            m += 12;
        }
        
        this._computedYears = y;
        this._computedMonths = m;
        
        console.log('Calculated: y=' + y + ', m=' + m + ', d=' + d);

        // Calculate expected period type
        this.calculateExpectedPeriodType();
        
        console.log('After calculateExpectedPeriodType: periodType=' + this.periodType + ', expectedPeriodType=' + this.expectedPeriodType);

        // Calculate rate based on UPDATED period type
        if ((this.isShort && this.isProRataBasis) || 
            (['301', '302', '303'].includes(this.cob) && this.premiumCalculation === '4')) {
            this.calculatedRate = parseFloat((this.dayCount / 365).toFixed(6));
            console.log('Short term or Pro Rata rate calculated: ' + this.calculatedRate);
        } else if ((this.isLongTerm || this.isPremiumLongTerm) && y >= 1) {
            const fullYearsLater = new Date(start);
            fullYearsLater.setFullYear(start.getFullYear() + y);
            const extraMs = end - fullYearsLater;
            const extraDays = Math.floor(extraMs / (1000 * 60 * 60 * 24));
            this.calculatedRate = extraDays > 0 ? parseFloat((extraDays / 365).toFixed(6)) : 0;
            console.log('Long term rate calculated: ' + this.calculatedRate + ', extraDays=' + extraDays);
        } else {
            this.calculatedRate = null;
            console.log('No rate calculated');
        }

        // Update the years/months info
        this.updateYearsMonthsInfo();

        // Handle Long Term schema rows if applicable
        if (this.isLongTerm && this.schemaType != null) {
            const hasExtra = m > 0 || d > 0;
            const rowCount = y + (hasExtra ? 1 : 0);
            const newRows = [];
            
            console.log('🔧 Building Long Term adjustment rows:');
            console.log('   - Years:', y);
            console.log('   - Has extra:', hasExtra);
            console.log('   - Row count:', rowCount);
            console.log('   - Existing transactions:', this.transactions.length);
            
            // Find the previous last row (extra row) from existing data
            let previousLastRowYear = null;
            let previousLastRowValue = null;
            
            if (this.transactions.length > 0) {
                // Get the maximum year from existing transactions
                const existingYears = this.transactions.map(txn => txn.Year__c);
                const maxExistingYear = existingYears.length > 0 ? Math.max(...existingYears) : 0;
                
                // Check if the max year was an extra row (Short period type)
                const previousLastRow = this.transactions.find(txn => 
                    txn.Year__c === maxExistingYear && 
                    (txn.Short_Period_Type__c === '2' || txn.Insurance_Period_Type__c === '2')
                );
                
                if (previousLastRow) {
                    previousLastRowYear = maxExistingYear;
                    previousLastRowValue = previousLastRow.Value__c;
                    console.log('   - Previous last row found: Year', previousLastRowYear, 'Value:', previousLastRowValue);
                }
            }
            
            for (let i = 0; i < rowCount; i++) {
                const yearNum = i + 1;
                const isExtraRow = hasExtra && i === rowCount - 1;
                
                // Find existing data
                const existingTxn = this.transactions.find(txn => txn.Year__c === yearNum);
                const oldUiRow = this.adjustmentRows.find(row => row.year === yearNum);
                
                let recordId = oldUiRow?.recordId || existingTxn?.Id || null;
                let rowType = null;
                let rowPercentage = null;
                let showBasisPicklist = false;
                
                if (yearNum === 1) {
                    // Year 1 is always 100%
                    rowPercentage = 100;
                    rowType = null;
                    showBasisPicklist = false;
                    console.log(`     Year ${yearNum}: Setting to 100% (Year 1)`);
                } 
                else if (isExtraRow) {
                    // This is the NEW last row (extra row)
                    // Always use calculated rate for Pro-Rata basis
                    rowType = '2'; // Pro-Rata basis
                    rowPercentage = this.calculatedRate;
                    showBasisPicklist = true;
                    console.log(`     Year ${yearNum}: Extra row, setting to calculated rate: ${this.calculatedRate}`);
                } 
                else {
                    // Annual rows (not year 1, not extra)
                    
                    // Check if this was the PREVIOUS last row (extra row)
                    if (yearNum === previousLastRowYear) {
                        // This was the previous extra row, now it's an annual row
                        // EMPTY it so user can fill it
                        rowType = '2'; // Default to Pro-Rata basis
                        rowPercentage = null; // Empty for user to fill
                        showBasisPicklist = false;
                        console.log(`     Year ${yearNum}: Was previous last row, emptying for annual input`);
                    }
                    else if (yearNum <= previousLastRowYear) {
                        // This is an existing annual row (before the previous last row)
                        // Keep its value
                        rowType = oldUiRow?.type || existingTxn?.Short_Period_Type__c || '2';
                        rowPercentage = oldUiRow?.percentage ?? existingTxn?.Value__c ?? null;
                        showBasisPicklist = false;
                        console.log(`     Year ${yearNum}: Existing annual row, keeping value: ${rowPercentage}`);
                    }
                    else {
                        // This is a NEW annual row (added because period was extended)
                        // Empty for user to fill
                        rowType = '2'; // Default to Pro-Rata basis
                        rowPercentage = null; // Empty for user input
                        showBasisPicklist = false;
                        console.log(`     Year ${yearNum}: New annual row, emptying for user input`);
                    }
                }
                
                newRows.push({ 
                    recordId: recordId, 
                    year: yearNum, 
                    percentage: rowPercentage, 
                    type: rowType,
                    showBasisPicklist: showBasisPicklist
                });
            }
            
            this.adjustmentRows = [...newRows];
            console.log('   Final adjustmentRows:', JSON.stringify(this.adjustmentRows, null, 2));
        } else {
            console.log('   Not Long Term or no schema type, clearing adjustmentRows');
            this.adjustmentRows = [];
        }
    }

    updateYearsMonthsInfo() {
        console.log('updateYearsMonthsInfo called with:');
        console.log('_computedYears=' + this._computedYears);
        console.log('_computedMonths=' + this._computedMonths);
        console.log('calculatedRate=' + this.calculatedRate);
        console.log('periodType=' + this.periodType);

        // Handle COB 301/302/303 premium calculation cases
        if (['301', '302', '303'].includes(this.cob)) {
            if (this.premiumCalculation === '4') {
                const formattedRate = this.calculatedRate !== null && this.calculatedRate !== undefined 
                    ? this.calculatedRate.toFixed(6)
                    : '0.000000';
                this.yearsMonthsInfo = `Rate ${formattedRate}`;
            } else if (this.premiumCalculation === '5') {
                this.yearsMonthsInfo = `Percentage ${this.percentage || 0}%`;
            } else if (this.premiumCalculation === '6' || this.premiumCalculation === '2' || this.premiumCalculation === '3') {
                const y = this._computedYears || 0;
                const m = this._computedMonths || 0;
                let base = `${y} Year${y !== 1 ? 's' : ''}`;
                if (m > 0) {
                    base += ` and ${m} Month${m !== 1 ? 's' : ''}`;
                }
                
                if (this.calculatedRate !== null && this.calculatedRate !== undefined) {
                    const totalRate = y + this.calculatedRate;
                    const formattedRate = totalRate.toFixed(6);
                    this.yearsMonthsInfo = `${base} | Rate: ${formattedRate}`;
                } else {
                    const formattedRate = y.toFixed(6);
                    this.yearsMonthsInfo = `${base} | Rate: ${formattedRate}`;
                }
            }
            console.log('yearsMonthsInfo for COB 301/302/303: ' + this.yearsMonthsInfo);
            return;
        }

        // Handle Annual case
        if (this.isAnnual) { 
            this.yearsMonthsInfo = '1 Year'; 
            console.log('yearsMonthsInfo for Annual: ' + this.yearsMonthsInfo);
            return; 
        }

        // Handle Short Period case
        if (this.isShort) {
            console.log('this.isShort');
            if (this.isProRataBasis) { 
                const formattedRate = this.calculatedRate !== null && this.calculatedRate !== undefined 
                    ? this.calculatedRate.toFixed(6)
                    : '0.000000';
                this.yearsMonthsInfo = `Rate ${formattedRate}`; 
                console.log('this.isProRataBasis, yearsMonthsInfo: ' + this.yearsMonthsInfo); 
            } else { 
                this.yearsMonthsInfo = `Percentage ${this.percentage || 0}%`; 
                console.log('this.isPercentageBasis, yearsMonthsInfo: ' + this.yearsMonthsInfo);
            }
            return;
        }

        // Handle Long Term case
        const y = this._computedYears || 0;
        const m = this._computedMonths || 0;

        let base = `${y} Year${y !== 1 ? 's' : ''}`; 

        if (m > 0) {
            base += ` and ${m} Month${m !== 1 ? 's' : ''}`;
        }

        console.log('Long Term calculation: y=' + y + ', m=' + m);
        console.log('calculatedRate=' + this.calculatedRate);

        if (this.calculatedRate !== null && this.calculatedRate !== undefined) {
            const totalRate = y + this.calculatedRate;
            const formattedRate = totalRate.toFixed(6);
            this.yearsMonthsInfo = `${base} | Rate: ${formattedRate}`;
        } else {
            this.yearsMonthsInfo = base;
        }

        console.log('Final yearsMonthsInfo: ' + this.yearsMonthsInfo);
    }
    
    async handleSave() {
        console.log('💾 ======== HANDLE SAVE ========');
        console.log('   Starting save process with validation...');
        
        // 1. Validation for limited forms
        if (this.isLimitedForm) {
            if (!this.startDate) {
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Start Date is required.',
                    variant: 'error'
                }));
                return;
            }
            
            if (this.isEndDateRequired && !this.endDate) {
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'End Date is required.',
                    variant: 'error'
                }));
                return;
            }
        } else {
            // Validation for non-limited forms
            if (!this.startDate || !this.endDate) {
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Start Date and End Date are required.',
                    variant: 'error'
                }));
                return;
            }
        }

        // 2. Validate date range
        if (this.startDate && this.endDate) {
            const start = new Date(this.startDate);
            const end = new Date(this.endDate);
            if (isNaN(start.getTime()) || isNaN(end.getTime()) || start > end) {
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Start Date must be before or equal to End Date.',
                    variant: 'error'
                }));
                return;
            }
        }

        // 3. Check for period type validation warning
        if (!this.isLimitedForm && this.showPeriodTypeValidationError) {
            const userConfirmed = await this.confirmSaveWithValidationError();
            if (!userConfirmed) {
                this.isLoading = false;
                return;
            }
        }

        // 4. Validate main percentage input (for Short-Period and Premium Calculation)
        let validationErrors = [];
        
        // Validate percentage for Short-Period with Percentage basis
        if (!this.isLimitedForm && this.periodType === '2' && this.shortBasis === '1') {
            if (this.percentage === null || this.percentage === undefined || this.percentage === '') {
                validationErrors.push('Percentage is required for Short-Period with Percentage basis.');
            } else {
                const percentageNum = parseFloat(this.percentage);
                if (isNaN(percentageNum) || percentageNum < 0 || percentageNum > 100) {
                    validationErrors.push('Percentage for Short-Period must be a number between 0 and 100.');
                }
            }
        }
        
        // Validate percentage for Premium Calculation with Percentage type
        if (this.isPremiumPercentageInput) {
            if (this.percentage === null || this.percentage === undefined || this.percentage === '') {
                validationErrors.push('Percentage is required for Premium Calculation with Percentage type.');
            } else {
                const percentageNum = parseFloat(this.percentage);
                if (isNaN(percentageNum) || percentageNum < 0 || percentageNum > 100) {
                    validationErrors.push('Percentage for Premium Calculation must be a number between 0 and 100.');
                }
            }
        }

        // 5. Validate adjustment rows percentages
        if (this.adjustmentRows.length > 0) {
            for (const row of this.adjustmentRows) {
                // Skip year 1 (always 100%)
                if (row.year === 1) continue;
                
                if (row.percentage !== null && row.percentage !== undefined && row.percentage !== '') {
                    const percentageNum = parseFloat(row.percentage);
                    
                    // Check if it's a valid number
                    if (isNaN(percentageNum)) {
                        validationErrors.push(`Invalid percentage value for year ${row.year}. Please enter a valid number.`);
                    }
                    
                    // Check range for Discounted Premium schema
                    if (this.schemaType === 'Discounted Premium') {
                        if (percentageNum < 0 || percentageNum > 100) {
                            validationErrors.push(`Percentage for year ${row.year} must be between 0 and 100 for Discounted Premium schema.`);
                        }
                    }
                    
                    // Check range for Sum Insured Adjustment schema
                    if (this.schemaType === 'Sum Insured Adjustment') {
                        if (percentageNum < 0 || percentageNum > 100) {
                            validationErrors.push(`Percentage for year ${row.year} must be between 0 and 100 for Sum Insured Adjustment schema.`);
                        }
                    }
                } else if (row.showBasisPicklist && row.type === '1') {
                    // If it's a percentage basis row and percentage is empty
                    validationErrors.push(`Percentage for year ${row.year} is required when using Percentage basis.`);
                }
            }
        }

        // 6. Validate Number of Years (if applicable)
        if (this.years !== null && this.years !== undefined) {
            const yearsNum = parseInt(this.years);
            if (isNaN(yearsNum) || yearsNum < 0) {
                validationErrors.push('Number of Years must be a positive number.');
            }
        }

        // 7. Show validation errors if any
        if (validationErrors.length > 0) {
            this.isLoading = false;
            
            // Create a formatted error message
            let errorMessage = 'Please fix the following errors:\n\n';
            validationErrors.forEach((error, index) => {
                errorMessage += `${index + 1}. ${error}\n`;
            });
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Validation Error',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky' // Keep the toast visible longer
            }));
            
            // Also log to console for debugging
            console.error('❌ Validation errors:', validationErrors);
            return;
        }

        // 8. Process based on period type for non-limited forms
        if (!this.isLimitedForm) {
            if (this.periodType === '2' && this.shortBasis === '1') {
                // Short-Period with Percentage basis
                this.calculatedRate = null;
                this.years = null;
                this._computedYears = null;
            } else if (this.periodType === '2' && this.shortBasis === '2') {
                // Short-Period with Pro-Rata basis
                this.percentage = null;
                this.years = null;
                this._computedYears = null;
                
                if (this.calculatedRate !== null && this.calculatedRate !== undefined) {
                    this.calculatedRate = parseFloat(this.calculatedRate.toFixed(6));
                }
            } else if (this.periodType === '1') {
                // Annual
                this.calculatedRate = null;
                this.years = 1;
            } else if (this.periodType === '3') {
                // Long Term
                if (this.calculatedRate !== null && this.calculatedRate !== undefined) {
                    this.calculatedRate = parseFloat(this.calculatedRate.toFixed(6));
                }
                
                if (!this.years && this._computedYears) {
                    this.years = this._computedYears;
                }
            }
        }

        // 9. Start loading
        this.isLoading = true;
        
        // 10. Prepare transaction rows with proper number formatting
        const transactionRows = this.adjustmentRows.map(row => {
            let rowPercentage = row.percentage;
            let rowType = row.type;
            
            if (row.year > 1 && rowPercentage) {
                if (this.schemaType === 'Sum Insured Adjustment') {
                    // Convert to number and then to string to ensure it's a valid number
                    const num = parseFloat(rowPercentage);
                    rowPercentage = isNaN(num) ? '0' : String(num);
                } else if (this.schemaType === 'Discounted Premium') {
                    if (rowType === '2' && this.calculatedRate !== null) {
                        rowPercentage = this.calculatedRate.toFixed(6);
                    } else {
                        const num = parseFloat(rowPercentage);
                        rowPercentage = isNaN(num) ? '0' : num.toFixed(6);
                    }
                }
            }
            
            return {
                recordId: row.recordId,
                year: row.year,
                percentage: rowPercentage,
                type: rowType
            };
        });

        // 11. Prepare data to save
        const dataToSave = {
            opportunityId: this.recordId, 
            periodType: this.periodType, 
            startDate: this.startDate, 
            endDate: this.endDate,
            shortBasis: this.shortBasis, 
            percentage: this.percentage, 
            schemaType: this.schemaType, 
            numberOfYear: this.years,
            totalYears: this._computedYears, 
            totalMonth: this._computedMonths, 
            periodRate: this.calculatedRate !== null && this.calculatedRate !== undefined 
                ? parseFloat(this.calculatedRate.toFixed(6)) 
                : null,
            premiumCalculation: this.premiumCalculation,
            transactionRows: transactionRows
        };
        
        console.log('📤 dataToSave:', JSON.stringify(dataToSave, null, 2));
        
        try {
            // 12. Save data
            await saveInsuranceDetails({ wrapper: dataToSave });
            
            // 13. Show success message
            this.dispatchEvent(new ShowToastEvent({ 
                title: 'Success', 
                message: 'Insurance Period details have been saved.', 
                variant: 'success' 
            }));
            
            // 14. Refresh wired data using refreshApex
            await Promise.all([
                refreshApex(this.wiredOppResult),
                refreshApex(this.wiredTxnResult)
            ]);
            
            // 15. Exit edit mode
            this.isEditing = false;
            
            // 16. Navigate to record page after a brief delay
            setTimeout(() => {
                this[NavigationMixin.Navigate]({ 
                    type: 'standard__recordPage', 
                    attributes: { 
                        recordId: this.recordId, 
                        actionName: 'view' 
                    } 
                });
            }, 1000);
            
        } catch (error) {
            // Handle error - stay in edit mode
            this.isEditing = true;
            
            let message = 'An unknown error occurred while saving.';
            if (error && error.body && error.body.message) {
                message = error.body.message;
            } else if (error && error.message) {
                message = error.message;
            }
            
            this.dispatchEvent(new ShowToastEvent({ 
                title: 'Error Saving Record', 
                message: message, 
                variant: 'error' 
            }));
            
            console.error('❌ Save error:', error);
        } finally { 
            this.isLoading = false; 
        }
        
        console.log('✅ Save process completed');
        console.log('==========================================');
    }

    // Helper method to refresh data after save
    refreshData() {
        this.isLoading = true;
        
        getOpportunity({ recordId: this.recordId })
            .then(data => {
                this.oppRecord = data;
                this.periodType = data.Insurance_Period_Type__c;
                this.shortBasis = data.Short_Period_Basis__c;
                this.startDate = data.Start_Date_Periode__c;
                this.endDate = data.End_Date_Periode__c;
                this.percentage = data.Percentage__c;
                this.premiumCalculation = data.premium_calculation__c;
                this.calculateDuration();
                this.calculateExpectedPeriodType();
                
                return getTransactions({ opportunityId: this.recordId });
            })
            .then(data => {
                this.transactions = data;
                if (data.length > 0) {
                    this.schemaType = data[0].Schema_Type__c;
                }
                
                this.calculateDuration();
                this.calculateExpectedPeriodType();
            })
            .catch(error => {
                console.error('Error refreshing data:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}