@IsTest
global with sharing class chartDataTestClass {
    @IsTest
    global static void getDataTestMethod() {
        Opportunity testOpp1 = new Opportunity(Name='test Opp1', CloseDate=Date.today(), StageName = 'Prospecting', Amount=100,AlreadyPaid__c=70);
        Opportunity testOpp2 = new Opportunity(Name='test Opp2', CloseDate=Date.today(), StageName = 'Prospecting',Amount=200,AlreadyPaid__c=50);
        insert testOpp1;
        insert testOpp2;

        chartDataClass cls = new chartDataClass();
        List<lwcc.ChartDataProvider.ChartData> data = cls.getData();
        System.assertNotEquals(data,null);
        Decimal paid = (Decimal)data[0].detail[0];
        Decimal leftToPay = (Decimal)data[0].detail[1];
        System.assertEquals(paid,120);
        System.assertEquals(leftToPay,180);

    }

    @IsTest
    global static void initTestMethod() {
        try {
            chartDataClass cls = new chartDataClass();
            cls.init(1);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, e.getMessage());
        }

    }
}