public with sharing class BristarSummary_API_Ctrl {
    public static String getBristarSummary(BristarSummary_API_Wrapper.GetRequest_Model jreq) {
        //BristarSummary_API_Wrapper.GetRequest_Model jreq = (BristarSummary_API_Wrapper.GetRequest_Model)JSON.deserialize(jsonRequest, BristarSummary_API_Wrapper.GetRequest_Model.class);
        
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        SCC_Custom_API_Response_Code__mdt rc = new SCC_Custom_API_Response_Code__mdt();

        if (String.isBlank(jreq.startDate) || String.isBlank(jreq.endDate) || String.isBlank(jreq.area)) {
            rc = maprc?.get('Mandatory');
            return createErrorResponse(rc);
        }
        Date strDate = Date.valueOf(jreq.startDate);
        Date endDate = Date.valueOf(jreq.endDate);

        List<String> conditions = new List<String>();
        conditions.add('Date__c >= ' + jreq.startDate + ' AND Date__c <= ' + jreq.endDate + 'AND Status != \'Cancelled\' AND Status != \'Disconnected\'');
        String flag = '';
        String orderBy = '';
        String status='ALL';
        // Check if status ticket is not empty
        if (String.isNotBlank(jreq.statusTicket)) {
            if (jreq.statusTicket == 'OPEN') {
                status = 'OPEN';
                conditions.add('IsClosed__c = false');
            } else if (jreq.statusTicket == 'CLOSED') {
                conditions.add('IsClosed__c = true');
                status = 'CLOSED';
            }else{
                rc = maprc?.get('Data_Not_Found');
                return createErrorResponse(rc);
            }
        }
        // Check if Area is KP or RO
        if(String.isNotBlank(jreq.area) && jreq.area == 'KP' && jreq.region == ''){
            conditions.add('Area__c = \'KP00\'');
            conditions.add('Cost_Center__c != null');
            orderBy = 'Date__c';
            flag = 'KP';
        }else if(String.isNotBlank(jreq.area) && jreq.area == 'RO' && jreq.costCenter == ''){
            conditions.add('Area__c != \'KP00\'');
            conditions.add('Region__c != null');
            conditions.add('Region__c != \'KP\'');
            orderBy = 'Date__c';
            flag = 'RO';
        }else{
            rc = maprc?.get('Data_Not_Found');
            return createErrorResponse(rc);
        }

        // Second condition: Check if costCenter is not empty
        if (String.isNotBlank(jreq.costCenter)) {
            conditions.add('Cost_Center__c = \''+String.escapeSingleQuotes(jreq.costCenter)+'\'');
            flag = 'KP1';
            orderBy = 'Date__c';
        }

        // Third condition: Check if region is not empty
        if (String.isNotBlank(jreq.region) && jreq.costCenter == '') {
            conditions.add('Region__c = \''+String.escapeSingleQuotes(jreq.region)+'\'');
            conditions.add('Main_Branch__c != null');
            flag = 'RO1';
            orderBy = 'Date__c';
        }

        // Fourth condition: Check if mainBranch is not empty
        if (String.isNotBlank(jreq.mainBranch) && jreq.costCenter == '') {
            conditions.add('Main_Branch__c = \''+String.escapeSingleQuotes(jreq.mainBranch)+'\'');
            conditions.add('Branch_Code__c != null');
            flag = 'RO2';
            orderBy = 'Date__c';
        }

        // Five condition: Check if branch is not empty
        if (String.isNotBlank(jreq.branch) && jreq.costCenter == '') {
            conditions.add('Branch_Code__c = \''+String.escapeSingleQuotes(jreq.branch)+'\'');
            flag = 'RO3';
            orderBy = 'Date__c';
        }

        String query = buildQuery(conditions, orderBy);
        
        if (String.isBlank(query)) {
            rc = maprc?.get('Data_Not_Found');
            return createErrorResponse(rc);
        }

        Integer page = String.isNotBlank(jreq.page) ? Integer.valueOf(jreq.page) : null;
        Integer pageSize = String.isNotBlank(jreq.lmt) ? Integer.valueOf(jreq.lmt) : null;

        if(flag == 'KP'){
            return processSummaryDataKP(maprc, jreq.area, status, jreq.startDate, jreq.endDate);
        }else if (flag == 'KP1'){
            return processDetailDataKP(query, maprc, jreq.area, jreq.costCenter, jreq.startDate, jreq.endDate, page, pageSize, jreq.statusTicket);
        }else if (flag == 'RO'){
            return processSummaryDataRO(maprc, jreq.area, status, jreq.startDate, jreq.endDate);
        }else if(flag == 'RO1'){
            return processSummaryDataRO1(maprc, jreq.area, jreq.region, status, jreq.startDate, jreq.endDate);
        }else if(flag == 'RO2'){
            return processSummaryDataRO2(maprc, jreq.area, jreq.region, jreq.mainBranch, status, jreq.startDate, jreq.endDate);
        }else if(flag == 'RO3'){
            return processDetailDataRO(query, maprc, jreq.area, jreq.region, jreq.mainBranch, jreq.branch, jreq.startDate, jreq.endDate, page, pageSize, jreq.statusTicket);
        }else{
            rc = maprc?.get('Data_Not_Found');
            return createErrorResponse(rc);
        }
    }

    private static String buildQuery(List<String> conditions, String orderBy) {
        String fields = 'Id, Area__c, Date__c, IsClosed__c, Cost_Center__c, SLA_saat_ini__c, Total_SLA_2__c, Gap_Terhadap_SLA__c, ' +
                    'ClosedDate, Description, Status, CreatedDate, Case_Number__c, Region__c, Region_Name__c, Main_Branch__c, ' +
                    'Main_Branch_Description__c, Branch_Code__c, Within_Target_SLA__c, Branch_Unit_Name__c, ' +
                    'Cost_Center_Description__c, SCC_Call_Type__r.Name, SCC_Call_Type__r.SSC_Case_Description__c';
    
        // Ensure conditions list is not empty
        if (conditions == null || conditions.isEmpty()) {
            return null;
        }
        
        String whereClause = String.join(conditions, ' AND ');
        String query = 'SELECT ' + fields + ' FROM Case WHERE ' + whereClause;
        
        // Add ORDER BY only if orderBy is not blank
        if (String.isNotBlank(orderBy)) {
            query += ' ORDER BY ' + orderBy;
        }
        
        System.debug('Initial Query: ' + query);
        return query;
    }

    public static String processSummaryDataKP(Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String status, String startDate, String endDate) {
        // Initialize the response wrapper
        BristarSummary_API_Wrapper.GetResponseKP_Model jres = new BristarSummary_API_Wrapper.GetResponseKP_Model();
        List<BristarSummary_API_Wrapper.GetDetailKP_Model> divisionSummaryList = new List<BristarSummary_API_Wrapper.GetDetailKP_Model>();

        // Base condition for case queries
        String caseBaseCondition = 
            'Area__c = \'KP00\' ' +
            'AND Date__c >= '+startDate+' ' +
            'AND Date__c <= '+endDate +' ' +
            'AND Status IN (\'New\',\'Waiting Document\',\'Working\',\'Escalated\',\'Closed\') ' +
            'AND Cost_Center__c != null ';
    
        // Execute aggregate queries
        List<AggregateResult> open = getCaseAggregateResultsKP('', false, caseBaseCondition);
        List<AggregateResult> closed = getCaseAggregateResultsKP('', true,caseBaseCondition);
        List<AggregateResult> onSlaOpen = getCaseAggregateResultsKP(' AND Within_Target_SLA__c = \'Sesuai SLA\'', false, caseBaseCondition);
        List<AggregateResult> overSlaOpen = getCaseAggregateResultsKP(' AND Within_Target_SLA__c = \'Melebihi SLA\'', false, caseBaseCondition);
        List<AggregateResult> onSlaClosed = getCaseAggregateResultsKP(' AND Within_Target_SLA__c = \'Sesuai SLA\'', true, caseBaseCondition);
        List<AggregateResult> overSlaClosed = getCaseAggregateResultsKP(' AND Within_Target_SLA__c = \'Melebihi SLA\'', true, caseBaseCondition);
        List<AggregateResult> onSla = getCaseAggregateResultsKP(' AND Within_Target_SLA__c = \'Sesuai SLA\'', null,caseBaseCondition);
        List<AggregateResult> overSla = getCaseAggregateResultsKP(' AND Within_Target_SLA__c = \'Melebihi SLA\'', null,caseBaseCondition);

        // Fetch master list of cost centers
        List<AggregateResult> masterResults = [
            SELECT Cost_Center__c, Cost_Center_Description__c
            FROM Orgeh__c
            WHERE Cost_Center__c != null
            GROUP BY Cost_Center__c, Cost_Center_Description__c
        ];

        // Create maps for efficient lookups
        Map<String, Integer> openCountMap = createCountMapKP(open);
        Map<String, Integer> closedCountMap = createCountMapKP(closed);
        Map<String, Integer> onSlaCountOpenMap = createCountMapKP(onSlaOpen);
        Map<String, Integer> overSlaCountOpenMap = createCountMapKP(overSlaOpen);
        Map<String, Integer> onSlaCountClosedMap = createCountMapKP(onSlaClosed);
        Map<String, Integer> overSlaCountClosedMap = createCountMapKP(overSlaClosed);
        Map<String, Integer> onSlaCountMap = createCountMapKP(onSla);
        Map<String, Integer> overSlaCountMap = createCountMapKP(overSla);
    
        for (AggregateResult result : masterResults) {
            BristarSummary_API_Wrapper.GetDetailKP_Model wrapper = new BristarSummary_API_Wrapper.GetDetailKP_Model();
        
            // Set basic cost center details
            wrapper.costCenter = (String) result.get('Cost_Center__c');
            wrapper.costCenterDesc = (String) result.get('Cost_Center_Description__c');
            
            // Check status
            if(status == 'OPEN'){
                // Lookup and set counts from other aggregate results
                wrapper.openTicket = String.valueOf(openCountMap.get(wrapper.costCenter) != null ? openCountMap.get(wrapper.costCenter) : 0);
                wrapper.closedTicket = '0';
                wrapper.onSla = String.valueOf(onSlaCountOpenMap.get(wrapper.costCenter) != null ? onSlaCountOpenMap.get(wrapper.costCenter) : 0);
                wrapper.overSla = String.valueOf(overSlaCountOpenMap.get(wrapper.costCenter) != null ? overSlaCountOpenMap.get(wrapper.costCenter) : 0);
            }else if(status == 'CLOSED'){
                // Lookup and set counts from other aggregate results
                wrapper.openTicket = '0';
                wrapper.closedTicket = String.valueOf(closedCountMap.get(wrapper.costCenter) != null ? closedCountMap.get(wrapper.costCenter) : 0);
                wrapper.onSla = String.valueOf(onSlaCountClosedMap.get(wrapper.costCenter) != null ? onSlaCountClosedMap.get(wrapper.costCenter) : 0);
                wrapper.overSla = String.valueOf(overSlaCountClosedMap.get(wrapper.costCenter) != null ? overSlaCountClosedMap.get(wrapper.costCenter) : 0);
            }else if(status == 'ALL'){
                system.debug('Run Status ALL');
                // Lookup and set counts from other aggregate results
                wrapper.openTicket = String.valueOf(openCountMap.get(wrapper.costCenter) != null ? openCountMap.get(wrapper.costCenter) : 0);
                wrapper.closedTicket = String.valueOf(closedCountMap.get(wrapper.costCenter) != null ? closedCountMap.get(wrapper.costCenter) : 0);
                wrapper.onSla = String.valueOf(onSlaCountMap.get(wrapper.costCenter) != null ? onSlaCountMap.get(wrapper.costCenter) : 0);
                wrapper.overSla = String.valueOf(overSlaCountMap.get(wrapper.costCenter) != null ? overSlaCountMap.get(wrapper.costCenter) : 0);
            }
            divisionSummaryList.add(wrapper);
        }
    
        // Sort the summary list
        divisionSummaryList.sort(new TotalKPComparator());
    
        // Set response details
        jres.divisionSummary = divisionSummaryList;
        jres.area = area;
    
        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
    
        // Return the final API response
        return BristarSummary_API_Ctrl.returnAPIKP(jres);
    }

    // Helper method to fetch aggregate results dynamically
    public static List<AggregateResult> getCaseAggregateResultsKP(String additionalCondition, Boolean isClosed, String caseBaseCondition) {
        // Start building the query
        String query = 'SELECT Cost_Center__c, Cost_Center_Description__c, COUNT(Id) recordCount ' +
            'FROM Case ' +
            'WHERE ' + caseBaseCondition;

        // Add the IsClosed condition only if isClosed is not null
        if (isClosed != null) {
        query += ' AND IsClosed = :isClosed';
        }

        // Add any additional conditions
        if (!String.isEmpty(additionalCondition)) {
        query += additionalCondition;
        }

        // Finalize the query with grouping and ordering
        query += ' GROUP BY Cost_Center__c, Cost_Center_Description__c ' +
        'ORDER BY COUNT(Id) DESC';

        system.debug('query kp :'+query);

        // Execute the query
        return Database.query(query);
    }

    // Helper method to create a map of Cost Center to Record Count
    private static Map<String, Integer> createCountMapKP(List<AggregateResult> aggregateResults) {
        Map<String, Integer> countMap = new Map<String, Integer>();
        
        for (AggregateResult result : aggregateResults) {
            String costCenter = (String) result.get('Cost_Center__c');
            Integer recordCount = (Integer) result.get('recordCount');
            countMap.put(costCenter, recordCount);
        }
        
        return countMap;
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

    private static String processSummaryDataRO(Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String status, String startdate, String endDate) {
        BristarSummary_API_Wrapper.GetResponseRO_Model jres = new BristarSummary_API_Wrapper.GetResponseRO_Model();
        // List<BristarSummary_API_Wrapper.GetDetailRO_Model> regionSummaryList = new List<BristarSummary_API_Wrapper.GetDetailRO_Model>();
        List<BristarSummary_API_Wrapper.GetDetailRO_Model> regionSummaryMap = new List<BristarSummary_API_Wrapper.GetDetailRO_Model>();

        // Base condition for case queries
        String caseBaseCondition = 
            'Area__c != \'KP00\' ' +
            'AND Region__c != null ' +
            'AND Main_branch__c != null ' +
            'AND CodeBranch__c != null ' +
            'AND Date__c >= '+startdate+' ' +
            'AND Date__c <= '+endDate+' ' +
            'AND Status IN (\'New\',\'Waiting Document\',\'Working\',\'Escalated\',\'Closed\')';
    
        // Execute aggregate queries
        List<AggregateResult> open = getCaseAggregateResultsRO('', false, caseBaseCondition);
        List<AggregateResult> closed = getCaseAggregateResultsRO('', true,caseBaseCondition);
        List<AggregateResult> onSlaOpen = getCaseAggregateResultsRO(' AND Within_Target_SLA__c = \'Sesuai SLA\'', false, caseBaseCondition);
        List<AggregateResult> overSlaOpen = getCaseAggregateResultsRO(' AND Within_Target_SLA__c = \'Melebihi SLA\'', false, caseBaseCondition);
        List<AggregateResult> onSlaClosed = getCaseAggregateResultsRO(' AND Within_Target_SLA__c = \'Sesuai SLA\'', true, caseBaseCondition);
        List<AggregateResult> overSlaClosed = getCaseAggregateResultsRO(' AND Within_Target_SLA__c = \'Melebihi SLA\'', true, caseBaseCondition);
        List<AggregateResult> onSla = getCaseAggregateResultsRO(' AND Within_Target_SLA__c = \'Sesuai SLA\'', null,caseBaseCondition);
        List<AggregateResult> overSla = getCaseAggregateResultsRO(' AND Within_Target_SLA__c = \'Melebihi SLA\'', null,caseBaseCondition);

        List<AggregateResult> masterResults = [SELECT Region__c, Region_Name__c
                                        FROM Branch_Unit__c
                                        WHERE Region__c != null AND Uker_type__c != 'RO' AND Region__c != 'KP' AND Kode_Cabang__c != null AND BranchCode__c != null
                                        GROUP BY Region__c, Region_Name__c];
        
        // Create maps to efficiently look up counts
        Map<String, Integer> openCountMap = createCountMapRO(open);
        Map<String, Integer> closedCountMap = createCountMapRO(closed);
        Map<String, Integer> onSlaCountOpenMap = createCountMapRO(onSlaOpen);
        Map<String, Integer> overSlaCountOpenMap = createCountMapRO(overSlaOpen);
        Map<String, Integer> onSlaCountClosedMap = createCountMapRO(onSlaClosed);
        Map<String, Integer> overSlaCountClosedMap = createCountMapRO(overSlaClosed);
        Map<String, Integer> onSlaCountMap = createCountMapRO(onSla);
        Map<String, Integer> overSlaCountMap = createCountMapRO(overSla);

        for (AggregateResult result : masterResults) {
            BristarSummary_API_Wrapper.GetDetailRO_Model wrapper = new BristarSummary_API_Wrapper.GetDetailRO_Model();
        
            // Set basic cost center details
            wrapper.region = (String) result.get('Region__c');
            wrapper.regionDesc = (String) result.get('Region_Name__c');
            
            // Check status
            if(status == 'OPEN'){
                // Lookup and set counts from other aggregate results
                wrapper.openTicket = String.valueOf(openCountMap.get(wrapper.region) != null ? openCountMap.get(wrapper.region) : 0);
                wrapper.closedTicket = '0';
                wrapper.onSla = String.valueOf(onSlaCountOpenMap.get(wrapper.region) != null ? onSlaCountOpenMap.get(wrapper.region) : 0);
                wrapper.overSla = String.valueOf(overSlaCountOpenMap.get(wrapper.region) != null ? overSlaCountOpenMap.get(wrapper.region) : 0);
            }else if(status == 'CLOSED'){
                // Lookup and set counts from other aggregate results
                wrapper.openTicket = '0';
                wrapper.closedTicket = String.valueOf(closedCountMap.get(wrapper.region) != null ? closedCountMap.get(wrapper.region) : 0);
                wrapper.onSla = String.valueOf(onSlaCountClosedMap.get(wrapper.region) != null ? onSlaCountClosedMap.get(wrapper.region) : 0);
                wrapper.overSla = String.valueOf(overSlaCountClosedMap.get(wrapper.region) != null ? overSlaCountClosedMap.get(wrapper.region) : 0);
            }else if(status == 'ALL'){
                // Lookup and set counts from other aggregate results
                wrapper.openTicket = String.valueOf(openCountMap.get(wrapper.region) != null ? openCountMap.get(wrapper.region) : 0);
                wrapper.closedTicket = String.valueOf(closedCountMap.get(wrapper.region) != null ? closedCountMap.get(wrapper.region) : 0);
                wrapper.onSla = String.valueOf(onSlaCountMap.get(wrapper.region) != null ? onSlaCountMap.get(wrapper.region) : 0);
                wrapper.overSla = String.valueOf(overSlaCountMap.get(wrapper.region) != null ? overSlaCountMap.get(wrapper.region) : 0);
            }
            regionSummaryMap.add(wrapper);
        }

        // Sort divisionSummary by totalActivities (descending order)
        regionSummaryMap.sort(new TotalROComparator());

        jres.regionSummary = regionSummaryMap;
        jres.area = area;

        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;

        return BristarSummary_API_Ctrl.returnAPIRO(jres);
    }

    // Helper method to fetch aggregate results dynamically
    public static List<AggregateResult> getCaseAggregateResultsRO(String additionalCondition, Boolean isClosed, String caseBaseCondition) {
        // Start building the query
        String query = 'SELECT Region__c, COUNT(Id) recordCount ' +
            'FROM Case ' +
            'WHERE ' + caseBaseCondition;

        // Add the IsClosed condition only if isClosed is not null
        if (isClosed != null) {
        query += ' AND IsClosed = :isClosed';
        }

        // Add any additional conditions
        if (!String.isEmpty(additionalCondition)) {
        query += additionalCondition;
        }

        // Finalize the query with grouping and ordering
        query += ' GROUP BY Region__c ' +
        'ORDER BY COUNT(Id) DESC';

        system.debug('query kp :'+query);

        // Execute the query
        return Database.query(query);
    }

    // Helper method to create a map of Cost Center to Record Count
    private static Map<String, Integer> createCountMapRO(List<AggregateResult> aggregateResults) {
        Map<String, Integer> countMap = new Map<String, Integer>();
        
        for (AggregateResult result : aggregateResults) {
            String region = (String) result.get('Region__c');
            Integer recordCount = (Integer) result.get('recordCount');
            countMap.put(region, recordCount);
        }
        
        return countMap;
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

    private static String processSummaryDataRO1(Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String region, String status, String startdate, String endDate) {
        BristarSummary_API_Wrapper.GetResponseRO1_Model jres = new BristarSummary_API_Wrapper.GetResponseRO1_Model();
        // List<BristarSummary_API_Wrapper.GetDetailRO1_Model> mainBranchSummaryList = new List<BristarSummary_API_Wrapper.GetDetailRO1_Model>();
        List<BristarSummary_API_Wrapper.GetDetailRO1_Model> mainBranchSummaryMap = new List<BristarSummary_API_Wrapper.GetDetailRO1_Model>();

        // Base condition for case queries
        String caseBaseCondition = 
            'Area__c != \'KP00\' ' +
            'AND Region__c != null ' +
            'AND Region__c = \''+region+'\' ' +
            'AND Main_branch__c != null ' +
            'AND CodeBranch__c != null ' +
            'AND Date__c >= '+startdate+' ' +
            'AND Date__c <= '+endDate+' ' +
            'AND Status IN (\'New\',\'Waiting Document\',\'Working\',\'Escalated\',\'Closed\')';
    
        // Execute aggregate queries
        List<AggregateResult> open = getCaseAggregateResultsRO1('', false, caseBaseCondition);
        List<AggregateResult> closed = getCaseAggregateResultsRO1('', true,caseBaseCondition);
        List<AggregateResult> onSlaOpen = getCaseAggregateResultsRO1(' AND Within_Target_SLA__c = \'Sesuai SLA\'', false, caseBaseCondition);
        List<AggregateResult> overSlaOpen = getCaseAggregateResultsRO1(' AND Within_Target_SLA__c = \'Melebihi SLA\'', false, caseBaseCondition);
        List<AggregateResult> onSlaClosed = getCaseAggregateResultsRO1(' AND Within_Target_SLA__c = \'Sesuai SLA\'', true, caseBaseCondition);
        List<AggregateResult> overSlaClosed = getCaseAggregateResultsRO1(' AND Within_Target_SLA__c = \'Melebihi SLA\'', true, caseBaseCondition);
        List<AggregateResult> onSla = getCaseAggregateResultsRO1(' AND Within_Target_SLA__c = \'Sesuai SLA\'', null,caseBaseCondition);
        List<AggregateResult> overSla = getCaseAggregateResultsRO1(' AND Within_Target_SLA__c = \'Melebihi SLA\'', null,caseBaseCondition);

        List<AggregateResult> masterResults = [SELECT Kode_Cabang__c, Nama_Cabang__c
                                        FROM Branch_Unit__c
                                        WHERE Kode_Cabang__c != null AND Region__c = : region AND Uker_type__c != 'RO' AND Region__c != 'KP' AND BranchCode__c != null
                                        GROUP BY Kode_Cabang__c, Nama_Cabang__c];

        // Create maps to efficiently look up counts
        Map<String, Integer> openCountMap = createCountMapRO1(open);
        Map<String, Integer> closedCountMap = createCountMapRO1(closed);
        Map<String, Integer> onSlaCountOpenMap = createCountMapRO1(onSlaOpen);
        Map<String, Integer> overSlaCountOpenMap = createCountMapRO1(overSlaOpen);
        Map<String, Integer> onSlaCountClosedMap = createCountMapRO1(onSlaClosed);
        Map<String, Integer> overSlaCountClosedMap = createCountMapRO1(overSlaClosed);
        Map<String, Integer> onSlaCountMap = createCountMapRO1(onSla);
        Map<String, Integer> overSlaCountMap = createCountMapRO1(overSla);

        for (AggregateResult result : masterResults) {
            BristarSummary_API_Wrapper.GetDetailRO1_Model wrapper = new BristarSummary_API_Wrapper.GetDetailRO1_Model();
        
            // Set basic cost center details
            wrapper.mainBranch = (String) result.get('Kode_Cabang__c');
            wrapper.MainBranchDesc = (String) result.get('Nama_Cabang__c');
            
            // Check status
            if(status == 'OPEN'){
                // Lookup and set counts from other aggregate results
                wrapper.openTicket = String.valueOf(openCountMap.get(wrapper.mainBranch) != null ? openCountMap.get(wrapper.mainBranch) : 0);
                wrapper.closedTicket = '0';
                wrapper.onSla = String.valueOf(onSlaCountOpenMap.get(wrapper.mainBranch) != null ? onSlaCountOpenMap.get(wrapper.mainBranch) : 0);
                wrapper.overSla = String.valueOf(overSlaCountOpenMap.get(wrapper.mainBranch) != null ? overSlaCountOpenMap.get(wrapper.mainBranch) : 0);
            }else if(status == 'CLOSED'){
                // Lookup and set counts from other aggregate results
                wrapper.openTicket = '0';
                wrapper.closedTicket = String.valueOf(closedCountMap.get(wrapper.mainBranch) != null ? closedCountMap.get(wrapper.mainBranch) : 0);
                wrapper.onSla = String.valueOf(onSlaCountClosedMap.get(wrapper.mainBranch) != null ? onSlaCountClosedMap.get(wrapper.mainBranch) : 0);
                wrapper.overSla = String.valueOf(overSlaCountClosedMap.get(wrapper.mainBranch) != null ? overSlaCountClosedMap.get(wrapper.mainBranch) : 0);
            }else if(status == 'ALL'){
                // Lookup and set counts from other aggregate results
                wrapper.openTicket = String.valueOf(openCountMap.get(wrapper.mainBranch) != null ? openCountMap.get(wrapper.mainBranch) : 0);
                wrapper.closedTicket = String.valueOf(closedCountMap.get(wrapper.mainBranch) != null ? closedCountMap.get(wrapper.mainBranch) : 0);
                wrapper.onSla = String.valueOf(onSlaCountMap.get(wrapper.mainBranch) != null ? onSlaCountMap.get(wrapper.mainBranch) : 0);
                wrapper.overSla = String.valueOf(overSlaCountMap.get(wrapper.mainBranch) != null ? overSlaCountMap.get(wrapper.mainBranch) : 0);
            }
            mainBranchSummaryMap.add(wrapper);
        }

        // Sort divisionSummary by totalActivities (descending order)
        mainBranchSummaryMap.sort(new TotalRO1Comparator());

        jres.mainBranchSummary = mainBranchSummaryMap;
        jres.area = area;

        jres.region = region;
        String regionDesc = [SELECT Region_Name__c FROM Branch_Unit__c WHERE Region__c = :region LIMIT 1].Region_Name__c;
        jres.regionDesc = regionDesc;

        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;

        return BristarSummary_API_Ctrl.returnAPIRO1(jres);
    }

    // Helper method to fetch aggregate results dynamically
    public static List<AggregateResult> getCaseAggregateResultsRO1(String additionalCondition, Boolean isClosed, String caseBaseCondition) {
         // Start building the query
         String query = 'SELECT Main_Branch__c, COUNT(Id) recordCount ' +
         'FROM Case ' +
         'WHERE ' + caseBaseCondition;

        // Add the IsClosed condition only if isClosed is not null
        if (isClosed != null) {
        query += ' AND IsClosed = :isClosed';
        }

        // Add any additional conditions
        if (!String.isEmpty(additionalCondition)) {
        query += additionalCondition;
        }

        // Finalize the query with grouping and ordering
        query += ' GROUP BY Main_Branch__c ' +
        'ORDER BY COUNT(Id) DESC';

        system.debug('query kp :'+query);

        // Execute the query
        return Database.query(query);
    }

    // Helper method to create a map of Cost Center to Record Count
    private static Map<String, Integer> createCountMapRO1(List<AggregateResult> aggregateResults) {
        Map<String, Integer> countMap = new Map<String, Integer>();
        
        for (AggregateResult result : aggregateResults) {
            String mainBranch = (String) result.get('Main_Branch__c');
            Integer recordCount = (Integer) result.get('recordCount');
            countMap.put(mainBranch, recordCount);
        }
        
        return countMap;
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

    private static String processSummaryDataRO2(Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String region, String mainBranch, String status, String startdate, String endDate) {
        BristarSummary_API_Wrapper.GetResponseRO2_Model jres = new BristarSummary_API_Wrapper.GetResponseRO2_Model();
        List<BristarSummary_API_Wrapper.GetDetailRO2_Model> branchSummaryMap = new List<BristarSummary_API_Wrapper.GetDetailRO2_Model>();

        // Base condition for case queries
        String caseBaseCondition = 
            'Area__c != \'KP00\' ' +
            'AND Region__c != null ' +
            'AND Region__c = \''+region+'\' ' +
            'AND Main_Branch__c = \''+mainBranch+'\' ' +
            'AND Main_branch__c != null ' +
            'AND CodeBranch__c != null ' +
            'AND Date__c >= '+startdate+' ' +
            'AND Date__c <= '+endDate+' ' +
            'AND Status IN (\'New\',\'Waiting Document\',\'Working\',\'Escalated\',\'Closed\')';
    
        // Execute aggregate queries
        List<AggregateResult> open = getCaseAggregateResultsRO2('', false, caseBaseCondition);
        List<AggregateResult> closed = getCaseAggregateResultsRO2('', true,caseBaseCondition);
        List<AggregateResult> onSlaOpen = getCaseAggregateResultsRO2(' AND Within_Target_SLA__c = \'Sesuai SLA\'', false, caseBaseCondition);
        List<AggregateResult> overSlaOpen = getCaseAggregateResultsRO2(' AND Within_Target_SLA__c = \'Melebihi SLA\'', false, caseBaseCondition);
        List<AggregateResult> onSlaClosed = getCaseAggregateResultsRO2(' AND Within_Target_SLA__c = \'Sesuai SLA\'', true, caseBaseCondition);
        List<AggregateResult> overSlaClosed = getCaseAggregateResultsRO2(' AND Within_Target_SLA__c = \'Melebihi SLA\'', true, caseBaseCondition);
        List<AggregateResult> onSla = getCaseAggregateResultsRO2(' AND Within_Target_SLA__c = \'Sesuai SLA\'', null,caseBaseCondition);
        List<AggregateResult> overSla = getCaseAggregateResultsRO2(' AND Within_Target_SLA__c = \'Melebihi SLA\'', null,caseBaseCondition);

        List<AggregateResult> masterResults = [SELECT Branch_Code__c, Name
                                        FROM Branch_Unit__c
                                        WHERE Kode_Cabang__c != null AND Branch_Code__c != null AND Region__c = : region AND Kode_Cabang__c = : mainBranch AND Uker_type__c != 'RO'
                                        GROUP BY Branch_Code__c, Name];

        // Create maps to efficiently look up counts
        Map<String, Integer> openCountMap = createCountMapRO2(open);
        Map<String, Integer> closedCountMap = createCountMapRO2(closed);
        Map<String, Integer> onSlaCountOpenMap = createCountMapRO2(onSlaOpen);
        Map<String, Integer> overSlaCountOpenMap = createCountMapRO2(overSlaOpen);
        Map<String, Integer> onSlaCountClosedMap = createCountMapRO2(onSlaClosed);
        Map<String, Integer> overSlaCountClosedMap = createCountMapRO2(overSlaClosed);
        Map<String, Integer> onSlaCountMap = createCountMapRO2(onSla);
        Map<String, Integer> overSlaCountMap = createCountMapRO2(overSla);

        for (AggregateResult result : masterResults) {
            BristarSummary_API_Wrapper.GetDetailRO2_Model wrapper = new BristarSummary_API_Wrapper.GetDetailRO2_Model();
        
            // Set basic cost center details
            String branchCode = (String) result.get('Branch_Code__c');
            wrapper.branch = branchCode != null ? padLeft(branchCode, 5, '0') : '00000';
            wrapper.branchDesc = (String) result.get('Name');
            
            // Check status
            if(status == 'OPEN'){
                // Lookup and set counts from other aggregate results
                wrapper.openTicket = String.valueOf(openCountMap.get(wrapper.branch) != null ? openCountMap.get(wrapper.branch) : 0);
                wrapper.closedTicket = '0';
                wrapper.onSla = String.valueOf(onSlaCountOpenMap.get(wrapper.branch) != null ? onSlaCountOpenMap.get(wrapper.branch) : 0);
                wrapper.overSla = String.valueOf(overSlaCountOpenMap.get(wrapper.branch) != null ? overSlaCountOpenMap.get(wrapper.branch) : 0);
            }else if(status == 'CLOSED'){
                // Lookup and set counts from other aggregate results
                wrapper.openTicket = '0';
                wrapper.closedTicket = String.valueOf(closedCountMap.get(wrapper.branch) != null ? closedCountMap.get(wrapper.branch) : 0);
                wrapper.onSla = String.valueOf(onSlaCountClosedMap.get(wrapper.branch) != null ? onSlaCountClosedMap.get(wrapper.branch) : 0);
                wrapper.overSla = String.valueOf(overSlaCountClosedMap.get(wrapper.branch) != null ? overSlaCountClosedMap.get(wrapper.branch) : 0);
            }else if(status == 'ALL'){
                // Lookup and set counts from other aggregate results
                wrapper.openTicket = String.valueOf(openCountMap.get(wrapper.branch) != null ? openCountMap.get(wrapper.branch) : 0);
                wrapper.closedTicket = String.valueOf(closedCountMap.get(wrapper.branch) != null ? closedCountMap.get(wrapper.branch) : 0);
                wrapper.onSla = String.valueOf(onSlaCountMap.get(wrapper.branch) != null ? onSlaCountMap.get(wrapper.branch) : 0);
                wrapper.overSla = String.valueOf(overSlaCountMap.get(wrapper.branch) != null ? overSlaCountMap.get(wrapper.branch) : 0);
            }
            branchSummaryMap.add(wrapper);
        }

        // Sort divisionSummary by totalActivities (descending order)
        branchSummaryMap.sort(new TotalRO2Comparator());

        jres.branchSummary = branchSummaryMap;
        jres.area = area;
        jres.region = region;
        jres.regionDesc = [SELECT Region_Name__c, Nama_Cabang__c FROM Branch_Unit__c WHERE Region__c = :region AND Kode_Cabang__c = :mainBranch LIMIT 1].Region_Name__c;
        jres.mainBranch = mainBranch;
        jres.mainBranchDesc = [SELECT Region_Name__c, Nama_Cabang__c FROM Branch_Unit__c WHERE Region__c = :region AND Kode_Cabang__c = :mainBranch LIMIT 1].Nama_Cabang__c;

        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;

        return BristarSummary_API_Ctrl.returnAPIRO2(jres);
    }

    // Helper method to fetch aggregate results dynamically
    public static List<AggregateResult> getCaseAggregateResultsRO2(String additionalCondition, Boolean isClosed, String caseBaseCondition) {
        // Start building the query
        String query = 'SELECT CodeBranch__c, COUNT(Id) recordCount ' +
        'FROM Case ' +
        'WHERE ' + caseBaseCondition;

       // Add the IsClosed condition only if isClosed is not null
       if (isClosed != null) {
       query += ' AND IsClosed = :isClosed';
       }

       // Add any additional conditions
       if (!String.isEmpty(additionalCondition)) {
       query += additionalCondition;
       }

       // Finalize the query with grouping and ordering
       query += ' GROUP BY CodeBranch__c ' +
       'ORDER BY COUNT(Id) DESC';

       system.debug('query kp :'+query);

       // Execute the query
       return Database.query(query);
    }

    // Utility method for padding
    public static String padLeft(String input, Integer length, String padChar) {
        while (input.length() < length) {
            input = padChar + input;
        }
        return input;
    }

    // Helper method to create a map of Cost Center to Record Count
    private static Map<String, Integer> createCountMapRO2(List<AggregateResult> aggregateResults) {
        Map<String, Integer> countMap = new Map<String, Integer>();
        
        for (AggregateResult result : aggregateResults) {
            String branch = (String) result.get('CodeBranch__c');
            Integer recordCount = (Integer) result.get('recordCount');
            countMap.put(branch, recordCount);
        }
        
        return countMap;
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

    public static void updateDivisionSummaryKP(BristarSummary_API_Wrapper.GetDetailKP_Model divisionSummary, Case cs) {
        if (cs.IsClosed__c) {
            divisionSummary.closedTicket = String.valueOf(Integer.valueOf(divisionSummary.closedTicket) + 1);
        } else {
            divisionSummary.openTicket = String.valueOf(Integer.valueOf(divisionSummary.openTicket) + 1);
        }
        
        if (cs.Within_Target_SLA__c == 'Melebihi SLA') {
            divisionSummary.overSla = String.valueOf(Integer.valueOf(divisionSummary.overSla) + 1);
        } else if (cs.Within_Target_SLA__c == 'Sesuai SLA') {
            divisionSummary.onSla = String.valueOf(Integer.valueOf(divisionSummary.onSla) + 1);
        }
    }

    public static void updateRegionSummaryRO(BristarSummary_API_Wrapper.GetDetailRO_Model regionSummary, Case cs) {
        if (cs.IsClosed__c) {
            regionSummary.closedTicket = String.valueOf(Integer.valueOf(regionSummary.closedTicket) + 1);
        } else {
            regionSummary.openTicket = String.valueOf(Integer.valueOf(regionSummary.openTicket) + 1);
        }
        
        if (cs.Within_Target_SLA__c == 'Melebihi SLA') {
            regionSummary.overSla = String.valueOf(Integer.valueOf(regionSummary.overSla) + 1);
        } else if (cs.Within_Target_SLA__c == 'Sesuai SLA') {
            regionSummary.onSla = String.valueOf(Integer.valueOf(regionSummary.onSla) + 1);
        }
    }

    public static void updateMainBranchSummaryRO(BristarSummary_API_Wrapper.GetDetailRO1_Model mainBranchSummary, Case cs) {
        if (cs.IsClosed__c) {
            mainBranchSummary.closedTicket = String.valueOf(Integer.valueOf(mainBranchSummary.closedTicket) + 1);
        } else {
            mainBranchSummary.openTicket = String.valueOf(Integer.valueOf(mainBranchSummary.openTicket) + 1);
        }
        
        if (cs.Within_Target_SLA__c == 'Melebihi SLA') {
            mainBranchSummary.overSla = String.valueOf(Integer.valueOf(mainBranchSummary.overSla) + 1);
        } else if (cs.Within_Target_SLA__c == 'Sesuai SLA') {
            mainBranchSummary.onSla = String.valueOf(Integer.valueOf(mainBranchSummary.onSla) + 1);
        }
    }

    public static void updateBranchSummaryRO(BristarSummary_API_Wrapper.GetDetailRO2_Model branchSummary, Case cs) {
        if (cs.IsClosed__c) {
            branchSummary.closedTicket = String.valueOf(Integer.valueOf(branchSummary.closedTicket) + 1);
        } else {
            branchSummary.openTicket = String.valueOf(Integer.valueOf(branchSummary.openTicket) + 1);
        }
        
        if (cs.Within_Target_SLA__c == 'Melebihi SLA') {
            branchSummary.overSla = String.valueOf(Integer.valueOf(branchSummary.overSla) + 1);
        } else if (cs.Within_Target_SLA__c == 'Sesuai SLA') {
            branchSummary.onSla = String.valueOf(Integer.valueOf(branchSummary.onSla) + 1);
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
                cases = Database.query(query);
            } else {
                // If no pagination, just execute the query as is
                query += ' LIMIT 50000';
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

            String conditions ='';

            if (String.isNotBlank(statusTicket)) {
                if (statusTicket == 'OPEN') {
                    conditions = 'Status != \'Cancelled\' AND Status != \'Disconnected\' AND Isclosed = false AND Cost_Center__c = \'' + costCenter + '\' AND Area__c = \'KP00\' AND Date__c >= ' + startDate + ' AND Date__c <= ' + endDate;
                } else if (statusTicket == 'CLOSED') {
                    conditions = 'Status != \'Cancelled\' AND Status != \'Disconnected\' AND Isclosed = true AND Cost_Center__c = \'' + costCenter + '\' AND Area__c = \'KP00\' AND Date__c >= ' + startDate + ' AND Date__c <= ' + endDate;
                }
            }else{
                conditions = 'Status != \'Cancelled\' AND Status != \'Disconnected\' AND Cost_Center__c = \'' + costCenter + '\' AND Area__c = \'KP00\' AND Date__c >= ' + startDate + ' AND Date__c <= ' + endDate;
            }
            
            calculateSummaryDataKP(jres, conditions, page, pageSize);

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
        }else{
            paginationClause = ' LIMIT 50000';
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
            jres.regionDesc = cases.isEmpty() ? '' : cases[0].Region_Name__c;
            jres.mainBranch = mainBranch;
            jres.mainBranchDesc = cases.isEmpty() ? '' : cases[0].Main_Branch_Description__c;
            jres.branch = branch;
            jres.branchDesc = cases.isEmpty() ? '' : cases[0].Branch_Unit_Name__c;
            
            // Build conditions for calculateSummaryDataRO - Using string concatenation instead of String.format()
            String conStatus = '';
            if (String.isNotBlank(statusTicket)){
                if (statusTicket == 'OPEN'){
                    conStatus = ' AND IsClosed = false';
                } else if (statusTicket == 'CLOSED'){
                    conStatus = ' AND IsClosed = true';
                }
            }
            String validBranchCodesStr = '\'' + String.join(new List<String>(validBranchCodes), '\',\'') + '\'';
            String conditions = 'Region__c = \'' + String.escapeSingleQuotes(region) + '\' AND ' +
                            'Main_Branch__c = \'' + String.escapeSingleQuotes(mainBranch) + '\' AND ' +
                            'Branch_Code__c = \'' + String.escapeSingleQuotes(branch) + '\' AND ' +
                            'Area__c != \'KP00\' AND ' +
                            'Region__c != \'KP\' AND ' +
                            'Status != \'Cancelled\' AND ' +
                            'Status != \'Disconnected\' AND ' +
                            'Branch_Code__c IN (' + validBranchCodesStr + ') AND ' +
                            'Date__c >= ' + startDate + ' AND ' +
                            'Date__c <= ' + endDate + conStatus;
            
            System.debug('Conditions string: ' + conditions);
            
            calculateSummaryDataRO(jres, conditions, page, pageSize);
            
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

    private static void calculateSummaryDataKP(BristarSummary_API_Wrapper.GetResponseKP1_Model jres, String conditions, Integer page, Integer pageSize) {
        // Retrieve all cases matching the cost center

        System.debug('conditions :'+conditions);

        List<Case> cases = Database.query('SELECT Id, IsClosed, Within_Target_SLA__c, Area__c, Region__c ' +
                                      'FROM Case ' +
                                      'WHERE ' + conditions);
    
        Integer openTicketCount = 0; 
        Integer closedTicketCount = 0; 
        Integer overSlaCount = 0;
        Integer onSlaCount = 0;

        System.debug('Counting Case :'+cases);
        
        for (Case cs : cases) {
            if (cs.IsClosed) {
                closedTicketCount++;
            } else {
                openTicketCount++;
            }
            
            if (cs.Within_Target_SLA__c == 'Melebihi SLA') {
                overSlaCount++;
            } else if (cs.Within_Target_SLA__c == 'Sesuai SLA') {
                onSlaCount++;
            }
        }
        
        jres.openTicket = String.valueOf(openTicketCount);
        jres.closedTicket = String.valueOf(closedTicketCount);
        jres.overSla = String.valueOf(overSlaCount);
        jres.onSLa = String.valueOf(onSlaCount);
    }

    private static void calculateSummaryDataRO(BristarSummary_API_Wrapper.GetResponseRO3_Model jres, String conditions, Integer page, Integer pageSize) {
        String query = 'SELECT Id, IsClosed, Within_Target_SLA__c ' +
                        'FROM Case ' +
                        'WHERE ' + conditions;
        
        List<Case> cases = Database.query(query);
    
        Integer openTicketCount = 0;
        Integer closedTicketCount = 0;
        Integer overSlaCount = 0;
        Integer onSlaCount = 0;
        
        System.debug('Query: ' + query);
        System.debug('Counting Case: ' + cases.size());
        
        for (Case cs : cases) {
            if (cs.IsClosed) {
                closedTicketCount++;
            } else {
                openTicketCount++;
            }
            
            if (cs.Within_Target_SLA__c == 'Melebihi SLA') {
                overSlaCount++;
            } else if (cs.Within_Target_SLA__c == 'Sesuai SLA') {
                onSlaCount++;
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
        ticket.caseType = cs.SCC_Call_Type__r.Name;
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