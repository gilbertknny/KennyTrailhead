import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
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
    premiumCalculation = null; // NEW: Added for Premium Calculation

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
    get isLongTerm() { return this.periodType === '3'; }
    get isAnnual() { return this.periodType === '1'; }
    get isShort() { return this.periodType === '2'; }
    get isPercentageBasis() { return this.shortBasis === '1'; }
    get isProRataBasis() { return this.shortBasis === '2'; }
    get showInfo() { return !this.isAnnual; }
    
    // NEW: Getter for limited form (only show dates)
    get isLimitedForm() {
        return ['101', '602', '851', '852'].includes(this.cob);
    }
    
    // NEW: Getter to check if end date is required
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
    // NEW: Premium Calculation Options
    get premiumCalculationOptions() {
        return [
            { label: 'Flat', value: '1' },                         // Only for exactly 1 year
            { label: 'Decreasing Sum Insured', value: '2' },      // For more than 1 year
            { label: 'Discount Rate', value: '3' },               // For more than 1 year
            { label: 'Pro Rata', value: '4' },                    // For less than 1 year (default)
            { label: 'Percentage', value: '5' },                  // For less than 1 year
            { label: 'Long Period', value: '6' }                  // For more than 1 year (default)
        ];
    }
    
    // NEW: Restricted Premium Calculation Options based on duration
        // ------ NEW: Premium Calculation Restriction Logic ------
    get allowedPremiumCalculationOptions() {
        // If we don't have dates, return all options
        if (!this.startDate || !this.endDate) {
            return this.premiumCalculationOptions;
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
            // Less than 1 year - Allow "Pro Rata" (value: '4') and "Percentage" (value: '5')
            return this.premiumCalculationOptions.filter(option => 
                option.value === '4' || option.value === '5'
            );
        } else if (actualYearDiff === 1 && monthDiff === 0 && dayDiff === 0) {
            // Exactly 1 year - Only allow "Flat" (value: '1')
            return this.premiumCalculationOptions.filter(option => option.value === '1');
        } else {
            // More than 1 year - Allow "Long Period" (value: '6'), "Decreasing Sum Insured" (value: '2'), 
            // and "Discount Rate" (value: '3')
            return this.premiumCalculationOptions.filter(option => 
                option.value === '6' || option.value === '2' || option.value === '3'
            );
        }
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
        
        let newPremiumCalculation = null;
        
        if (actualYearDiff === 0) {
            // Less than 1 year - Default to "Pro Rata" (4), but user can also select "Percentage" (5)
            // Only set default if not already set to one of the allowed options
            if (!this.premiumCalculation || 
                (this.premiumCalculation !== '4' && this.premiumCalculation !== '5')) {
                newPremiumCalculation = '4';
            }
        } else if (actualYearDiff === 1 && monthDiff === 0 && dayDiff === 0) {
            // Exactly 1 year - Set to "Flat" (1)
            newPremiumCalculation = '1';
        } else {
            // More than 1 year - Default to "Long Period" (6), but user can also select 
            // "Decreasing Sum Insured" (2) or "Discount Rate" (3)
            // Only set default if not already set to one of the allowed options
            if (!this.premiumCalculation || 
                (this.premiumCalculation !== '6' && 
                 this.premiumCalculation !== '2' && 
                 this.premiumCalculation !== '3')) {
                newPremiumCalculation = '6';
            }
        }
        
        // Only update if we have a new value to set
        if (newPremiumCalculation !== null && this.premiumCalculation !== newPremiumCalculation) {
            this.premiumCalculation = newPremiumCalculation;
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

    connectedCallback() {
        console.log('last update 10/12/2025 14.36');
        console.log('opptyId: ' + this.recordId);
        console.log('isOwner: ' + this.isOwner);
    }

    // ------ Lifecycle & Data ------
    @wire(getOpportunity, { recordId: '$recordId' })
    wiredOpportunity(result) {
        try {
            this.wiredOppResult = result;
            const { data, error } = result;
            if (data) {
                this.error = undefined;
                this.oppRecord = data;
                this.periodType = data.Insurance_Period_Type__c;
                this.shortBasis = data.Short_Period_Basis__c;
                this.startDate = data.Start_Date_Periode__c;
                this.endDate = data.End_Date_Periode__c;
                this.percentage = data.Percentage__c;
                this.stage = data.StageName;
                this.cob = data.COB__c;
                this.premiumCalculation = data.premium_calculation__c; // NEW: Load premium calculation
                this.isOwner = data.isOwner__c;
                this.calculateDuration();
                this.calculateExpectedPeriodType();
                // NEW: Adjust premium calculation on load
                this.adjustPremiumCalculationBasedOnDuration();
                this.originalForm = {
                    periodType: this.periodType,
                    years: this.years,
                    shortBasis: this.shortBasis,
                    startDate: this.startDate,
                    endDate: this.endDate,
                    percentage: this.percentage,
                    premiumCalculation: this.premiumCalculation // NEW: Include in original form
                };
                this.isTypeLocked = true;
                console.log('COB='+this.cob);
                console.log('premiumCalculation='+this.premiumCalculation);
                console.log('stage='+this.stage);
            } else if (error) {
                this.error = error;
                this.isLoading = false;
                console.error('Opportunity load error:', error);
            }
        } catch (err) {
            console.error('Error in wiredOpportunity:', err);
            this.isLoading = false;
        }
    }

    @wire(getTransactions, { opportunityId: '$recordId' })
    wiredTransactions(result) {
        this.wiredTxnResult = result;
        this.isLoading = false;
        const { data, error } = result;

        if (data) {
            this.transactions = data;
            this.error = undefined;
            if (data.length > 0) {
                this.schemaType = data[0].Schema_Type__c;
            }

            this.adjustmentRows = [];

            if (this.oppRecord) {
                this.calculateDuration();
                this.calculateExpectedPeriodType();
            }
        } else if (error) {
            this.error = error;
            console.error('Transactions load error', error);
        }
    }

    get isReadOnly() {
        return this.stage === 'Closed Won' || this.stage === 'Closed Lost' || this.stage === 'Cancel' || this.isEditing == false || this.isOwner == false;
    }

    get isNotOwner(){
        return !this.isOwner;
    }

    // ------ NEW: Premium Calculation Handler ------
    handlePremiumCalculationChange(event) {
        this.premiumCalculation = event.detail.value;
    }

    // ------ NEW: Premium Calculation Restriction Logic ------
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
        
        let newPremiumCalculation = null;
        
        if (actualYearDiff === 0) {
            // Less than 1 year - Set to "Pro Rata"
            newPremiumCalculation = '4';
        } else if (actualYearDiff === 1 && monthDiff === 0 && dayDiff === 0) {
            // Exactly 1 year - Set to "Flat"
            newPremiumCalculation = '1';
        } else {
            // More than 1 year - Set to "Long Period"
            newPremiumCalculation = '6';
        }
        
        // Only update if the value is different
        if (this.premiumCalculation !== newPremiumCalculation) {
            this.premiumCalculation = newPremiumCalculation;
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
        
        // Calculate difference in years
        const yearDiff = end.getFullYear() - start.getFullYear();
        const monthDiff = end.getMonth() - start.getMonth();
        const dayDiff = end.getDate() - start.getDate();
        
        let actualYearDiff = yearDiff;
        if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
            actualYearDiff--;
        }
        
        // Determine expected period type
        if (actualYearDiff === 0) {
            this.expectedPeriodType = '2'; // Short Period (less than 1 year)
        } else if (actualYearDiff === 1 && monthDiff === 0 && dayDiff === 0) {
            this.expectedPeriodType = '1'; // Annual (exactly 1 year)
        } else {
            this.expectedPeriodType = '3'; // Long Term (more than 1 year)
        }
        
        this.validatePeriodType();
    }

    validatePeriodType() {
        // Skip validation if premium calculation is shown (COB 301, 302, 303)
        if (this.showPremiumCalculation) {
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
    
    // Keep the existing handleSave method, but we need to adjust one part:

    // ------ Event handlers ------
    handleEdit() {
        this.isEditing = true;
        if(this.isOwner == false){
            alert('Anda tidak memiliki akses/diperbolehkan merubah Opportunity ini!');
            this.isEditing = false;
        }
        if(this.stage === 'Closed Won' || this.stage === 'Closed Lost' || this.stage === 'Cancel'){
            alert('Tidak dapat melakukan perubahan pada stage Closed atau Cancel');
            this.isEditing = false;
        }
    }

    handleCancel() {
        this.isEditing = false;
    }

    handleSchemaChange(event) { 
        this.schemaType = event.detail.value; 
        this.calculateDuration(); 
    }

    handleTypeChange(event) {
        // Handle both lightning-radio-group and custom HTML radio buttons
        const newType = event.detail ? event.detail.value : event.target.value;
        
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

        this.percentage = null; this.startDate = null; this.endDate = null;
        this.calculatedRate = null; this.adjustmentRows = []; this.dayCount = null; this.yearsMonthsInfo = null;
        this.years = (newType === '1') ? 1 : null;

        this.calculateDuration();
        this.calculateExpectedPeriodType();
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
        this.startDate = event.detail.value;
        if (this.isAnnual && this.startDate) {
            const dt = new Date(this.startDate);
            dt.setFullYear(dt.getFullYear() + 1);
            this.endDate = dt.toISOString().slice(0, 10);
        }
        this.calculateDuration();
        this.calculateExpectedPeriodType();
        // NEW: Adjust premium calculation based on new dates
        this.adjustPremiumCalculationBasedOnDuration();
    }

    handleEndDateChange(event) { 
        this.endDate = event.detail.value; 
        this.calculateDuration();
        this.calculateExpectedPeriodType();
        // NEW: Adjust premium calculation based on new dates
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
                    showBasisPicklist: r.showBasisPicklist // Preserve the showBasisPicklist property
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

        // Convert commas to dots first
        s = s.replace(/,/g, '.');

        // Keep only digits and dots
        s = s.replace(/[^0-9.]/g, '');

        // Allow at most one dot (keep the first dot, remove others)
        const parts = s.split('.');
        if (parts.length > 1) {
            s = parts.shift() + (parts.length ? '.' + parts.join('') : '');
        }

        // Prevent leading dot: ".5" -> "0.5"
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

        // Keep local model in sync while typing
        const year = parseInt(input.dataset.year, 10);
        const percentage = sanitized;
        this.adjustmentRows = this.adjustmentRows.map(r =>
            r.year === year ? { ...r, percentage } : r
        );
    }

    // Sanitize pasted content and apply immediately
    handleRowPercentagePaste(event) {
        event.preventDefault();
        const paste = (event.clipboardData || window.clipboardData).getData('text') || '';
        const sanitized = this.sanitizePercentageString(paste);
        const input = event.target;
        input.value = sanitized;

        // Sync model to reflect paste immediately
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

            // sync model immediately
            const year = parseInt(input.dataset.year, 10);
            const percentage = this.sanitizePercentageString(newValue);
            this.adjustmentRows = this.adjustmentRows.map(r =>
                r.year === year ? { ...r, percentage } : r
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

        // Ensure the visible input shows the sanitized value (safe try/catch)
        try {
            event.target.value = percentage;
        } catch (e) {
            // silent fail-safe
        }

        // Update adjustmentRows with sanitized percentage
        this.adjustmentRows = this.adjustmentRows.map(r =>
            r.year === year ? { ...r, percentage } : r
        );

        // Preserve existing behavior
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
        
        if (d < 0) { m--; }
        if (d >= 30) { m++; }
        if (m < 0) { y--; m += 12; }
        this._computedYears = y;
        this._computedMonths = m;

        if (this.isShort && this.isProRataBasis) {
            this.calculatedRate = parseFloat((this.dayCount / 365).toFixed(6));
        } else if (this.isLongTerm && y >= 1) {
            const fullYearsLater = new Date(start);
            fullYearsLater.setFullYear(start.getFullYear() + y);
            const extraMs = end - fullYearsLater;
            const extraDays = Math.floor(extraMs / (1000 * 60 * 60 * 24)) + 1; 
            this.calculatedRate = extraDays > 0 ? parseFloat((extraDays / 365).toFixed(6)) : 0;
        } else {
            this.calculatedRate = null;
        }

        if (this.isLongTerm && this.schemaType != null) {
            const hasExtra = m > 0 || d > 0;
            const rowCount = y + (hasExtra ? 1 : 0);
            const newRows = [];
            const oldUiRows = [...this.adjustmentRows];

            for (let i = 0; i < rowCount; i++) {
                const yearNum = i + 1;
                const isExtraRow = hasExtra && i === rowCount - 1;
                const existingTxn = this.transactions.find(txn => txn.Year__c === yearNum);
                const oldUiRow = oldUiRows.find(row => row.year === yearNum);

                let rowType = null;
                let rowPercentage = null;
                let showBasisPicklist = false;
                
                let recordId = oldUiRow?.recordId || existingTxn?.Id || null;
                
                if (i === 0) {
                    rowPercentage = 100;
                    rowType = null; // First row doesn't need type
                    showBasisPicklist = false; // First row never shows basis
                } else if (isExtraRow) {
                    // Last row with extra months shows basis picklist
                    rowType = oldUiRow?.type || existingTxn?.Short_Period_Type__c || '2';
                    if (rowType === '2') {
                        rowPercentage = this.calculatedRate; 
                    } else {
                        rowPercentage = oldUiRow?.percentage ?? existingTxn?.Value__c ?? null;
                    }
                    showBasisPicklist = true; // Only the last row with extra months shows basis
                } else {
                    // Middle rows don't show basis picklist
                    rowType = oldUiRow?.type || existingTxn?.Short_Period_Type__c || '2';
                    rowPercentage = oldUiRow?.percentage ?? existingTxn?.Value__c ?? null;
                    showBasisPicklist = false;
                }

                newRows.push({ 
                    recordId: recordId, 
                    year: yearNum, 
                    percentage: rowPercentage, 
                    type: rowType,
                    showBasisPicklist: showBasisPicklist // Add this property
                });
            }
            this.adjustmentRows = [...newRows];
        } else {
            this.adjustmentRows = [];
        }

        this.updateYearsMonthsInfo();
        this.calculateExpectedPeriodType();
    }

    updateYearsMonthsInfo() {
        console.log('updateYearsMonthsInfo called');

        // Handle Annual case
        if (this.isAnnual) { 
            this.yearsMonthsInfo = '1 Year'; 
            return; 
        }

        // Handle Short Period case
        if (this.isShort) {
            console.log('this.isShort');
            if (this.isProRataBasis) { 
                this.yearsMonthsInfo = `Rate ${this.calculatedRate}`; 
                console.log('this.isProRataBasis'); 
            } else { 
                this.yearsMonthsInfo = `Percentage ${this.percentage || 0}%`; 
            }
            return;
        }

        // Handle Long Term case
        const y = this._computedYears;
        const m = this._computedMonths;

        let base = `${y} Year${y !== 1 ? 's' : ''}`; 

        if (m > 0) {
            base += ` and ${m} Month${m !== 1 ? 's' : ''}`;
        }

        console.log('m = ' + m);
        console.log('dayCount = ' + this.dayCount);
        console.log('this.adjustmentRows : ', JSON.stringify(this.adjustmentRows));

        // Check if adjustmentRows exists and has elements before accessing
        const lastRow = this.adjustmentRows && this.adjustmentRows.length > 0 
            ? this.adjustmentRows[this.adjustmentRows.length - 1] 
            : null;

        console.log('lastRow:', lastRow);

        if (lastRow) {
            console.log('lastRow.type = ' + lastRow.type);
            if (lastRow.type === '1') { 
                console.log('masuk if'); 
                this.yearsMonthsInfo = `${base} | Percentage ${lastRow.percentage || 0}%`;
            } else if (lastRow.type === '2') { 
                console.log('masuk else if'); 
                this.yearsMonthsInfo = `${base} | Total Rate ${(this._computedYears + this.calculatedRate)}`;
            } else { 
                console.log('masuk else'); 
                this.yearsMonthsInfo = base; 
            }
        } else {
            console.log('no lastRow');
            if (this._computedYears >= 1 && this._computedMonths > 0) {
                this.yearsMonthsInfo = `${base} | Total Rate ${(this._computedYears + this.calculatedRate)}`;
            } else {
                this.yearsMonthsInfo = base;
            }
        }

        console.log('rate = ' + this.calculatedRate);
    }
    
    async handleSave() {
        // NEW: Different validation for limited form
        if (this.isLimitedForm) {
            // For limited form, only validate start date
            if (!this.startDate) {
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Start Date is required.',
                    variant: 'error'
                }));
                return;
            }
            
            // For COB 101, end date is optional, for others it's required
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
            // Original validation for non-limited forms
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

        // Date order validation (only if both dates are provided)
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

        // Skip period type validation for limited form
        if (!this.isLimitedForm && this.showPeriodTypeValidationError) {
            const userConfirmed = await this.confirmSaveWithValidationError();
            if (!userConfirmed) {
                this.isLoading = false;
                return; // User canceled the save
            }
        }

        // data validation when switching between Percentage & Pro-Rata Basis in type Short
        if (!this.isLimitedForm) {
            if(this.periodType == '2' && this.shortBasis == '1'){ // Short & Percentage
                this.calculatedRate = null;
                this.years = null;
                this._computedYears = null;
            }else if(this.periodType == '2' && this.shortBasis == '2'){ // Short & Pro-Rata Basis
                this.percentage = null;
                this.years = null;
                this._computedYears = null;
            }else if(this.periodType == '1'){
                this.calculatedRate = null;
            }
        }

        this.isLoading = true;
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
            periodRate: this.calculatedRate,
            premiumCalculation: this.premiumCalculation, // NEW: Include premium calculation
            transactionRows: this.adjustmentRows
        };
        console.log('dataToSave: '+JSON.stringify(dataToSave, null, 2));
        this.isEditing = false;
        saveInsuranceDetails({ wrapper: dataToSave })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({ title: 'Success', message: 'Insurance Period details have been saved.', variant: 'success' }));
                this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId: this.recordId, actionName: 'view' }});
            })
            .catch(error => {
                let message = 'An unknown error occurred.';
                if (error && error.body && error.body.message) {
                    message = error.body.message;
                }
                this.dispatchEvent(new ShowToastEvent({ title: 'Error Saving Record', message: message, variant: 'error' }));
            })
            .finally(() => { this.isLoading = false; });
    }
}