public with sharing class BlackListClass {
    @AuraEnabled
    public static Map<String,Object> getBlackList() {
        Map<String,Object> result = new Map<String,Object>{};
        List<String> accountIds = new List<String>();
        List<String> contactIds = new List<String>();
        for(Black_list__c acc: [select Record_id__c from Black_list__c where Record_type__c='Account']) {
            accountIds.add(acc.Record_id__c);
        }

        for(Black_list__c cont: [select Record_id__c from Black_list__c where Record_type__c='Contact']) {
            contactIds.add(cont.Record_id__c);
        }
        result.put('accounts',[select Id, Name from Account where Id in: accountIds]);

        result.put('contacts',[select Id, Name from Contact where Id in: contactIds]);

        return result;
    }
    @AuraEnabled
    public static Map<String, Object> deleteFromBlackList(List<String> Ids){
        Map<String, Object> result = new Map<String, Object>{};
        try {
            delete [select Id from Black_list__c where Record_id__c in :Ids];        
            result.put('success', true);
        }
        catch(Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        return result;
        
    }


    @AuraEnabled
    public static Map<String, Object> insertIntoBlackList(List<String> Ids){
        Map<String, Object> result = new Map<String, Object>{};
        try {
            List<Account> newAccs = new List<Account>();
            newAccs = [select Id,Name from Account where Id in: Ids];
            List<Contact> newContacts = new List<Contact>();
            newContacts = [select Id, Name from Contact where Id in: Ids];
            List<Black_list__c> insertList = new List<Black_list__c>();
            for(Account a: newAccs) {
                insertList.add(new Black_list__c(Record_id__c=a.Id, Record_type__c='Account'));
            }
            for(Contact c: newContacts) {
                insertList.add(new Black_list__c(Record_id__c=c.Id, Record_type__c='Contact'));
            }
            Database.SaveResult[] insertResult = Database.insert(insertList, false);    
            List<Database.Error> errors = new List<Database.Error>();
            for (Database.SaveResult saveRes: insertResult){
                if (!saveRes.isSuccess()){
                    errors.add(saveRes.getErrors().get(0));
                }
            }

            result.put('success', errors.size()==0);
            result.put('errors', errors);
        }
        catch(Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        return result;
        
    }
    // @AuraEnabled
    // public static Map<String, Object> insertIntoBlackList(List<String> Ids){
    //     delete [select Id from Black_list__c where Record_id__c in :Ids];        
    // }

    @AuraEnabled
    public static Map<String,Object> getAllAccountsAndContacts() {
        Map<String,Object> result = new Map<String,Object>{};
        result.put('accounts', [select Id, Name from Account order by Name]);

        result.put('contacts', [select Id, Name from Contact order by Name]);

        return result;
    }
}