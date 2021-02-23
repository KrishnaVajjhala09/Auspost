/**
 * ClosedCaseCalloutTest
 * Created by Krishna Vajjhala on 23/02/2021
 * Test class for CloseCaseCalloutTest
 */
@isTest
public class ClosedCaseCalloutTest {
    //Test data set up with 10 Cases each for success and failure
    @testSetup static void setup() {
        List<case> casesToInsert = new List<Case>();
        for(integer i=0;i<10;i++){
            Case caseRecord = new Case(Subject = 'Test Success', Status = 'Closed');
            casesToInsert.add(caseRecord);
        }
        for(integer i=0;i<10;i++){
            Case caseRecord = new Case(Subject = 'Test Failures', Status = 'Closed');
            casesToInsert.add(caseRecord);
        }
        insert casesToInsert;    
    }    

   @isTest static void testSuccess(){
        List<case> cases= [select Id from Case where Subject ='Test Success'];
       	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ClosedCaseCalloutMock.MockHttpSuccessResponseGenerator()); 
        SchedulableContext sc = null;
		closedCaseCalloutBatch batch = new ClosedCaseCalloutBatch();
		batch.execute(sc);
       	Test.stopTest();
       	//Assert cases set to Closed with Key
       	List<Case> casesWithKey= [select Id from Case where Status ='Closed' and secretKey__c!= NULL];
       	System.assertEquals(10, casesWithKey.size(),'Success');       
    }
   @isTest static void testFailures(){ 
        List<case> cases= [select Id from Case where Subject ='Test Failure'];
       	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ClosedCaseCalloutMock.MockHttpFailureResponseGenerator()); 
        SchedulableContext sc = null;
		closedCaseCalloutBatch batch = new ClosedCaseCalloutBatch();
		batch.execute(sc);
       	Test.stopTest();
       	//Assert cases set to In progress
       	List<Case> casesReverted= [select Id from Case where Status ='In Progress'];
       	System.assertEquals(10, casesReverted.size(),'Success');
    }    
}