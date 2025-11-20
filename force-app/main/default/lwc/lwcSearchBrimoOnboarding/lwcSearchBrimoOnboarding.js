/** 
    LWC Name    : lwcSearchBrimoOnboarding.js
    Created Date       : 14 July 2025
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    //release 4
    1.0   14/07/2025   Rakeyan Nuramria                  Initial Version
    1.0   11/08/2025   Rakeyan Nuramria                  Add API Functionality & Record page behaviour
**/

import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import searchOnboardingBrimo from '@salesforce/apex/SCC_CaseBRICare.searchOnboardingBrimo';

export default class LwcSearchBrimoOnboarding extends LightningElement {
    /** ===== UI state ===== */
    @track isLoading = false;
    @track showResult = false;
    @track nik = '';
    @track nikNumberError = '';
    @track hasError = false;
    @track errorMsg = '';
    @track responseData = {};
    @track errorKind = 'unknown'; // 'server' | 'notfound' | 'validation' | 'unknown'

    /** ===== Dev toggle ===== */
    @track useMock = false;
    showDevToggle = true; //if production set it to false

    /** ===== Record page mode ===== */
    @api useRecordContext = false;
    @api recordId;
    // Default this to your current object/field; keep configurable in App Builder
    @api recordNikFieldApiName = 'Campaign_Detail__c.NIK__c';

    // Booleans default TRUE via private fields
    _autoRunOnLoad = true;
    @api get autoRunOnLoad() { return this._autoRunOnLoad; }
    set autoRunOnLoad(v) { this._autoRunOnLoad = (v === true || v === 'true'); }

    _hideSearchInRecordMode = true;
    @api get hideSearchInRecordMode() { return this._hideSearchInRecordMode; }
    set hideSearchInRecordMode(v) { this._hideSearchInRecordMode = (v === true || v === 'true'); }

    @api presetNik = '';

    /** ===== Concurrency & reactivity guards ===== */
    _lastNikFromRecord = null;
    _lastExecutedNik = null;
    _currentRunId = 0;          // bump each search start
    _wireDebounce;              // timer id for record wire debounce
    static DEBOUNCE_MS = 250;

    /** ===== Wired helpers ===== */
    get wiredRecordId() {
        return (this.useRecordContext && !this.presetNik) ? this.recordId : null;
    }
    get wiredFields() {
        return (this.useRecordContext && !this.presetNik && this.recordNikFieldApiName)
            ? [this.recordNikFieldApiName]
            : [];
    }

    /** ===== Layout getters ===== */
    get mainCardIconName() { return this.useRecordContext ? 'utility:user' : 'standard:search'; }
    get mainCardTitle() { return this.useRecordContext ? 'Informasi Onboarding BRIMO' : 'Pencarian Onboarding BRIMO'; }
    get showInfoCard() { return this.useRecordContext || (!this.isLoading && (this.hasError || this.showResult)); }
    get showOuterSpinnerHomeMode() { return !this.useRecordContext && this.isLoading; }
    get showInnerSpinnerRecordMode() { return this.useRecordContext && this.isLoading; }
    get hideSearchSection() { return this.useRecordContext && this.hideSearchInRecordMode; }

    /** ===== Mock toggle UI ===== */
    get mockButtonLabel() { return this.useMock ? 'MOCK ON' : 'MOCK OFF'; }
    get mockButtonVariant() { return this.useMock ? 'success' : 'neutral'; }
    get mockButtonIcon() { return this.useMock ? 'utility:bug' : 'utility:offline'; }

    /** ===== Form helpers ===== */
    get isSearchButtonDisabled() { return !(this.nik && !this.nikNumberError); }
    get disableNIKField() { return this.isLoading; }

    // Show/Hide close action on the home info card
    get showHomeCloseAction() {
        // Home only; show when the card is visible (error or result)
        return !this.useRecordContext && (this.hasError || this.showResult);
    }


    /** ===== Lifecycle ===== */
    connectedCallback() {
        // If a parent/Flow provided NIK directly in record mode, validate then auto-run if valid
        if (this.useRecordContext && this.presetNik) {
            this.sanitizeAndSetNik(this.presetNik);
            if (!this.nik) {
                this.showValidationError('NIK pada record kosong atau tidak diisi.');
                return;
            }
            if (!this.nikNumberError && this.autoRunOnLoad) {
                this.startSearch('presetNik');
            } else if (this.nikNumberError) {
                this.showValidationError('NIK pada record harus 16 digit.');
            }
        }
    }

