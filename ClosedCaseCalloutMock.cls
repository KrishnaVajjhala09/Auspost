/**
 * ClosedCaseCalloutMock
 * Created by Krishna Vajjhala on 23/02/2021
 * Mock class for test Class ClosedCaseCalloutTest
 */
public class ClosedCaseCalloutMock{
    //Method is to mock the success response, which generates the Key and success flag as true
    public class MockHttpSuccessResponseGenerator implements HttpCallOutMock {
        public HTTPResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success":"true","secretKey":"454345yfdzfbws"}');
            response.setStatusCode(200);
            return response;
        }
            
    }
    //Method is to mock the failure response, which generates the error message if any and success flag as false
    public class MockHttpFailureResponseGenerator implements HttpCallOutMock {
        public HTTPResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success":"false","error":"error message"}');
            response.setStatusCode(500);
            return response;
        } 
            
    }    
}

