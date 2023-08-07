import { LightningElement, api } from 'lwc';

import exBatch from '@salesforce/apex/batchScheduleClass.executeBatch'
import scheduleBatch from '@salesforce/apex/batchScheduleClass.scheduleBatch'
import abortBatch from '@salesforce/apex/batchScheduleClass.abortBatch'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe } from 'lightning/empApi';


export default class ScheduleBatchComponent extends LightningElement {

    isExecuting = false;
    cronString = '0 0 0 * * ?';
    scheduleJob;
    @api batchClassName;
    @api scheduleClassName;





    channelName = '/event/batch_finish_event__e';
    subscription;

    messageCallback(response, batchJob) {
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
            'jobName': 'Scheduling Batch from LWC',
            'cronString': this.cronString,
            'scheduleClassName': this.scheduleClassName,

        }).then((result)=> {
            console.log(result);
            if (result != '') {
                this.isExecuting = true;
            }
            else {
                const event = new ShowToastEvent({
                    title: 'something goes wrong',
                    message: '',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }
            this.scheduleJob = result;
            console.log(this.scheduleJob);
        })
        .catch((e)=> {
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
            console.log(e);
        })
        this.isExecuting = false;
    }

    handleRun(event) {
        console.log('hi');
        exBatch({'batchClassName': this.batchClassName})
        .then((result)=> {
            console.log(result);
            subscribe(this.channelName, -1, (response)=>this.messageCallback(response, result)).then(result=>this.subscription=result);
        })
        .catch((e)=>{console.log(e);});
    }
}