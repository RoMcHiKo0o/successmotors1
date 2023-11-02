import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import get_Invoice_id from '@salesforce/apex/InvoiceEmail.get_Invoice_id';
import sendEmail from '@salesforce/apex/InvoiceEmail.sendEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { CloseActionScreenEvent } from 'lightning/actions';





import getAllData from '@salesforce/apex/InvoiceEmail.getAllData';

export default class EmailQuickAction extends NavigationMixin(LightningElement) {

    @api recordId;
    name;
    email;
    subject;
    body;

    @wire(getAllData, {oppId: '$recordId'})
    getData({data, error}) {
        if (data) {
            this.name = data.name;
            this.email = data.email;
            this.body = data.body;
            this.subject = data.subject;
        }
        if (error) {
        }
    }

    handleChange(event) {
        this.body = event.detail.value;
    }


    showHandle() {
        get_Invoice_id({oppId: this.recordId}).then(
            (response)=> {
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
                const event = new ShowToastEvent({
                    title: 'Preview error',
                    message: 'No invoices found',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            });
        
    }

    sendHandle() {
        sendEmail({
            oppId: this.recordId,
            subject: this.subject,
            body: this.body
        }).then(result => {
            if (result.success) {
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
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'No invoices found for attachment',
                    variant: 'error'
                });
                this.dispatchEvent(event);
        })

    }

}