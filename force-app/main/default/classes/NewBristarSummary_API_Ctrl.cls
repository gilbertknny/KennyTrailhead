// public with sharing class NewBristarSummary_API_Ctrl {
//     public NewBristarSummary_API_Ctrl() {

//     }
// }

public with sharing class NewBristarSummary_API_Ctrl {
    public static String getBristarSummary(BristarSummary_API_Wrapper.GetRequest_Model jreq) {
        //BristarSummary_API_Wrapper.GetRequest_Model jreq = (BristarSummary_API_Wrapper.GetRequest_Model)JSON.deserialize(jsonRequest, BristarSummary_API_Wrapper.GetRequest_Model.class);
        
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        SCC_Custom_API_Response_Code__mdt rc = new SCC_Custom_API_Response_Code__mdt();

        if (String.isBlank(jreq.startDate) || String.isBlank(jreq.endDate) || String.isBlank(jreq.area)) {
            rc = maprc?.get('Mandatory');
            return createErrorResponse(rc);
        }

        List<String> conditions = new List<String>();
        List<String> conditionsDtl = new List<String>();
        conditions.add('Date__c >= ' + jreq.startDate + ' AND Date__c <= ' + jreq.endDate);
        conditionsDtl.add('Date__c >= ' + jreq.startDate + ' AND Date__c <= ' + jreq.endDate + 'AND Status IN (\'New\', \'Waiting Document\', \'Working\', \'Escalated\', \'Returned\',\'Closed\')');
        String flag = '';
        String orderBy = '';
        String status = '';
        // Check if status ticket is not empty
        if (String.isNotBlank(jreq.statusTicket)) {
            if (jreq.statusTicket == 'OPEN') {
                status = 'OPEN';
                conditionsDtl.add('IsClosed__c = false');
            } else if (jreq.statusTicket == 'CLOSED') {
                status = 'CLOSED';
                conditionsDtl.add('IsClosed__c = true');
            }else{
                rc = maprc?.get('Data_Not_Found');
                return createErrorResponse(rc);
            }
        }else{
            status = 'ALL';
        }
        // Check if Area is KP or RO
        if(String.isNotBlank(jreq.area) && jreq.area == 'KP' && jreq.region == ''){
            conditions.add('area__c = \'KP00\'');
            conditions.add('costCenter__c != null');
            conditionsDtl.add('Area__c = \'KP00\'');
            orderBy = 'Date__c';
            flag = 'KP';
            System.debug('status KP :'+status);
        }else if(String.isNotBlank(jreq.area) && jreq.area == 'RO' && jreq.costCenter == ''){
            conditions.add('area__c != \'KP00\'');
            conditions.add('region__c != null');
            conditions.add('region__c != \'KP\'');
            conditions.add('mainBranch__c != null');
            conditions.add('branch__c != null');
            conditionsDtl.add('Area__c != \'KP00\'');
            // conditionsDtl.add('Region__c != null');
            // conditionsDtl.add('Region__c != \'KP\'');
            orderBy = 'Date__c';
            flag = 'RO';
        }else{
            rc = maprc?.get('Data_Not_Found');
            return createErrorResponse(rc);
        }

        // Second condition: Check if costCenter is not empty
        if (String.isNotBlank(jreq.costCenter)) {
            conditionsDtl.add('Cost_Center__c = \''+String.escapeSingleQuotes(jreq.costCenter)+'\'');
            flag = 'KP1';
            orderBy = 'Date__c';
        }

        // Third condition: Check if region is not empty
        if (String.isNotBlank(jreq.region) && jreq.costCenter == '') {
            conditions.add('region__c = \''+String.escapeSingleQuotes(jreq.region)+'\'');
            conditionsDtl.add('Region_Code__c = \''+String.escapeSingleQuotes(jreq.region)+'\'');
            flag = 'RO1';
            orderBy = 'Date__c';
        }

        // Fourth condition: Check if mainBranch is not empty
        if (String.isNotBlank(jreq.mainBranch) && jreq.costCenter == '') {
            conditions.add('mainBranch__c = \''+String.escapeSingleQuotes(jreq.mainBranch)+'\'');
            conditionsDtl.add('Main_Branch__c = \''+String.escapeSingleQuotes(jreq.mainBranch)+'\'');
            flag = 'RO2';
            orderBy = 'Date__c';
        }

        // Five condition: Check if branch is not empty
        if (String.isNotBlank(jreq.branch) && jreq.costCenter == '') {
            conditionsDtl.add('Branch_Code__c = \''+String.escapeSingleQuotes(jreq.branch)+'\'');
            flag = 'RO3';
            orderBy = 'Date__c';
        }

        String query = buildQuerySummary(conditions, orderBy);
        String queryDetail = buildQueryDetail(conditionsDtl, orderBy);
        
        if (String.isBlank(query)) {
            rc = maprc?.get('Data_Not_Found');
            return createErrorResponse(rc);
        }

        Integer page = String.isNotBlank(jreq.page) ? Integer.valueOf(jreq.page) : null;
        Integer pageSize = String.isNotBlank(jreq.lmt) ? Integer.valueOf(jreq.lmt) : null;

        if(flag == 'KP'){
            System.debug('query KP :'+query);
            System.debug('maprc KP :'+maprc);
            System.debug('area KP :'+jreq.area);
            System.debug('Status KP :'+status);
            return processSummaryDataKP(query, maprc, jreq.area, status);
        }else if (flag == 'KP1'){
            return processDetailDataKP(queryDetail, maprc, jreq.area, jreq.costCenter, jreq.startDate, jreq.endDate, page, pageSize, jreq.statusTicket);
        }else if (flag == 'RO'){
            return processSummaryDataRO(query, maprc, jreq.area, status);
        }else if(flag == 'RO1'){
            return processSummaryDataRO1(query, maprc, jreq.area, jreq.region, status);
        }else if(flag == 'RO2'){
            return processSummaryDataRO2(query, maprc, jreq.area, jreq.region, jreq.mainBranch, status);
        }else if(flag == 'RO3'){
            return processDetailDataRO(queryDetail, maprc, jreq.area, jreq.region, jreq.mainBranch, jreq.branch, jreq.startDate, jreq.endDate, page, pageSize, jreq.statusTicket);
        }else{
            rc = maprc?.get('Data_Not_Found');
            return createErrorResponse(rc);
        }
    }

    private static String buildQuerySummary(List<String> conditions, String orderBy) {
        String fields = 'Id, area__c, Date__c, costCenter__c, region__c, regionDesc__c, mainBranch__c, mainBranchDesc__c, branch__c, branchDesc__c, costCenterDesc__c, onSla__c, overSla__c, onSlaOpen__c, overSlaOpen__c, onSlaClosed__c, overSlaClosed__c, openTicket__c, closedTicket__c';
    
        // Ensure conditions list is not empty
        if (conditions == null || conditions.isEmpty()) {
            return null;
        }
        
        String whereClause = String.join(conditions, ' AND ');
        String query = 'SELECT ' + fields + ' FROM Bristar_Summary__c WHERE ' + whereClause;
        
        // Add ORDER BY only if orderBy is not blank
        if (String.isNotBlank(orderBy)) {
            query += ' ORDER BY ' + orderBy;
        }
        
        System.debug('Initial Query: ' + query);
        return query;
    }

    private static String buildQueryDetail(List<String> conditionsDtl, String orderBy) {
        String fields = 'Id, Area__c, Date__c, IsClosed__c, Cost_Center__c, SLA_saat_ini__c, Total_SLA_2__c, Gap_Terhadap_SLA__c, ' +
                    'ClosedDate, Status, CreatedDate, Case_Number__c, Region_Code__c, Region_Description__c, Main_Branch__c, ' +
                    'Main_Branch_Description__c, Branch_Code__c, Within_Target_SLA__c, Branch_Unit_Name__c, ' +
                    'Cost_Center_Description__c, SCC_Call_Type__r.Name, SCC_Call_Type__r.SSC_Case_Description__c';
    
        // Ensure conditions list is not empty
        if (conditionsDtl == null || conditionsDtl.isEmpty()) {
            return null;
        }
        
        String whereClause = String.join(conditionsDtl, ' AND ');
        String query = 'SELECT ' + fields + ' FROM Case WHERE ' + whereClause;
        
        // Add ORDER BY only if orderBy is not blank
        if (String.isNotBlank(orderBy)) {
            query += ' ORDER BY ' + orderBy;
        }
        
        System.debug('Initial Query: ' + query);
        return query;
    }

    public static String processSummaryDataKP(String query, Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String status) {
        System.debug('Status process KP :'+status);
        System.debug('Query Bristar Sum :'+query);
        BristarSummary_API_Wrapper.GetResponseKP_Model jres = new BristarSummary_API_Wrapper.GetResponseKP_Model();
        // List<BristarSummary_API_Wrapper.GetDetailKP_Model> divisionSummaryList = new List<BristarSummary_API_Wrapper.GetDetailKP_Model>();
        Map<String, BristarSummary_API_Wrapper.GetDetailKP_Model> divisionSummaryMap = new Map<String, BristarSummary_API_Wrapper.GetDetailKP_Model>();
        
        Set<String> masterCostCenters = new Set<String>();
        Map<String, String> masterCostCenterDescriptions = new Map<String, String>();
        
        List<AggregateResult> results = [SELECT Cost_Center__c, Cost_Center_Description__c
                                        FROM Orgeh__c
                                        WHERE Cost_Center__c != null
                                        GROUP BY Cost_Center__c, Cost_Center_Description__c];
        
        System.debug('AggregateResult :'+results);

        for (AggregateResult ar : results) {
            String costCenter = (String)ar.get('Cost_Center__c');
            String description = (String)ar.get('Cost_Center_Description__c');
            masterCostCenters.add(costCenter);
            masterCostCenterDescriptions.put(costCenter, description);
        }

        // Process cases
        Set<String> processedCostCenters = new Set<String>();
        for (Bristar_Summary__c cs : Database.query(query)) {
            System.debug('cs overSlaClosed__c:'+cs.overSlaClosed__c);

            String divisiKey = cs.costCenter__c;
            processedCostCenters.add(divisiKey);
            
            if (!divisionSummaryMap.containsKey(divisiKey)) {
                BristarSummary_API_Wrapper.GetDetailKP_Model evdkp = new BristarSummary_API_Wrapper.GetDetailKP_Model();
                evdkp.costCenter = divisiKey != null ? divisiKey : '';
                evdkp.costCenterDesc = cs.costCenterDesc__c != null ? cs.costCenterDesc__c : '';
                evdkp.openTicket = '0';
                evdkp.closedTicket = '0';
                evdkp.overSla = '0';
                evdkp.onSla = '0';
                divisionSummaryMap.put(divisiKey, evdkp);
            }

            BristarSummary_API_Wrapper.GetDetailKP_Model devisionSummary = divisionSummaryMap.get(divisiKey);
            system.debug('devisionSummary:'+devisionSummary);
            system.debug('divisionSummaryMap:'+divisionSummaryMap);
            system.debug('divisiKey:'+divisiKey);
            system.debug('Bristar_Summary__c:'+cs);

            System.debug('bristar KP :'+cs);

            updateDivisionSummaryKP(devisionSummary, cs, status);
        }

        // Create empty data for master Cost Centers not found in Cases
        for (String masterCostCenter : masterCostCenters) {
            if (!processedCostCenters.contains(masterCostCenter)) {
                BristarSummary_API_Wrapper.GetDetailKP_Model evdkp = new BristarSummary_API_Wrapper.GetDetailKP_Model();
                evdkp.costCenter = masterCostCenter;
                evdkp.costCenterDesc = masterCostCenterDescriptions.get(masterCostCenter);
                evdkp.openTicket = '0';
                evdkp.closedTicket = '0';
                evdkp.overSla = '0';
                evdkp.onSla = '0';
                divisionSummaryMap.put(masterCostCenter, evdkp);
            }
        }


       // Convert the map values to a list
       List<BristarSummary_API_Wrapper.GetDetailKP_Model> divisionSummaryList = new List<BristarSummary_API_Wrapper.GetDetailKP_Model>(divisionSummaryMap.values());
        
       // Sort divisionSummary by totalActivities (descending order)
       divisionSummaryList.sort(new TotalKPComparator());

        jres.divisionSummary = divisionSummaryList;
        jres.area = area;

        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;

        return BristarSummary_API_Ctrl.returnAPIKP(jres);
    }

    public static void updateDivisionSummaryKP(BristarSummary_API_Wrapper.GetDetailKP_Model divisionSummary, Bristar_Summary__c cs, String status) {
        System.debug('Status update KP :'+status);

        Decimal openTicket = cs.openTicket__c != null ? cs.openTicket__c : 0;
        Decimal overSlaOpen = cs.overSlaOpen__c != null ? cs.overSlaOpen__c : 0;
        Decimal onSlaOpen = cs.onSlaOpen__c != null ? cs.onSlaOpen__c : 0;
        Decimal closedTicket = cs.closedTicket__c != null ? cs.closedTicket__c : 0;
        Decimal overSlaClosed = cs.overSlaClosed__c != null ? cs.overSlaClosed__c : 0;
        Decimal onSlaClosed = cs.onSlaClosed__c != null ? cs.onSlaClosed__c : 0;
        Decimal overSla = cs.overSla__c != null ? cs.overSla__c : 0;
        Decimal onSla = cs.onSla__c != null ? cs.onSla__c : 0;

        system.debug('openTicket :'+openTicket);
        system.debug('overSlaOpen :'+overSlaOpen);
        system.debug('onSlaOpen :'+onSlaOpen);
        system.debug('closedTicket :'+closedTicket);
        system.debug('overSlaClosed :'+overSlaClosed);
        system.debug('onSlaClosed :'+onSlaClosed);
        system.debug('overSla :'+overSla);
        system.debug('onSla :'+onSla);

        if (status == 'OPEN') {
            divisionSummary.openTicket = String.valueOf(Integer.valueOf(divisionSummary.openTicket) + openTicket);
            divisionSummary.overSla = String.valueOf(Integer.valueOf(divisionSummary.overSla) + overSlaOpen);
            divisionSummary.onSla = String.valueOf(Integer.valueOf(divisionSummary.onSla) + onSlaOpen);
        } else if (status == 'CLOSED'){
            divisionSummary.closedTicket = String.valueOf(Integer.valueOf(divisionSummary.closedTicket) + closedTicket);
            divisionSummary.overSla = String.valueOf(Integer.valueOf(divisionSummary.overSla) + overSlaClosed);
            divisionSummary.onSla = String.valueOf(Integer.valueOf(divisionSummary.onSla) + onSlaClosed);
        } else if (status == 'ALL'){
            divisionSummary.closedTicket = String.valueOf(Integer.valueOf(divisionSummary.closedTicket) + closedTicket);
            divisionSummary.openTicket = String.valueOf(Integer.valueOf(divisionSummary.openTicket) + openTicket);
            divisionSummary.overSla = String.valueOf(Integer.valueOf(divisionSummary.overSla) + overSla);
            divisionSummary.onSla = String.valueOf(Integer.valueOf(divisionSummary.onSla) + onSla);
        }
    }

    // Comparator class remains the same
    private class TotalKPComparator implements Comparator<BristarSummary_API_Wrapper.GetDetailKP_Model> {
        public Integer compare(BristarSummary_API_Wrapper.GetDetailKP_Model a, BristarSummary_API_Wrapper.GetDetailKP_Model b) {
            Integer aOverSla = Integer.valueOf(a.overSla);
            Integer bOverSla = Integer.valueOf(b.overSla);
            
            // Primary sort by overSla
            if (aOverSla != bOverSla) {
                return bOverSla - aOverSla; // Descending order
            }
            
            // Secondary sort by total tickets (openTicket + closedTicket)
            Integer aTotalTickets = Integer.valueOf(a.openTicket) + Integer.valueOf(a.closedTicket);
            Integer bTotalTickets = Integer.valueOf(b.openTicket) + Integer.valueOf(b.closedTicket);
            
            return bTotalTickets - aTotalTickets; // Descending order
        }
    }

    public static String returnAPIKP(BristarSummary_API_Wrapper.GetResponseKP_Model jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }

    private static String processSummaryDataRO(String query, Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String status) {
        BristarSummary_API_Wrapper.GetResponseRO_Model jres = new BristarSummary_API_Wrapper.GetResponseRO_Model();
        // List<BristarSummary_API_Wrapper.GetDetailRO_Model> regionSummaryList = new List<BristarSummary_API_Wrapper.GetDetailRO_Model>();
        Map<String, BristarSummary_API_Wrapper.GetDetailRO_Model> regionSummaryMap = new Map<String, BristarSummary_API_Wrapper.GetDetailRO_Model>();

        Set<String> masterRegions = new Set<String>();
        Map<String, String> masterRegionDescriptions = new Map<String, String>();

        // First, get the valid BranchCode__c values from Branch_Unit__c
        Set<String> validBranchCodes = new Set<String>();
        for(Branch_Unit__c bu : [SELECT BranchCode__c 
                                FROM Branch_Unit__c 
                                WHERE Uker_type__c != 'RO' AND Region__c != 'KP'
                                AND BranchCode__c != null ]) {
            validBranchCodes.add(bu.BranchCode__c);
        }

        List<AggregateResult> results = [SELECT Region__c, Region_Name__c
                                        FROM Branch_Unit__c
                                        WHERE Region__c != null AND Uker_type__c != 'RO' AND Region__c != 'KP'
                                        GROUP BY Region__c, Region_Name__c];
        
        System.debug('AggregateResult :'+results);

        for (AggregateResult ar : results) {
            String region = (String)ar.get('Region__c');
            String description = (String)ar.get('Region_Name__c');
            masterRegions.add(region);
            masterRegionDescriptions.put(region, description);
        }
        // Process cases with additional branch filtering
        Set<String> processedRegions = new Set<String>();

        for (Bristar_Summary__c cs : Database.query(query)) {
            // Only include cases where Branch_Code__c matches valid branch codes
            if (validBranchCodes.contains(cs.branch__c)) {
                // filteredCases.add(cs);
                String regionKey = cs.region__c;
                processedRegions.add(regionKey);
                
                if (!regionSummaryMap.containsKey(regionKey)) {
                    BristarSummary_API_Wrapper.GetDetailRO_Model evdkp = new BristarSummary_API_Wrapper.GetDetailRO_Model();
                    evdkp.region = regionKey != null ? regionKey : '';
                    evdkp.regionDesc = cs.regionDesc__c != null ? cs.regionDesc__c : '';
                    evdkp.openTicket = '0';
                    evdkp.closedTicket = '0';
                    evdkp.overSla = '0';
                    evdkp.onSla = '0';
                    regionSummaryMap.put(regionKey, evdkp);
                }
                
                BristarSummary_API_Wrapper.GetDetailRO_Model regionSummary = regionSummaryMap.get(regionKey);
                system.debug('region summay test1 :'+regionSummary);
                system.debug('region summay test 2:'+regionSummaryMap);
                system.debug('region summay test3 :'+regionKey);
                system.debug('region summay cs:'+cs);
                updateRegionSummaryRO(regionSummary, cs, status);
            }
        }

        // Create empty data for master Cost Centers not found in Cases
        for (String masterRegion : masterRegions) {
            if (!processedRegions.contains(masterRegion)) {
                BristarSummary_API_Wrapper.GetDetailRO_Model evdkp = new BristarSummary_API_Wrapper.GetDetailRO_Model();
                evdkp.region = masterRegion;
                evdkp.regionDesc = masterRegionDescriptions.get(masterRegion);
                evdkp.openTicket = '0';
                evdkp.closedTicket = '0';
                evdkp.overSla = '0';
                evdkp.onSla = '0';
                regionSummaryMap.put(masterRegion, evdkp);
            }
        }

        // Convert the map values to a list
        List<BristarSummary_API_Wrapper.GetDetailRO_Model> regionSummaryList = new List<BristarSummary_API_Wrapper.GetDetailRO_Model>(regionSummaryMap.values());
        
        // Sort divisionSummary by totalActivities (descending order)
        regionSummaryList.sort(new TotalROComparator());

        jres.regionSummary = regionSummaryList;
        jres.area = area;

        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;

        return BristarSummary_API_Ctrl.returnAPIRO(jres);
    }

    // Comparator class remains the same
    private class TotalROComparator implements Comparator<BristarSummary_API_Wrapper.GetDetailRO_Model> {
        public Integer compare(BristarSummary_API_Wrapper.GetDetailRO_Model a, BristarSummary_API_Wrapper.GetDetailRO_Model b) {
            Integer aOverSla = Integer.valueOf(a.overSla);
            Integer bOverSla = Integer.valueOf(b.overSla);
            
            // Primary sort by overSla
            if (aOverSla != bOverSla) {
                return bOverSla - aOverSla; // Descending order
            }
            
            // Secondary sort by total tickets (openTicket + closedTicket)
            Integer aTotalTickets = Integer.valueOf(a.openTicket) + Integer.valueOf(a.closedTicket);
            Integer bTotalTickets = Integer.valueOf(b.openTicket) + Integer.valueOf(b.closedTicket);
            
            return bTotalTickets - aTotalTickets; // Descending order
        }
    }

    public static String returnAPIRO(BristarSummary_API_Wrapper.GetResponseRO_Model jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }

    private static String processSummaryDataRO1(String query, Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String region, String status) {
        BristarSummary_API_Wrapper.GetResponseRO1_Model jres = new BristarSummary_API_Wrapper.GetResponseRO1_Model();
        // List<BristarSummary_API_Wrapper.GetDetailRO1_Model> mainBranchSummaryList = new List<BristarSummary_API_Wrapper.GetDetailRO1_Model>();
        Map<String, BristarSummary_API_Wrapper.GetDetailRO1_Model> mainBranchSummaryMap = new Map<String, BristarSummary_API_Wrapper.GetDetailRO1_Model>();

        String regionDesc = '';

        Set<String> masterMainBranchs = new Set<String>();
        Map<String, String> masterMainBranchsDescriptions = new Map<String, String>();

        // First, get the valid BranchCode__c values from Branch_Unit__c
        Set<String> validBranchCodes = new Set<String>();
        for(Branch_Unit__c bu : [SELECT BranchCode__c 
                                FROM Branch_Unit__c 
                                WHERE Uker_type__c != 'RO' AND Region__c != 'KP'
                                AND BranchCode__c != null]) {
            validBranchCodes.add(bu.BranchCode__c);
        }

        List<AggregateResult> results = [SELECT Kode_Cabang__c, Nama_Cabang__c
                                        FROM Branch_Unit__c
                                        WHERE Kode_Cabang__c != null AND Region__c = : region AND Uker_type__c != 'RO' AND Region__c != 'KP'
                                        GROUP BY Kode_Cabang__c, Nama_Cabang__c];

        for (AggregateResult ar : results) {
            String mainBranch = (String)ar.get('Kode_Cabang__c');
            String description = (String)ar.get('Nama_Cabang__c');
            masterMainBranchs.add(mainBranch);
            masterMainBranchsDescriptions.put(mainBranch, description);
        }
        // Process cases
        Set<String> processedMainBranchs = new Set<String>();

        for (Bristar_Summary__c cs : Database.query(query)) {
            // Only include cases where Branch_Code__c matches valid branch codes
            System.debug('case branch :'+cs.branch__c);
            if (validBranchCodes.contains(cs.branch__c)){
                // filteredCases.add(cs);
                String mainBranchKey = cs.mainBranch__c;
                processedMainBranchs.add(mainBranchKey);

                if (!mainBranchSummaryMap.containsKey(mainBranchKey)) {
                    BristarSummary_API_Wrapper.GetDetailRO1_Model evdkp = new BristarSummary_API_Wrapper.GetDetailRO1_Model();
                    evdkp.mainBranch = mainBranchKey != null ? mainBranchKey : '';
                    evdkp.mainBranchDesc = cs.mainBranchDesc__c != null ? cs.mainBranchDesc__c : '';
                    evdkp.openTicket = '0';
                    evdkp.closedTicket = '0';
                    evdkp.overSla = '0';
                    evdkp.onSla = '0';
                    mainBranchSummaryMap.put(mainBranchKey, evdkp);
                }

                BristarSummary_API_Wrapper.GetDetailRO1_Model mainBranchSummary = mainBranchSummaryMap.get(mainBranchKey);
                updateMainBranchSummaryRO(mainBranchSummary, cs, status);

                if (String.isBlank(regionDesc) && cs.regionDesc__c != null) {
                    regionDesc = cs.regionDesc__c;
                }
            }
        }

        // Create empty data for master Cost Centers not found in Cases
        for (String masterMainBranch : masterMainBranchs) {
            if (!processedMainBranchs.contains(masterMainBranch)) {
                BristarSummary_API_Wrapper.GetDetailRO1_Model evdkp = new BristarSummary_API_Wrapper.GetDetailRO1_Model();
                evdkp.mainBranch = masterMainBranch;
                evdkp.mainBranchDesc = masterMainBranchsDescriptions.get(masterMainBranch);
                evdkp.openTicket = '0';
                evdkp.closedTicket = '0';
                evdkp.overSla = '0';
                evdkp.onSla = '0';
                mainBranchSummaryMap.put(masterMainBranch, evdkp);
            }
        }

        // Convert the map values to a list
        List<BristarSummary_API_Wrapper.GetDetailRO1_Model> mainBranchSummaryList = new List<BristarSummary_API_Wrapper.GetDetailRO1_Model>(mainBranchSummaryMap.values());
        
        // Sort divisionSummary by totalActivities (descending order)
        mainBranchSummaryList.sort(new TotalRO1Comparator());

        jres.mainBranchSummary = mainBranchSummaryList;
        jres.area = area;
        jres.region = region;
        jres.regionDesc = regionDesc;

        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;

        return BristarSummary_API_Ctrl.returnAPIRO1(jres);
    }

    // Comparator class remains the same
    private class TotalRO1Comparator implements Comparator<BristarSummary_API_Wrapper.GetDetailRO1_Model> {
        public Integer compare(BristarSummary_API_Wrapper.GetDetailRO1_Model a, BristarSummary_API_Wrapper.GetDetailRO1_Model b) {
            Integer aOverSla = Integer.valueOf(a.overSla);
            Integer bOverSla = Integer.valueOf(b.overSla);
            
            // Primary sort by overSla
            if (aOverSla != bOverSla) {
                return bOverSla - aOverSla; // Descending order
            }
            
            // Secondary sort by total tickets (openTicket + closedTicket)
            Integer aTotalTickets = Integer.valueOf(a.openTicket) + Integer.valueOf(a.closedTicket);
            Integer bTotalTickets = Integer.valueOf(b.openTicket) + Integer.valueOf(b.closedTicket);
            
            return bTotalTickets - aTotalTickets; // Descending order
        }
    }

    public static String returnAPIRO1(BristarSummary_API_Wrapper.GetResponseRO1_Model jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }

    private static String processSummaryDataRO2(String query, Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String region, String mainBranch, String status) {
        BristarSummary_API_Wrapper.GetResponseRO2_Model jres = new BristarSummary_API_Wrapper.GetResponseRO2_Model();
        Map<String, BristarSummary_API_Wrapper.GetDetailRO2_Model> branchSummaryMap = new Map<String, BristarSummary_API_Wrapper.GetDetailRO2_Model>();

        String regionDesc = '';
        String mainBranchDesc = '';

        Set<String> masterBranchs = new Set<String>();
        Map<String, String> masterBranchsDescriptions = new Map<String, String>();

        // First, get the valid BranchCode__c values from Branch_Unit__c
        Set<String> validBranchCodes = new Set<String>();
        for(Branch_Unit__c bu : [SELECT BranchCode__c 
                                FROM Branch_Unit__c 
                                WHERE Uker_type__c != 'RO' AND Region__c != 'KP'
                                AND BranchCode__c != null]) {
            validBranchCodes.add(bu.BranchCode__c);
        }

        List<Branch_Unit__c> results = [SELECT BranchCode__c, Name
                                        FROM Branch_Unit__c
                                        WHERE Kode_Cabang__c != null AND Name != null AND Region__c = : region AND Kode_Cabang__c = : mainBranch AND Uker_type__c != 'RO'
                                        ORDER BY BranchCode__c ASC];
        
        System.debug('Branch_Unit__c :'+results);

        for (Branch_Unit__c ar : results) {
            String branch = (String)ar.get('BranchCode__c');
            String description = (String)ar.get('Name');
            masterBranchs.add(branch);
            masterBranchsDescriptions.put(branch, description);
        }
        // Process cases
        Set<String> processedBranchs = new Set<String>();

        for (Bristar_Summary__c cs : Database.query(query)) {
            if (validBranchCodes.contains(cs.branch__c)) {
                String branchKey = cs.branch__c;
                processedBranchs.add(branchKey);

                if (!branchSummaryMap.containsKey(branchKey)) {
                    BristarSummary_API_Wrapper.GetDetailRO2_Model evdkp = new BristarSummary_API_Wrapper.GetDetailRO2_Model();
                    evdkp.branch = branchKey != null ? branchKey : '';
                    evdkp.branchDesc = cs.branchDesc__c != null ? cs.branchDesc__c : '';
                    evdkp.openTicket = '0';
                    evdkp.closedTicket = '0';
                    evdkp.overSla = '0';
                    evdkp.onSla = '0';
                    branchSummaryMap.put(branchKey, evdkp);
                }

                BristarSummary_API_Wrapper.GetDetailRO2_Model branchSummary = branchSummaryMap.get(branchKey);
                updateBranchSummaryRO(branchSummary, cs, status);

                if (String.isBlank(regionDesc) && cs.regionDesc__c != null) {
                    regionDesc = cs.regionDesc__c;
                }
        
                if (String.isBlank(mainBranchDesc) && cs.mainBranchDesc__c != null) {
                    mainBranchDesc = cs.mainBranchDesc__c;
                }
            }
        }

        // Create empty data for master Cost Centers not found in Cases
        for (String masterBranch : masterBranchs) {
            if (!processedBranchs.contains(masterBranch)) {
                BristarSummary_API_Wrapper.GetDetailRO2_Model evdkp = new BristarSummary_API_Wrapper.GetDetailRO2_Model();
                evdkp.branch = masterBranch;
                evdkp.branchDesc = masterBranchsDescriptions.get(masterBranch);
                evdkp.openTicket = '0';
                evdkp.closedTicket = '0';
                evdkp.overSla = '0';
                evdkp.onSla = '0';
                branchSummaryMap.put(masterBranch, evdkp);
            }
        }

        // Convert the map values to a list
        List<BristarSummary_API_Wrapper.GetDetailRO2_Model> branchSummaryList = new List<BristarSummary_API_Wrapper.GetDetailRO2_Model>(branchSummaryMap.values());
        
        // Sort divisionSummary by totalActivities (descending order)
        branchSummaryList.sort(new TotalRO2Comparator());

        jres.branchSummary = branchSummaryList;
        jres.area = area;
        jres.region = region;
        jres.regionDesc = regionDesc;
        jres.mainBranch = mainBranch;
        jres.mainBranchDesc = mainBranchDesc;

        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;

        return BristarSummary_API_Ctrl.returnAPIRO2(jres);
    }

     // Comparator class remains the same
     private class TotalRO2Comparator implements Comparator<BristarSummary_API_Wrapper.GetDetailRO2_Model> {
        public Integer compare(BristarSummary_API_Wrapper.GetDetailRO2_Model a, BristarSummary_API_Wrapper.GetDetailRO2_Model b) {
            Integer aOverSla = Integer.valueOf(a.overSla);
            Integer bOverSla = Integer.valueOf(b.overSla);
            
            // Primary sort by overSla
            if (aOverSla != bOverSla) {
                return bOverSla - aOverSla; // Descending order
            }
            
            // Secondary sort by total tickets (openTicket + closedTicket)
            Integer aTotalTickets = Integer.valueOf(a.openTicket) + Integer.valueOf(a.closedTicket);
            Integer bTotalTickets = Integer.valueOf(b.openTicket) + Integer.valueOf(b.closedTicket);
            
            return bTotalTickets - aTotalTickets; // Descending order
        }
    }

    public static String returnAPIRO2(BristarSummary_API_Wrapper.GetResponseRO2_Model jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }

    public static void updateRegionSummaryRO(BristarSummary_API_Wrapper.GetDetailRO_Model regionSummary, Bristar_Summary__c cs, String status) {

        Decimal openTicket = cs.openTicket__c != null ? cs.openTicket__c : 0;
        Decimal overSlaOpen = cs.overSlaOpen__c != null ? cs.overSlaOpen__c : 0;
        Decimal onSlaOpen = cs.onSlaOpen__c != null ? cs.onSlaOpen__c : 0;
        Decimal closedTicket = cs.closedTicket__c != null ? cs.closedTicket__c : 0;
        Decimal overSlaClosed = cs.overSlaClosed__c != null ? cs.overSlaClosed__c : 0;
        Decimal onSlaClosed = cs.onSlaClosed__c != null ? cs.onSlaClosed__c : 0;
        Decimal overSla = cs.overSla__c != null ? cs.overSla__c : 0;
        Decimal onSla = cs.onSla__c != null ? cs.onSla__c : 0;

        system.debug('openTicket :'+openTicket);
        system.debug('overSlaOpen :'+overSlaOpen);
        system.debug('onSlaOpen :'+onSlaOpen);
        system.debug('closedTicket :'+closedTicket);
        system.debug('overSlaClosed :'+overSlaClosed);
        system.debug('onSlaClosed :'+onSlaClosed);
        system.debug('overSla :'+overSla);
        system.debug('onSla :'+onSla);

        if (status == 'OPEN') {
            regionSummary.openTicket = String.valueOf(Integer.valueOf(regionSummary.openTicket) + openTicket);
            regionSummary.overSla = String.valueOf(Integer.valueOf(regionSummary.overSla) + overSlaOpen);
            regionSummary.onSla = String.valueOf(Integer.valueOf(regionSummary.onSla) + onSlaOpen);
        } else if (status == 'CLOSED'){
            regionSummary.closedTicket = String.valueOf(Integer.valueOf(regionSummary.closedTicket) + closedTicket);
            regionSummary.overSla = String.valueOf(Integer.valueOf(regionSummary.overSla) + overSlaClosed);
            regionSummary.onSla = String.valueOf(Integer.valueOf(regionSummary.onSla) + onSlaClosed);
        } else if (status == 'ALL'){
            regionSummary.closedTicket = String.valueOf(Integer.valueOf(regionSummary.closedTicket) + closedTicket);
            regionSummary.openTicket = String.valueOf(Integer.valueOf(regionSummary.openTicket) + openTicket);
            regionSummary.overSla = String.valueOf(Integer.valueOf(regionSummary.overSla) + overSla);
            regionSummary.onSla = String.valueOf(Integer.valueOf(regionSummary.onSla) + onSla);
        }
    }

    public static void updateMainBranchSummaryRO(BristarSummary_API_Wrapper.GetDetailRO1_Model mainBranchSummary, Bristar_Summary__c cs, String status) {
        Decimal openTicket = cs.openTicket__c != null ? cs.openTicket__c : 0;
        Decimal overSlaOpen = cs.overSlaOpen__c != null ? cs.overSlaOpen__c : 0;
        Decimal onSlaOpen = cs.onSlaOpen__c != null ? cs.onSlaOpen__c : 0;
        Decimal closedTicket = cs.closedTicket__c != null ? cs.closedTicket__c : 0;
        Decimal overSlaClosed = cs.overSlaClosed__c != null ? cs.overSlaClosed__c : 0;
        Decimal onSlaClosed = cs.onSlaClosed__c != null ? cs.onSlaClosed__c : 0;
        Decimal overSla = cs.overSla__c != null ? cs.overSla__c : 0;
        Decimal onSla = cs.onSla__c != null ? cs.onSla__c : 0;

        system.debug('openTicket :'+openTicket);
        system.debug('overSlaOpen :'+overSlaOpen);
        system.debug('onSlaOpen :'+onSlaOpen);
        system.debug('closedTicket :'+closedTicket);
        system.debug('overSlaClosed :'+overSlaClosed);
        system.debug('onSlaClosed :'+onSlaClosed);
        system.debug('overSla :'+overSla);
        system.debug('onSla :'+onSla);
        if (status == 'OPEN') {
            mainBranchSummary.openTicket = String.valueOf(Integer.valueOf(mainBranchSummary.openTicket) + openTicket);
            mainBranchSummary.overSla = String.valueOf(Integer.valueOf(mainBranchSummary.overSla) + overSlaOpen);
            mainBranchSummary.onSla = String.valueOf(Integer.valueOf(mainBranchSummary.onSla) + onSlaOpen);
        } else if (status == 'CLOSED'){
            mainBranchSummary.closedTicket = String.valueOf(Integer.valueOf(mainBranchSummary.closedTicket) + closedTicket);
            mainBranchSummary.overSla = String.valueOf(Integer.valueOf(mainBranchSummary.overSla) + overSlaClosed);
            mainBranchSummary.onSla = String.valueOf(Integer.valueOf(mainBranchSummary.onSla) + onSlaClosed);
        } else if (status == 'ALL'){
            mainBranchSummary.closedTicket = String.valueOf(Integer.valueOf(mainBranchSummary.closedTicket) + closedTicket);
            mainBranchSummary.openTicket = String.valueOf(Integer.valueOf(mainBranchSummary.openTicket) + openTicket);
            mainBranchSummary.overSla = String.valueOf(Integer.valueOf(mainBranchSummary.overSla) + overSla);
            mainBranchSummary.onSla = String.valueOf(Integer.valueOf(mainBranchSummary.onSla) + onSla);
        }
    }

    public static void updateBranchSummaryRO(BristarSummary_API_Wrapper.GetDetailRO2_Model branchSummary, Bristar_Summary__c cs, String status) {
        Decimal openTicket = cs.openTicket__c != null ? cs.openTicket__c : 0;
        Decimal overSlaOpen = cs.overSlaOpen__c != null ? cs.overSlaOpen__c : 0;
        Decimal onSlaOpen = cs.onSlaOpen__c != null ? cs.onSlaOpen__c : 0;
        Decimal closedTicket = cs.closedTicket__c != null ? cs.closedTicket__c : 0;
        Decimal overSlaClosed = cs.overSlaClosed__c != null ? cs.overSlaClosed__c : 0;
        Decimal onSlaClosed = cs.onSlaClosed__c != null ? cs.onSlaClosed__c : 0;
        Decimal overSla = cs.overSla__c != null ? cs.overSla__c : 0;
        Decimal onSla = cs.onSla__c != null ? cs.onSla__c : 0;

        system.debug('openTicket :'+openTicket);
        system.debug('overSlaOpen :'+overSlaOpen);
        system.debug('onSlaOpen :'+onSlaOpen);
        system.debug('closedTicket :'+closedTicket);
        system.debug('overSlaClosed :'+overSlaClosed);
        system.debug('onSlaClosed :'+onSlaClosed);
        system.debug('overSla :'+overSla);
        system.debug('onSla :'+onSla);
        if (status == 'OPEN') {
            branchSummary.openTicket = String.valueOf(Integer.valueOf(branchSummary.openTicket) + openTicket);
            branchSummary.overSla = String.valueOf(Integer.valueOf(branchSummary.overSla) + overSlaOpen);
            branchSummary.onSla = String.valueOf(Integer.valueOf(branchSummary.onSla) + onSlaOpen);
        } else if (status == 'CLOSED'){
            branchSummary.closedTicket = String.valueOf(Integer.valueOf(branchSummary.closedTicket) + closedTicket);
            branchSummary.overSla = String.valueOf(Integer.valueOf(branchSummary.overSla) + overSlaClosed);
            branchSummary.onSla = String.valueOf(Integer.valueOf(branchSummary.onSla) + onSlaClosed);
        } else if (status == 'ALL'){
            branchSummary.closedTicket = String.valueOf(Integer.valueOf(branchSummary.closedTicket) + closedTicket);
            branchSummary.openTicket = String.valueOf(Integer.valueOf(branchSummary.openTicket) + openTicket);
            branchSummary.overSla = String.valueOf(Integer.valueOf(branchSummary.overSla) + overSla);
            branchSummary.onSla = String.valueOf(Integer.valueOf(branchSummary.onSla) + onSla);
        }
    }
    
    public static String processDetailDataKP(String query, Map<String, SCC_Custom_API_Response_Code__mdt> maprc, 
    String area, String costCenter, String startdate, String endDate, Integer page, Integer pageSize, String statusTicket) {
    
        try {
            BristarSummary_API_Wrapper.GetResponseKP1_Model jres = new BristarSummary_API_Wrapper.GetResponseKP1_Model();
            List<BristarSummary_API_Wrapper.GetDetailKP1_Model> ticketSummaryList = new List<BristarSummary_API_Wrapper.GetDetailKP1_Model>();
            
            List<Case> cases;           
            
            // Handle pagination differently based on whether parameters are provided
            if (page != null && pageSize != null && page > 0 && pageSize > 0) {
                Integer offset = (page - 1) * pageSize;
                query += ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET ' + String.valueOf(offset);
                system.debug('Limit 1:'+query);
                cases = Database.query(query);
            } else {
                // If no pagination, just execute the query as is
                query += ' LIMIT 50';
                system.debug('Limit 2:'+query);
                cases = Database.query(query);
            }

            Schema.DescribeFieldResult f = Case.Status.getDescribe();
            List<Schema.PicklistEntry> p = f.getPicklistValues();
            map<String, String> mapstatus = new map<String, String>();
            // Create both mappings
            map<String, String> mapStatusByApiName = new map<String, String>();
            map<String, String> mapStatusByLabel = new map<String, String>();   
            
            for(Schema.PicklistEntry pck: p){
                mapStatusByLabel.put(pck.getValue(),pck.getLabel());
                mapStatusByApiName.put(pck.getLabel(),pck.getValue());
                // mapstatus.put(pck.getLabel(), pck.getValue());
            }
            System.debug('MapStatus Content: ' + mapStatusByLabel);
            System.debug('MapStatus Content: ' + mapStatusByApiName);
            
            for (Case cs : cases) {
                System.debug('Case Status: ' + cs.Status + ', Mapped Status: ' + mapStatusByLabel.get(cs.Status));
                ticketSummaryList.add(createTicketModelKP(cs,mapStatusByLabel.get(cs.status)));
            }

            // Sort the ticketSummaryList
            ticketSummaryList.sort(new TotalKP1Comparator());

            jres.ticketSummary = ticketSummaryList;
            jres.area = area;
            jres.costCenter = costCenter;
            jres.costCenterDesc = cases.isEmpty() ? '' : cases[0].Cost_Center_Description__c;

            String conditions = 'costCenter__c = \'' + costCenter + '\' AND area__c = \'KP00\' AND date__c >= ' + startDate + ' AND date__c <= ' + endDate;
            
            calculateSummaryDataKP(jres, conditions, page, pageSize, statusTicket);

            SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
            jres.responseCode = rc?.Response_Code__c;
            jres.responseMessage = rc?.Description__c;

            return BristarSummary_API_Ctrl.returnAPIKP1(jres);
            
        } catch (Exception e) {
            // Handle the error gracefully
            SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Error');
            BristarSummary_API_Wrapper.GetResponseKP1_Model errorResponse = new BristarSummary_API_Wrapper.GetResponseKP1_Model();
            errorResponse.responseCode = rc?.Response_Code__c;
            errorResponse.responseMessage = e.getMessage();
            return BristarSummary_API_Ctrl.returnAPIKP1(errorResponse);
        }
    }

    // Comparator class remains the same
    private class TotalKP1Comparator implements Comparator<BristarSummary_API_Wrapper.GetDetailKP1_Model> {
        public Integer compare(BristarSummary_API_Wrapper.GetDetailKP1_Model a, BristarSummary_API_Wrapper.GetDetailKP1_Model b) {
            Integer aOverSla = Integer.valueOf(a.gapTerhadapSla);
            Integer bOverSla = Integer.valueOf(b.gapTerhadapSla);
            
            return aOverSla - bOverSla; // Descending order
        }
    }

    public static String returnAPIKP1(BristarSummary_API_Wrapper.GetResponseKP1_Model jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }

    private static String processDetailDataRO(String query, Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String region, String mainBranch, String branch, String startdate, String endDate, Integer page, Integer pageSize, String statusTicket) {
        BristarSummary_API_Wrapper.GetResponseRO3_Model jres = new BristarSummary_API_Wrapper.GetResponseRO3_Model();
        List<BristarSummary_API_Wrapper.GetDetailRO3_Model> ticketSummaryList = new List<BristarSummary_API_Wrapper.GetDetailRO3_Model>();
        

        // First, get the valid BranchCode__c values from Branch_Unit__c
        Set<String> validBranchCodes = new Set<String>();
        for(Branch_Unit__c bu : [SELECT BranchCode__c 
                                FROM Branch_Unit__c 
                                WHERE Uker_type__c != 'RO' AND Region__c != 'KP'
                                AND BranchCode__c != null]) {
            validBranchCodes.add(bu.BranchCode__c);
        }

        // Remove any potential trailing spaces from the original query
        query = query.trim();   

        // Remove the ORDER BY clause if it exists (we'll add it back later)
        String orderByPattern = '(?i)\\s+ORDER\\s+BY\\s+.*$';
        query = query.replaceAll(orderByPattern, '');

         // Add the branch code filter
        List<String> validBranchCodesList = new List<String>(validBranchCodes);
        String branchCodeFilter = ' AND Branch_Code__c IN :validBranchCodesList';

        // Build the order and optional pagination clause
        String orderClause = ' ORDER BY Date__c';
        String paginationClause = '';

        // Only add pagination if both page and pageSize are provided
        if (page != null && pageSize != null) {
            Integer offset = (page - 1) * pageSize;
            paginationClause = ' LIMIT :pageSize OFFSET :offset';
        }else {
            paginationClause = ' LIMIT 50';
        }

        // Combine the query
        String finalQuery = query + branchCodeFilter + orderClause + paginationClause;

        System.debug('Final Query: ' + finalQuery);

        try {
            List<Case> cases = Database.query(finalQuery);
            
            Schema.DescribeFieldResult f = Case.Status.getDescribe();
            List<Schema.PicklistEntry> p = f.getPicklistValues();
            Map<String, String> mapstatus = new Map<String, String>();
            for(Schema.PicklistEntry pck: p) {
                mapstatus.put(pck.getValue(), pck.getLabel());
            }
            
            for (Case cs : cases) {
                ticketSummaryList.add(createTicketModelRO(cs, mapstatus.get(cs.Status)));
            }
            
            // Sort the ticketSummaryList
            ticketSummaryList.sort(new TotalRO3Comparator());
            
            jres.ticketSummary = ticketSummaryList;
            jres.area = area;
            jres.region = region;
            jres.regionDesc = cases.isEmpty() ? '' : cases[0].Region_Description__c;
            jres.mainBranch = mainBranch;
            jres.mainBranchDesc = cases.isEmpty() ? '' : cases[0].Main_Branch_Description__c;
            jres.branch = branch;
            jres.branchDesc = cases.isEmpty() ? '' : cases[0].Branch_Unit_Name__c;
            
            // String validBranchCodesStr = '\'' + String.join(new List<String>(validBranchCodes), '\',\'') + '\'';
            String conditions = 'region__c = \'' + String.escapeSingleQuotes(region) + '\' AND ' +
                            'mainBranch__c = \'' + String.escapeSingleQuotes(mainBranch) + '\' AND ' +
                            'branch__c = \'' + String.escapeSingleQuotes(branch) + '\' AND ' +
                            'area__c != \'KP00\' AND ' +
                            'region__c != \'KP\' AND ' +
                            'date__c >= ' + startDate + ' AND ' +
                            'date__c <= ' + endDate;
            
            System.debug('Conditions string: ' + conditions);
            
            calculateSummaryDataRO(jres, conditions, page, pageSize, statusTicket);
            
            SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
            jres.responseCode = rc?.Response_Code__c;
            jres.responseMessage = rc?.Description__c;
            
        } catch(Exception e) {
            System.debug('Error executing query: ' + e.getMessage());
            SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Error');
            jres.responseCode = rc?.Response_Code__c;
            jres.responseMessage = e.getMessage();
        }
        
        return BristarSummary_API_Ctrl.returnAPIRO3(jres);
    }

    // Comparator class remains the same
    public class TotalRO3Comparator implements Comparator<BristarSummary_API_Wrapper.GetDetailRO3_Model> {
        public Integer compare(BristarSummary_API_Wrapper.GetDetailRO3_Model a, BristarSummary_API_Wrapper.GetDetailRO3_Model b) {
            Integer aOverSla = Integer.valueOf(a.gapTerhadapSla);
            Integer bOverSla = Integer.valueOf(b.gapTerhadapSla);
            
            return aOverSla - bOverSla; // Descending order
        }
    }

    public static String returnAPIRO3(BristarSummary_API_Wrapper.GetResponseRO3_Model jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }

    private static void calculateSummaryDataKP(BristarSummary_API_Wrapper.GetResponseKP1_Model jres, String conditions, Integer page, Integer pageSize, String status) {
        // Retrieve all cases matching the cost center

        System.debug('conditions :'+conditions);

        List<Bristar_Summary__c> bs = Database.query('SELECT Id, openTicket__c, closedTicket__c, onSla__c, overSla__c, onSlaOpen__c, overSlaOpen__c, onSlaClosed__c, overSlaClosed__c ' +
                                      'FROM Bristar_Summary__c ' +
                                      'WHERE ' + conditions);
    
        Integer openTicketCount = 0; 
        Integer closedTicketCount = 0; 
        Integer overSlaCount = 0;
        Integer onSlaCount = 0;

        System.debug('Counting Case :'+bs);
        
        for (Bristar_Summary__c cs : bs) {
            if (String.isNotBlank(status)) {
                if(status == 'OPEN'){
                    overSlaCount = overSlaCount + Integer.valueOf(cs.overSlaOpen__c);
                    onSlaCount = onSlaCount + Integer.valueOf(cs.onSlaOpen__c);
                    openTicketCount = openTicketCount + Integer.valueOf(cs.openTicket__c);
                    closedTicketCount = closedTicketCount;
                } else if(status == 'CLOSED') {
                    overSlaCount = overSlaCount + Integer.valueOf(cs.overSlaClosed__c);
                    onSlaCount = onSlaCount + Integer.valueOf(cs.onSlaClosed__c);
                    closedTicketCount = closedTicketCount + Integer.valueOf(cs.closedTicket__c);
                    openTicketCount = openTicketCount;
                }
            } else {
                openTicketCount = openTicketCount + Integer.valueOf(cs.openTicket__c);
                closedTicketCount = closedTicketCount + Integer.valueOf(cs.closedTicket__c);
                overSlaCount = overSlaCount + Integer.valueOf(cs.overSla__c);
                onSlaCount = onSlaCount + Integer.valueOf(cs.onSla__c);
            }
        }
        
        jres.openTicket = String.valueOf(openTicketCount);
        jres.closedTicket = String.valueOf(closedTicketCount);
        jres.overSla = String.valueOf(overSlaCount);
        jres.onSLa = String.valueOf(onSlaCount);
    }

    private static void calculateSummaryDataRO(BristarSummary_API_Wrapper.GetResponseRO3_Model jres, String conditions, Integer page, Integer pageSize, String status) {
        
        List<Bristar_Summary__c> bs = Database.query('SELECT Id, openTicket__c, closedTicket__c, onSla__c, overSla__c, onSlaOpen__c, overSlaOpen__c, onSlaClosed__c, overSlaClosed__c ' +
                                      'FROM Bristar_Summary__c ' +
                                      'WHERE ' + conditions);
    
        Integer openTicketCount = 0; 
        Integer closedTicketCount = 0; 
        Integer overSlaCount = 0;
        Integer onSlaCount = 0;

        System.debug('Counting Case :'+bs);
        
        for (Bristar_Summary__c cs : bs) {
            if (String.isNotBlank(status)) {
                if(status == 'OPEN'){
                    overSlaCount = overSlaCount + Integer.valueOf(cs.overSlaOpen__c);
                    onSlaCount = onSlaCount + Integer.valueOf(cs.onSlaOpen__c);
                    openTicketCount = openTicketCount + Integer.valueOf(cs.openTicket__c);
                    closedTicketCount = closedTicketCount;
                } else if(status == 'CLOSED') {
                    overSlaCount = overSlaCount + Integer.valueOf(cs.overSlaClosed__c);
                    onSlaCount = onSlaCount + Integer.valueOf(cs.onSlaClosed__c);
                    closedTicketCount = closedTicketCount + Integer.valueOf(cs.closedTicket__c);
                    openTicketCount = openTicketCount;
                }
            } else {
                openTicketCount = openTicketCount + Integer.valueOf(cs.openTicket__c);
                closedTicketCount = closedTicketCount + Integer.valueOf(cs.closedTicket__c);
                overSlaCount = overSlaCount + Integer.valueOf(cs.overSla__c);
                onSlaCount = onSlaCount + Integer.valueOf(cs.onSla__c);
            }
        }
        
        jres.openTicket = String.valueOf(openTicketCount);
        jres.closedTicket = String.valueOf(closedTicketCount);
        jres.overSla = String.valueOf(overSlaCount);
        jres.onSLa = String.valueOf(onSlaCount);
    }

    public static BristarSummary_API_Wrapper.GetDetailKP1_Model createTicketModelKP(Case cs, String status) {
        BristarSummary_API_Wrapper.GetDetailKP1_Model ticket = new BristarSummary_API_Wrapper.GetDetailKP1_Model();
        ticket.caseNumber = cs.Case_Number__c != null ? cs.Case_Number__c : '';
        ticket.createdTime = cs.CreatedDate != null ? String.valueOf(cs.CreatedDate) : '';
        ticket.closedTime = cs.ClosedDate != null ? String.valueOf(cs.ClosedDate) : '';
        if(cs.Status == 'Returned'){
            ticket.status = cs.Status;
        }else{
            ticket.status = status;
        }
        ticket.caseType = cs.SCC_Call_Type__r.Name != null ? cs.SCC_Call_Type__r.Name : '';
        ticket.caseDescription = cs.SCC_Call_Type__r.SSC_Case_Description__c != null ? cs.SCC_Call_Type__r.SSC_Case_Description__c : '';
        ticket.slaSaatIni = cs.SLA_saat_ini__c != null ? String.valueOf(cs.SLA_saat_ini__c) : '';
        ticket.targetSla = cs.Total_SLA_2__c != null ? String.valueOf(cs.Total_SLA_2__c) : '';
        ticket.gapTerhadapSla = cs.Gap_Terhadap_SLA__c != null ? String.valueOf(cs.Gap_Terhadap_SLA__c) : '';
        return ticket;
    }

    public static BristarSummary_API_Wrapper.GetDetailRO3_Model createTicketModelRO(Case cs, String status) {
        BristarSummary_API_Wrapper.GetDetailRO3_Model ticket = new BristarSummary_API_Wrapper.GetDetailRO3_Model();
        ticket.caseNumber = cs.Case_Number__c != null ? cs.Case_Number__c : '';
        ticket.createdTime = cs.CreatedDate != null ? String.valueOf(cs.CreatedDate) : '';
        ticket.closedTime = cs.ClosedDate != null ? String.valueOf(cs.ClosedDate) : '';
        if(cs.Status == 'Returned'){
            ticket.status = cs.Status;
        }else{
            ticket.status = status;
        }
        ticket.caseType = cs.SCC_Call_Type__r.Name != null ? cs.SCC_Call_Type__r.Name : '';
        ticket.caseDescription = cs.SCC_Call_Type__r.SSC_Case_Description__c != null ? cs.SCC_Call_Type__r.SSC_Case_Description__c : '';
        ticket.slaSaatIni = cs.SLA_saat_ini__c != null ? String.valueOf(cs.SLA_saat_ini__c) : '';
        ticket.targetSla = cs.Total_SLA_2__c != null ? String.valueOf(cs.Total_SLA_2__c) : '';
        ticket.gapTerhadapSla = cs.Gap_Terhadap_SLA__c != null ? String.valueOf(cs.Gap_Terhadap_SLA__c) : '';
        return ticket;
    }

    private static String createErrorResponse(SCC_Custom_API_Response_Code__mdt rc) {
        BristarSummary_API_Wrapper.GetResponseModel jres = new BristarSummary_API_Wrapper.GetResponseModel();
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
        return BristarSummary_API_Ctrl.returnAPI(jres);
    }

    public static String returnAPI(BristarSummary_API_Wrapper.GetResponseModel jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }
}