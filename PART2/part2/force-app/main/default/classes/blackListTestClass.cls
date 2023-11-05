@IsTest
global with sharing class blackListTestClass {
    @TestSetup
    static void generateBlackList(){
        Account acc1 = new Account(Name='acc1');
        Account acc2 = new Account(Name='acc2');
        insert acc1;
        insert acc2;
        Contact cont1 = new Contact(LastName='cont1');
        insert cont1;


        Black_list__c blr1 = new Black_list__c(Record_id__c= acc1.Id, Record_type__c='Account');

        Black_list__c blr2 = new Black_list__c(Record_id__c= acc2.Id, Record_type__c='Account');
        Black_list__c blr3 = new Black_list__c(Record_id__c= cont1.Id, Record_type__c='Contact');
        insert blr1;
        insert blr2;
        insert blr3;
    }

    @IsTest
    global static void getBlackListTestMethod() {
        Map<String, Object> bl = BlackListClass.getBlackList();
        System.assertNotEquals(bl,null);
        System.assertEquals(2, ((List<Account>)bl.get('accounts')).size());
        System.assertEquals(1, ((List<Contact>)bl.get('contacts')).size());
        System.assertEquals('acc1', ((List<Account>)bl.get('accounts'))[0].Name);

        System.assertEquals('cont1', ((List<Contact>)bl.get('contacts'))[0].Name);

    }

    @IsTest
    global static void deleteFromBlackListTestMethod1() {
        Black_list__c toDelete = [select Id from Black_list__c limit 1];
        List<String> ids = new List<String>();
        ids.add(toDelete.Id);

        Map<String, Object> result = BlackListClass.deleteFromBlackList(ids);
        System.assert((Boolean)result.get('success'));

    }

    @IsTest
    global static void getAllAccountsAndContactsTestMethod() {
        Map<String,Object> data = BlackListClass.getAllAccountsAndContacts();
        System.assertNotEquals(null, data);
        System.assertEquals(2, ((List<Account>)data.get('accounts')).size());
        System.assertEquals(1, ((List<Contact>)data.get('contacts')).size());
        System.assertEquals('acc1', ((List<Account>)data.get('accounts'))[0].Name);

        System.assertEquals('cont1', ((List<Contact>)data.get('contacts'))[0].Name);
    }

    @IsTest
    global static void insertIntoBlackListTestMethod1() {
        Account acc3 = new Account(Name='acc3');
        Contact cont2 = new Contact(LastName='cont2');
        insert acc3;
        insert cont2;
        List<String> ids = new List<String>();
        ids.add(acc3.Id);
        ids.add(cont2.Id);
        Map<String, Object> data = BlackListClass.insertIntoBlackList(ids);
        System.assertNotEquals(null, data);
        System.assert((Boolean)data.get('success'));
        System.assertEquals(5, [select Id From Black_list__c].size());
    }

    @IsTest
    global static void insertIntoBlackListTestMethod2() {
        Account acc3 = new Account(Name='acc3');
        insert acc3;
        List<String> ids = new List<String>();
        ids.add(acc3.Id);
        Integer blackListLength = [select Id from Black_list__c].size();
        ids.add([select Record_id__c from Black_list__c limit 1].Record_id__c);
        Map<String, Object> data = BlackListClass.insertIntoBlackList(ids);
        System.assertNotEquals(null, data);
        System.assertNotEquals(true, (Boolean)data.get('success'));
        System.assertNotEquals(null, data.get('errors'));
        System.assertEquals(blackListLength+1, [select Id From Black_list__c].size());
    }
}