public with sharing class HBScheduleClass implements Schedulable {
    // public Database.Batchable<SObject> batchClass;
    // public HBScheduleClass(Database.Batchable<SObject> bc) {
    //     this.batchClass = bc;
    // }
    public void execute(SchedulableContext sc)
    {
        // database.executebatch(this.batchClass, 200);
        database.executebatch(new HBBatchClass(), 200);
    }
}