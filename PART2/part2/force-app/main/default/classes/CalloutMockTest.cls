@isTest
global class CalloutMockTest implements HttpCalloutMock {
    // Implement this interface method
    global String url;
    global Integer statuscode;
    global CalloutMockTest(String URL, Integer code) {
        this.url = URL;
        this.statuscode = code;
    }
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals(this.url, req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        String body;
        if (this.statuscode == 200) {
        	body = '{\"coord\":{\"lon\":23.8258,\"lat\":53.6884},\"weather\":[{\"id\":800,\"main\":\"Clear\",\"description\":\"clear sky\",\"icon\":\"01d\"}],\"base\":\"stations\",\"main\":{\"temp\":22.92,\"feels_like\":23.17,\"temp_min\":22.92,\"temp_max\":22.92,\"pressure\":1021,\"humidity\":73},\"visibility\":10000,\"wind\":{\"speed\":2,\"deg\":160},\"clouds\":{\"all\":0},\"dt\":1692167692,\"sys\":{\"type\":1,\"id\":8936,\"country\":\"BY\",\"sunrise\":1692155076,\"sunset\":1692208429},\"timezone\":10800,\"id\":627904,\"name\":\"Hrodna\",\"cod\":200}';    
        }
        else {
            body = '{\"message\":\"error\"}';
        }
        
        res.setBody(body);
        res.setStatusCode(this.statuscode);
        return res;
    }
}