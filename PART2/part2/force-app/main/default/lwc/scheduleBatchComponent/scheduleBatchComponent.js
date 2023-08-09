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
            console.log(result.error);
        })
        .catch((error) => {
            console.log(error);
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
                    console.log('you are unsubscribe', JSON.stringify(response));
                }
            );
            
        }
        
    };

    handleChange(event) {
        this.cronString = event.target.value;
    }

    handleSchedule(event) {
        console.log(this.cronString);
        scheduleBatch({
            'jobName': this.jobName,
            'cronString': this.cronString,
            'scheduleClassName': this.scheduleClassName,

        }).then((result)=> {
            console.log(result);
            if (result.jobId != '') {
                this.isExecuting = true;
                this.scheduleJob = result.jobId;
                console.log(this.scheduleJob);
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
            console.log('error in schedule');
            console.log(e);
        });  

    }

    handleAbort(event) {
        console.log('опа: ' + this.scheduleJob);
        abortBatch({'job': this.scheduleJob})
        .then((result)=> {
            console.log(result);
        })
        .catch((e)=> {
            console.log('error in abort');
            console.log(e);
        })
        this.isExecuting = false;
    }

    handleRun(event) {
        this.notFinished = true;
        console.log('hi');
        exBatch({'batchClassName': this.batchClassName})
        .then((result)=> {
            console.log(result);
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
            console.log('error in execute batch');
            console.log(e);
        });
    }
}