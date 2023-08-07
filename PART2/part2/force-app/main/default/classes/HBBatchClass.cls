public with sharing class HBBatchClass implements Database.Batchable<SObject> {
    public final String emailTemplateName = 'Happy_Birthday_Email_Template';
    public Database.QueryLocator start(Database.BatchableContext BC){

        Date todate = Date.today();
        String query = 'select Name, Email from Contact where DAY_IN_MONTH(Birthdate) = ' + todate.day() +  ' AND CALENDAR_MONTH(Birthdate) = ' + todate.month();
        return Database.getQueryLocator(query);
    }
  
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        EmailTemplate HBTemplate = [select Subject, Body from EmailTemplate where DeveloperName=:emailTemplateName limit 1];

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        System.debug(scope);
        System.debug(HBTemplate);
        for (Sobject cont: scope) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(HBTemplate.Id);
            mail.setTargetObjectId(cont.Id);
            emailList.add(mail);
        }
        System.debug(emailList);


        try {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList, false);
            System.debug(results);
            
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

    }
  
    public void finish(Database.BatchableContext BC){
        batch_finish_event__e event = new batch_finish_event__e(
            Status__c = [select Status from AsyncApexJob where Id =:BC.getJobId()].Status,
            JobId__c = BC.getJobId()
        );
        Database.SaveResult result = EventBus.publish(event);
    }
}