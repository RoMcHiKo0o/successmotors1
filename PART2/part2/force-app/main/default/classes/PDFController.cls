public class PDFController {

    public Organization org { get; set; }
    public String todayDate { get; set; }
    public Address address { get; set; }
    public String addressString { get; set; }
    public Id oppId {get; set;}
    public Contact oppContact {get; set;}
    public List<OpportunityLineItem> oppProds {get; set;}
    public Object balance_due {get; set;}
    
    ApexPages.StandardController ctrl;
   
   
    public Opportunity opp {
        get {return [SELECT id ,name,owner.Name,ownerid, Invoice_Number__c from opportunity where Id=:oppId];} set;
    } 

   
    public PDFController(ApexPages.StandardController ctrl) {
       this.ctrl = ctrl;       
       oppId = ctrl.getId();
    }
    
    public PDFController() {
        oppId = ApexPages.currentPage().getParameters().get('id');
        //oppId = '006Do0000048ec1IAA';
        org = [select Name, Country,City,Address from Organization where Id=: userInfo.getOrganizationId()];
        address = org.Address;
        addressString = (address.getCountry()==null ? '' : address.getCountry()) +
            (address.getCity()==null ? '' : address.getCity());
        todayDate = Date.today().day() + ' ' + Date.today().month() + ' ' + Date.today().year();
        todayDate = DateTime.now().format('dd/MM/yyyy');
      	Id contId = [Select ContactId from OpportunityContactRole where OpportunityId=:oppId and IsPrimary=true].ContactId;
        oppContact = [select Name,Phone,Email from Contact where Id=:contId];
        oppProds = [select
                    Id,
                    ListPrice,
                    TotalPrice,
                    Quantity,
                    Product2.Name
                    from OpportunityLineItem
                    where OpportunityId=:oppId
                   ];
        AggregateResult[] groupedResults = [select
                                            sum(TotalPrice)total
                                            from OpportunityLineItem
                                            where OpportunityId=:oppId
                                           ];
        balance_due = '$ ' + groupedResults[0].get('total');
        
   }
    
    public PageReference generatepdf() {
        PageReference page = Page.PDFPage;
        
        page.getParameters().put('id', oppId);
        Blob pdfBlob;
        if (Test.isRunningTest()) {
            pdfBlob = BLOB.valueOf('test content');
        }
        else {
        	pdfBlob = page.getContent();    
        }
        
        
        List<ContentVersion> cvs = [SELECT Id,contentdocumentid FROM ContentVersion WHERE Title = :opp.Invoice_Number__c];
        if (cvs.size()==0) {
            ContentVersion cv1 = new ContentVersion(
                Title=opp.Invoice_Number__c, 
                VersionData = pdfBlob,
                PathOnClient=opp.Invoice_Number__c+'.pdf'
            );
            insert cv1;
            ContentDocumentLink cl = new ContentDocumentLink(
            LinkedEntityId = oppId,
            ContentDocumentId = [SELECT contentdocumentid FROM ContentVersion WHERE Id=:cv1.Id].ContentDocumentId
            );
            insert cl;
        }
        else {
            ContentVersion cv1 = new ContentVersion(
                Title=opp.Invoice_Number__c, 
                VersionData = pdfBlob,
                PathOnClient=opp.Invoice_Number__c+'.pdf',
                ContentDocumentId=cvs[0].ContentDocumentId
            );
            insert cv1;
        }
        
        return page;
    }
    
}