@isTest
public class paymentTriggerTest {
    
	@isTest
    public static void testTrigger() {
        Account testAccount = new Account(Name = 'testName');
        insert testAccount;
        Contact testContact = new Contact(LastName = 'testLastName' ,AccountId = testAccount.Id);
        insert testContact;
        String oppName = 'Test opp';
        Opportunity testOpp = new Opportunity(
            ContactId = testContact.Id,
            Name = oppName,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 1000
        );
        insert testOpp;
        Payment__c testPayment = new Payment__c(OpportunityName__c = oppName, Amount__c = 100, FirstName__c = 'test', LastName__c = 'test');
        insert testPayment;
        system.assertEquals(100, [select AlreadyPaid__c from Opportunity where Name =: oppName limit 1].AlreadyPaid__c);
        system.assertEquals('Partially Paid', [select Pay_status__c from Opportunity where Name =: oppName limit 1].Pay_status__c);
 		
        Payment__c testPayment2 = new Payment__c(OpportunityName__c = oppName, Amount__c = 1000, FirstName__c = 'test', LastName__c = 'test');
        insert testPayment2;
        system.assertEquals(1000, [select AlreadyPaid__c from Opportunity where Name =: oppName limit 1].AlreadyPaid__c);
        system.assertEquals('Fully Paid', [select Pay_status__c from Opportunity where Name =: oppName limit 1].Pay_status__c);
        
        String contactOwnerId = [select OwnerId from Contact where Id =:testContact.Id].OwnerId;
        Task new_task = [select Id, WhatId, OwnerId, ReminderDateTime from Task where WhatId=:testOpp.Id and OwnerId = :contactOwnerId];
        Date offset = Date.today()+1;
        DateTime rem_date = DateTime.newInstance(offset, Time.newInstance(10,0,0,0));
        System.assertNotEquals(null, new_task);
        System.assertEquals(rem_date, new_task.ReminderDateTime);
    }
}