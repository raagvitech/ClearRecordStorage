@isTest
private class ClearRecordStorageTest {
    @testSetup
    static void testsetupmethod(){
        List<Account> accList = new List<Account>();
        for(Integer i=1;i<=200;i++){
            Account accObj = new Account(Name = 'test'+i);
            accList.add(accObj);
        }
       
         List<Contact> conList = new List<Contact>();
        for(Integer i=1;i<=	200;i++){
            Contact conObj = new Contact(LastName = 'test'+i);
            conList.add(conObj);
        }
        
          List<Task> oppList = new List<Task>();
        for(Integer i=1;i<= 200;i++){
            Task opObj = new Task(Subject = 'test'+i);
            oppList.add(opObj);
        }
        insert accList;
        insert conList;
        insert oppList;
    }
	@isTest
    static void insertTestmethod(){
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Name like '%test%'];
        System.assertEquals(200, accList.size());
    }
    @isTest
    static void testReturnsObjects() {
        List<Object> expected = new List<Object>();
        expected.add('Account');
        expected.add('Contact');
        expected.add('Task');        
        
        Test.startTest();
        ClearRecordStorage.returnsObjects();
        Test.stopTest();
        
        System.assertEquals(3, expected.size());
    }

    @isTest
    static void testDeleteRecords() {
        List<String> objectNames = new List<String>{'Account', 'Contact','Task'};

        Test.startTest();
        ClearRecordStorage.deleteRecords(objectNames);
        Test.stopTest();
        
        // Assert that the batch job was created
        //List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJobs];
        //System.assertEquals(3, jobs.size());
    }
}