    /** ===== Wire to record ===== */
    @wire(getRecord, { recordId: '$wiredRecordId', fields: '$wiredFields' })
    wiredNik({ data, error }) {
        if (!this.useRecordContext || this.presetNik) return;

        if (error) {
            this.handleSearchError('Gagal membaca NIK dari record.', 'server');
            return;
        }
        if (!data) return;

        const fieldApi = (this.recordNikFieldApiName || '').split('.').pop();
        const newNikRaw = data.fields?.[fieldApi]?.value;

        clearTimeout(this._wireDebounce);
        this._wireDebounce = setTimeout(() => {
            const prev = this.nik;
            this.sanitizeAndSetNik(newNikRaw);

            // First wire should be processed even if value === '' (same as initial)
            const firstRun = (this._lastNikFromRecord === null);
            if (!firstRun && this.nik === prev) return;

            // remember last value from record
            this._lastNikFromRecord = this.nik;

            // reset UI state (make sure your clearErrorAndResult() does NOT flip isLoading)
            this.clearErrorAndResult();

            // validations for record page
            if (!this.nik) {
                this.showValidationError('NIK pada record kosong atau tidak diisi.');
                return;
            }
            if (this.nikNumberError) {
                this.showValidationError('NIK pada record harus 16 digit.');
                return;
            }

            // auto-run when valid
            if (this.autoRunOnLoad) {
                this.startSearch('recordChange');
            }
        }, this.constructor.DEBOUNCE_MS);
    }

    /** ===== Start a search (centralized) ===== */
    startSearch(reason = 'manual') {
        this._currentRunId += 1;
        const runId = this._currentRunId;

        this.isLoading = true;  // show spinner (esp. record mode)
        this.hasError = false;
        this.showResult = false;
        this._lastExecutedNik = this.nik;

        if (this.useMock) {
            const lastDigit = this.nik.charAt(this.nik.length - 1);
            if (parseInt(lastDigit, 10) >= 6) {
                this.fetchDataOnboardingMock(runId);
            } else {
                this.fetchDataEmptyResponseMock(runId);
            }
        } else {
            this.fetchDataOnboarding(runId);
        }
    }

    /** ===== Manual search (home/app) ===== */
    handleSearch() {
        this.sanitizeAndSetNik(this.nik);
        if (!this.nik || this.nikNumberError) {
            this.showToast('Validasi', 'Masukkan NIK 16 digit yang valid.', 'warning');
            this.showValidationError('NIK harus 16 digit.');
            return;
        }
        this.startSearch('manual');
    }

