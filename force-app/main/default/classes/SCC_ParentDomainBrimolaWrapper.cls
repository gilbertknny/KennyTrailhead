/**
 * Class: SCC_ParentDomainBrimolaWrapper
 * @description This wrapper class holds data retrieved from the Brimola API,
 *              including details about the pangkalan and agent, as well as a list
 *              of Brilink transactions.
 * Author: Abhinav Sharma
 * Created Date: 2024-05-30
 */

 public without sharing class SCC_ParentDomainBrimolaWrapper {
    /**
     * @description Name of the pangkalan
     */
    @AuraEnabled
    public String pangkalanName { get; set; }
    /**
     * @description Id of the pangkalan
     */
    @AuraEnabled
    public String pangkalanId { get; set; }

    /**
     * @description Corporate client BRIVA number
     */
    @AuraEnabled
    public String corpClientBriva { get; set; }

    /**
     * @description Corporate BRIVA number
     */
    @AuraEnabled 
    public String corpBriva { get; set; }

    /**
     * @description Agent's account number
     */
    @AuraEnabled
    public String agenNorek { get; set; }

    /**
     * @description Name of the agent
     */
    @AuraEnabled
    public String agenName { get; set; }

    /**
     * @description Agent's ID
     */
    @AuraEnabled
    public String agenId { get; set; }

    /**
     * @description Address of the agent
     */
    @AuraEnabled
    public String agenAlamat { get; set; }
    
    /**
     * @description Error Message
     */
    @AuraEnabled
    public String errorMessage { get; set; }

    /**
     * @description List of Brilink transactions
     */
    @AuraEnabled
    public List<SCC_DomainBrimolaWrapper.BrilinkTrx> data { get; set; }
}