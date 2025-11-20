/**
 * @description       : Class helper untuk mencari Feature ID berdasarkan data Case dan Transaksi.
 * Versi ini telah di-refactor untuk tidak lagi melakukan query SOQL secara langsung,
 * melainkan menerima data dari Map yang sudah di-query sebelumnya (bulkified).
 * @author            : Suherbing
 * @last modified on  : 20-07-2025
**/
public with sharing class SCC_MasterMappingFeature {
    
    /**
     * @description Wrapper class untuk mengembalikan hasil pencarian feature.
     */
    public class MappingMasterWrapper {
        public String FeatureId{get;set;} 
        public Boolean matchedConditionAmount{get; set;}
        public String provider{get;set;}
        
        public MappingMasterWrapper(String FeatureId, Boolean matchedConditionAmount,String provider) {
            this.FeatureId = FeatureId;
            this.matchedConditionAmount = matchedConditionAmount;
            this.provider = provider;
        }
    }

    // public class MappingMasterWrapperPulsa{

    //     public String FeatureId{get;set;} 
    //     public Boolean matchedConditionAmount{get; set;}
    //     public String provider{get;set;}
        
    //     public MappingMasterWrapperPulsa(String FeatureId, Boolean matchedConditionAmount,String provider) {
    //         this.FeatureId = FeatureId;
    //         this.matchedConditionAmount = matchedConditionAmount;
    //         this.provider = provider;
    //     }

    // }
    
    /**
     * @description Method ini mencari Feature ID berdasarkan data Case dan Transaksi dari Map yang sudah disediakan.
     * @param cS Case yang sedang diproses.
     * @param data Data transaksi dari API.
     * @param mapFeatures Map yang berisi semua Master Mapping Feature, di-query sebelumnya secara bulk.
     * @return MappingMasterWrapper berisi FeatureId dan status kecocokan nominal, atau null jika tidak ditemukan.
     */

    public static MappingMasterWrapper getFeature(Case cS,  SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data, Map<String, List<Master_Mapping_Feature__c>> mapFeatures) {
        
        // --- Ekstrak nilai dari parameter untuk kemudahan pembacaan ---
        String caseType = cS.SCC_Call_Type__r.external_id__c;
        Decimal csNominal = cS.SCC_Amount__c;
        String remark = data.trremk;
        String remark2 = data.tlbds2;
        // Konversi API value string ke Decimal
        Decimal rkNominal = data.mutasiDebet;

        // **KUNCI OPTIMISASI**: Ambil daftar mapping dari Map, bukan dari query baru.
        List<Master_Mapping_Feature__c> allMappingsForCaseType = mapFeatures.get(caseType);

        // Jika tidak ada mapping sama sekali untuk case type ini, hentikan proses lebih awal.
        if (allMappingsForCaseType == null || allMappingsForCaseType.isEmpty()) {
            return null;
        }


        // --- Pass 1: Cari semua mapping yang cocok berdasarkan Remark__c ---
        List<Master_Mapping_Feature__c> matchedMappings = new List<Master_Mapping_Feature__c>();
        for (Master_Mapping_Feature__c mapping : allMappingsForCaseType) {

            if(String.isNotBlank(caseType)&& caseType == '8434' && remark.toUpperCase().contains('PUL-SIM')){
                System.debug('mapping remark' + mapping.Remark__c);
                System.debug('remark' + remark);
                if(mapping.Remark__c != null && remark != null){

                        String[] mappingParts = mapping.Remark__c.trim().split('\\s+');

                        if(mappingParts.size() == 2){

                             String mappingPulSim = mappingParts[0].toUpperCase();
                             String mappingBankCode = mappingParts[1].toUpperCase();

                             
                             System.debug('mapping bank code' + mappingBankCode);
                             System.debug('mapping pul sim' + mappingPulSim);


                            Pattern p = Pattern.compile('(?i)(PUL-SIM).*?(MP|NBNB|WBNK)');
                            Matcher m = p.matcher(remark);

                            if(m.find()){
                                System.debug('match remark telkomesl');
                                String remarkPulSim = m.group(1).toUpperCase();
                                String remarkBankCode = m.group(2).toUpperCase();

                                if (remarkPulSim == mappingPulSim && remarkBankCode == mappingBankCode) {
                                    matchedMappings.add(mapping);
                                }
                            }
                        }
                    }
            }else {
                if (mapping.Remark__c != null && remark != null && remark.toUpperCase().contains(mapping.Remark__c.toUpperCase())) {
                    matchedMappings.add(mapping);
                }
            }

        }

        // --- Evaluasi hasil pencarian ---
        Boolean amountMatch = (csNominal == rkNominal);
        
        // Jika hanya satu record ditemukan, itu adalah hasil yang paling mungkin.


        if (matchedMappings.size() == 1) {

            if(String.isNotBlank(caseType)&& caseType == '8434'){
                return new MappingMasterWrapper(
                    matchedMappings[0].Feature__r.Fitur_ID__c,
                    amountMatch,
                    matchedMappings[0].Provider__c
                );
            }else{
                return new MappingMasterWrapper(matchedMappings[0].Feature__r.Fitur_ID__c, amountMatch , '');
            }
        }

        // Jika ditemukan lebih dari satu, persempit pencarian dengan Remark_2__c
        else if (matchedMappings.size() > 1 && remark2 != null) {
            for (Master_Mapping_Feature__c mapping : matchedMappings) {
                if (mapping.Remark_2__c != null && 
                    remark2.toUpperCase().contains(mapping.Remark_2__c.toUpperCase())) {
                    // Ditemukan kecocokan yang lebih spesifik, kembalikan nilainya.
                    return new MappingMasterWrapper(mapping.Feature__r.Fitur_ID__c, amountMatch,'');
                }
            }
        }
        
        // Jika tidak ada yang cocok setelah semua pengecekan, kembalikan null.
        return null;
    }
}