public class newTaskClass {
    
    @InvocableMethod
    public static List<Task> createtask(List<Contact> contacts) {
        List<Task> tasks = new List<Task>();
        for (Contact cont: contacts) {
            Task task = new Task();
            task.OwnerId = cont.OwnerId;
            task.Priority = 'High';
            task.Status = 'Not Started';
            task.Subject = 'Call';
            Date offset = Date.today()+3;
            if (DateTime.now().hourGMT()>=7) {
                offset += 1;
            }
            task.ReminderDateTime = DateTime.newInstance(offset, Time.newInstance(10,0,0,0));
            task.WhatId = cont.AccountId;
            insert task;   
            tasks.add(task);
        }
        
        return tasks;
    }
}