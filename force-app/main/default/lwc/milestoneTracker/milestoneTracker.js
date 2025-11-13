import { LightningElement, api, track, wire } from 'lwc';
import getCustomMilestonesWithDetails from '@salesforce/apex/CustomMilestoneService.getCustomMilestonesWithDetails';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";

export default class milestoneTracker extends NavigationMixin(LightningElement) {
    @api recordId; // The ID of the Case record
    @track milestones = [];
    @track hasCaseType = false;
    @track intervalId;

    connectedCallback() {
        // Set up the interval to update the remaining time every second
        this.intervalId = setInterval(() => {
            this.updateRemainingTime();
        }, 1000);
    }

    disconnectedCallback() {
        // Clear the interval when the component is destroyed
        clearInterval(this.intervalId);
    }

    /*handleMessage(message) {
        getCustomMilestonesWithDetails({ recordId: message.recordId })
            .then(result => {
                this.initializeSla(result);
            })
            .catch(error => {
                console.error(error);
            });
    }*/

    @wire(getCustomMilestonesWithDetails, { recordId: '$recordId' })
    wiredResult(value) {
        const { data, error } = value;
        if (data) {
            this.initializeSla(data);
        } else if (error) {
            console.error(error);
        }
    }

    handleClickName(event){
        let id = event.target.dataset.itemId;
        this.navigateToRecordViewPage(id);
        //console.log('id:'+id);

    }

    navigateToRecordViewPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: recordId,
                objectApiName: "Task",
                actionName: "view",
            },
        });
    }

    initializeSla(data) {
        // Extract only the first milestone's hasCaseType value
        //console.log('--initializeSla--');
        //console.log(data);
        //console.log('data-length:'+data.length);
        this.wiredMilestones = data;
        if(data.length > 0){
            const firstMilestone = data[0];
            //console.log('firstMilestone:'+firstMilestone);
            this.hasCaseType = firstMilestone.hasCaseType;
        }
        this.milestones = data.map(milestone => {
            let targetTime = this.formatDuration(milestone.targetResponseInMins * 60000);
            let targetTimeInDays = this.formatDurationInDays(milestone.targetResponseInMins * 60000);
            let remainingTime = milestone.isViolated
                ? this.convertTimeToMilliseconds(milestone.timeSinceTargetInMins) : 
                milestone.isCompleted ? this.convertTimeToMilliseconds(milestone.elapsedTimeInMins) :
                this.convertTimeToMilliseconds(milestone.elapsedTimeInMins);
            /*let remainingTime = milestone.isViolated
                ? this.convertTimeToMilliseconds(milestone.timeSinceTargetInMins) : 
                milestone.isCompleted ? this.convertTimeToMilliseconds(milestone.elapsedTimeInMins) :
                this.convertTimeToMilliseconds(milestone.timeRemainingInMins);*/ 
            /*console.log('milestone.isViolated:'+milestone.isViolated);
            console.log('milestone.timeSinceTargetInMins:'+milestone.timeSinceTargetInMins);
            console.log('milestone.isCompleted:'+milestone.isCompleted);
            console.log('milestone.elapsedTimeInMins:'+milestone.elapsedTimeInMins);
            console.log('milestone.timeRemainingInMins:'+milestone.timeRemainingInMins);
            console.log('remainingTime:'+remainingTime);*/
            let showTarget = true;
            let milescss = '';//'height: 80px !important;';
            //if(milestone.milestoneName == 'Waiting Document') showTarget = false;
            //if(milestone.milestoneName.indexOf('Escalation Team')>-1) milescss = 'height: 100px !important;';
            return {
                id: milestone.id,
                milestoneStarted: milestone.milestoneStarted,
                name: milestone.milestoneName,
                teamName: milestone.teamName,
                targetTime: targetTime,
                targetTimeInDays: targetTimeInDays,
                remainingTime: remainingTime,
                isViolated: milestone.isViolated,
                isCompleted: milestone.isCompleted,
                isStop:milestone.isStop,
                showTarget: showTarget,
                elapsedTimeInMins: milestone.elapsedTimeInMins,
                targetDate: milestone.targetDate,
                milestoneClass: 
                    milestone.isCompleted ? 
                    'color: grey;background-color: #F5F5F5;border: 1px solid #F5F5F5;border-radius: 8px;margin-bottom: 5px;padding: 5px;'+milescss : 
                    milestone.isViolated ? 
                    'color: red;background-color: white;border: 1px solid red;border-radius: 8px;margin-bottom: 5px;padding: 5px;' :
                    milestone.milestoneStarted ?  
                    'color: black; background-color: white;border: 1px solid #070707;border-radius: 8px;margin-bottom: 5px;padding: 5px;':
                    milestone.isActive ?
                    'color: black; background-color: white;border: 1px solid #070707;border-radius: 8px;margin-bottom: 5px;padding: 5px;':
                    'color: grey; background-color: #F5F5F5;border: 1px solid grey;border-radius: 8px;margin-bottom: 5px;padding: 5px;',
            };
        });
    }

    updateRemainingTime() {
        this.milestones = this.milestones.map(milestone => {
            let updatedRemainingTime;
            // Reduce the remaining time by 1000ms (1 second)
            if (!milestone.isCompleted && !milestone.isStop) {
                updatedRemainingTime = milestone.remainingTime + 1000;
            } else {
                updatedRemainingTime = milestone.remainingTime;
            }

            return {
                ...milestone,
                remainingTime: updatedRemainingTime,
                formattedRemainingTime: this.formatDuration(updatedRemainingTime),
            };
        });
    }

    formatDuration(milliseconds) {
        const totalSeconds = Math.floor(milliseconds / 1000);
        const days = Math.floor(totalSeconds / (3600 * 24));
        const hours = Math.floor((totalSeconds % (3600 * 24)) / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = totalSeconds % 60;

        return `${days} Hari ${hours} Jam ${minutes} Menit ${seconds} Detik`;
    }

    formatDurationInDays(milliseconds) {
        const totalSeconds = Math.floor(milliseconds / 1000);
        const days = Math.floor(totalSeconds / (3600 * 24));
        return `${days} Hari`;
    }

    convertTimeToMilliseconds(timeString) {
        let [minutes, seconds] = timeString.split(':').map(Number);
        let minutesInMilliseconds = minutes * 60 * 1000;
        let secondsInMilliseconds = seconds * 1000;
        return minutesInMilliseconds + secondsInMilliseconds;
    }
}