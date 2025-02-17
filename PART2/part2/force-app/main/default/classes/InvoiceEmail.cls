global class InvoiceEmail implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String regex = 'INV-\\d{6}';
        String str = email.subject;
        Matcher matcher = Pattern.compile(regex).matcher(str);
		Boolean flag = matcher.find();
        if (flag) {
            String invoice = matcher.group(0);
            try {
            	Opportunity opp = [Select Id, StageName from Opportunity where Invoice_Number__c =: invoice Limit 1];    
                
                str = email.plainTextBody.split('\\n')[0];
                Boolean approved = str.contains('Approved');
                Boolean rejected = str.contains('Rejected');
                if (approved) {
                    String newStage = InvoiceEmail.get_next(opp.StageName);
                    opp.StageName = newStage;
                    update opp;
                }
                else if (rejected) {
                    opp.StageName = 'Closed Lost';
                    update opp;
                }
            }
            catch(Exception e) {
                throw new DmlException(e.getMessage());
            }
        }
        else {
        }
        return result;
    }
    
    public static String get_next(String stage) {
        if (stage.contains('Closed')) {
            return stage;
        }
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Integer i;
        for(i=0; i<ple.size(); i++){
            if (ple[i].getLabel() == stage) {
                break;
            }
        } 
        return ple[i+1].getLabel();
    }
    

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getAllData(String oppId){

        OpportunityContactRole cont = [Select Contact.Name, Contact.Email from OpportunityContactRole where OpportunityId=:oppId limit 1];

        EmailTemplate template = [select Subject, HtmlValue from EmailTemplate where DeveloperName=:'Invoice_Email_Template'];
        List<Messaging.RenderEmailTemplateBodyResult> email = Messaging.renderEmailTemplate(cont.ContactId, oppId, new List<String>{template.Subject, template.HtmlValue});
        Map<String,Object> response = new Map<String, Object>();
        String body = email[1].getMergedBody().replace(']]>', '');
        response.put('subject', email[0].getMergedBody());
        response.put('body', body);
        response.put('name', cont.Contact.Name);
        response.put('email', cont.Contact.Email);
        return response;
    }


    @AuraEnabled(cacheable=true)
    public static Id get_Invoice_id(String oppId){
        try {
            String invoice = [select Invoice_Number__c from Opportunity where Id=:oppId limit 1].Invoice_Number__c;
            return [select id from ContentDocument where Title =: invoice limit 1].Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled(cacheable=true)
    public static Map<String,Object> sendEmail(String oppId, String subject, String body){
        try {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            EmailTemplate emailTemplate = [select Subject, HtmlValue from EmailTemplate where DeveloperName=:'Invoice_Email_Template'];
            Id contactId = [Select ContactId from OpportunityContactRole where OpportunityId=:oppId limit 1].ContactId;
            String EmailServiceName = 'Email Invoice Handle';
            Id EmailServiceId = [SELECT Id, FunctionName FROM EmailServicesFunction where FunctionName =: EmailServiceName limit 1].Id;
            EmailServicesAddress  esa = [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId =:EmailServiceId];
            message.setReplyTo(esa.LocalPart + '@' + esa.EmailDomainName);
            message.setSubject(subject);
            message.setHtmlBody(body);
            message.setTargetObjectId(contactId);
            message.setWhatId(oppId);
            String inv_number = [select Invoice_Number__c from Opportunity where Id =:oppId limit 1].Invoice_Number__c;
            
            Blob pdfblob = [SELECT VersionData FROM ContentVersion WHERE IsLatest = TRUE and Title=:inv_number LIMIT 1].VersionData;
            
            
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('invoice.pdf');
            efa.setContentType('application/pdf');
            efa.setBody(pdfblob);
            message.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            
            
            
            Messaging.SendEmailResult[] result = Messaging.sendEmail(new List<Messaging.Email>{message});
            Map<String,Object> res = new Map<String, Object>();
            res.put('success', result[0].isSuccess());
            res.put('error', result[0].getErrors());
            return res;
            
        } catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // @AuraEnabled(cacheable=true)
    // static public EmailTemplate get_email_template(String templateId) {
    //     return [select Id, Subject, Body, HtmlValue from EmailTemplate where Id=:templateId limit 1];
    // }
    
    // @AuraEnabled(cacheable=true)
    // static public OpportunityContactRole getOppContact(String oppId) {
    //     return [Select Contact.Name, Contact.Email from OpportunityContactRole where OpportunityId=:oppId limit 1];
    // }

}