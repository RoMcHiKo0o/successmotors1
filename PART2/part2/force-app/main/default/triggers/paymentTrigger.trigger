trigger paymentTrigger on Payment__c (before insert) {
    
    PaymentHandleClass.handlePayments(Trigger.new);
}