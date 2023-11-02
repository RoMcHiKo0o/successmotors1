import { LightningElement, wire, api, track } from 'lwc';
import getOpps from '@salesforce/apex/sharingOppClass.getOpps';
import getUsers from '@salesforce/apex/sharingOppClass.getUsers';

import shareOpps from '@salesforce/apex/sharingOppClass.shareOpps';
import cascadeDelete from '@salesforce/apex/sharingOppClass.cascadeDelete';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityShareList extends LightningElement {

    opps = [];
    selectedRows = [];
    columns = [
        {label: 'Opportunity name', fieldName: 'Name'},
        {label: 'Created Date', fieldName: "CreatedDate", type: 'date'},
        {label: 'Close Date', fieldName: "CloseDate", type: 'date'},
        {label: 'Amount', fieldName: "Amount",
        type: 'currency', cellAttributes: {alignment: "left"}, typeAttributes: {fieldName: "Amount", currencyCode: 'USD', step: '0.01' }}
    ];

    users = [];

    connectedCallback(){
        getOpps()
        .then((data)=>{
            this.opps=data;
        })
        .catch((e)=>{
        })

        getUsers()
        .then((data)=> {
            this.users = data;
        })
        .catch(e=>{
        })

    }

    handleRowSelection(event) {
        switch (event.detail.config.action) {
            case 'selectAllRows':
                for (let i = 0; i < event.detail.selectedRows.length; i++) {
                    this.selectedRows.push(event.detail.selectedRows[i].Id);
                }
                break;
            case 'deselectAllRows':
                this.selectedRows = [];
                break;
            case 'rowSelect':
                this.selectedRows.push(event.detail.config.value);
                break;
            case 'rowDeselect':
                this.selectedRows=this.selectedRows.filter(el => el!=event.detail.config.value);
                break;
            default:
                break;
        }
    }

    handleDelete() {
        cascadeDelete({"Ids": this.selectedRows})
        .then(data => {
            let eventData;
            if (data.success) {
                let deletedRows = data.deletedIds;
                this.opps = this.opps.filter(el => deletedRows.indexOf(el)==-1);
                eventData = {
                    title: 'Success',
                    message: `Opportunities were successfully deleted.
                    Deleted: ${deletedRows.length}, not deleted: ${this.selectedRows.length-deletedRows.length}`,
                    variant: 'success'
                }
            }
            else {
                eventData = {
                    title: 'Error',
                    message: data.errors,
                    variant: 'error'
                }
            }
            this.dispatchEvent(new ShowToastEvent(eventData));
            
        })
        .catch((err) => {
        })

        this.data = this.data.filter((el) => this.selectedRows.indexOf(el.Id)==-1)
    }

    handleShareClick(event) {
        let userId = event.target.value;
        shareOpps({'ids': this.selectedRows, 'userId': userId})
        .then(result => {
            if (result.success) {
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Opportunities were successfully shared',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
            }
            else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: result.errors,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
        })
        .catch(err=> {
        })

    }
}