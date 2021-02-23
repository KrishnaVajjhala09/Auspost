/**
 * ClosedCaseCalloutBatch
 * Created by Krishna Vajjhala on 23/02/2021
 * Batch class for callout to nfapihub for 
 * generating secretkeys on closed cases
 */
global class ClosedCaseCalloutBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts{
    List<Case> caseKeyUpdate = new List<Case>();    
    List<String> emails = new List<String>{'krishnavajjhala09@gmail.com'};

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, secretKey__c, Status, CreatedBy.Email From Case where secretKey__c = NULL and IsClosed=true');
    }
     
    global void execute(Database.BatchableContext bc, List<Case> cases){

        for(Case caserec: cases)
        {
            try{
                Case updateCase= new Case();
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();           
                request.setHeader('Content-Type', 'application/json');
                request.setEndpoint('https://nfapihub.herokuapp.com/');
                request.setMethod('POST');
                request.setBody('{"id":"case.Id","agentid":"Case.CreatedBy.Id"}');
                request.setTimeout(120000);
                response = http.send(request);
                if (response.getStatusCode() == 200) {
                    String jsonResponse = response.getBody();
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    String key= (String)results.get('secretKey');
                    String status=(String)results.get('success');
                    updateCase.secretKey__c = key;
                    updateCase.Id=caserec.Id;
                    emails.add(caserec.CreatedBy.Email);
                    if(status=='true')
                    {
                        caseKeyUpdate.add(updateCase);
                    }else{
                        updateCase.Status ='In Progress'; //Set the status to something other than closed to be picked up by the next batch
                        caseKeyUpdate.add(updateCase);
                    }
                }else{ //Error status code
                    updateCase.Id=caserec.Id; 
                    updateCase.Status ='In Progress'; //Set the status to something other than closed to be picked up by the next batch
                    caseKeyUpdate.add(updateCase);                  
                }
            }
            catch(Exception e){
                System.debug('Error-' + e.getMessage());   
            }           
        }
        if(caseKeyUpdate.size()>0)
        {
            update caseKeyUpdate;
        }
    }
    global void finish(Database.BatchableContext bc){
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	AsyncApexJob a = [Select ApexClassId, JobType, TotalJobItems, JobItemsProcessed,  NumberofErrors, Status, CompletedDate from AsyncApexJob where Id =: bc.getJobId()];
        mail.setToAddresses(emails);
        mail.setReplyTo('admin@ausposttest.com');
        mail.setSenderDisplayName('Case Callout Batch Results');
        mail.setSubject('Batch Processing '+a.Status);
        mail.setPlainTextBody('Records processed:  '+a.TotalJobItems + 'Number of Errors: '+a.NumberofErrors + ' at '+a.CompletedDate);
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    global void execute (SchedulableContext sc){
        ClosedCaseCalloutBatch batch = new ClosedCaseCalloutBatch();
        Database.executeBatch(batch);
    }    
}