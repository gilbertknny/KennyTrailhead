global without sharing class VisualForceQueryParamsController {
    public String ani {get; private set;}
    public String dnis {get; private set;} 
    public String uui {get; private set;} 
    public String ucid {get; private set;} 
    public String queue {get; private set;} 
    public VisualForceQueryParamsController() { 
        ani =  ApexPages.currentPage().getParameters().get('ANI'); 
        dnis =  ApexPages.currentPage().getParameters().get('DNIS'); 
        uui =  ApexPages.currentPage().getParameters().get('UUI'); 
        ucid =  ApexPages.currentPage().getParameters().get('UCID'); 
        queue =  ApexPages.currentPage().getParameters().get('Queue'); 
    }

    public PageReference redirect(){
        String phn = ani;
        PageReference pr;
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest();
        req.phoneNumber = phn;
        List<SCC_HomePageSearch.CustomerProfile> lcp = SCC_HomePageSearch.getCustomerProfile(req);
        Id idacc = null;
        if(String.isnotblank(lcp[0]?.acc?.Id)){
            pr = new PageReference('/'+lcp[0]?.acc?.Id);
        
        }else{
            lcp = SCC_HomePageSearch.getCardLink('', phn, '', '');
            if(String.isnotblank(lcp[0]?.acc?.Id)){
                pr = new PageReference('/'+lcp[0]?.acc?.Id);
            }
            else{
                pr = new PageReference('/lightning/page/home?0.source=alohaHeader');
            }
        }
        pr.setRedirect(true);
        return pr;
    }
}