public with sharing class OpportunityStats {
    @AuraEnabled(cacheable=true)
    public static List<Map<String,Object>> getAllAccounts(Integer page, String search, String accountId){
        Integer offsetNumber = 10*page;
        String query = 'Select Id, Name, (select Id, Name, CreatedDate, CloseDate, Amount from opportunities where isClosed=true) from Account where ';
        if (accountId != '') {
            query = query + 'Id = \'' + accountId + '\'';
        }
        else {
            query = query + 'Name like \'%' + search + '%\'';
        }
        query = query + ' Limit 10 OFFSET ' +  offsetNumber;
        List<Account> lst = (List<Account>)Database.query(query); 
        List<Map<String, Object>> result = new List<Map<String, Object>>{};
            for (Account acc: lst) {
                Map<String, Object> accResult = new Map<String, Object>();    
                accResult.put('Id', acc.Id);
                accResult.put('Name', acc.Name);
                List<Map<String,Object>> oppList = new List<Map<String, Object>>{};
                    Decimal total = 0;
                for(Opportunity opp: acc.Opportunities) {
                    Map<String, Object> oppResult = new Map<String, Object>();   
                    oppResult.put('Id', opp.Id);
                    oppResult.put('Name', opp.Name);
                    oppResult.put('CreatedDate', opp.CreatedDate);
                    oppResult.put('CloseDate', opp.CloseDate);
                    oppResult.put('Amount', opp.Amount);
                    total += opp.Amount;
                    oppList.add(oppResult);
                }
                accResult.put('Opportunities', oppList);
                accResult.put('AccountAmount', acc.Name + ': $' + total);
                accResult.put('Total', total);
                result.add(accResult);
            }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOppProds(String oppId){
        return [select Id,Product2.Name, Quantity, ListPrice, Opportunity.Name from OpportunityLineItem where OpportunityId =:oppId];
    }
}