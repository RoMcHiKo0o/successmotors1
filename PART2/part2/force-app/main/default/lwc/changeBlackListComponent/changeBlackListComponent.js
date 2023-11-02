import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getAllAccountsAndContacts from '@salesforce/apex/BlackListClass.getAllAccountsAndContacts';
import deleteFromBlackList from '@salesforce/apex/BlackListClass.deleteFromBlackList';
import insertIntoBlackList from '@salesforce/apex/BlackListClass.insertIntoBlackList';


import { publish, MessageContext } from 'lightning/messageService';
import blackListChannel from '@salesforce/messageChannel/blackList__c';




export default class changeBlackListComponent extends LightningModal {

    isChanged = false;
    initialValues = [];
    options = [];
    insertList = [];
    deleteList = [];
    @api initialData;

    @wire(MessageContext)
    messageContext;


    connectedCallback() {
        getAllAccountsAndContacts()
        .then(data => {
            let accountData = data.accounts;
            let contactData = data.contacts;
            let accountResult = []
            let contactResult = []
            accountResult = accountData.map((x) => {
                return {'value': x.Id, 'label': x.Name + " (Account)"};
            }
            );
            contactResult = contactData.map((x) => {
                return {'value': x.Id, 'label': x.Name + " (Contact)"};
            }
            );
            this.options = [...accountResult, ...contactResult];
            this.initialValues = this.initialData.map(el => {return el.Id});
        })
        .catch(err => {});
    }

    handleChange(e) {
        this.insertList = e.detail.value.filter(el => this.initialValues.indexOf(el)==-1);
        this.deleteList = this.initialValues.filter(el => e.detail.value.indexOf(el)==-1);

        this.isChanged = this.insertList.length || this.deleteList.length;
    }

    handleCancel() {
        this.close();
    }

    handleSave() {
        Promise.all([deleteFromBlackList({Ids: this.deleteList}), insertIntoBlackList({Ids: this.insertList})]) 
        .then(data => {
            let payload;
            if (data[0].success && data[1].success) {
                payload = {
                    title: 'Success',
                    message: 'Black list was successfully changed',
                    variant: 'success'
                };
                publish(this.messageContext, blackListChannel, payload);
                this.close();
            }
            else {
                payload = {
                    title: 'Error',
                    message: [data[0].errors, data[1].errors],
                    variant: 'error'
                } 
                publish(this.messageContext, blackListChannel, payload);
            }

        })
        .catch(err => {
        })
    }
}