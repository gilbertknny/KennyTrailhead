/**
 *  @description APILog2
 */
public without sharing class APILog2 {
    /**
     * @description signWithCertificate
     * @param ehl Endpoint_Header_List__mdt
     * @param stringToSign String
     * @return signWithCertificate
     */
    public static Blob signWithCertificate(Endpoint_Header_List__mdt ehl,String stringToSign){
        Blob signedKey = Crypto.signWithCertificate(ehl.Algorithms__c, Blob.valueOf(stringToSign), ehl.CertificateName__c);
        return signedKey;
    }
    /**
     * @description stringtoSignMac
     * @param eapi Endpoint__mdt
     * @param ehl Endpoint_Header_List__mdt
     * @param wr WrapperRequest
     * @return stringtoSignMac
     */
    public static String stringtoSignMac(Endpoint__mdt eapi, Endpoint_Header_List__mdt ehl,APILog.WrapperRequest wr){
        Blob targetBlob;
        if(wr.bodyblob!=null){
            targetBlob = wr.bodyblob;
        }
        else{
            String jsonbd = JSON.serialize(JSON.deserializeUntyped(wr.bodyreq),true);
            wr.bodyreq = jsonbd;
            targetBlob = Blob.valueOf(jsonbd);
        }
        Blob hash = Crypto.generateDigest(ehl.Algorithms2__c, targetBlob);
        String hex = EncodingUtil.convertToHex(hash).toLowerCase();
        String stringToSign = eapi.Method__c+':'+eapi.Directory__c+':'+wr.token+':'+hex+':'+wr.timestamp;
        return stringToSign;
    }
    /**
     * @description generateMac
     * @param ehl Endpoint_Header_List__mdt
     * @param stringToSign String
     * @return generateMac
     */
    public static Blob generateMac(Endpoint_Header_List__mdt ehl,String stringToSign){
        Blob data = crypto.generateMac(ehl.Algorithms__c,Blob.valueOf(stringToSign),Blob.valueOf(ehl.Client_Secret__c));
        return data;
    }
    /**
     * @description generatefile
     * @param file Blob
     * @return generatefile
     */
    public static String generatefile(Blob file){
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'body.txt'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'body JSON'; // Display name of the files
        conVer.VersionData = file; // converting your binary string to Blog
        conVer.SyncFile__c = true;
        if(!Schema.sObjectType.ContentVersion.isCreateable()){
            return null;
        }
        insert conVer;
        ContentVersion cv = [SELECT Id,ContentDocumentId,FileExtension, FileType FROM ContentVersion WHERE Id =:conVer.Id];
        return cv.ContentDocumentId;
    }
}