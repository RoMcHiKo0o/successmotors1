@IsTest
public with sharing class InvoiceEmailTest {
    
    @TestSetup
    static public void setupEmailData() {        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact testContact = new Contact(LastName = 'Test Contact', AccountId=testAccount.Id, Phone='+123', Email='test@test.com');
        insert testContact;
        Opportunity testOpp = new Opportunity(AccountId = testAccount.Id, Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
        insert testOpp;
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = testOpp.Id, ContactId = testContact.Id, isPrimary=true);
        insert ocr;
        
        
        Opportunity testOpportunity = [select Invoice_Number__c from Opportunity limit 1];
        ContentVersion testContent = new ContentVersion(
            Title=testOpportunity.Invoice_Number__c, 
            VersionData = Blob.valueOf('Test Text'),
            PathOnClient=testOpportunity.Invoice_Number__c+'.pdf'
        );
        insert testContent;
        ContentDocumentLink testContentDocLink = new ContentDocumentLink(
            LinkedEntityId = testOpportunity.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id=:testContent.Id limit 1].ContentDocumentId
        );
        insert testContentDocLink;
    }
    
    @isTest static void testGetNext() {

		System.debug([select DeveloperName from EmailTemplate]);
        Opportunity opp = new Opportunity(Name='Test', StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        String nextStage = InvoiceEmail.get_next(opp.StageName);
        System.assertEquals('Qualification', nextStage);

        opp.StageName = 'Closed Won';
        update opp;
        nextStage = InvoiceEmail.get_next(opp.StageName);
        System.assertEquals('Closed Won', nextStage);
    }

    @isTest static void testGetInvoiceIdSuccess() {
        Test.startTest();
        Opportunity testOpportunity = [select Invoice_Number__c from Opportunity limit 1];
        Id result = InvoiceEmail.get_Invoice_id(testOpportunity.Id);
        System.assertEquals([select Id from ContentDocument where Title=:testOpportunity.Invoice_Number__c limit 1].Id, result);
        Test.stopTest();
    }


    @isTest static void testGetInvoiceIdError() {
        Test.startTest();
        Id oppId = [select Id from Opportunity limit 1].Id;
        delete [select Id from Opportunity];

        try{
            Id result = InvoiceEmail.get_Invoice_id(oppId);
            system.assert(false, 'Should have thrown an exception');
        }catch(AuraHandledException e){
            system.assert(true, 'AuraHandledException caught');
        }
        Test.stopTest();
    }


    @isTest static void testHandleInboundEmailApproved() {
        InvoiceEmail IM = new InvoiceEmail();
        Test.startTest();	
		Opportunity testOpportunity = [SELECT Id, StageName, Invoice_Number__c FROM Opportunity limit 1];

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'test subject: ' + testOpportunity.Invoice_Number__c;
        email.plainTextBody = 'Approved';

        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'test@test.com';

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result = IM.handleInboundEmail(email, envelope);
        System.debug(result);
        System.assertEquals(true, result.success);
        System.assertEquals(null, result.message);
        System.assertEquals('Qualification', testOpportunity.StageName);
        Test.stopTest();
    }

    @isTest static void testHandleInboundEmailRejected() {
        InvoiceEmail IM = new InvoiceEmail();
        Test.startTest();
        Opportunity testOpportunity = [SELECT Id, StageName, Invoice_Number__c FROM Opportunity limit 1];
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'test subject: ' + testOpportunity.Invoice_Number__c;
        email.plainTextBody = 'Rejected';

        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'test@test.com';

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result = IM.handleInboundEmail(email, envelope);
        System.debug(result);
        System.assertEquals(true, result.success);
        System.assertEquals(null, result.message);
        System.assertEquals('Closed Lost', testOpportunity.StageName);
    }


    @isTest static void testHandleInboundEmailError() {
        try {
            InvoiceEmail IM = new InvoiceEmail();
            Test.startTest();
			Opportunity testOpportunity = [SELECT Id, StageName, Invoice_Number__c FROM Opportunity limit 1];

            Messaging.InboundEmail email = new Messaging.InboundEmail();
            email.subject = 'test subject: ' + testOpportunity.Invoice_Number__c;
            email.plainTextBody = 'Approved';

            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            envelope.fromAddress = 'test@test.com';

            delete [Select Id from Opportunity];
            Messaging.InboundEmailResult result = IM.handleInboundEmail(email, envelope);
            system.assert(false, 'Should have thrown an exception');
        }catch(DmlException e){
            system.assert(true, 'DmlException is caught');
        }
        test.stopTest();
        
    }
    
    @isTest
    public static void testGetAlldata() {
        test.startTest();
        String oppId = [select Id from Opportunity limit 1].Id;
        String contId = [select ContactId from Opportunity where Id=:oppId limit 1].ContactId;
        Map<String,Object> result = InvoiceEmail.getAllData(oppId);
        Contact cont = [select Name, Email from Contact where Id=:contId];
        System.assertEquals(cont.Name, result.get('name'));
        System.assertEquals(cont.Email, result.get('email'));
        test.stopTest();
    }
    
	@isTest static void testSendEmail() {
        test.startTest();
        String oppId = [select Id from Opportunity limit 1].Id;
        String subject = 'test subject';
        String body = 'test body';
        Map<String,Object> result = InvoiceEmail.sendEmail(oppId, subject, body);
        System.assertEquals(1, Limits.getEmailInvocations());
        System.assertEquals(true, result.get('success'));
        test.stopTest();
    }
    
    @isTest static void testSendEmailError() {
        test.startTest();
        String oppId = [select Id from Opportunity limit 1].Id;
        String subject = 'test subject';
        String body = 'test body';
        delete [select Id from Opportunity];
        try {
            Map<String,Object> result = InvoiceEmail.sendEmail(oppId, subject, body);
            system.assert(false, 'Should have thrown an exception');
        }catch(AuraHandledException e){
            system.assert(true, 'AuraHandledException is caught');
        }
        test.stopTest();
    }
}