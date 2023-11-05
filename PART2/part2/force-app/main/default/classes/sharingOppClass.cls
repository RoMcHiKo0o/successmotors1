public with sharing class sharingOppClass {
    @AuraEnabled
    public static List<Opportunity> getOpps(){
        return [Select Id, Name, Amount, CloseDate, CreatedDate from Opportunity where is_Processed__c=false];
    }

    @AuraEnabled
    public static List<User> getUsers(){
        return [select Id, Name from User where Id != :UserInfo.getUserId()];
    }

    @AuraEnabled
    public static Map<String, Object> shareOpps(List<String> ids, String userId){
        List<OpportunityShare> oppShareList = new List<OpportunityShare>();
        for(String id: ids) {
            OpportunityShare oppShare = new OpportunityShare(OpportunityId=id,
            UserOrGroupId=userId,
            OpportunityAccessLevel='Edit',
            RowCause='Manual');
            oppShareList.add(oppShare);
        }
        Database.SaveResult[] insertResult = Database.insert(oppShareList, false);
        List<Database.Error> errors = new List<Database.Error>();
        for (Database.SaveResult saveRes: insertResult){
            if (!saveRes.isSuccess()){
                errors.add(saveRes.getErrors().get(0));
            }
        }

        Map<String, Object> result = new Map<String, Object>{};
        result.put('success', errors.size()==0);
        result.put('errors', errors);
        return result;
    }

    @AuraEnabled
    public static void opportunityDelete(List<String> Ids){

        List<String> accountIds = new List<String>();
        List<String> contactIds = new List<String>();
        for(Black_list__c acc: [select Record_id__c from Black_list__c where Record_type__c='Account']) {
            accountIds.add(acc.Record_id__c);
        }

        for(Black_list__c cont: [select Record_id__c from Black_list__c where Record_type__c='Contact']) {
            contactIds.add(cont.Record_id__c);
        }

        List<String> contactsToDelete = new List<String>();
        for(Opportunity opp: [select ContactId from Opportunity where Id in :Ids and ContactId not in :contactIds]) {
            contactsToDelete.add(opp.ContactId);
        }

        List<String> accountsToDelete = new List<String>();
        for(Opportunity opp: [select AccountId from Opportunity where Id in :Ids and AccountId not in :accountIds]) {
            accountsToDelete.add(opp.AccountId);
        }

        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact cont: [select Id from Contact where AccountId in :accountsToDelete]) {
            cont.AccountId = null;
            contactsToUpdate.add(cont);
        }

        delete [select Id from Opportunity where Id in :Ids];
        update contactsToUpdate;
        delete [select Id from Contact where Id in :contactsToDelete];
        delete [select Id from Account where Id in :accountsToDelete];

    }
}