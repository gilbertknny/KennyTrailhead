import { LightningElement, api, track } from 'lwc';
import getSessionDetails from '@salesforce/apex/scc_SabrinaMilestoneCtrl.getSessionDetails';
import updateTimerStatus from '@salesforce/apex/scc_SabrinaMilestoneCtrl.updateTimerStatus';
import getTargetFirstResponseTime from '@salesforce/apex/scc_SabrinaMilestoneCtrl.getTargetFirstResponseTime';

export default class Scc_SabrinaMilestone extends LightningElement {
    @api recordId;
    @track targetTime;
    @track createdDate;
    @track countdownTime;
    @track targetTimeFormatted;
    @track firstResponseTimeFormatted;
    @track stoppedTimeFormatted;
    @track isCompleted = false;
    @track isTimerStopped = false;
    @track timerClass = 'card-sabrina-content';
    intervalId;

    async connectedCallback() {
        if (!this.recordId) {
            console.error('RecordId not available');
            return;
        }
        await this.fetchTargetTime();
        await this.fetchSessionData();
        this.formatTargetTime();
    }

    async fetchTargetTime() {
        try {
            this.targetTime = await getTargetFirstResponseTime({ recordId: this.recordId });
            console.log('Fetched target time:', this.targetTime);
        } catch (error) {
            console.error('Error fetching target time:', error);
        }
    }

    async fetchSessionData() {
        try {
            const session = await getSessionDetails({ sessionId: this.recordId });
            console.log('Fetched session:', session);
    
            this.status = session.Status;
            
            if (this.status === 'Ended') {
                console.log('Status is Ended, stopping timer.');
                this.stopTimer();
            }
    
            if (session.is_Timer_Stop__c) {
                this.isTimerStopped = true;
                this.stoppedTimeFormatted = session.Waktu_Penyelesaian__c;
                this.countdownTime = this.stoppedTimeFormatted;
                this.completedTime = session.First_Response_Time__c;
    
                if (this.completedTime > this.targetTime) {
                    this.timerClass = 'timer-violated';
                } else {
                    this.timerClass = 'card-sabrina-content';
                }
                return;
            }
    
            if (session.CreatedDate && this.targetTime) {
                this.createdDate = new Date(session.CreatedDate);
                this.startCountdown();
            } else {
                console.error('CreatedDate atau targetTime kosong:', session.CreatedDate, this.targetTime);
            }
        } catch (error) {
            console.error('Error retrieving session:', error);
        }
    }

    formatTargetTime() {
        if (this.targetTime) {
            this.targetTimeFormatted = `${this.targetTime} menit`;
        } else {
            this.targetTimeFormatted = 'Tidak ada target waktu';
        }
    }

    startCountdown() {
        const targetTimeInMillis = this.targetTime * 60 * 1000;
    
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
    
        this.isTimerStopped = false;
    
        this.intervalId = setInterval(() => {
            if (this.status === 'Ended') {
                this.stopTimer();
            }
    
            const currentTime = new Date().getTime();
            const elapsedTime = currentTime - this.createdDate.getTime();
    
            if (elapsedTime <= targetTimeInMillis) {
                this.countdownTime = this.formatTimeLeft(elapsedTime);
                this.timerClass = 'card-sabrina-content';
            } else {
                const overtimeMillis = elapsedTime - targetTimeInMillis;
                this.countdownTime = `${this.formatTimeLeft(overtimeMillis)}`;
                this.timerClass = 'timer-violated';
            }
        }, 1000);
    }    

    @api
    async stopTimer() {
        console.log('stopTimer() dipanggil di LWC!');
        clearInterval(this.intervalId); // Hentikan timer
        this.isTimerStopped = true;

        const now = new Date().getTime();
        const elapsedTime = now - this.createdDate.getTime();
        const targetTimeInMillis = this.targetTime * 60 * 1000;
        let completionTime = '';

        if (elapsedTime <= targetTimeInMillis) {
            this.firstResponseTimeFormatted = this.formatTimeLeft(elapsedTime);
            this.isCompleted = true;
            console.log(`Waktu penyelesaian: ${this.firstResponseTimeFormatted}`);
            completionTime = `${this.firstResponseTimeFormatted}`;
            this.timerClass = 'card-sabrina-content'; // Tetap normal jika dalam target
        } else {
            const overtimeMillis = elapsedTime - targetTimeInMillis;
            this.firstResponseTimeFormatted = `${this.formatTimeLeft(overtimeMillis)}`;
            console.warn(`Overtime: ${this.firstResponseTimeFormatted}`);
            completionTime = this.firstResponseTimeFormatted;
            this.timerClass = 'timer-violated'; // Warna merah jika overtime
        }

        this.stoppedTimeFormatted = completionTime;
        // this.stoppedTimeFormatted = this.countdownTime;

        try {
            await updateTimerStatus({
                recordId: this.recordId,
                isStopped: true,
                completionTime: completionTime,
                completedTime: Math.floor(elapsedTime / 60000) // Konversi ms ke menit
            });
            console.log('Status timer dan waktu penyelesaian berhasil diperbarui di Salesforce');
        } catch (error) {
            console.error('Gagal memperbarui status timer di Salesforce:', error);
        }
    }

    convertFormattedTimeToMinutes(formattedTime) {
        let totalMinutes = 0;

        const timeParts = formattedTime.split(' ');
        timeParts.forEach((part) => {
            if (part.includes('d')) {
                totalMinutes += parseInt(part) * 1440; // 1 hari = 1440 menit
            } else if (part.includes('h')) {
                totalMinutes += parseInt(part) * 60; // 1 jam = 60 menit
            } else if (part.includes('m')) {
                totalMinutes += parseInt(part); // Menit
            }
        });

        return totalMinutes;
    }

    formatTimeLeft(ms) {
        const totalSeconds = Math.floor(ms / 1000);
        const days = Math.floor(totalSeconds / 86400);
        const hours = Math.floor((totalSeconds % 86400) / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = totalSeconds % 60;

        let formattedTime = '';
        if (days > 0) {
            formattedTime += `${days}d `;
        }
        if (hours > 0 || formattedTime) {
            formattedTime += `${hours}h `;
        }
        if (minutes > 0 || formattedTime) {
            formattedTime += `${minutes}m `;
        }
        formattedTime += `${seconds}s`;

        return formattedTime.trim();
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }
}