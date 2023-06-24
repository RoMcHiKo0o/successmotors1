import { LightningElement, api } from 'lwc';

export default class FilterSearchComponent extends LightningElement {

    handleAccountChange(event) {
        this.dispatchEvent(new CustomEvent('accountchange',
            {
                detail: event.target.value
            }
        ))
    }


    handleAmountChange(event) {
        this.dispatchEvent(new CustomEvent('amountchange',
            {
                detail: event.target.value || 0
            }
        ))
    }

    handleSelectChange(event) {
        this.dispatchEvent(new CustomEvent('selectchange',
            {
                detail: event.target.value
            }
        ))
    }
}