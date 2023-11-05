trigger ContactDeleteTrigger on Contact (after delete) {
    List<String> toDeleteList = new List<String>();
    for(Contact cont: Trigger.old) {
        toDeleteList.add(cont.Id);
    }

    delete [select Id from Black_list__c where Record_id__c in :toDeleteList and Record_type__c='Contact'];
}