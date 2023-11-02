global without sharing class chartDataClass extends lwcc.ChartDataProvider {
    public override void init(final Object initParameter) {

    }

    public override List<lwcc.ChartDataProvider.ChartData> getData() {
        List<lwcc.ChartDataProvider.ChartData> chartData = new List<lwcc.ChartDataProvider.ChartData>();
        lwcc.ChartDataProvider.ChartData payData = new lwcc.ChartDataProvider.ChartData();


        AggregateResult result = [select sum(Amount)amount, sum(AlreadyPaid__c)paid from Opportunity][0];
        Decimal paid = (Decimal)result.get('paid');
        Decimal total = (Decimal)result.get('amount');
        Decimal leftToPay = total - paid;
        Decimal paidPercent = (paid/total*100).setScale(2);
        Decimal leftToPayPercent = (leftToPay/total*100).setScale(2);
       
        List<String> labels = new List<String>();
        labels.add('Paid: ' + paidPercent + '%');
        labels.add('Left to Pay: ' +  leftToPayPercent + '%');
        payData.labels = labels;

        List<Decimal> detail = new List<Decimal>();
        detail.add(paid);
        detail.add(leftToPay);
        payData.detail = detail;

        chartData.add(payData);
        return chartData;
    }
}