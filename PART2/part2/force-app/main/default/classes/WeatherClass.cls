public with sharing class WeatherClass {
    public static String BASE_URL = 'http://api.openweathermap.org/data/2.5/';
    public static String METRIC_UNIT = '&units=metric';

    public static String create_city_url(String cityName) {
        if (Test.isRunningTest()) {
        }
        String apikey = get_API_KEY(UserInfo.getUserId());
        return BASE_URL + '/weather?q=' + cityName + '&appid=' + apikey + METRIC_UNIT;
    }

    public static String get_API_KEY(String userId) {
        try {
            User_City__mdt uc = User_city__mdt.getInstance('city_' + userId);
            return uc.API_KEY__c;
        } catch (Exception e) {
            return '';
        }
            
    }

    public static HttpResponse callout(String url) {
        if (Test.isRunningTest()) {
            url = 'http://example.com/example/test';
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        
        Http http = new Http();
        return http.send(req);
    }

    @AuraEnabled
    public static Map<String, Object> find_city(String cityName) {
        cityName = cityName.replaceAll(' ', '%20');
        String url = WeatherClass.create_city_url(cityName);
        HttpResponse res = WeatherClass.callout(url);


        Map<String, Object> result = new Map<String, Object>{};
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        if (res.getStatusCode()==200) {
            
            result.put('status', true);
            result.put('main', (Map<String, Object>) responseBody.get('main'));
            result.put('wind', (Map<String, Object>) responseBody.get('wind'));
            result.put('clouds', (Map<String, Object>) responseBody.get('clouds'));
            List<Object> tmp = (List<Object>)responseBody.get('weather');
            result.put('icon', (String) ((Map<String,Object>)tmp[0]).get('icon'));
        }
        else {
            result.put('status', false);
            result.put('message', (String) responseBody.get('message'));
        }
        return result;
    }

    

    @AuraEnabled
    public static Map<String, Object> get_default_city() {
        Map<String, Object> result = new Map<String, Object>{};
        try {
            User_city__mdt user_city = User_city__mdt.getInstance('city_' + UserInfo.getUserId());
            String cityName = '';
            if (user_city != null) {
                cityName = user_city.City_name__c;
            }
            else {
                cityName = WeatherClass.create_metadata_record();
            }
            result.put('status', true);
            result.put('cityName', cityName);
        } catch (Exception e) {
            result.put('status', false);
            result.put('message', e.getMessage());
        }
        return result;
    }

    public static String create_metadata_record() {
        String cityName = '';
        String API_KEY = '938db07d3de81c1737630c210a3a605e';
        cityName =  [select City from User where Id=:UserInfo.getUserId() limit 1].City;
        
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'User_city.city_' + UserInfo.getUserId();
        customMetadata.label = 'city_' + UserInfo.getUserId();


        Metadata.CustomMetadataValue api_field = new Metadata.CustomMetadataValue();
        api_field.field = 'API_KEY__c';
        api_field.value = API_KEY;
        customMetadata.values.add(api_field);
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        if (!Test.isRunningTest()) {
            Id deployRequestId = Metadata.Operations.enqueueDeployment(mdContainer, null);
        }
        return cityName;
    }

    @AuraEnabled
    public static Boolean has_permission(String permName){

        String userId = UserInfo.getUserId();
        String permId = [select Id from PermissionSet where Name=:permName limit 1].Id;
        return ([select Id from PermissionSetAssignment where PermissionSetId=:permId and AssigneeId=:userId].size()>0);
    }
}