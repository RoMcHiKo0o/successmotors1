import { LightningElement, api ,track,wire} from 'lwc';
import getAllAccounts from '@salesforce/apex/OpportunityStats.getAllAccounts';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import CREATED_FIELD from '@salesforce/schema/Opportunity.CreatedDate';
import CLOSE_FIELD from '@salesforce/schema/Opportunity.CloseDate';
import AMOUNT_FIELD from '@salesforce/schema/Opportunity.Amount';
import myModal from 'c/myModal';

import { CurrentPageReference } from 'lightning/navigation';

export default class OpportunityList extends LightningElement {
    @api recordId;
    accountId = '';
    accs = [];
    filteredAccs = [];
    @api hasAccs;
    @api isLoaded=false;
    @api isAccPage = false;
    page = 0;
    noPrev = true;
    noNext = false;
    


    search = '';
    amount = 0;
    sign = 'more';


    @api selectedRow;


    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.isAccPage = currentPageReference.attributes.objectApiName === 'Account' &&
            currentPageReference.type === 'standard__recordPage';
            console.log(currentPageReference);
        }
        this.accountId = this.isAccPage ? currentPageReference.attributes.recordId : '';    
        
        console.log('page detected: ' + this.accountId);
    }



    actions = [
        { label: 'Show Opportunity Products', name: 'show_opp_prod' }
    ];



    columns = [

        {label: 'Opportunity name', fieldName: 'oppLink',
        type: 'url',
        typeAttributes: { label: { fieldName: NAME_FIELD.fieldApiName}, target: '_blank' }},
        
        {label: 'Created Date', fieldName: CREATED_FIELD.fieldApiName, type: 'date'},
        {label: 'Close Date', fieldName: CLOSE_FIELD.fieldApiName, type: 'date'},
        {label: 'Amount', fieldName: AMOUNT_FIELD.fieldApiName,
        type: 'currency', typeAttributes: { currencyCode: 'USD', step: '0.01' }},
        {
            type: 'action',
            typeAttributes: { rowActions: this.actions }
        }
    ];

    @wire(getAllAccounts, {page: '$page', search: '$search', accountId: '$accountId'})
    getAccs({data, error}) {
        console.log('getting accounts: ' + this.accountId);
        if(data) {
            this.isLoaded = false;
            console.log(this.hasAccs);
            this.noNext = data.length<10;
            this.accs = this.changeData(data);
            this.filterAccounts();
            console.log(this.filteredAccs);
        }
        else if (error) {
            console.log(error);
        }
    }

    changeData(data) {
        try {
            var res = [];
            data.forEach(acc => {
                var oppRes = [];
                if (acc?.Opportunities) {
                    acc?.Opportunities.forEach(opp => {
                        oppRes.push({...opp, oppLink: '/' + opp.Id});
                    });
                    acc = Object.assign({}, acc, {Opportunities: oppRes, hasOpps: oppRes.length>0})
                }
                res.push(acc);
            });
            return res;
        }
        catch(e) {
            console.log('ошибка');
            console.log(e);
        }
    }

    setNextPage() {
        console.log('next');
        this.page++; 
        this.noPrev = false;
        console.log(this.filteredAccs);
    }
    
    setPrevPage() {
        console.log('prev');
        this.page--;
        this.noNext = false;
        this.noPrev = this.page==0;
        console.log(this.filteredAccs);
        
    }

    async showOppProducts() {
        const result = await myModal.open({oppId: this.selectedRow.Id, header: this.selectedRow.Name});
        console.log(result);
        
    }
    isTrue(a) {
        const s = this.sign;
        const b = this.amount;
        switch (s) {
            case 'more':
                return a>=b;
            case 'less':
                return a<=b;
            case 'equals':
                return a==b;
            default:
                break;
        }
        
    }
    filterAccounts() {
        try {
            this.isLoaded = false;
            this.filteredAccs = this.accs.filter((el) => {
                return this.isTrue(el.Total);
            })
            this.hasAccs = true;
            if (this.filteredAccs.length==0) {
                this.hasAccs = false;
            }    
            this.isLoaded = true;
        } catch (error) {
            console.log(error);
        }
        
        console.log(this.filteredAccs);
    }

    handleRowAction(event) {
        console.log(event.detail.row);
        this.selectedRow = event.detail.row;
        console.log('selected id: ' + this.selectedRow);
        this.showOppProducts();
    }

    handleAccountChange(event) {
        this.search = event.target.value;
        this.page = 0;
        this.noPrev = true;
        console.log(this.search);
    }

    handleAmountChange(event) {
        this.amount = event.target.value || 0;
        console.log(this.amount);
        this.filterAccounts();
    }
    handleSelectChange(event) {
        this.sign = event.target.value;
        console.log(this.sign);
        this.filterAccounts();
    }
}