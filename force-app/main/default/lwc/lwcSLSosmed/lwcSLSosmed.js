import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import updateStatusSL from '@salesforce/apex/SLSosmedController.updateStatusSL';
import SPROUTEX_FIELD from '@salesforce/schema/Case.SproutExId__c';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import DATETIME_POST_FIELD from '@salesforce/schema/Case.Date_Time_Post__c';
import DATETIME_ANSWER_FIELD from '@salesforce/schema/Case.Date_Time_Answer__c';
import SL_STARTED_FIELD from '@salesforce/schema/Case.SCC_SL_Sosmed_Timer_Dimulai__c';
import SL_STOPPED_TIME_FIELD from '@salesforce/schema/Case.SCC_SL_Sosmed_Waktu_Stop__c';
import SL_ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import SL_TARGET_RESPONSE from '@salesforce/schema/Case.SCC_Target_Response_Time_Non_Voice__c';
import RESPONSE_TIME_FIELD from '@salesforce/schema/Case.Response_Time_Minutes__c';
import SL_VIOLATION from '@salesforce/schema/Case.SCC_SL_Sosmed_Violation__c';
import CLOSED_DATE_FIELD from '@salesforce/schema/Case.ClosedDate';
import CREATED_DATE_FIELD from '@salesforce/schema/Case.CreatedDate';
import SL_COMPLETED_FIELD from '@salesforce/schema/Case.SCC_SL_Sosmed_Completed__c';
import { refreshApex } from '@salesforce/apex';

export default class lwcSLSosmed extends LightningElement {
    @api recordId;

    @track originTicket;
    @track target;
    @track timerCalc = 'card-sosmed-content';
    @track completed = 'card-sosmed-content';
    @track isCompleted = false;
    @track timer = 'Memuat...';
    @track isViolated = false;
    @track isSosmedTicket = true;
    @track penyelesaian;
    @track wiredCaseResult;
    
    // Control flags to prevent unnecessary updates
    hasBeenUpdated = false;
    previousStatus = null;
    previousDateTimeAnswer = null;
    previousIsViolated = null;
    isTimerRunning = false;
    
