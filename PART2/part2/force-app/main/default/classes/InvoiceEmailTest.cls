@IsTest
public with sharing class InvoiceEmailTest {
    @isTest static void testGetNext() {


        Opportunity opp = new Opportunity(Name='Test', StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        String nextStage = InvoiceEmail.get_next(opp.StageName);
        System.assertEquals('Qualification', nextStage);

        opp.StageName = 'Closed Won';
        update opp;
        nextStage = InvoiceEmail.get_next(opp.StageName);
        System.assertEquals('Closed Won', nextStage);
    }


    @isTest
    static void testGetEmailTemplate() {
        
        EmailTemplate testTemplate = new EmailTemplate();
        testTemplate.isActive = true;
        testTemplate.Name = 'Test Template';
        testTemplate.DeveloperName = 'Test_Template';
        testTemplate.TemplateType = 'text';
        testTemplate.FolderId = UserInfo.getUserId();
        testTemplate.Subject = 'Test Subject';
        testTemplate.Body = 'Test Body';
        insert testTemplate;
        EmailTemplate result = InvoiceEmail.get_email_template(testTemplate.Id);
        System.assertEquals(testTemplate.Id, result.Id);
    }
    
    @isTest static void testGetOppContact() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact testContact = new Contact(AccountId = testAccount.Id, LastName = 'Test Contact');
        insert testContact;
        Opportunity testOpportunity = new Opportunity(AccountId = testAccount.Id,
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert testOpportunity;
        OpportunityContactRole testOCR = new OpportunityContactRole(OpportunityId = testOpportunity.Id,
            ContactId = testContact.Id
        );
        insert testOCR;
        OpportunityContactRole result = InvoiceEmail.getOppContact(testOpportunity.Id);
        System.assertEquals(testOCR.Id, result.Id);
    }

    @isTest static void testGetInvoiceIdSuccess() {
        ContentVersion testContent = new ContentVersion(
            Title = 'Test Invoice',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Text')
        );
        insert testContent;
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContent.Id].ContentDocumentId;

        Id result = InvoiceEmail.get_Invoice_id(testContent.Title);
        System.assertEquals(contentDocumentId, result);
    }


    @isTest static void testGetInvoiceIdError() {
        ContentVersion testContent = new ContentVersion(
            Title = 'Test Invoice',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Text')
        );
        insert testContent;
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContent.Id].ContentDocumentId;


        try{
            Id result = InvoiceEmail.get_Invoice_id('');
            system.assert(false, 'Should have thrown an exception');
        }catch(AuraHandledException e){
            system.assert(true, 'AuraHandledException caught');
        }
    }


    @isTest static void testHandleInboundEmailApproved() {
        InvoiceEmail IM = new InvoiceEmail();
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert testOpportunity;
        testOpportunity = [Select Invoice_Number__c from Opportunity where Id=:testOpportunity.Id];
        ContentVersion testCV = new ContentVersion(
            Title=testOpportunity.Invoice_Number__c, 
            VersionData = Blob.valueOf('Test Text'),
            PathOnClient=testOpportunity.Invoice_Number__c+'.pdf'
        );
        insert testCV;
        ContentDocumentLink testCDL = new ContentDocumentLink(
        LinkedEntityId = testOpportunity.Id,
        ContentDocumentId = [SELECT contentdocumentid FROM ContentVersion WHERE Id=:testCV.Id].ContentDocumentId
        );
        insert testCDL;


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

        testOpportunity = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpportunity.Id];
        System.assertEquals('Qualification', testOpportunity.StageName);
    }

    @isTest static void testHandleInboundEmailRejected() {
        InvoiceEmail IM = new InvoiceEmail();
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert testOpportunity;

        testOpportunity = [Select Invoice_Number__c from Opportunity where Id=:testOpportunity.Id];
        ContentVersion testCV = new ContentVersion(
            Title=testOpportunity.Invoice_Number__c, 
            VersionData = Blob.valueOf('Test Text'),
            PathOnClient=testOpportunity.Invoice_Number__c+'.pdf'
        );
        insert testCV;
        ContentDocumentLink testCDL = new ContentDocumentLink(
        LinkedEntityId = testOpportunity.Id,
        ContentDocumentId = [SELECT contentdocumentid FROM ContentVersion WHERE Id=:testCV.Id].ContentDocumentId
        );
        insert testCDL;


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

        testOpportunity = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpportunity.Id];
        System.assertEquals('Closed Lost', testOpportunity.StageName);
    }


    @isTest static void testHandleInboundEmailError() {
        try {
            InvoiceEmail IM = new InvoiceEmail();
            Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today()
            );
            insert testOpportunity;
            testOpportunity = [Select Invoice_Number__c from Opportunity where Id=:testOpportunity.Id];
            ContentVersion testCV = new ContentVersion(
                Title=testOpportunity.Invoice_Number__c, 
                VersionData = Blob.valueOf('Test Text'),
                PathOnClient=testOpportunity.Invoice_Number__c+'.pdf'
            );
            insert testCV;
            ContentDocumentLink testCDL = new ContentDocumentLink(
            LinkedEntityId = testOpportunity.Id,
            ContentDocumentId = [SELECT contentdocumentid FROM ContentVersion WHERE Id=:testCV.Id].ContentDocumentId
            );
            insert testCDL;


            Messaging.InboundEmail email = new Messaging.InboundEmail();
            email.subject = 'test subject: ' + testOpportunity.Invoice_Number__c;
            email.plainTextBody = 'Approved';

            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            envelope.fromAddress = 'test@test.com';

            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            delete testOpportunity;
            result = IM.handleInboundEmail(email, envelope);
            system.assert(false, 'Should have thrown an exception');
        }catch(DmlException e){
            system.assert(true, 'DmlException is caught');
        }
        
    }

    @isTest static void testSendEmail() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact testContact = new Contact(AccountId = testAccount.Id, LastName = 'Test Contact', Email = 'test@test.com');
        insert testContact;
        Opportunity testOpportunity = new Opportunity(AccountId = testAccount.Id, Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
        insert testOpportunity;
        testOpportunity = [Select Invoice_Number__c from Opportunity where Id=:testOpportunity.Id];
        ContentVersion testContent = new ContentVersion(
            Title = testOpportunity.Invoice_Number__c,
            PathOnClient = testOpportunity.Invoice_Number__c + '.pdf',
            VersionData = Blob.valueOf('Test Content')
        );
        insert testContent;
        Map<String,Object> result = InvoiceEmail.sendEmail(testOpportunity.Id, testContact.Id);
        System.assertEquals(1, Limits.getEmailInvocations());
        System.assertEquals(true, result.get('success'));
    }

    @isTest static void testSendEmailError() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact testContact = new Contact(AccountId = testAccount.Id, LastName = 'Test Contact', Email = 'test@test.com');
        insert testContact;
        Opportunity testOpportunity = new Opportunity(AccountId = testAccount.Id, Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
        insert testOpportunity;
        testOpportunity = [Select Invoice_Number__c from Opportunity where Id=:testOpportunity.Id];
        String oppId = testOpportunity.Id;
        String contId = testContact.Id;
        delete testOpportunity;
        delete testContact;
        delete testAccount;
        try {
            Map<String,Object> result = InvoiceEmail.sendEmail(oppId, contId);
            system.assert(false, 'Should have thrown an exception');
        }catch(AuraHandledException e){
            system.assert(true, 'AuraHandledException is caught');
        }
        
    }
}