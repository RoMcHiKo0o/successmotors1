@isTest
public with sharing class newTaskClassTest {
    @isTest
    public static void createnewtaskTest() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        List<Contact> contactList = new List<Contact>();

        for(Integer i=0;i<3;i++) {
            Contact testContact = new Contact(LastName = 'Test Contact: ' + i, AccountId=testAccount.Id);
            insert testContact;
            contactList.add(testContact);
        }
        List<Task> taskList = newTaskClass.createtask([select Id, OwnerId, AccountId from Contact]);

        System.assertEquals(3, taskList.size());

        for (Task t : taskList) {
            System.assertEquals('High', t.Priority);
            System.assertEquals('Not Started', t.Status);
            System.assertEquals('Call', t.Subject);
            System.assertNotEquals(null, t.ReminderDateTime);
            System.assertNotEquals(null, t.WhatId);
        }
        
    }
}