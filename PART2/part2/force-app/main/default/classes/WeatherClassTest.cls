@isTest
public class WeatherClassTest {
	@isTest
    public static void create_url_test(){
        String cityName = 'TestCity';
        // How to test private variable?!
        String api_key = '938db07d3de81c1737630c210a3a605e';
        String base_url = WeatherClass.BASE_URL;
        String metric = WeatherClass.METRIC_UNIT;
        System.assertEquals(base_url + '/weather?q=' + cityName + '&appid=' + api_key + metric, WeatherClass.create_city_url('TestCity'));
    }
    
    @isTest
    public static void callout_test() {
        String url = 'http://example.com/example/test';
        Test.setMock(HttpCalloutMock.class, new CalloutMockTest(url, 200));
        HttpResponse res = WeatherClass.callout(url);
        System.assertEquals(200, res.getStatusCode());
        System.assertNotEquals(null, res.getBody());
    }
    
    @isTest
    public static void find_city_test() {
        String url = 'http://example.com/example/test';
        Test.setMock(HttpCalloutMock.class, new CalloutMockTest(url, 200));
        String cityName = 'TestCity';
        Map<String, Object> result = WeatherClass.find_city(cityName);
        try{
            System.assertNotEquals(null, result.get('main'));
            System.assertNotEquals(null, result.get('icon'));
            System.assertNotEquals(null, result.get('clouds'));
            System.assertNotEquals(false, result.get('status'));
        }
        catch (Exception e){
            System.assert(false);
        }
        
    }
    @isTest
    public static void find_city_test_401() {
        String url = 'http://example.com/example/test';
        Test.setMock(HttpCalloutMock.class, new CalloutMockTest(url, 401));
        String cityName = 'TestCity';
        Map<String, Object> result = WeatherClass.find_city(cityName);
        try{
            System.assertNotEquals(null, result.get('message'));
            System.assertNotEquals(true, result.get('status'));
        }
        catch (Exception e){
            System.assert(false);
        }
        
    }
    @isTest
    public static void create_metadata_record_test() {
        try {
            String cityName = WeatherClass.create_metadata_record();
            String real_city_name = [select City from User where Id=:UserInfo.getUserId() limit 1].City;
        	System.assertEquals(cityName, real_city_name);
        }
        catch (System.AsyncException e) {
            System.Assert(true);
        }
        catch (Exception e) {
            System.Assert(false);
        }
        
    }
    
    @isTest
    public static void create_metadata_record_test_null_city_name() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User test_user = new User(
            Alias = 'standt',
            UserName=uniqueUserName,
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8', LastName='Testing',
            TimeZoneSidKey='America/Los_Angeles',
            Email='standarduser@testorg.com',
            LanguageLocaleKey='en_US',
            ProfileId = p.Id
        );
        insert test_user;

        System.runAs(test_user) {
            try {
                String cityName = WeatherClass.create_metadata_record();
                System.assertEquals(cityName, null);
            }
            catch (System.AsyncException e) {
                System.Assert(true);
            }
            catch (Exception e) {
                System.Assert(false);
            }
        }
    }
    
    @isTest
    public static void get_defauly_city_test() {
        Map<String, Object> result = WeatherClass.get_default_city();
        System.assertEquals(true, result.get('status'));
    }
    
    @isTest
    public static void get_defauly_city_test_null_city() {
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User test_user = new User(
            Alias = 'standt',
            UserName=uniqueUserName,
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8', LastName='Testing',
            TimeZoneSidKey='America/Los_Angeles',
            Email='standarduser@testorg.com',
            LanguageLocaleKey='en_US',
            ProfileId = p.Id
        );
        insert test_user;
        
        System.runAs(test_user) {
            Map<String, Object> result = WeatherClass.get_default_city();
        	System.assertEquals(true, result.get('status'));
        }
        
    }
}