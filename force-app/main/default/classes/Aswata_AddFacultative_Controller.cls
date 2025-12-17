public with sharing class Aswata_AddFacultative_Controller {
    
    @AuraEnabled(cacheable=false)
    public static List<Asset> getRiskList() {
        return [
            SELECT Id,
                Name,
                Amount_Insured__c,
                Risk_ID__c,
                Opportunity__c,
                Opportunity__r.Name,
                Opportunity__r.Busreq_ID__c 
                FROM Asset WHERE RecordType.Name = 'Risk' 
                AND Has_Facultative__c = true 
                AND Facultative_Folder__c = null WITH SECURITY_ENFORCED  
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset> getRiskAssets(Id recordId) {
        return [
            SELECT Id,
                   Name,
                   Amount_Insured__c,
                   Risk_ID__c,
                   Opportunity__c,
                   Opportunity__r.Name,
                   Opportunity__r.Busreq_ID__c
            FROM Asset
            WHERE RecordType.Name = 'Risk'
              AND Has_Facultative__c = true
              //AND Opportunity__r.Opportunity_Type__c != 'Facultative Outward'
              AND Facultative_Folder__c = :recordId
            WITH SECURITY_ENFORCED
        ];
    }

    @AuraEnabled
    public static void updateSelectedRisks(List<Id> assetIds, Id folderId) {
        
        System.debug(assetIds.size() + ' - ' + folderId);
        if (assetIds == null || assetIds.isEmpty()) return;

        List<Asset> assetsToUpdate = [
            SELECT Id, Facultative_Folder__c
            FROM Asset
            WHERE Id IN :assetIds
            WITH SECURITY_ENFORCED
        ];

        for (Asset a : assetsToUpdate) {
            a.Facultative_Folder__c = folderId;
        }

        update assetsToUpdate;
    }

    
    /*
    

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDefaultRiskDetail(String recordId) {

        // === STEP 1: Get Treaty JSON from Quote ===
        Quote quoteRecord = [
            SELECT Id, Treaty_Distribution_Response__c, OpportunityId
            FROM Quote
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (String.isBlank(quoteRecord.Treaty_Distribution_Response__c)) {
            return new Map<String, Object>{ 'error' => 'No Treaty Distribution data found' };
        }

        // === STEP 2: Deserialize JSON ===
        List<Object> jsonList = 
            (List<Object>) JSON.deserializeUntyped(quoteRecord.Treaty_Distribution_Response__c);

        // === STEP 3: Build dynamic SOQL conditions ===
        List<String> conditions = new List<String>();
        for (Object o : jsonList) {
            Map<String, Object> data = (Map<String, Object>) o;
            String busreqId = (String) data.get('busreq_id');
            String riskNo   = (String) data.get('riskNo');
            if (!String.isBlank(busreqId) && !String.isBlank(riskNo)) {
                conditions.add(
                    '(Opportunity__r.Busreq_ID__c = \'' + 
                    String.escapeSingleQuotes(busreqId) +
                    '\' AND Risk_ID__c = \'' + 
                    String.escapeSingleQuotes(riskNo) + '\')'
                );
            }
        }

        if (conditions.isEmpty()) {
            return new Map<String, Object>{ 'error' => 'No valid Busreq/Risk pairs found.' };
        }

        // === STEP 4: Execute SOQL ===
        String finalQuery = 
            'SELECT Id, origin_risk__r.Name, origin_risk__r.Amount_Insured__c, origin_risk__r.Risk_ID__c , origin_risk__r.Description, origin_risk__r.Address_Description__c,' +
            ' origin_risk__r.Volcanic_Zone__c, origin_risk__r.Flood_Zone__c, origin_risk__r.Eq_Zone__c, origin_risk__r.Tsunami_Zone__c,' +
            ' origin_risk__r.Opportunity__c, origin_risk__r.Opportunity__r.Name, origin_risk__r.Opportunity__r.StageName,' +
            ' origin_risk__r.Opportunity__r.Start_Date_Periode__c, origin_risk__r.Opportunity__r.End_Date_Periode__c,' +
            ' origin_risk__r.Opportunity__r.Busreq_ID__c, origin_risk__r.Opportunity__r.The_Insured_Name__r.Name,' +
            ' opportunity_facultative__r.Facultative_Folder__r.Name, origin_risk__r.Opportunity__r.Name,' +
            ' origin_risk__r.Commission_All_Coverages__c, origin_risk__r.Rate_All_Coverages__c, ' +
            ' opportunity_facultative__r.Rate__c, opportunity_facultative__r.Commission__c, ' +
            ' opportunity_facultative__r.Share_Offered__c, opportunity_facultative__r.Share_Accepted_Approved__c, ' + 
            ' opportunity_facultative__r.Share_Binding__c, opportunity_facultative__r.Share_Pending_Binding__c, ' +
            ' opportunity_facultative__r.ShortFall__c, opportunity_facultative__r.Facultative_Folder__r.Folder_Status__c '+
            ' FROM Asset WHERE ' + String.join(conditions, ' OR ') +
            ' WITH SECURITY_ENFORCED';

        System.debug('finalQuery: ' + finalQuery);
        List<Asset> assets = Database.query(finalQuery);

        if (assets.isEmpty()) {
            return new Map<String, Object>{ 'error' => 'No Asset records found.' };
        }

        // === STEP 5: Build options for dropdown ===
        List<Map<String, String>> options = new List<Map<String, String>>();
        for (Asset ast : assets) {
            options.add(new Map<String, String>{
                'label' => ast.origin_risk__r.Opportunity__r.Busreq_ID__c + ' - ' + ast.origin_risk__r.Risk_ID__c,
                'value' => ast.Id
            });
            system.debug('StageName: ' + ast.origin_risk__r.Opportunity__r.StageName);
        }

        List<Map<String, Object>> sooList = new List<Map<String, Object>>();
        for (Asset a : assets) {
            sooList.add(new Map<String, Object>{
                'Id' => a.Id,
                // Use Facultative_SOO__r.Name (related record). Null-safe check:
                'Name' => (a.Facultative_SOO__r != null ? a.Facultative_SOO__r.Name : null),
                'BusreqId' => (a.Opportunity__r != null ? a.Opportunity__r.Busreq_ID__c : null),
                'Reinsurer' => null, // if you have a direct field on Asset or related, put it here
                'RiskId' => a.Risk_ID__c,
                'ShareOffered' => null, // if value exists on asset use a.<Field> else leave null
                'ShareAccepted' => null, // same as above
                'Status' => (a.Opportunity__r != null ? a.Opportunity__r.StageName : null),
                'TotalSumInsured' => a.Amount_Insured__c
            });
        }

        // === STEP 6: Take first asset as default ===
        Asset firstAsset = assets[0];

        System.debug('firstAsset: ' + firstAsset);
        // === Build Situation Info ===
        List<String> parts = new List<String>();
        if (String.isNotBlank(firstAsset.Address_Description__c)) {
            parts.add('Address: ' + firstAsset.Address_Description__c);
        }
        if (String.isNotBlank(firstAsset.Flood_Zone__c)) {
            parts.add('Flood Zone: ' + firstAsset.Flood_Zone__c);
        }
        if (String.isNotBlank(firstAsset.Eq_Zone__c)) {
            parts.add('EQ Zone: ' + firstAsset.Eq_Zone__c);
        }
        if (String.isNotBlank(firstAsset.Volcanic_Zone__c)) { 
            parts.add('Volcanic Zone: ' + firstAsset.Volcanic_Zone__c);
        }
        if (String.isNotBlank(firstAsset.Tsunami_Zone__c)) { 
            parts.add('Tsunami Zone: ' + firstAsset.Tsunami_Zone__c);
        }
        String situation = String.join(parts, ' | ');


        // Get value from JSON treaty
        String firstBusreqId = firstAsset.Opportunity__r != null ? firstAsset.Opportunity__r.Busreq_ID__c : null;
        String firstRiskNo   = firstAsset.Risk_ID__c;
        Decimal totalSumInsured = null;
        Decimal accumulationAWTShare = null;
        Decimal treatyAmount = null;
        Decimal exhaustedUtilizedAmount = null;
        Decimal remainingAmount = null;
        Decimal excessAmount = null;

        for (Object o : jsonList) {
            Map<String, Object> data = (Map<String, Object>) o;
            String busreqId = (String) data.get('busreq_id');
            String riskNo   = (String) data.get('riskNo');
            if (busreqId == firstBusreqId && riskNo == firstRiskNo) {
                if (data.containsKey('totalSumInsuredShare')) {
                    totalSumInsured = (Decimal) data.get('totalSumInsuredShare');
                }
                if (data.containsKey('accumulatedSumInsuredShare')) {
                    accumulationAWTShare = (Decimal) data.get('accumulatedSumInsuredShare');
                }
                if (data.containsKey('treaty')) {
                    treatyAmount = (Decimal) data.get('treaty');
                }
                if (data.containsKey('exhaustedUtilized')) {
                    exhaustedUtilizedAmount = (Decimal) data.get('exhaustedUtilized');
                }
                if (data.containsKey('remaining')) {
                    remainingAmount = (Decimal) data.get('remaining');
                }
                if (data.containsKey('excess')) {
                    excessAmount = (Decimal) data.get('excess');
                }
                break;
            }
        }

        System.debug('Matched totalSumInsured100 from JSON: ' + totalSumInsured);
        Decimal shareOfferedAmount;
        Decimal shareAcceptedAmount;
        Decimal shareBindingAmount;
        Decimal sharePendingAmount;
        Decimal shortFallAmount;

        // Safely retrieve related rate fields
        Decimal rateOffered = firstAsset.Facultative_Folder__r?.Share_Offered__c;
        Decimal rateAccepted = firstAsset.Facultative_Folder__r?.Share_Accepted__c;
        Decimal rateBinding   = firstAsset.Facultative_Folder__r?.Share_Binding__c;
        Decimal ratePending   = firstAsset.Facultative_Folder__r?.Share_Pending_Bending__c;
        Decimal rateShortfall = firstAsset.Facultative_Folder__r?.Short_Fall__c;

        // Calculate each safely
        shareOfferedAmount = (rateOffered != null && totalSumInsured != null && totalSumInsured > 0)
            ? (rateOffered * totalSumInsured) / 100
            : 0;

        shareAcceptedAmount = (rateAccepted != null && totalSumInsured != null && totalSumInsured > 0)
            ? (rateAccepted * totalSumInsured) / 100
            : 0;

        shareBindingAmount = (rateBinding != null && totalSumInsured != null && totalSumInsured > 0)
            ? (rateBinding * totalSumInsured) / 100
            : 0;

        sharePendingAmount = (ratePending != null && totalSumInsured != null && totalSumInsured > 0)
            ? (ratePending * totalSumInsured) / 100
            : 0;

        shortFallAmount = (rateShortfall != null && totalSumInsured != null && totalSumInsured > 0)
            ? (rateShortfall * totalSumInsured) / 100
            : 0;

        // === Get related QQ names ===
        List<Transaction_Data__c> qqList = [
            SELECT QQ_Name__r.Name
            FROM Transaction_Data__c
            WHERE Opportunity__c = :firstAsset.Opportunity__c
            AND RecordType.Name = 'Member of QQ'
            AND QQ_Name__r.Name != null
            WITH SECURITY_ENFORCED
        ];

        List<String> qqNames = new List<String>();
        for (Transaction_Data__c t : qqList) {
            qqNames.add(t.QQ_Name__r.Name);
        }
        String qqNameCombined = qqNames.isEmpty() ? null : String.join(qqNames, ', ');

        System.debug('qqNameCombined: ' + qqNameCombined + ' qqList: ' + qqList.size());
        // === STEP 7: Prepare result map ===
        Map<String, Object> result = new Map<String, Object>{
            'defaultAsset' => new Map<String, Object>{
                'Id' => firstAsset.Id,
                'Name' => firstAsset.Name,
                'FacFolderNo' => firstAsset.Facultative_Folder__r.Name,
                'FacultativeSOO' => firstAsset.Facultative_SOO__r.Name,
                'AmountInsured' => totalSumInsured,
                'AccumulationAswataShare' => accumulationAWTShare,
                'RiskId' => firstAsset.Risk_ID__c,
                'Description' => firstAsset.Description,
                'Situation' => situation,
                'OpportunityId' => firstAsset.Opportunity__c,
                'OpportunityName' => firstAsset.Opportunity__r?.Name,
                'OpportunityStage' => firstAsset.Opportunity__r?.StageName,
                'BusreqId' => firstAsset.Opportunity__r?.Busreq_ID__c,
                'InsuredName' => firstAsset.Opportunity__r?.The_Insured_Name__r?.Name,
                'StartDate' => firstAsset.Opportunity__r?.Start_Date_Periode__c,
                'EndDate' => firstAsset.Opportunity__r?.End_Date_Periode__c,
                'QQName' => qqNameCombined,
                'TreatyAmount' => treatyAmount,
                'ExhaustedAmount' => exhaustedUtilizedAmount,
                'RemainingAmount' => remainingAmount,
                'ExcessAmount' => excessAmount,
                'OriginalRate' => firstAsset.Rate_All_Coverages__c,
                'OriginalCommission' => firstAsset.Commission_All_Coverages__c,
                'FacultativeReinsurer' => '',
                'RateOffered' => firstAsset.Facultative_Folder__r.Rate_Offered__c,
                'CommissionOffered' => firstAsset.Facultative_Folder__r.Commission_Offered__c,
                'ShareOfferedPercent' => firstAsset.Facultative_Folder__r.Share_Offered__c,
                'ShareAcceptedPercent' => firstAsset.Facultative_Folder__r.Share_Accepted__c,
                'ShareBinding' => firstAsset.Facultative_Folder__r.Share_Binding__c,
                'SharePendingBinding' => firstAsset.Facultative_Folder__r.Share_Pending_Bending__c,
                'ShortFall' => firstAsset.Facultative_Folder__r.Short_Fall__c,
                'FolderStatus' => firstAsset.Facultative_Folder__r.Folder_Status__c,
                'Currency' => firstAsset.Facultative_Folder__r.Currency__c,
                'FacultativeStatus' => '',
                'ShareOfferedAmount' => shareOfferedAmount,
                'ShareAcceptedAmount' => shareAcceptedAmount,
                'ShareBindingAmount' => shareBindingAmount,
                'SharePendingAmount' => sharePendingAmount,
                'ShortFallAmount' => shortFallAmount,
                'FacultativeOpportunityNo' => firstAsset.Opportunity_Facultative__r?.Name
            },
            'options' => options
            //,'sooList' => sooList
        };

        System.debug('Result: '+ result);
        return result;
    }*/

    /*
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFolderAndRiskDetail(String recordId) {
        // === STEP 1: Get Quote Opportunity
        Quote quoteRecord = [
            SELECT Id, OpportunityId
            FROM Quote
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        // === STEP 2: Build folder Options dropdown ===
        List<Asset> folderList = [Select Id, Name, Risk_ID__c, Facultative_Folder__r.Name,
                                                Facultative_Folder__r.Folder_Status__c, Facultative_Folder__r.Id
                                                from Asset where RecordType.Name = 'Risk' and Opportunity__c =: quoteRecord.OpportunityId 
                                                and Opportunity__r.Opportunity_Type__c != 'Facultative Outward'
                                                //and Set_Facultative__c >= 1 cek jika risk ini memang sudah di set facultative
                                                WITH SECURITY_ENFORCED];

        List<Map<String, String>> folderoptions = new List<Map<String, String>>();
        Map<String, String> folderStatusMap = new Map<String, String>();
        Set<Id> uniqueFolderIds = new Set<Id>();
        for (Asset ast : folderList) {
            if (ast.Facultative_Folder__r != null && !uniqueFolderIds.contains(ast.Facultative_Folder__r.Id)) {
                uniqueFolderIds.add(ast.Facultative_Folder__r.Id);

                folderOptions.add(new Map<String, String>{
                    'label' => ast.Facultative_Folder__r.Name,
                    'value' => ast.Facultative_Folder__r.Id
                });

                folderStatusMap.put(ast.Facultative_Folder__r.Id, ast.Facultative_Folder__r.Folder_Status__c);
            }
        }

        // === STEP 3: Prepare result map ===
        Map<String, Object> result = new Map<String, Object>{
            'folderOptions' => folderOptions,
            'folderStatusMap' => folderStatusMap
        };

        System.debug('Result: '+ result);
        return result;
    }*/

    /*@AuraEnabled
    public static Map<String, Object> getListOpportunityFolder(String recordId) {
        // === STEP 2: Build folder Options dropdown ===
        List<Asset> assetList = [SELECT Id,
                                    Name,
                                    Amount_Insured__c,
                                    Risk_ID__c,
                                    Opportunity__c,
                                    Opportunity__r.Name,
                                    Opportunity__r.Busreq_ID__c 
                                    FROM Asset WHERE RecordType.Name = 'Risk' 
                                    AND Has_Facultative__c = true 
                                    AND Opportunity__r.Opportunity_Type__c != 'Facultative Outward'
                                    AND Facultative_Folder__c =: recordId WITH SECURITY_ENFORCED 
                                ];

        
        // === STEP 2: Prepare a simpler list of maps for LWC ===
        List<Map<String, Object>> folderOpportunities = new List<Map<String, Object>>();
        for (Asset ast : assetList) {
            folderOpportunities.add(new Map<String, Object>{
                'Id' => ast.Id,
                'OpportunityName' => ast.Opportunity__r != null ? ast.Opportunity__r.Name : null,
                'BusreqID' => ast.Opportunity__r != null ? ast.Opportunity__r.Busreq_ID__c : null,
                'Risk_ID__c' => ast.Risk_ID__c,
                'Name' => ast.Name,
                'Amount_Insured__c' => ast.Amount_Insured__c,
                'RecordUrl' => '/lightning/r/Opportunity/' + ast.Opportunity__c + '/view'
            });
        }


        // === STEP 2.1: Additional Responsee All Opportunities ===
        
        List<Opportunity> offeringList = [Select Id, 
                                            Name,
                                            Busreq_ID__c, 
                                            Account.Name, 
                                            Share_Offered__c, 
                                            Share_Accepted_Approved__c, 
                                            Offering_status__c from Opportunity 
                                            WHERE Opportunity_Type__c = 'Facultative Outward'
                                            //AND Facultative_Folder__c =: recordId 
                                            WITH SECURITY_ENFORCED 
                                        ];
        // === STEP 2.2 : Prepare a simpler list of maps for LWC ===
        List<Map<String, Object>> offeringOpportunities = new List<Map<String, Object>>();
        for (Opportunity opty : offeringList) {
            offeringOpportunities.add(new Map<String, Object>{
                'Id' => opty.Id,
                'OpportunityName' => opty.Name,
                'BusreqID' => opty.Busreq_ID__c,
                'Reinsurer' => opty.Account.Name,
                'Share_offered__c' => opty.Share_Offered__c,
                'Share_accepted__c' => opty.Share_Accepted_Approved__c,
                'Status' => opty.Offering_status__c,
                'RecordUrl' => '/lightning/r/Opportunity/' + opty.Id + '/view' 
            });
        }

        // === STEP 2.3: Get All Risk Within Folder ===
        // === STEP 2.3 : Query all Assets related to those Opportunities ===
        if (!offeringList.isEmpty()) {
            assetList = [
                SELECT Id, Opportunity__r.Name, Risk_ID__c, Origin_Risk__c, 
                Origin_Risk__r.Opportunity__r.Busreq_ID__c,
                Origin_Risk__r.Risk_ID__c FROM Asset
                WHERE Origin_Risk__c != '' AND Opportunity__r.Id IN :offeringList
                WITH SECURITY_ENFORCED
            ];
        }

        // ✅ Convert into label-value format for LWC picklist
        List<Map<String, String>> assetPicklist = new List<Map<String, String>>();
        for (Asset a : assetList) {
            String label = a.Opportunity__r.Name + ' - '+ a.Origin_Risk__r.Opportunity__r.Busreq_ID__c + ' - ' + a.Origin_Risk__r.Risk_ID__c;
            assetPicklist.add(new Map<String, String>{
                'label' => label,
                'value' => a.Id
            });
        }

        // === STEP 3: Return as structured JSON ===
        Map<String, Object> result = new Map<String, Object>{
            'folderOpportunities' => folderOpportunities,
            'offeringOpportunities' => offeringOpportunities,
            'assetFolder' => assetPicklist
        };

        System.debug('✅ Result: ' + result);
        return result;
    }
    */    

/*
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getRiskDetail(Id riskId) {
         // === STEP 1: Get Asset Record ===
        Asset assetRecord = [
            SELECT  Id, origin_risk__r.Name, origin_risk__r.Amount_Insured__c, origin_risk__r.Risk_ID__c , origin_risk__r.Risk_Description__c, origin_risk__r.Risk_Address__c,
                    origin_risk__r.Volcanic_Zone__c, origin_risk__r.Flood_Zone__c, origin_risk__r.Eq_Zone__c, origin_risk__r.Tsunami_Zone__c,
                    origin_risk__r.Opportunity__c, origin_risk__r.Opportunity__r.StageName,Opportunity__r.Name,
                    origin_risk__r.Opportunity__r.Start_Date_Periode__c, origin_risk__r.Opportunity__r.End_Date_Periode__c,
                    origin_risk__r.Opportunity__r.Busreq_ID__c, origin_risk__r.Opportunity__r.The_Insured_Name__r.Name,
                    Opportunity__r.Facultative_Folder__r.Name, origin_risk__r.Opportunity__r.Name,
                    origin_risk__r.Commission_All_Coverages__c, origin_risk__r.Rate_All_Coverages__c,
                    Opportunity__r.Rate__c, Opportunity__r.Commision__c, 
                    Opportunity__r.Share_Offered__c, Opportunity__r.Share_Accepted_Approved__c, 
                    Opportunity__r.Share_Binding__c, Opportunity__r.Share_Pending_Binding__c, 
                    Opportunity__r.ShortFall__c, Opportunity__r.Facultative_Folder__r.Folder_Status__c 
            FROM Asset
            WHERE Id = :riskId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (assetRecord == null) {
            return new Map<String, Object>{ 'error' => 'Asset record not found.' };
        }

        // === STEP 2: Get related Quote (for Treaty JSON) ===
        Quote relatedQuote = [
            SELECT Id, Treaty_Distribution_Response__c
            FROM Quote
            WHERE OpportunityId = :assetRecord.origin_risk__r.Opportunity__c
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        List<Object> jsonList = new List<Object>();
        if (relatedQuote != null && !String.isBlank(relatedQuote.Treaty_Distribution_Response__c)) {
            jsonList = (List<Object>) JSON.deserializeUntyped(relatedQuote.Treaty_Distribution_Response__c);
        }

        // === STEP 3: Situation field composition ===
        List<String> parts = new List<String>();
        if (String.isNotBlank(assetRecord.origin_risk__r.Risk_Address__c)) {
            parts.add('Address: ' + assetRecord.origin_risk__r.Risk_Address__c);
        }
        if (String.isNotBlank(assetRecord.origin_risk__r.Flood_Zone__c)) {
            parts.add('Flood Zone: ' + assetRecord.origin_risk__r.Flood_Zone__c);
        }
        if (String.isNotBlank(assetRecord.origin_risk__r.Eq_Zone__c)) { 
            parts.add('EQ Zone: ' + assetRecord.origin_risk__r.Eq_Zone__c);
        }
        if (String.isNotBlank(assetRecord.origin_risk__r.Volcanic_Zone__c)) {
            parts.add('Volcanic Zone: ' + assetRecord.origin_risk__r.Volcanic_Zone__c);
        }
        if (String.isNotBlank(assetRecord.origin_risk__r.Tsunami_Zone__c)) {
            parts.add('Tsunami Zone: ' + assetRecord.origin_risk__r.Tsunami_Zone__c);
        }
        String situation = String.join(parts, ' | ');

        // === STEP 4: Match Treaty JSON by Busreq & Risk ===
        String busreqId = assetRecord.origin_risk__r.Opportunity__r?.Busreq_ID__c;
        String riskNo = assetRecord.origin_risk__r.Risk_ID__c;

        Decimal totalSumInsured = null;
        Decimal accumulationAWTShare = null;
        Decimal treatyAmount = null;
        Decimal exhaustedUtilizedAmount = null;
        Decimal remainingAmount = null;
        Decimal excessAmount = null;
        

        for (Object o : jsonList) {
            Map<String, Object> data = (Map<String, Object>) o;
            if (data.get('busreq_id') == busreqId && data.get('riskNo') == riskNo) {
                totalSumInsured = (Decimal) data.get('totalSumInsuredShare');
                accumulationAWTShare = (Decimal) data.get('accumulatedSumInsuredShare');
                treatyAmount = (Decimal) data.get('treaty');
                exhaustedUtilizedAmount = (Decimal) data.get('exhaustedUtilized');
                remainingAmount = (Decimal) data.get('remaining');
                excessAmount = (Decimal) data.get('excess');
                break;
            }
        }

        // === STEP 5: Get QQ Names ===
        List<Transaction_Data__c> qqList = [
            SELECT QQ_Name__r.Name
            FROM Transaction_Data__c
            WHERE Opportunity__c = :assetRecord.Origin_Risk__r.Opportunity__c
            AND RecordType.Name = 'Member of QQ'
            AND QQ_Name__r.Name != null
            WITH SECURITY_ENFORCED
        ];

        List<String> qqNames = new List<String>();
        for (Transaction_Data__c t : qqList) { 
            qqNames.add(t.QQ_Name__r.Name);
        }
        String qqNameCombined = qqNames.isEmpty() ? null : String.join(qqNames, ', ');

        System.debug('assetRecord: ' + assetRecord);
        // === STEP 6: Return FLAT structure ===
        return new Map<String, Object>{
            'RiskId' => assetRecord.Origin_Risk__r.Risk_ID__c,
            'Name' => assetRecord.Origin_Risk__r.Name,
            'Description' => assetRecord.Origin_Risk__r.Risk_Description__c,
            'Situation' => situation,
            'AmountInsured' => totalSumInsured,
            'AccumulationAswataShare' => accumulationAWTShare,
            'OpportunityId' => assetRecord.Origin_Risk__r.Opportunity__c,
            'OpportunityName' => assetRecord.Origin_Risk__r.Opportunity__r?.Name,
            'OpportunityStage' => assetRecord.Origin_Risk__r.Opportunity__r?.StageName,
            'BusreqId' => assetRecord.Origin_Risk__r.Opportunity__r?.Busreq_ID__c,
            'FacFolderNo' => assetRecord.Opportunity__r.Facultative_Folder__r.Name,
            'FacultativeOpportunityNo' => assetRecord.Opportunity__r?.Name,
            'InsuredName' => assetRecord.Origin_risk__r.Opportunity__r?.The_Insured_Name__r?.Name,
            'StartDate' => assetRecord.Origin_risk__r.Opportunity__r?.Start_Date_Periode__c,
            'EndDate' => assetRecord.Origin_risk__r.Opportunity__r?.End_Date_Periode__c,
            'TreatyAmount' => treatyAmount,
            'ExhaustedAmount' => exhaustedUtilizedAmount,
            'RemainingAmount' => remainingAmount,
            'ExcessAmount' => excessAmount,
            'OriginalRate' => assetRecord.Origin_risk__r.Rate_All_Coverages__c,
            'OriginalCommission' => assetRecord.Origin_risk__r.Commission_All_Coverages__c,
            'RateOffered' => assetRecord.Opportunity__r?.Rate__c,
            'CommissionOffered' => assetRecord.Opportunity__r?.Commision__c,
            'ShareOfferedPercent' => assetRecord.Opportunity__r?.Share_Offered__c,
            'ShareAcceptedPercent' => assetRecord.Opportunity__r?.Share_Accepted_Approved__c,
            'ShareBinding' => assetRecord.Opportunity__r?.Share_Binding__c,
            'SharePendingBinding' => assetRecord.Opportunity__r?.Share_Pending_Binding__c,
            'ShortFall' => assetRecord.Opportunity__r?.ShortFall__c,
            'FolderStatus' => assetRecord.Opportunity__r.Facultative_Folder__r?.Folder_Status__c,
            'QQName' => qqNameCombined
        };
    }
    */

    @AuraEnabled(cacheable=false)
    public static List<Account> searchAccounts(String searchKey) {
        if (String.isBlank(searchKey)) {
            return new List<Account>();
        }
        return [
            SELECT Id, Name, Insurance_ID__c
            FROM Account
            WHERE Name LIKE :('%' + searchKey + '%') and Type = 'REINSURANCE'
            With SECURITY_ENFORCED 
            ORDER BY Name
            LIMIT 5
        ];
    }

    @AuraEnabled
    public static void updateFacultativeStatus(Id recordId, String newStatus) {
        if (String.isBlank(recordId) || String.isBlank(newStatus)) {
            throw new AuraHandledException('Missing parameters.');
        }

        Opportunity so = [SELECT Id, Offering_status__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
        so.Offering_status__c = newStatus;
        update so;
    }


    

}