    errorMessage = '';
    intervalId;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            SPROUTEX_FIELD,
            STATUS_FIELD,
            DATETIME_POST_FIELD,
            DATETIME_ANSWER_FIELD,
            SL_STARTED_FIELD,
            SL_STOPPED_TIME_FIELD,
            SL_ORIGIN_FIELD,
            SL_TARGET_RESPONSE,
            RESPONSE_TIME_FIELD,
            CLOSED_DATE_FIELD,
            CREATED_DATE_FIELD,
            SL_VIOLATION,
            SL_COMPLETED_FIELD
        ]
    })
    wireCaseRecord(result) {
        this.wiredCaseResult = result;
        const { data, error } = result;
        
        if (data) {
            const sproutExId = getFieldValue(data, SPROUTEX_FIELD);
            const status = getFieldValue(data, STATUS_FIELD);
            const dateTimePost = getFieldValue(data, DATETIME_POST_FIELD);
            const dateTimeAnswer = getFieldValue(data, DATETIME_ANSWER_FIELD);
            const slStarted = getFieldValue(data, SL_STARTED_FIELD);
            const stoppedTime = getFieldValue(data, SL_STOPPED_TIME_FIELD);
            const originSosmed = getFieldValue(data, SL_ORIGIN_FIELD);
            const targetSosmed = getFieldValue(data, SL_TARGET_RESPONSE);
            const responseTime = getFieldValue(data, RESPONSE_TIME_FIELD);
            const closedDate = getFieldValue(data, CLOSED_DATE_FIELD);
            const createdDate = getFieldValue(data, CREATED_DATE_FIELD);
            const isViolated = getFieldValue(data, SL_VIOLATION);
            const isAlreadyCompleted = getFieldValue(data, SL_COMPLETED_FIELD);

            // Check if this is actually new data to prevent unnecessary processing
            if (this.previousStatus === status && 
                this.previousDateTimeAnswer === dateTimeAnswer && 
                this.previousIsViolated === isViolated) {
                return; // No changes, skip processing
            }

            // Update tracking variables
            this.previousStatus = status;
            this.previousDateTimeAnswer = dateTimeAnswer;
            this.previousIsViolated = isViolated;

            const mapDataSosmed = {
                'SproutEx ID': `${sproutExId}`,
                'Status': `${status}`,
                'DateTime Post': `${dateTimePost}`,
                'DateTime Answer': `${dateTimeAnswer}`,
                'SL Started': `${slStarted}`,
                'Stopped Time': `${stoppedTime}`,
                'Origin': `${originSosmed}`,
                'Target': `${targetSosmed}`,
                'Response Time': `${responseTime}`,
                'Closed Date': `${closedDate}`,
                'Created Date': `${createdDate}`,
                'Is Already Completed': `${isAlreadyCompleted}`
            };

            console.log('isViolated', isViolated);
            console.log('sosmed log data', mapDataSosmed);

            // Check if this is a sosmed ticket
            if (!sproutExId && !dateTimePost) {
                this.isSosmedTicket = false;
                this.errorMessage = 'Bukan Tiket Sosmed/Email';
                this.clearTimer();
                return;
            }

            // Set origin and target
            if (originSosmed) {
                this.originTicket = originSosmed;
                const targetTime = this.setTargetSosmed(targetSosmed);
                console.log('target time', targetTime);
                this.target = targetTime;
            }

            // Set violation styling
            if (isViolated) {
                this.isViolated = true;
                this.completed = 'card-sosmed-content-error';
                this.timerCalc = 'timer-violated';
            }

            // Check if case is completed
            if (this.isCaseCompleted(dateTimeAnswer, status)) {
                this.handleCompletedCase(dateTimeAnswer, responseTime, closedDate, createdDate, slStarted, isAlreadyCompleted);
                return;
            }

            // Start timer only if not already running and not completed
            if (slStarted && !this.isTimerRunning && !this.isCompleted) {
                this.startLocalTimer(slStarted, targetSosmed);
            }

        } else if (error) {
            console.error('Error fetching case record:', error);
            this.errorMessage = 'Gagal memuat Detail Tiket. Harap Refresh.';
        }
    }

    handleCompletedCase(dateTimeAnswer, responseTime, closedDate, createdDate, slStarted, isAlreadyCompleted) {
        this.isCompleted = true;
        this.timer = 'Tiket Telah Direspon';
        this.clearTimer();

        // Only update if not already updated and has started time
        if (slStarted && !this.hasBeenUpdated && !isAlreadyCompleted) {
            let formattedTime;

            if (dateTimeAnswer) {
                // Use Response_Time_Minutes__c if Date_Time_Answer__c exists
                formattedTime = this.formatResponseTime(responseTime);
            } else {
                // Calculate using ClosedDate - CreatedDate
                const closedDateTime = new Date(closedDate);
                const createdDateTime = new Date(createdDate);
                const diffInMinutes = (closedDateTime - createdDateTime) / (1000 * 60);
                formattedTime = this.formatResponseTime(diffInMinutes);
            }

            // Update case status and pass the formatted time
            this.updateCaseSosmed(
                this.recordId,
                this.isCompleted,
                this.isViolated,
                formattedTime
            ).then(result => {
                console.log('hasil update', result);
                this.hasBeenUpdated = true; // Prevent future updates
            }).catch(error => {
                console.error('Error updating case:', error);
            });

            this.penyelesaian = formattedTime;
        } else if (isAlreadyCompleted) {
            // Case already completed, just show the completion time
            this.hasBeenUpdated = true;
            if (responseTime) {
                this.penyelesaian = this.formatResponseTime(responseTime);
            }
        }
    }

    isCaseCompleted(dateTimeAnswer, status) {
        const completed = (
            dateTimeAnswer !== null ||
            ['Closed', 'Cancelled', 'Disconnected'].includes(status)
        );
        console.log('Is Case Completed:', completed);
        return completed;
    }

    startLocalTimer(startedTime, targetSl) {
        // Prevent multiple timers
        if (this.isTimerRunning) {
            return;
        }

        this.clearTimer();
        this.isTimerRunning = true;

        console.log('target sl', targetSl);

        let remainingSeconds = this.calculateRemainingSecond(targetSl, startedTime);
        console.log('Remaining Time:', remainingSeconds);

        this.intervalId = setInterval(() => {
            // Check if component is still valid and case not completed
            if (this.isCompleted) {
                this.clearTimer();
                return;
            }

            this.timer = this.formatedTime(remainingSeconds);
            remainingSeconds--;

            if (remainingSeconds <= 0 && !this.isViolated) {
                this.isViolated = true;
                this.timerCalc = 'timer-violated';
                this.completed = 'card-sosmed-content-error';
                
                // Update violation status to server
                this.updateCaseSosmed(
                    this.recordId,
                    false, // not completed yet
                    true,  // violated
                    null   // no end time yet
                ).then(result => {
                    console.log('Violation updated:', result);
                }).catch(error => {
                    console.error('Error updating violation:', error);
                });
            }
        }, 1000);
    }

    clearTimer() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
            this.isTimerRunning = false;
        }
    }

    async updateCaseSosmed(caseId, isCompleted, isViolated, endTimeCapture) {
        try {
            const result = await updateStatusSL({ caseId, isCompleted, isViolated, endTimeCapture });
            console.log('hasil update:', result);
            return result;
        } catch (err) {
            console.log('Error Update case', err.body ? err.body.message : err.message);
            throw err;
        }
    }

    setTargetSosmed(time) {
        const convertToSecond = time * 60;
        let target = this.formatedTime(convertToSecond);
        return target;
    }

    calculateRemainingSecond(targetTime, startedTime) {
        // Convert to millisecond because to calculate remaining second from target time and started target
        const startedTimeCase = new Date(startedTime);
        const nowTime = new Date();
        const convertToMilisecond = targetTime * 60 * 1000;
        console.log('Target on millisecond:', convertToMilisecond);

        // Calculate as second and return it
        let remainingSeconds = Math.floor((convertToMilisecond - (nowTime - startedTimeCase)) / 1000);
        return remainingSeconds;
    }

    formatedTime(totalSeconds) {
        const isNegative = totalSeconds < 0;
        totalSeconds = Math.abs(totalSeconds); // abs for positive
        const days = Math.floor(totalSeconds / 86400); // 1 day = 86400 seconds
        const hours = Math.floor((totalSeconds % 86400) / 3600); // Remaining hours after days
        const minutes = Math.floor((totalSeconds % 3600) / 60); // Remaining minutes after hours
        const seconds = totalSeconds % 60; // Remaining seconds

        let formattedTime = `${isNegative ? '- ' : ''}`;

        if (days > 0) {
            formattedTime += `${days} Hari `;
        }
        if (hours > 0 || days > 0) {
            formattedTime += `${String(hours).padStart(2, '0')} Jam `;
        }
        if (minutes > 0 || hours > 0 || days > 0) {
            formattedTime += `${String(minutes).padStart(2, '0')} Menit `;
        }
        formattedTime += `${String(seconds).padStart(2, '0')} Detik`;

        return formattedTime;
    }

    formatResponseTime(minutes) {
        if (!minutes) return '0 Detik';

        minutes = Math.abs(minutes);

        const days = Math.floor(minutes / (24 * 60));
        const hours = Math.floor((minutes % (24 * 60)) / 60);
        const remainingMinutes = Math.floor(minutes % 60);
        const seconds = Math.round((minutes % 1) * 60);

        let formattedTime = '';

        if (days > 0) {
            formattedTime += `${days} Hari `;
        }
        if (hours > 0) {
            formattedTime += `${hours} Jam `;
        }
        if (remainingMinutes > 0) {
            formattedTime += `${remainingMinutes} Menit `;
        }
        if (seconds > 0 || formattedTime === '') {
            formattedTime += `${seconds} Detik`;
        }

        return formattedTime.trim();
    }

    async handleAutoRefresh() {
        try {
            await refreshApex(this.wiredCaseResult);
            console.log('Component refreshed');
        } catch (error) {
            console.error('Error refreshing component:', error);
        }
    }

    disconnectedCallback() {
        this.clearTimer();
    }
}