    // Press Enter to search (home page search input)
    handleSearchKeydown(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            this.handleSearch();
        }
    }

    // Close action: hide the home result card (keep NIK input)
    handleCloseHomeInfoCard() {
        this.hasError = false;
        this.errorMsg = '';
        this.errorKind = 'unknown';
        this.showResult = false;
        this.responseData = {};
        // keep isLoading = false; keep nik + validation as-is
    }

    /** ===== Toggle mock mode ===== */
    handleToggleMockButton() {
        this.useMock = !this.useMock;
        this.showToast(
            'Mode Perubahan',
            this.useMock ? 'Menggunakan data dummy untuk pencarian.' : 'Menggunakan API asli untuk pencarian.',
            'info'
        );
        // Re-run immediately in record mode when NIK valid
        if (this.useRecordContext && this.nik && !this.nikNumberError) {
            this.startSearch('toggleMode');
        }
    }

    /** ===== Mock fetch: success ===== */
    fetchDataOnboardingMock(runId) {
        const resp = {
            response_code: '00',
            response_description: 'Success',
            response_data: {
                account: '',
                name: 'John Doe',
                nik: this.nik,
                status: 3,
                status_description: 'Validate phone'
            }
        };
        setTimeout(() => {
            if (runId !== this._currentRunId) return; // stale
            try {
                this.responseData = resp.response_data;
                this.errorMsg = '';
                this.hasError = false;
                this.showResult = true;
                this.showToast('Berhasil', 'Data onboarding (mock) ditemukan.', 'success');
            } catch (e) {
                this.handleSearchError('Terjadi kesalahan saat memproses data mock', 'unknown');
            } finally {
                this.isLoading = false;
            }
        }, 600);
    }

    /** ===== Mock fetch: empty/error variants ===== */
    fetchDataEmptyResponseMock(runId) {
        const d = this.nik.charAt(this.nik.length - 1);
        let resp = {};
        switch (d) {
            case '0': // Unknown error (no matching keywords)
                resp = { response_code: 'UEX', response_refnum: '123456789192', response_id: 'mock-unknown-error', response_description: 'Unexpected processing issue', response_data: null};
                break;
            case '1':
                resp = { response_code: '00', response_description: 'case 1: No data found (response_data return null), code 00', response_data: null };
                break;
            case '2':
                resp = { response_code: '00', response_description: "case 2: No record present (response_data object doesn't exist, code 00)" };
                break;
            case '3':
                resp = { response_code: '01', response_description: 'case 3: Data not found  (response_data return null, code 01 or not 00)', response_data: null };
                break;
            case '4':
                resp = { response_code: '99', response_description: 'case 4: Internal server error (response_data return null, test server error code not 00)', response_data: null };
                break;
            case '5':
                resp = {}; // no body
                break;
            default:
                resp = { response_code: 'LOE', response_description: "No Progress: Can't Found Progress Record", response_data: {} };
                break;
        }

        setTimeout(() => {
            if (runId !== this._currentRunId) return; // stale
            try {
                if (!resp || Object.keys(resp).length === 0) {
                    this.handleSearchError('Server tidak merespons', 'server');
                    return;
                }
                const desc = resp.response_description || '';
                const data = resp.response_data;
                const hasData = this.hasNonEmptyData(data);

                if (!hasData) {
                    const kind = this.classifyKindFromDescription(desc);
                    const message = desc || 'Data tidak ditemukan.';
                    this.handleSearchError(message, kind);
                    return;
                }

                if (resp.response_code && resp.response_code !== '00') {
                    const warn = desc ? `Kode: ${resp.response_code} (${desc})` : `Kode: ${resp.response_code}`;
                    this.showToast('Peringatan', warn, 'warning');
                }

                this.responseData = data;
                this.errorMsg = '';
                this.hasError = false;
                this.showResult = true;
            } catch (e) {
                this.handleSearchError('Terjadi kesalahan saat memproses data mock', 'unknown');
            } finally {
                this.isLoading = false;
            }
        }, 800);
    }

    /** ===== Real API ===== */
    fetchDataOnboarding(runId) {
        this.clearErrorAndResult(); // keep clean state for home/app
        const req = {
            nik: this.nik,
            channel_id: 'NBMB',
            client: 'BRIMON',
            request_refnum: ''
        };

        searchOnboardingBrimo({ req })
            .then((response) => {
                if (runId !== this._currentRunId) return; // stale
                if (!response) { this.handleSearchError('Server tidak merespons.', 'server'); return; }

                const desc = response.response_description || '';
                const data = response.response_data;
                const hasData = this.hasNonEmptyData(data);

                if (!hasData) {
                    const kind = this.classifyKindFromDescription(desc);
                    const message = desc || 'Data tidak ditemukan.';
                    this.handleSearchError(message, kind);
                    return;
                }

                if (response.response_code && response.response_code !== '00') {
                    const warn = desc ? `Kode: ${response.response_code} (${desc})` : `Kode: ${response.response_code}`;
                    this.showToast('Peringatan', warn, 'warning');
                }

                this.responseData = data;
                this.hasError = false;
                this.errorMsg = '';
                this.errorKind = 'unknown';
                this.showResult = true;
                this.showToast('Berhasil', 'Data onboarding ditemukan.', 'success');
            })
            .catch((err) => {
                if (runId !== this._currentRunId) return; // stale
                const body = err?.body;
                const msg =
                    (Array.isArray(body?.pageErrors) && body.pageErrors[0]?.message) ||
                    body?.message ||
                    err?.message ||
                    'Terjadi kesalahan tak terduga saat memproses permintaan.';
                this.handleSearchError(msg, 'server');
            })
            .finally(() => {
                if (runId !== this._currentRunId) return; // stale
                this.isLoading = false;
            });
    }

    /** ===== Error & input helpers ===== */
    handleSearchError(errorMessage, kind = 'unknown') {
        this.hasError = true;
        this.errorMsg = errorMessage;
        this.errorKind = kind;
        this.showResult = false;
        this.responseData = {};
        this.isLoading = false;
        this.showToast('Pencarian Gagal', errorMessage, 'error');
    }

    showValidationError(msg) {
        this.hasError = true;
        this.errorKind = 'validation';
        this.errorMsg = msg;
        this.showResult = false;
        this.isLoading = false;
    }

    handleNIKChange(event) {
        this.sanitizeAndSetNik(event.target.value);
        if (!this.nik) this.clearInputFields();
    }

    // Sanitize incoming NIK (keep digits only) + validate
    sanitizeAndSetNik(raw) {
        const cleaned = (raw || '').toString().replace(/\D/g, '');
        this.nik = cleaned.trim();
        this.validateNIKNumber();
        return this.nik;
    }

    validateNIKNumber() {
        const regex = /^\d{16}$/;
        this.nikNumberError = regex.test(this.nik) ? '' : 'NIK harus memiliki 16 digit angka.';
    }

    clearErrorAndResult() {
        // keep current validation flag; just reset result/error visuals
        this.errorMsg = '';
        // this.isLoading = false;
        this.showResult = false;
        this.responseData = {};
        this.hasError = false;
        this.errorKind = 'unknown';
    }

    clearInputFields() {
        this.nik = '';
        this.errorMsg = '';
        this.nikNumberError = '';
        this.isLoading = false;
        this.showResult = false;
        this.responseData = {};
        this.hasError = false;
        this.errorKind = 'unknown';
    }

    showToast(title, message, variant = 'info', mode = 'dismissable') {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant, mode }));
    }

    /** ===== Error visualization getters ===== */
    get errorType() { 
        return this.errorKind || 'unknown'; 
    }
    
    get errorIconName() {
        switch (this.errorType) {
            case 'server':     return 'utility:offline';
            case 'notfound':   return 'utility:search';
            case 'validation': return 'utility:warning';
            case 'unknown':    return 'utility:error';
            default:           return 'utility:info';
        }
    }
    
    get errorTitle() {
        switch (this.errorType) {
            case 'server':     return 'Server tidak merespons';
            case 'notfound':   return 'Data tidak ditemukan';
            case 'validation': return 'Validasi diperlukan';
            case 'unknown':    return 'An error has occurred';
            default:           return 'Terjadi kesalahan';
        }
    }
    
    get errorSubtitle() {
        switch (this.errorType) {
            case 'server':     return 'Coba lagi sebentar lagi, atau hubungi admin bila berlanjut.';
            case 'notfound':   return 'Pastikan NIK benar, atau coba pencarian lain.';
            case 'validation': return 'Masukkan NIK 16 digit angka yang valid.';
            case 'unknown':    return this.errorMsg || 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
            default:           return this.errorMsg || 'Silakan coba lagi.';
        }
    }

    /** ===== Utilities ===== */
    hasNonEmptyData(data) {
        if (data == null) return false;
        if (Array.isArray(data)) return data.length > 0;
        if (typeof data === 'object') return Object.keys(data).length > 0;
        if (typeof data === 'string') return data.trim().length > 0;
        return true; // numbers/booleans treated as present
    }

    normalizeDesc(desc) {
        return (desc || '')
            .toLowerCase()
            .normalize('NFKD')
            .replace(/[^\w\s]/g, ' ')
            .replace(/\s+/g, ' ')
            .trim();
    }

    classifyKindFromDescription(desc = '') {
        const d = this.normalizeDesc(desc);
        const serverHits = [
            'timeout','time out','io timeout','i o timeout','internal server error',
            'server error','service unavailable','bad gateway','gateway timeout',
            'network','connection','unavailable','down','ssl','tls','econn','refused','reset','timed out'
        ];
        if (serverHits.some(k => d.includes(k))) return 'server';

        const nfHits = [
            'not found','no data','no record','no progress','no progress record',
            'cant found','cannot find','could not find','empty result','no content','tidak ditemukan'
        ];
        if (nfHits.some(k => d.includes(k))) return 'notfound';

        const valHits = ['invalid','format','required','length','digit','mismatch','bad request','parameter'];
        if (valHits.some(k => d.includes(k))) return 'validation';

        return 'unknown';
    }

    handleRetry() {
        if (!this.nik) return;
        this.validateNIKNumber();
        if (this.nikNumberError) {
            this.showValidationError('NIK harus 16 digit.');
            return;
        }
        this.startSearch('retry');
    }
}