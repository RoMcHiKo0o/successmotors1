@isTest
public class HBScheduleClassTest {
	@istest
    public static void test() {
        Test.startTest();
        
        String jobId = System.schedule('testSchedule', '0 0 0 1 1 ? 2042', new HBScheduleClass());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals('0 0 0 1 1 ? 2042', ct.CronExpression);
        
        System.assertEquals(0, ct.TimesTriggered);
        
        System.assertEquals('2042-01-01 00:00:00', 
                            String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
   }
}