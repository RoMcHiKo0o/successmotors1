trigger AccountDeleteTrigger on Account (after delete) {
    List<String> toDeleteList = new List<String>();
    for(Account acc: Trigger.old) {
        toDeleteList.add(acc.Id);
    }

    delete [select Id from Black_list__c where Record_id__c in :toDeleteList and Record_type__c='Account'];

}