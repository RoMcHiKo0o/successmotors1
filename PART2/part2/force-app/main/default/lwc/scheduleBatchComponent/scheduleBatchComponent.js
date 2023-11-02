import { LightningElement, api } from 'lwc';

import exBatch from '@salesforce/apex/batchScheduleClass.executeBatch'
import scheduleBatch from '@salesforce/apex/batchScheduleClass.scheduleBatch'
import abortBatch from '@salesforce/apex/batchScheduleClass.abortBatch'
import checkScheduledJob from '@salesforce/apex/batchScheduleClass.checkScheduledJob'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe } from 'lightning/empApi';


export default class ScheduleBatchComponent extends LightningElement {

    isExecuting = false;
    notFinished = false;
    cronString = '0 0 0 * * ?';
    jobName = 'Scheduling Batch from LWC';
    scheduleJob;
    @api batchClassName;
    @api scheduleClassName;





    channelName = '/event/batch_finish_event__e';
    subscription;
    connectedCallback() {
        checkScheduledJob({'jobName': this.jobName})
        .then((result) => {
            this.isExecuting = (result.jobId != '');
            this.scheduleJob = result.jobId;
        })
        .catch((error) => {
        })
    }
    messageCallback(response, batchJob) {
        this.notFinished=false;
        if (response.data.payload.JobId__c == batchJob) {
            var title = '';
            var variant = '';
            if (response.data.payload.Status__c != 'Completed') {
                title = 'Something goes wrong';
                variant = 'error';
            }
            else {
                title = 'DONE!';
                variant = 'success';
            }
            const event = new ShowToastEvent({
                title: title,
                message: '',
                variant: variant
            });
            this.dispatchEvent(event);
            unsubscribe(
                this.subscription,
                (response)=>{
                }
            );
            
        }
        
    };

    handleChange(event) {
        this.cronString = event.target.value;
    }

    handleSchedule(event) {
        scheduleBatch({
            'jobName': this.jobName,
            'cronString': this.cronString,
            'scheduleClassName': this.scheduleClassName,

        }).then((result)=> {
            if (result.jobId != '') {
                this.isExecuting = true;
                this.scheduleJob = result.jobId;
            }
            else {
                const event = new ShowToastEvent({
                    title: 'something goes wrong',
                    message: result.error,
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }
            
        })
        .catch((e)=> {
        });  

    }

    handleAbort(event) {
        abortBatch({'job': this.scheduleJob})
        .then((result)=> {
        })
        .catch((e)=> {
        })
        this.isExecuting = false;
    }

    handleRun(event) {
        this.notFinished = true;
        exBatch({'batchClassName': this.batchClassName})
        .then((result)=> {
            if (result.jobId != '') {
                this.notFinished = true;
                subscribe(this.channelName, -1, (response)=>this.messageCallback(response, result.jobId)).then(result=>this.subscription=result);
            }
            else {
                const event = new ShowToastEvent({
                    title: 'something goes wrong',
                    message: result.error,
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }
            
        })
        .catch((e)=>{
        });
    }
}