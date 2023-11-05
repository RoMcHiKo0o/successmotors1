@IsTest
global with sharing class sharingOppTestClass {
    @TestSetup
    global static void generateOpps(){

        Account acc1 = new Account(Name='acc1');
        Account acc2 = new Account(Name='acc2');
        insert acc1;
        insert acc2;
        Contact cont1 = new Contact(LastName='cont1');
        insert cont1;

        Contact cont2 = new Contact(LastName='cont2',AccountId=acc1.Id);
        insert cont2;

        Black_list__c blr2 = new Black_list__c(Record_id__c= acc1.Id, Record_type__c='Account');
        Black_list__c blr3 = new Black_list__c(Record_id__c= cont1.Id, Record_type__c='Contact');
        insert blr2;
        insert blr3;

        Opportunity opp1 = new Opportunity(Name='opp1',CloseDate=Date.today(),StageName='Prospecting',is_Processed__c=false, AccountId=acc1.Id);
        Opportunity opp2 = new Opportunity(Name='opp2',CloseDate=Date.today(),StageName='Prospecting',is_Processed__c=false, ContactId=cont1.Id);
        Opportunity opp3 = new Opportunity(Name='opp3',CloseDate=Date.today(),StageName='Prospecting',is_Processed__c=true, ContactId=cont2.Id);
        Opportunity opp4 = new Opportunity(Name='opp4',CloseDate=Date.today(),StageName='Prospecting',is_Processed__c=true, AccountId=acc2.Id, ContactId=cont1.Id);
        insert opp1;
        insert opp2;
        insert opp3;
        insert opp4;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='asdasd122312sad@asdasd23.com');
        insert u1;
        User u2 = new User(Alias = 'sadasd', Email='standarduser2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@asdasd23.com');
        insert u2;

        insert new OpportunityShare(UserOrGroupId=u1.Id, OpportunityId=opp2.Id,OpportunityAccessLevel='Edit', RowCause='Manual');
    }
    @IsTest
    global static void getOppsTestMethod() {
        System.assertEquals(2, sharingOppClass.getOpps().size());
    }

    @IsTest
    global static void getUsersTestMethod() {
        System.assertEquals([select Id from User].size() - 1, sharingOppClass.getUsers().size());
    }

    @IsTest
    global static void opportunityDeleteTestMethod() {
        List<String> ToDeleteIds = new List<String>();
        for (Opportunity opp: [select Id from Opportunity]) {
            ToDeleteIds.add(opp.Id);
        }
        sharingOppClass.opportunityDelete(ToDeleteIds);
        System.assertEquals(0, [select Id from Opportunity].size());
        System.assertEquals(1, [select Id from Account].size());
        System.assertEquals(1, [select Id from Contact].size());

    }


    @IsTest
    global static void shareOppsTestMethod() {
        User u2 = [select Id from User where LastName='Testing2'];
        List<String> oppIds = new List<String>();
        Integer oldSize = [select Id from OpportunityShare].size();
        for(Opportunity opp: [select Id From Opportunity where Name = 'opp1' or Name = 'opp3']) {
            oppIds.add(opp.Id);
        }
        Map<String, Object> data = sharingOppClass.shareOpps(oppIds, u2.Id);
        System.assert((Boolean)data.get('success'));
        System.assertEquals(oldSize+2,[select Id from OpportunityShare].size());

    }
}