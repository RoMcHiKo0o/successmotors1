@isTest
public with sharing class OpportunityStatsTest {

    @TestSetup
    static void makeData(){
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Opportunity testOpportunity = new Opportunity(AccountId = testAccount.Id, Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
        insert testOpportunity;
        Product2 testProduct1 = new Product2(Name = 'Test Product 1', IsActive = true);
        insert testProduct1;
        Product2 testProduct2 = new Product2(Name = 'Test Product 2', IsActive = true);
        insert testProduct2;
        PricebookEntry testPrice1 = new PricebookEntry(Product2Id = testProduct1.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 100, IsActive = true);
        insert testPrice1;
        PricebookEntry testPrice2 = new PricebookEntry(Product2Id = testProduct2.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 200, IsActive = true);
        insert testPrice2;
        OpportunityLineItem testLineItem1 = new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPrice1.Id, Quantity = 1, TotalPrice = 100);
        insert testLineItem1;
        OpportunityLineItem testLineItem2 = new OpportunityLineItem(OpportunityId = testOpportunity.Id, PricebookEntryId = testPrice2.Id, Quantity = 2, TotalPrice = 400);
        insert testLineItem2;
    }
    @isTest static void testGetOppProds() {
        Test.startTest();
        Opportunity opp = [select Id, Name from Opportunity limit 1];
        List<OpportunityLineItem> result = OpportunityStats.getOppProds(opp.Id);
        Test.stopTest();
        System.assertEquals(2, result.size());
        for (OpportunityLineItem oli : result) {
            System.assertNotEquals(null, oli.Id);
            System.assertNotEquals(null, oli.Product2.Name);
            System.assertNotEquals(null, oli.Quantity);
            System.assertNotEquals(null, oli.ListPrice);
            System.assertEquals(opp.Name, oli.Opportunity.Name);
        }
    }

    @isTest
    static void testGetOppProdsError() {
        Test.startTest();
        Opportunity opp = [select Id, Name from Opportunity limit 1];
        String oppId = opp.Id;
        delete opp;
        List<OpportunityLineItem> result = OpportunityStats.getOppProds(oppId);
        Test.stopTest();
        system.assertEquals(0, result.size());        
    }


    @isTest static void testGetAllAccounts() {
        Test.startTest();
        List<Opportunity> opps = [select Id, StageName from Opportunity];
        for(Opportunity opp: opps) {
            opp.StageName = 'Closed Won';

        }
        update opps;
        List<Map<String,Object>> result = OpportunityStats.getAllAccounts(0, '', '');
        Test.stopTest();
        System.assertEquals(1, result.size());
        for (Map<String,Object> acc : result) {
            System.assertNotEquals(null, acc.get('Id'));
            System.assertNotEquals(null, acc.get('Name'));
            List<Map<String,Object>> oppList = (List<Map<String,Object>>)acc.get('Opportunities');
            System.debug(oppList);
            System.assertEquals(1, oppList.size());
            for (Map<String,Object> opp : oppList) {
                System.assertNotEquals(null, opp.get('Id'));
                System.assertNotEquals(null, opp.get('Name'));
                System.assertNotEquals(null, opp.get('CreatedDate'));
                System.assertNotEquals(null, opp.get('CloseDate'));
                System.assertNotEquals(null, opp.get('Amount'));
            }
            System.assertNotEquals(null, acc.get('AccountAmount'));
            System.assertNotEquals(null, acc.get('Total'));
        }
    }


    @isTest static void testGetAllAccountsByAccountId() {
        Test.startTest();
        List<Opportunity> opps = [select Id, StageName from Opportunity];
        for(Opportunity opp: opps) {
            opp.StageName = 'Closed Won';

        }
        update opps;
        Id accId = [select Id from Account limit 1].Id;
        List<Map<String,Object>> result = OpportunityStats.getAllAccounts(0, '', accId);
        Test.stopTest();
        System.assertEquals(1, result.size());
        for (Map<String,Object> acc : result) {
            System.assertNotEquals(null, acc.get('Id'));
            System.assertNotEquals(null, acc.get('Name'));
            List<Map<String,Object>> oppList = (List<Map<String,Object>>)acc.get('Opportunities');
            System.debug(oppList);
            System.assertEquals(1, oppList.size());
            for (Map<String,Object> opp : oppList) {
                System.assertNotEquals(null, opp.get('Id'));
                System.assertNotEquals(null, opp.get('Name'));
                System.assertNotEquals(null, opp.get('CreatedDate'));
                System.assertNotEquals(null, opp.get('CloseDate'));
                System.assertNotEquals(null, opp.get('Amount'));
            }
            System.assertNotEquals(null, acc.get('AccountAmount'));
            System.assertNotEquals(null, acc.get('Total'));
        }
    }
}