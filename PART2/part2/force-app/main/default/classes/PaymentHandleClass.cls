public with sharing class PaymentHandleClass {
    public static void handlePayments(List<Payment__c> payments) {
        List<Task> tasks = new List<Task>();
        for(Payment__c p: payments) {
            List<Opportunity> opps = [select Id, Amount, AlreadyPaid__c, Pay_status__c, ContactId from Opportunity where Name =:p.OpportunityName__c limit 1];
            if (opps.size() > 0) {
                Opportunity opp = opps[0];
                if (opp.Pay_status__c != 'Fully Paid') {
                    Decimal alreadyPaid = opp.AlreadyPaid__c+p.Amount__c;
                    if (alreadyPaid>=opp.Amount) {
                        opp.Pay_status__c = 'Fully Paid';
                        tasks.add(PaymentHandleClass.createTask(opp.ContactId, opp.Id));
                    }
                    opp.AlreadyPaid__c = Math.min(alreadyPaid, opp.Amount);
                    update opp;
                    //TODO подумать как сделть update списка, а не одному Opp.
                }
            }
        }
        insert tasks;
    }
    
    
    public static Task createTask(String contactId, String oppId) {
		Id ContactOwnerId = [select OwnerId from Contact where Id = :contactId limit 1].OwnerId;
        
        Date offset = Date.today()+1;
        /*
        if (DateTime.now().hourGMT()>=7) {
            offset += 1;
            }
        */
        DateTime rem_date = DateTime.newInstance(offset, Time.newInstance(10,0,0,0));
        
        Task newTask = new Task(
            OwnerId=ContactOwnerId,
            Priority = 'High',
            Status = 'Not Started',
            Subject = 'Delivery of goods',
            WhatId = oppId,
            ReminderDateTime = rem_date
        );
        return newTask;
    }
}