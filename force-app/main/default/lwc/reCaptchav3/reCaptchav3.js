import { LightningElement, track, api } from 'lwc';
import pageUrl from '@salesforce/resourceUrl/reCaptchav3';
import isReCaptchaValid from '@salesforce/apex/ReCaptchaController.isReCaptchaValid';

export default class ReCaptchav3 extends LightningElement {
    @track resultData;
    @track validReCAPTCHA = false;
    @track navigateTo;
    @api formToken;

    constructor() {
        super();
        this.navigateTo = pageUrl;
        this.listenForMessage = this.listenForMessage.bind(this);
        window.addEventListener("message", this.listenForMessage);
    }

    listenForMessage(e) {
        if (e.data && e.data.action === "getCaptcha") {
            const token = e.data.callCAPTCHAResponse;
            if (!token) {
                console.warn("Token not obtained!");
                // Dispatch error event
                this.dispatchEvent(new CustomEvent('captchaverified', {
                    detail: { verified: false, token: null }
                }));
                return;
            }

            this.formToken = token;
            console.log("✅ Token obtained:", this.formToken);

            isReCaptchaValid({ token: this.formToken })
                .then(result => {
                    // Normalize hyphenated key if present
                    if (result['error-codes']) {
                        result.errorCodes = result['error-codes'];
                        delete result['error-codes'];
                    }

                    this.resultData = result;
                    this.validReCAPTCHA = result.success;
                    
                    // Dispatch verification event with token
                    this.dispatchEvent(new CustomEvent('captchaverified', {
                        detail: { 
                            verified: this.validReCAPTCHA,
                            token: this.formToken,
                            score: result.score,
                            action: result.action
                        }
                    }));
                    
                    console.log('🧩 Full Response:', JSON.stringify(result, null, 2));
                })
                .catch(error => {
                    console.error('Error validating reCAPTCHA:', error);
                    // Dispatch error event
                    this.dispatchEvent(new CustomEvent('captchaverified', {
                        detail: { verified: false, token: null }
                    }));
                });
        }
    }

    disconnectedCallback() {
        window.removeEventListener("message", this.listenForMessage);
    }
}