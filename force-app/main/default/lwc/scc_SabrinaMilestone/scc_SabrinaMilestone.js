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
        
        // Inisialisasi countdownTime dengan nilai default
        this.countdownTime = '0s';
        
        await this.fetchTargetTime();
        await this.fetchSessionData();
        this.formatTargetTime();
        
        // Safety check - pastikan countdownTime memiliki nilai
        if (!this.countdownTime) {
            console.error('CountdownTime masih kosong setelah inisialisasi');
            this.countdownTime = '0s';
        }
    }

    async fetchTargetTime() {
        try {
            this.targetTime = await getTargetFirstResponseTime({ recordId: this.recordId });
            console.log('Fetched target time:', this.targetTime);
            
            // Validasi target time
            if (!this.targetTime || isNaN(this.targetTime) || this.targetTime <= 0) {
                console.warn('targetTime tidak valid:', this.targetTime);
                this.targetTime = 2; // Default 2 menit jika tidak tersedia atau tidak valid
                console.log('Menggunakan default targetTime:', this.targetTime);
            }
        } catch (error) {
            console.error('Error fetching target time:', error);
            this.targetTime = 2; // Default 2 menit jika terjadi error
            console.log('Menggunakan default targetTime karena error:', this.targetTime);
        }
    }

    async fetchSessionData() {
        try {
            const session = await getSessionDetails({ sessionId: this.recordId });
            console.log('Fetched session:', session);
    
            this.status = session.Status;
            
            // Pastikan createdDate selalu diisi selama tersedia
            if (session.CreatedDate) {
                // Konversi string ISO ke objek Date
                if (typeof session.CreatedDate === 'string') {
                    this.createdDate = new Date(session.CreatedDate);
                } else {
                    this.createdDate = session.CreatedDate;
                }
                console.log('CreatedDate diatur ke:', this.createdDate, 'timestamp:', this.createdDate.getTime());
            } else {
                console.error('CreatedDate tidak tersedia:', session.CreatedDate);
                // Fallback - gunakan waktu sekarang jika tidak ada createdDate
                this.createdDate = new Date();
                console.log('CreatedDate fallback ke:', this.createdDate);
            }
            
            // Jika status sudah Ended, hentikan timer tetapi tetap tampilkan nilai
            if (this.status === 'Ended') {
                console.log('Status is Ended, stopping timer.');
                this.clearTimerInterval();
                
                if (session.Waktu_Penyelesaian__c) {
                    this.countdownTime = session.Waktu_Penyelesaian__c;
                } else {
                    // Hitung waktu yang telah berlalu
                    const currentTime = new Date().getTime();
                    const elapsedTime = currentTime - this.createdDate.getTime();
                    this.countdownTime = this.formatTimeLeft(elapsedTime);
                }
                return;
            }
    
            // Jika timer sudah dihentikan sebelumnya, tampilkan waktu yang tersimpan
            if (session.is_Timer_Stop__c) {
                this.isTimerStopped = true;
                if (session.Waktu_Penyelesaian__c) {
                    this.stoppedTimeFormatted = session.Waktu_Penyelesaian__c;
                    this.countdownTime = this.stoppedTimeFormatted;
                } else {
                    console.warn('Timer sudah stop tapi waktu penyelesaian tidak ada');
                    // Hitung waktu yang telah berlalu
                    const currentTime = new Date().getTime();
                    const elapsedTime = currentTime - this.createdDate.getTime();
                    this.countdownTime = this.formatTimeLeft(elapsedTime);
                    this.stoppedTimeFormatted = this.countdownTime;
                }
                
                this.completedTime = session.First_Response_Time__c;
    
                if (this.completedTime > this.targetTime) {
                    this.timerClass = 'timer-violated';
                } else {
                    this.timerClass = 'card-sabrina-content';
                }
                return;
            }
    
            // Jika sampai di sini, berarti timer masih aktif
            console.log('Timer aktif, starting countdown');
            
            // Hitung waktu saat ini dan mulai timer
            const currentTime = new Date().getTime();
            const elapsedTime = currentTime - this.createdDate.getTime();
            console.log('Elapsed time (ms):', elapsedTime);
            this.countdownTime = this.formatTimeLeft(elapsedTime);
            console.log('Initial countdown time:', this.countdownTime);
            
            this.startCountdown();
        } catch (error) {
            console.error('Error retrieving session:', error);
            // Pastikan countdownTime selalu memiliki nilai
            this.countdownTime = this.countdownTime || '0s';
        }
    }

    formatTargetTime() {
        if (this.targetTime) {
            this.targetTimeFormatted = `${this.targetTime} menit`;
        } else {
            this.targetTimeFormatted = 'Tidak ada target waktu';
        }
    }

    clearTimerInterval() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    }

    startCountdown() {
        // Bersihkan interval sebelumnya jika ada
        this.clearTimerInterval();
        
        console.log('startCountdown dipanggil');
        
        // Validasi data yang diperlukan
        if (!this.createdDate) {
            console.error('CreatedDate tidak tersedia saat memulai countdown');
            this.createdDate = new Date(); // Fallback ke waktu sekarang
            console.log('Menggunakan waktu sekarang sebagai fallback:', this.createdDate);
        }
        
        if (!this.targetTime) {
            console.error('TargetTime tidak tersedia saat memulai countdown');
            this.targetTime = 2; // Default 2 menit
            console.log('Menggunakan default targetTime:', this.targetTime);
        }
        
        // Memastikan countdownTime telah diinisialisasi
        const currentTime = new Date().getTime();
        const elapsedTime = currentTime - this.createdDate.getTime();
        this.countdownTime = this.formatTimeLeft(elapsedTime);
        console.log('countdownTime awal:', this.countdownTime, 'elapsedTime (ms):', elapsedTime);
        
        const targetTimeInMillis = this.targetTime * 60 * 1000;
        this.isTimerStopped = false;
        
        console.log('Mulai interval dengan:');
        console.log('- createdDate:', this.createdDate, '(timestamp:', this.createdDate.getTime(), ')');
        console.log('- targetTime:', this.targetTime, 'menit');
        console.log('- targetTimeInMillis:', targetTimeInMillis, 'ms');
        console.log('- currentTime:', new Date(), '(timestamp:', currentTime, ')');
        console.log('- elapsedTime:', elapsedTime, 'ms');
    
        this.intervalId = setInterval(() => {
            // Jika status Ended, hentikan timer tapi simpan nilai terakhir
            if (this.status === 'Ended') {
                console.log('Status Ended terdeteksi, menghentikan interval');
                this.clearTimerInterval();
                return;
            }
    
            const now = new Date().getTime();
            const elapsed = now - this.createdDate.getTime();
            
            // Debugging intermittent - log setiap 5 detik
            if (Math.floor(elapsed/1000) % 5 === 0) {
                console.log('Timer update - now:', now, 'elapsed:', elapsed, 'ms');
            }
    
            if (elapsed <= targetTimeInMillis) {
                this.countdownTime = this.formatTimeLeft(elapsed);
                this.timerClass = 'card-sabrina-content';
            } else {
                const overtimeMillis = elapsed - targetTimeInMillis;
                this.countdownTime = `${this.formatTimeLeft(overtimeMillis)}`;
                this.timerClass = 'timer-violated';
            }
        }, 1000);
        
        console.log('Interval timer dimulai dengan ID:', this.intervalId);
    }

    @api
    async stopTimer() {
        console.log('stopTimer() dipanggil di LWC!');
        this.clearTimerInterval();
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
        this.countdownTime = completionTime; // Update countdownTime juga

        try {
            await updateTimerStatus({
                recordId: this.recordId,
                isStopped: true,
                completionTime: completionTime,
                completedTime: Math.floor(elapsedTime / 60000)
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
        // Validasi input
        if (!ms || isNaN(ms) || ms < 0) {
            console.warn('formatTimeLeft menerima nilai tidak valid:', ms);
            ms = 0; // Default ke 0 jika nilai tidak valid
        }
        
        const totalSeconds = Math.floor(ms / 1000);
        const days = Math.floor(totalSeconds / 86400);
        const hours = Math.floor((totalSeconds % 86400) / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = totalSeconds % 60;

        // Debugging
        console.log(`formatTimeLeft - ms: ${ms}, totalSeconds: ${totalSeconds}, days: ${days}, hours: ${hours}, minutes: ${minutes}, seconds: ${seconds}`);

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
        this.clearTimerInterval();
    }
}