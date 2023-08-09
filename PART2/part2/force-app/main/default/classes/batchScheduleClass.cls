public with sharing class batchScheduleClass {
    @AuraEnabled
    public static Map<String,String> executeBatch(String batchClassName) {
        Map<String, String> result = new Map<String, String>{};
        try {
            Type classType = Type.forName(batchClassName);

            Id jobId = Database.executeBatch((Database.Batchable<SObject>)classType.newINstance(), 200);
            result.put('jobId', jobId);
            result.put('error', ''); 
        }
        catch(Exception e) {
            System.debug(e);
            result.put('jobId', '');
            result.put('error', e.getMessage());
        }
        return result;        
    }

    @AuraEnabled
    public static Map<String,Object> checkScheduledJob(String jobName){
        Map<String,Object> result = new Map<String,Object>{};
        try {
            String CronJobDetailId = [select Id from CronJobDetail where Name =: jobName].Id;
            String jobId = [select Id from CronTrigger where CronJobDetailId =: CronJobDetailId].Id;
            result.put('jobId', jobId);
            result.put('error', '');
            
        } catch (Exception e) {
            result.put('jobId', '');
            result.put('error', e.getMessage());

        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,String> scheduleBatch(String jobName, String cronString, String scheduleClassName) {
        Map<String, String> result = new Map<String, String>{};
        try {
            Type scheduleClassType = Type.forName(scheduleClassName);

            String jobId = System.schedule(jobName, cronString, (Schedulable)scheduleClassType.newInstance());
            result.put('jobId', jobId);
            result.put('error', '');
            return result;
        }

        catch(Exception e) {
            System.debug(e);
            result.put('jobId', '');
            result.put('error', e.getMessage());
            return result;
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