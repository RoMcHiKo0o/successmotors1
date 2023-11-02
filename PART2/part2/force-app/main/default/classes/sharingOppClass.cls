public without sharing class sharingOppClass {
    @AuraEnabled
    public static List<Opportunity> getOpps(){
        // AggregateResult[] countList = [select OpportunityId, count(UserOrGroupId)cnt from OpportunityShare Group by OpportunityId ];
        // List<String> ids = new List<String>();
        // for(AggregateResult agg: countList) {
        //     ids.add((String)agg.get('OpportunityId'));
        //     // if ((Integer)agg.get('cnt') > 1) {
        //     //     String oppId = (String)agg.get('OpportunityId');
        //     //     ids.add(oppId);
        //     // }
        // }

        // // return [Select Id, Name, Amount, CloseDate, CreatedDate from Opportunity where Id in :ids and is_Processed__c=false];
        return [Select Id, Name, Amount, CloseDate, CreatedDate from Opportunity where is_Processed__c=false];
    }

    @AuraEnabled
    public static List<User> getUsers(){
        return [select Id, Name from User where Id != :UserInfo.getUserId()];
    }

    // @AuraEnabled
    // public static List<Double> getChartData(){
    //     List<Double> data = new List<Double>();
    //     AggregateResult res = [select sum(Amount)amount, sum(AlreadyPaid__c)paid from Opportunity][0];
    //     data.add((Double)res.get('paid'));
    //     data.add((Double)res.get('amount')-(Double)res.get('paid'));
        
    //     return data;
    // }

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
    public static Map<String, Object> cascadeDelete(List<String> Ids){
        Map<String, Object> result = new Map<String, Object>{};

        List<String> accountIds = new List<String>();
        List<String> contactIds = new List<String>();
        for(Black_list__c acc: [select Record_id__c from Black_list__c where Record_type__c='Account']) {
            accountIds.add(acc.Record_id__c);
        }

        for(Black_list__c cont: [select Record_id__c from Black_list__c where Record_type__c='Contact']) {
            contactIds.add(cont.Record_id__c);
        }

        List<String> deletedIds = new List<String>();
        List<String> deletedNames = new List<String>();
        for(Opportunity opp: [select Id, Name from Opportunity where id in :Ids and AccountId not in :accountIds and ContactId not in :contactIds]) {
            deletedIds.add(opp.Id);
            // deletedNames.add(opp.Name);
        }
        
        try {
            delete [select Id from Opportunity where Id in :deletedIds];
            result.put('deletedIds', deletedIds);
            result.put('success', true);
            // result.put('deletedNames', deletedNames);
        }
        catch(Exception e) {
            result.put('success', false);
            result.put('errors', e.getMessage());
        }
        // result.put('deletedNames', deletedNames);
        
        return result;
        
    }
}