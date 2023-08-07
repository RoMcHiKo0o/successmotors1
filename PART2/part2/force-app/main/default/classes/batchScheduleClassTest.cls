@isTest
public class batchScheduleClassTest {
	@isTest
    public static void executeBatchTest() {
        Test.startTest();
        String jobId = batchScheduleClass.executeBatch('HBBatchClass');
        System.assert([select Id from AsyncApexJob where Id=:jobId].size()>0);
        Test.stopTest();
    }
    
    // @isTest
    // public static void checkBatchTest() {
    //     Test.startTest();
    //     String jobId = batchScheduleClass.executeBatch('HBBatchClass');
    //     System.assertNotEquals('Failed', batchScheduleClass.checkJob(jobId));
    //     System.assertEquals('Failed', batchScheduleClass.checkJob(null));
    //     Test.stopTest();
    // }
    
    
    @isTest
    public static void scheduleBatchTest() {
        Test.startTest();
        String jobId = batchScheduleClass.scheduleBatch('test Job', '0 0 0 1 1 ? 2042', 'HBScheduleClass');
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger WHERE Id = :jobId];

        System.assertEquals('0 0 0 1 1 ? 2042', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2042-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        
        jobId = batchScheduleClass.scheduleBatch('test Job', '0 0 0 1 1 ? 2042', 'wrong class name');
        System.assertEquals('', jobId);
        
        Test.stopTest();
    }
    
    
    @isTest
    public static void abortBatchTest() {
        Test.startTest();
        String jobId = batchScheduleClass.scheduleBatch('test Job', '0 0 0 1 1 ? 2042', 'HBScheduleClass');
        //System.assertEquals(1, [select Id from AsyncApexJob where Id =:jobId].size());
        //batchScheduleClass.abortBatch(jobId);
        System.assertEquals(0, [select Id from AsyncApexJob where Id =:jobId].size());
        batchScheduleClass.abortBatch('wrongId');
        
        Test.stopTest();
    }
}