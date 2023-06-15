public with sharing class ClearRecordStorageBatch implements Database.Batchable<sObject>, Database.Stateful {
    public List<String> objectAPiName;
    public Integer NumberOfRecords = 0 ;
    public  Integer count = 0;
     public Set<Id> dataId = new Set<Id>();


        public Integer objIndex = 0 ;
        public ClearRecordStorageBatch(List<String> SobjectName,Integer valIndex)
        {
            objectAPiName = SobjectName ;
            objIndex = valIndex ;
            System.debug('objectAPiName--->' +objectAPiName);
            System.debug('objIndex---> '+objIndex);

        }
    
        public Database.QueryLocator start(Database.BatchableContext BC) {
            System.debug('inside start--->');
            String objRecords = 'SELECT Id FROM '+ objectAPiName[objIndex]+  ' ORDER BY CreatedDate DESC' ;
            System.debug('objRecords '+objRecords);
            return Database.getQueryLocator(objRecords);
    
        }
        public void execute(Database.BatchableContext bc, List<sObject> obj) {//Database.BatchableContext is an interface which return batch  id
        System.debug('inside execute obj'+obj);
        NumberOfRecords+=obj.size();
        try{
            List<Database.DeleteResult> deleteSObjectRecords = Database.delete(obj);
            System.debug('deleteSObjectRecords '+deleteSObjectRecords);
           for(Database.DeleteResult dataResult : deleteSObjectRecords)
           {
            if(dataResult.isSuccess())
            {
              System.debug('Number of Account deleted'+dataResult.getId());
              dataId.add(dataResult.getId());
            }
           }
           System.debug('id Size'+dataId.size());
            AsyncApexJob query =  [ SELECT  Id,Status, NumberOfErrors,JobItemsProcessed,TotalJobItems,ApexClass.Name FROM AsyncApexJob WHERE Id = :bc.getJobId() ] ;

            System.debug('query'+query);

            BatchEvent__e event = new BatchEvent__e();
            event.Id__c = query.Id ;
            event.TotalJobItems__c = query.TotalJobItems;//total number of records
            event.JobItemsProcessed__c = query.JobItemsProcessed;//total number of records successfull
            event.Status__c = query.Status;
            event.objectAPiName__c = objectAPiName[objIndex];
           
            EventBus.publish(event) ;
            System.debug('event'+event);
        }

        
        catch(Exception f)
        {
             
            System.debug('exception' + f.getMessage());
        }
    
       
        
        }
        public void finish(Database.BatchableContext bc) {
            // Start the second batch job
           
           try {
            
            System.debug('inside finish method');
            AsyncApexJob queryInfo =  [ SELECT  Id,Status, NumberOfErrors,JobItemsProcessed,TotalJobItems,ApexClass.Name FROM AsyncApexJob WHERE Id = :bc.getJobId() ] ;
            System.debug('queryInfo'+queryInfo);
            count+=dataId.size();
            BatchEvent__e event = new BatchEvent__e();
            event.Id__c = queryInfo.Id ;
            event.TotalJobItems__c = queryInfo.TotalJobItems;
            event.JobItemsProcessed__c = queryInfo.JobItemsProcessed;
            event.NumberOfRecordFailed__c = queryInfo.NumberOfErrors ;
            event.objectAPiName__c = objectAPiName[objIndex];
            event.Status__c = queryInfo.Status ;
            EventBus.publish(event) ;
            System.debug('event------>'+event);

              // Start the second batch job
            if(objIndex <  objectAPiName.size() - 1){

                System.debug('inside if of finish method');
                ClearRecordStorageBatch b2 = new ClearRecordStorageBatch(objectAPiName,++objIndex);
                // if(!Test.isRunningTest()){
                Id jobId  =  Database.executeBatch(b2);
               // }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            String[] toAddresses = new String[] {'amthur.rafia@raagvitech.com'}; 
            
            mail.setToAddresses(toAddresses);
            mail.setSubject('Match Merge Batch');
            mail.setPlainTextBody('Batch Apex Processed with '+NumberOfRecords+' Number of total Records  with '+count+' Success '+objectApiName );
            String objectNames = '';
            for (String objectApiName : objectAPiName) {
                objectNames += objectApiName + '\n';
            }
            mail.setPlainTextBody(mail.getPlainTextBody() + '\n\nObject API names:\n' + objectNames);
            mail.setReplyTo('amthur.rafia@raagvitech.com');
            mail.setSenderDisplayName('Salesforce Support');
            mail.setSubject('Batch Apex mail' );
            mail.setBccSender(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('mail-------->'+mail);

  
        
        }

           } catch (Exception f) {
            System.debug('Exception f'+f.getMessage());
           }
               
           
        }
    }