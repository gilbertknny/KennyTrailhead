/** @description ApexDefinedFlow  flow field wrapper for clause */
public without sharing class ApexDefinedFlow {
    @AuraEnabled  @InvocableVariable
    public String partitionCode;

    @AuraEnabled  @InvocableVariable
    public String busreqid; //busreq_id

    @AuraEnabled  @InvocableVariable
    public Id opportunityid;

    @AuraEnabled  @InvocableVariable
    public String policynum;

    @AuraEnabled  @InvocableVariable
    public Id insurancepolicyid;

    @AuraEnabled  @InvocableVariable
    public String clausedesccl; //clause_desc_cl

    @AuraEnabled  @InvocableVariable
    public String clausename; //clause_name

    @AuraEnabled  @InvocableVariable
    public Boolean ischanged; //is_changed

    @AuraEnabled  @InvocableVariable
    public Boolean isadditional; //is_additional

    @AuraEnabled  @InvocableVariable
    public String clausaid; //clausaid

    @AuraEnabled  @InvocableVariable
    public Id mdclausaid;

    @AuraEnabled  @InvocableVariable
    public String uniqueid;

    public ApexDefinedFlow(){
        
    }
}