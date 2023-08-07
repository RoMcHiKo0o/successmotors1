public with sharing class batchScheduleClass {
    @AuraEnabled
    public static String executeBatch(String batchClassName) {
        Type classType = Type.forName(batchClassName);

		Id jobId = Database.executeBatch((Database.Batchable<SObject>)classType.newINstance(), 200);
        return jobId;
    }

    // @AuraEnabled(cacheable=true)
    // public static string checkJob(String job){
    //     System.debug(job);
    //     if (job != null) {
    //         AsyncApexJob AAjob = [select Status from AsyncApexJob where Id=:job limit 1];
    //         System.debug(AAjob);
    //         if (AAjob != null) {
    //             return AAjob.Status;
    //         }
         
    //     }
    //     return 'Failed';
        
    // }

    @AuraEnabled(cacheable=true)
    public static String scheduleBatch(String jobName, String cronString, String scheduleClassName) {
        try {
            Type scheduleClassType = Type.forName(scheduleClassName);

            String jobId = System.schedule(jobName, cronString, (Schedulable)scheduleClassType.newInstance());
            return jobId;
        }

        catch(Exception e) {
            System.debug('opaaa');
            System.debug(e);
            return '';
        }
        
    }

    @AuraEnabled
    public static void abortBatch(String job){
        try {
            System.AbortJob(job);    
        } catch (Exception e) {
            System.debug(e);
        }
    }

}