trigger paymentTrigger on Payment__c (before insert) {
    
    /*
    if(System.isFuture()) {
        return;
    }
    PaymentHandleClass.handlePayments(JSON.serialize(Trigger.new));
    */
    PaymentHandleClass.handlePayments(Trigger.new);
}