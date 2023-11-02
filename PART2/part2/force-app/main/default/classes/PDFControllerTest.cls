@isTest
public with sharing class PDFControllerTest {

    @TestSetup
    static void makeData(){
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact testContact = new Contact(LastName = 'Test Contact', AccountId=testAccount.Id, Phone='+123', Email='test@test.com');
        insert testContact;
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

    @isTest
    static void generatePDFTest() {

        Test.startTest();
        Opportunity opp = [select Id from Opportunity limit 1];
        Id oppId = opp.Id;
        Contact testContact = [select Id,Name, Phone,Email from Contact limit 1];
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = oppId, ContactId = testContact.Id, isPrimary=true);
        insert ocr;
        PageReference myVfPage = Page.PDFPage;
        Test.setCurrentPage(myVfPage);

        // ApexPages.StandardController ctrl = new ApexPages.StandardController();

        
        ApexPages.currentPage().getParameters().put('id', oppId);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(opp);
        PDFController ctrlC = new PDFController(ctrl);
        // System.assertEquals(ctrl, ctrlC.ctrl);
        System.assertEquals(oppId, ctrlC.oppId);
        System.assertEquals(opp.Id, ctrlC.opp.Id);

        PDFController pdfC = new PDFController();
        System.assertEquals(opp.Id, pdfC.opp.Id);
        System.assertNotEquals(null, pdfC.oppContact);
        List<OpportunityLineItem> testOppProds = [select Id from OpportunityLineItem where OpportunityId=:oppId];
        System.assertEquals(testOppProds.size(), pdfC.oppProds.size());

        System.assertEquals('$ 500.0', pdfC.balance_due);

        Pagereference result = pdfC.generatepdf();

        System.assertNotEquals(null, result);
        String inv_number = [select Invoice_Number__c from Opportunity limit 1].Invoice_Number__c;
        List<ContentVersion> cv = [select Id, Title, ContentDocumentId from ContentVersion where Title=:inv_number];
        List<ContentDocument> cd = [select Id, Title from ContentDocument where Title=:inv_number];
        System.assertEquals(1, cv.size());
        System.assertEquals(1, cd.size());

        result = pdfC.generatepdf();
        cv = [select Id, Title, ContentDocumentId from ContentVersion where Title=:inv_number];
        cd = [select Id, Title from ContentDocument where Title=:inv_number];

        System.assertEquals(2, cv.size());
        System.assertEquals(1, cd.size());
        Test.stopTest();
    } 
}