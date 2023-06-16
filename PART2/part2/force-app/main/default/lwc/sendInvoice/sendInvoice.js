import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getEmailTemplate from '@salesforce/apex/InvoiceEmail.get_email_template';
import getOppContact from '@salesforce/apex/InvoiceEmail.getOppContact';
import { getRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import INV_FIELD from '@salesforce/schema/Opportunity.Invoice_Number__c';
import get_Invoice_id from '@salesforce/apex/InvoiceEmail.get_Invoice_id';
import sendEmail from '@salesforce/apex/InvoiceEmail.sendEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { CloseActionScreenEvent } from 'lightning/actions';



export default class EmailQuickAction extends NavigationMixin(LightningElement) {

    templateId = '00XDo000000tizZMAQ';
    contact = {name: "", email: "", id: ""};
    subject = '';
    HtmlValue = '';
    opp = {};
    @api
    recordId;

    success = false;

    loadData() {
        Promise.all([
            getEmailTemplate({templateId: this.templateId}),
            getOppContact({oppId: this.recordId})
        ]).then((values)=> {
            console.log(values);
            let data1 = values[0];
            let data2 = values[1];
            this.contact = {...this.contact,
                name: data2.Contact?.Name,
                email: data2.Contact?.Email,
                id: data2.Contact?.Id
            };
            this.subject = this.fillSubject(data1.Subject);
            this.HtmlValue = this.fillBody(data1.HtmlValue);

        }).catch(err=>console.log(err))
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ID_FIELD, NAME_FIELD, INV_FIELD]})
    setopp({data,error}) {
        console.log(data);
        console.log(this.recordId);
        if (data) {
            console.log('getting opp data');
            this.opp = data;  
            this.loadData();
        }
        else if (error) {
            console.log(error);
        }
    }

    fillBody(htmlData) {      
        console.log('body');
        htmlData = htmlData.replace(']]>', '');
        console.log(this.recordId && this.opp?.fields?.Name?.value);
        // if (this.recordId && this.opp?.fields?.Name?.value) {
        console.log('changing');
        htmlData = htmlData.replace('{!Opportunity.Name}', this.opp?.fields?.Name?.value);
        htmlData = htmlData.replace('{!Contact.Name}', this.contact.name);
        // }
        return htmlData;
    }

    fillSubject(htmlData) {
        console.log('subject'); 
        console.log(this.opp?.fields?.Invoice_Number__c?.value);
        // if (this.opp?.fields?.Invoice_Number__c?.value) {
        console.log('changing');
        htmlData = htmlData.replace('{!Opportunity.Invoice_Number__c}', this.opp?.fields?.Invoice_Number__c?.value);
        // }
        return htmlData;
    }


    handleChange(event) {
        this.HtmlValue = event.detail.value;
    }

    showHandle() {
        console.log('1');
        get_Invoice_id({invoice: this.opp.fields.Invoice_Number__c.value}).then(
            (response)=> {
                console.log(response);
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'filePreview'
                    },
                    state : {
                        selectedRecordId: response
                    }
                })
            }).catch(error=>{
                console.log(error.body.message);
                const event = new ShowToastEvent({
                    title: 'Preview error',
                    message: 'No invoices found',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            });
        
    }

    sendHandle() {
        var comp = this;
        sendEmail({
            oppId: this.opp?.fields?.Id?.value,
            contactId: this.contact.id
        }).then(result => {
            if (result.success) {
                // this.success = true;
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Email successfully sent',
                    variant: 'success'
                }); 
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(event);
                    
            }
            else {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Smth goes wrong',
                    variant: 'error'
                });
                this.dispatchEvent(event);
                
            }
        }).catch(error => {
            console.log(error.body.message);
            console.log('ошибка при отправке');
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'No invoices found for attachment',
                    variant: 'error'
                });
                this.dispatchEvent(event);
        })

    }

}