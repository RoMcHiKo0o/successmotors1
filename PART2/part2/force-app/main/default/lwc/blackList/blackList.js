import { LightningElement, wire } from 'lwc';

import getBlackList from '@salesforce/apex/BlackListClass.getBlackList';
import deleteFromBlackList from '@salesforce/apex/BlackListClass.deleteFromBlackList';
import changeBlackListComponent from 'c/changeBlackListComponent';


import { subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import blackListChannel from '@salesforce/messageChannel/blackList__c';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BlackList extends LightningElement {
    data=[];
    subscription = null;
    isLoading=false;
    selectedRows = [];
    columns = [
        {label: 'Name', fieldName: 'Name'},
        {label: 'Type', fieldName: 'Type'}
    ];

    @wire(MessageContext)
    messageContext;



    subscribeToMessageChannel() {
        this.subscription = subscribe(
          this.messageContext,
          blackListChannel,
          (message) => this.handleMessage(message)
        );
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(m) {
        const event = new ShowToastEvent(m)
        this.dispatchEvent(event);
        if (m.title == 'Success') {
            this.refresh();
        }
    }

    refresh() {
        this.isLoading = true;
        this.data = [];
        getBlackList()
        .then(data => {
            let accountData = data.accounts;
            let contactData = data.contacts;
            let accountResult = []
            let contactResult = []
            accountResult = accountData.map((x) => {
                let tmp = {"Id": x.Id, "Name": x.Name, "Type": "Account"};
                return tmp;
            }
            );
            contactResult = contactData.map((x) => {
                let tmp = {"Id": x.Id, "Name": x.Name, "Type": "Contact"};
                return tmp;
            }
            );
            this.data = [...accountResult, ...contactResult];
            this.isLoading=false;
        })
        .catch(err => {
        })
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
        this.refresh();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
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

    async handleChange() {
        
        const result = await changeBlackListComponent.open({initialData: this.data});
    }
}