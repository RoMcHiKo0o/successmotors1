@IsTest
public class HBBatchClassTest {
	@isTest
    public static void test() {
        Test.startTest();
        Account testAccount = new Account(Name = 'testName');
        insert testAccount;
        Contact testContact = new Contact(LastName = 'testLastName',
                                          AccountId = testAccount.Id,
                                          Email = 'test_mail@gmail.com',
                                          Birthdate=Date.today());
        insert testContact;
        
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');

       	String jobId = Database.executeBatch(new HBBatchClass(), 200);
        Test.stopTest();
        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
    }
    
    
    @isTest
    public static void negative_test() {
        Test.startTest();
        Account testAccount = new Account(Name = 'testName');
        insert testAccount;
        Contact testContact = new Contact(LastName = 'testLastName',
                                          AccountId = testAccount.Id,
                                          Email = '',
                                          Birthdate=Date.today());
        insert testContact;
       	String jobId = Database.executeBatch(new HBBatchClass(), 200);
		Test.stopTest();      
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');
    }
}