import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getOppProds from '@salesforce/apex/OpportunityStats.getOppProds';

import QUANTITY_FIELD from '@salesforce/schema/OpportunityLineItem.Quantity';
import LISTPRICE_FIELD from '@salesforce/schema/OpportunityLineItem.ListPrice';
export default class myModal extends LightningModal {

    @api oppId;
    @api oli;
    @api header;
    @api hasOli;
    @api isLoaded = false;


    
    columns = [
        {label: 'Name', fieldName: 'Product2Name', type: 'text'},
        {label: 'Quantity', fieldName: QUANTITY_FIELD.fieldApiName, type: 'number'},
        {label: 'ListPrice', fieldName: LISTPRICE_FIELD.fieldApiName, 
        type: 'currency', typeAttributes: { currencyCode: 'USD', step: '0.01' }},
    ];

    @wire(getOppProds, {oppId: '$oppId'})
    getOLI({data, error}) {
        this.isLoaded = false;
        console.log('modal oppid');
        console.log(this.oppId);
        if (data) {
            console.log(data);
            this.hasOli = data.length>0;
            this.oli= data.map(row => { 
                return {...row, Product2Name: row.Product2.Name } 
            })
            this.isLoaded = true;
        }
        else if (error) {
            console.log(error);
        }
    }
}