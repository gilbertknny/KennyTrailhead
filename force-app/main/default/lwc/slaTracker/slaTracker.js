import { LightningElement, api, wire } from 'lwc';
import getCaseMilestones from '@salesforce/apex/SCC_CaseMilestoneController.getCaseMilestones';

export default class SlaOlaTracker extends LightningElement {
    @api recordId; // The ID of the Case record

    milestones = [];

    @wire(getCaseMilestones, { caseId: '$recordId' })
    wiredMilestones({ error, data }) {
        if (data) {
            this.milestones = data.map(milestone => {
                //let targetTime = this.calculateTargetTime(milestone.StartDate, milestone.TargetDate);
                let targetTime = this.formatDuration(milestone.TargetResponseInMins * 60000);
                let remainingTime = milestone.IsViolated ? this.formatDuration(this.convertTimeToMilliseconds(milestone.TimeSinceTargetInMins)) : this.formatDuration(this.convertTimeToMilliseconds(milestone.TimeRemainingInMins));

                return {
                    id: milestone.Id,
                    name: milestone.MilestoneType.Name,
                    targetTime: targetTime,
                    remainingTime: remainingTime,
                    isViolated : milestone.IsViolated,
                    isCompleted : milestone.IsCompleted,
                    milestoneClass : milestone.IsCompleted ? 'background-color: lightgray;' : 'background-color: white;',
                    violatedClass : milestone.IsViolated ? 'color: red;' : 'color: black;',
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    calculateTargetTime(startDate, targetDate) {
        let start = new Date(startDate);
        let target = new Date(targetDate);
        let duration = target - start;

        return this.formatDuration(duration);
    }

    calculateRemainingTime(targetDate) {
        let now = new Date();
        let target = new Date(targetDate);
        let remaining = target - now;
        //return remaining > 0 ? this.formatDuration(remaining) : 'Expired';
        return remaining > 0 ? this.formatDuration(remaining) : this.formatDuration(remaining);
    }

    formatTime(dateString) {
        let date = new Date(dateString);
        return `${date.getDate()} ${this.getMonthName(date.getMonth())} ${date.getFullYear()}`;
    }

    formatDuration(milliseconds) {
        const totalSeconds = Math.floor(milliseconds / 1000);
        const days = Math.floor(totalSeconds / (3600 * 24));
        const hours = Math.floor((totalSeconds % (3600 * 24)) / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = totalSeconds % 60;

        return `${days} Hari ${hours} Jam ${minutes} Menit ${seconds} Detik`;
    }

    getMonthName(monthIndex) {
        const monthNames = [
            'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
            'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        return monthNames[monthIndex];
    }

    convertTimeToMilliseconds(timeString) {
        // Split the time string into minutes and seconds
        let [minutes, seconds] = timeString.split(':').map(Number);

        // Convert minutes and seconds to milliseconds
        let minutesInMilliseconds = minutes * 60 * 1000;
        let secondsInMilliseconds = seconds * 1000;

        // Calculate the total time in milliseconds
        let totalMilliseconds = minutesInMilliseconds + secondsInMilliseconds;

        return totalMilliseconds;
    }
}