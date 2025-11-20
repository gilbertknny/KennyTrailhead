public with sharing class EventMonitoring_API_Ctrl {

    // Handle API get by Date
    public static String getEventMonitoring(EventMonitoring_API_Wrapper.GetRequest_Model jreq) {
        System.debug('class called');
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        SCC_Custom_API_Response_Code__mdt rc = new SCC_Custom_API_Response_Code__mdt();

        // First condition: Check if StartDate and EndDate are not empty
        if (String.isBlank(jreq.StartDate) || String.isBlank(jreq.EndDate) || String.isBlank(jreq.area)) {
            rc = maprc?.get('Mandatory');
            return createErrorResponse(rc);
        }

        Date startDate = Date.valueOf(jreq.startDate);
        Date endDate = Date.valueOf(jreq.endDate);
        String area = jreq.area;
        String costCenter = jreq.costCenter;
        String region = jreq.region;
        String mainBranch = jreq.mainBranch;
        String branch = jreq.branch;
        String page = jreq.page;
        String lmt = jreq.lmt;

        Integer recordLimit = 0;
        Integer currentPage = 0;
        Integer offset = 0;
        String limitOffsetTop = '';
        String limitOffset = '';

        if (String.isNotBlank(lmt) && String.isNotBlank(page)) {
            recordLimit = Integer.valueOf(lmt);
            currentPage = Integer.valueOf(page);
            offset = (currentPage - 1) * recordLimit;
            limitOffsetTop = ' LIMIT ' + recordLimit + ' OFFSET ' + offset;
        }

        // Build the condition string
        String cond = 'Date__c >= ' + jreq.startDate + ' AND Date__c <= ' + jreq.endDate;
        String flag = '';

        // Check if Area is KP or RO
        if(String.isNotBlank(area) && area == 'KP'){
            System.debug('Called KP');
            cond = cond+' AND Area__c = \'KP00\' AND Cost_Center__c != null';
            flag = 'KP';
            limitOffset = limitOffsetTop;
        }else if(String.isNotBlank(area) && area == 'RO'){
            cond = cond+' AND Area__c != \'KP00\' AND Region__c != null AND Main_Branch__c != null AND Branch_Code__c != null';
            flag = 'RO';
            limitOffset = limitOffsetTop;
        }else{
            rc = maprc?.get('Data_Not_Found');
            return createErrorResponse(rc);
        }

        // Second condition: Check if costCenter is not empty
        if (String.isNotBlank(costCenter)) {
            cond = cond+' AND Cost_Center__c = :costCenter';
            flag = 'KP1';
            limitOffset = limitOffsetTop;
        }

        // Third condition: Check if region is not empty
        if (String.isNotBlank(region)) {
            cond = cond+' AND Region__c = :region';
            flag = 'RO1';
            limitOffset = '';
        }

        // Fourth condition: Check if mainBranch is not empty
        if (String.isNotBlank(mainBranch)) {
            cond = cond+' AND Main_Branch__c = :mainBranch';
            flag = 'RO2';
            limitOffset = '';
        }

        // Five condition: Check if branch is not empty
        if (String.isNotBlank(branch)) {
            cond = cond+' AND Branch_Code__c = :branch';
            flag = 'RO3';
            limitOffset = limitOffsetTop;
        }

        String addfield = ',Anomali_Category__r.RecordType.Name,User__r.Name';
        String allfield = SOQL_SOBJECT.getallfield('Monitoring_Summary__c');
        String orderByField = 'Date__c';
        String sortOrder = 'DESC'; // Can be 'ASC' or 'DESC'
        String query = 'SELECT ' + allField + addField + 
        ' FROM Monitoring_Summary__c' + 
        (String.isNotBlank(cond) ? ' WHERE ' + cond : '') +
        ' ORDER BY ' + orderByField + ' ' + sortOrder + limitOffset;
        
        List<Monitoring_Summary__c> listms = Database.query(query);

        // Fifth condition: Check if data is found and return the result
        // if (!listms.isEmpty()) {
            // if flag is KP then check condition
        if(flag == 'KP'){
            System.debug('Called KP 2');
            return processAndReturnResultsKP(listms, maprc, area);
        }else if (flag == 'KP1'){
            return processAndReturnResultsKP1(listms, maprc, area, costCenter, cond);
        }else if (flag == 'RO'){
            return processAndReturnResultsRO(listms, maprc, area);
        }else if(flag == 'RO1'){
            return processAndReturnResultsRO1(listms, query, maprc, area, region, offset, recordLimit);
        }else if(flag == 'RO2'){
            return processAndReturnResultsRO2(listms, query, maprc, area, region, mainBranch, recordLimit, offset);
        }else if(flag == 'RO3'){
            return processAndReturnResultsRO3(listms, maprc, area, region, mainBranch, branch, cond);
        }else{
            rc = maprc?.get('Data_Not_Found');
            return createErrorResponse(rc);
        }
        // } else {
        //     // Last condition: If no data found, return an error message
        //     rc = maprc?.get('Data_Not_Found');
        //     return createErrorResponse(rc);
        // }
    }

    private static String processAndReturnResultsKP(List<Monitoring_Summary__c> listms, Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area) {
        EventMonitoring_API_Wrapper.GetResponseKP_Model jres = new EventMonitoring_API_Wrapper.GetResponseKP_Model();
        Map<String, EventMonitoring_API_Wrapper.GetDetailKP_Model> divisionSummaryMap = new Map<String, EventMonitoring_API_Wrapper.GetDetailKP_Model>();
    
        // Fetch required anomaly types from Custom Metadata Type
        Set<String> requiredAnomalyTypes = new Set<String>();
        Required_Anomaly_Types__mdt requiredTypes = Required_Anomaly_Types__mdt.getInstance('Default');
        if (requiredTypes != null && String.isNotBlank(requiredTypes.Anomaly_Types__c)) {
            requiredAnomalyTypes.addAll(requiredTypes.Anomaly_Types__c.split(','));
        }

        System.debug('requiredAnomalyTypes :'+requiredAnomalyTypes);

        Set<String> masterCostCenters = new Set<String>();
        Map<String, String> masterCostCenterDescriptions = new Map<String, String>();

        List<AggregateResult> results = [SELECT Cost_Center__c, Cost_Center_Description__c
                                        FROM Orgeh__c
                                        WHERE Cost_Center__c != null
                                        GROUP BY Cost_Center__c, Cost_Center_Description__c];

        for (AggregateResult ar : results) {
            String costCenter = (String)ar.get('Cost_Center__c');
            String description = (String)ar.get('Cost_Center_Description__c');
            masterCostCenters.add(costCenter);
            masterCostCenterDescriptions.put(costCenter, description);
        }

        System.debug('masterCostCenters :'+masterCostCenters);

        // Count records instead of summing Total__c
        Map<String, Map<String, Integer>> recordCounts = new Map<String, Map<String, Integer>>();

        System.debug('listms :'+listms);

        Set<String> processedCostCenters = new Set<String>();
        for (Monitoring_Summary__c ms : listms) {
            String areaKey = ms.Area__c;
            String anomalyTypeKey = ms.Anomali_Category__r.RecordType.Name;
            String cosCenterKey = ms.Cost_Center__c;

            processedCostCenters.add(cosCenterKey);
            // String countRecord = '0';
            if (!recordCounts.containsKey(cosCenterKey)) {
                recordCounts.put(cosCenterKey, new Map<String, Integer>());
            }

            Map<String, Integer> anomalyCounts = recordCounts.get(cosCenterKey);
            anomalyCounts.put(anomalyTypeKey, anomalyCounts.containsKey(anomalyTypeKey) ? anomalyCounts.get(anomalyTypeKey) + 1 : 1);
    
            if (!divisionSummaryMap.containsKey(cosCenterKey)) {
                EventMonitoring_API_Wrapper.GetDetailKP_Model evdkp = new EventMonitoring_API_Wrapper.GetDetailKP_Model();
                evdkp.cosCenter = cosCenterKey;
                evdkp.cosCenterDesc = ms.Divisi__c;
                evdkp.activities = new List<EventMonitoring_API_Wrapper.GetActivitiesKP_Model>();
                evdkp.totalActivities = '0';
                divisionSummaryMap.put(cosCenterKey, evdkp);
            }
        }

        // Create empty data for master Cost Centers not found in Cases
        for (String masterCostCenter : masterCostCenters) {
            if (!processedCostCenters.contains(masterCostCenter)) {
                EventMonitoring_API_Wrapper.GetDetailKP_Model evdkp = new EventMonitoring_API_Wrapper.GetDetailKP_Model();
                evdkp.cosCenter = masterCostCenter;
                evdkp.cosCenterDesc = masterCostCenterDescriptions.get(masterCostCenter);
                evdkp.activities = new List<EventMonitoring_API_Wrapper.GetActivitiesKP_Model>();
                evdkp.totalActivities = '0';
                divisionSummaryMap.put(masterCostCenter, evdkp);
            }
        }

        // Update divisionSummaryMap with record counts
        for (String cosCenterKey : recordCounts.keySet()) {
            EventMonitoring_API_Wrapper.GetDetailKP_Model detailKP = divisionSummaryMap.get(cosCenterKey);
            Map<String, Integer> anomalyCounts = recordCounts.get(cosCenterKey);
            
            Integer totalActivities = 0;
            for (String anomalyTypeKey : anomalyCounts.keySet()) {
                Integer count = anomalyCounts.get(anomalyTypeKey);
                totalActivities += count;
                
                EventMonitoring_API_Wrapper.GetActivitiesKP_Model evakp = new EventMonitoring_API_Wrapper.GetActivitiesKP_Model();
                evakp.anomalyType = anomalyTypeKey;
                evakp.total = String.valueOf(count);
                detailKP.activities.add(evakp);
            }
            
            detailKP.totalActivities = String.valueOf(totalActivities);
        }
    
        // Ensure all required anomaly types are present in each division
        for (EventMonitoring_API_Wrapper.GetDetailKP_Model detail : divisionSummaryMap.values()) {
            Map<String, EventMonitoring_API_Wrapper.GetActivitiesKP_Model> activityMap = new Map<String, EventMonitoring_API_Wrapper.GetActivitiesKP_Model>();
            for (EventMonitoring_API_Wrapper.GetActivitiesKP_Model activity : detail.activities) {
                activityMap.put(activity.anomalyType, activity);
            }
    
            for (String requiredType : requiredAnomalyTypes) {
                if (!activityMap.containsKey(requiredType)) {
                    EventMonitoring_API_Wrapper.GetActivitiesKP_Model newActivity = new EventMonitoring_API_Wrapper.GetActivitiesKP_Model();
                    newActivity.anomalyType = requiredType;
                    newActivity.total = '0';
                    detail.activities.add(newActivity);
                }
            }
        }
    
        // Convert the map values to a list
        List<EventMonitoring_API_Wrapper.GetDetailKP_Model> divisionSummaryList = new List<EventMonitoring_API_Wrapper.GetDetailKP_Model>(divisionSummaryMap.values());
    
        // Sort divisionSummary by totalActivities (descending order)
        divisionSummaryList.sort(new DivisionSummaryComparatorKP());
    
        // Sort activities for each division by total (descending order)
        for (EventMonitoring_API_Wrapper.GetDetailKP_Model detail : divisionSummaryList) {
            detail.activities.sort(new ActivitiesComparatorKP());
        }
    
        jres.divisionSummary = divisionSummaryList;
    
        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
        jres.area = area;
    
        return EventMonitoring_API_Ctrl.returnAPIKP(jres);
    }
    
    // Comparator classes remain the same
    private class DivisionSummaryComparatorKP implements Comparator<EventMonitoring_API_Wrapper.GetDetailKP_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetDetailKP_Model a, EventMonitoring_API_Wrapper.GetDetailKP_Model b) {
            Integer aTotal = Integer.valueOf(a.totalActivities);
            Integer bTotal = Integer.valueOf(b.totalActivities);
            return bTotal - aTotal; // Descending order
        }
    }
    
    private class ActivitiesComparatorKP implements Comparator<EventMonitoring_API_Wrapper.GetActivitiesKP_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetActivitiesKP_Model a, EventMonitoring_API_Wrapper.GetActivitiesKP_Model b) {
            Integer aTotal = Integer.valueOf(a.total);
            Integer bTotal = Integer.valueOf(b.total);
            return bTotal - aTotal; // Descending order
        }
    }

    private static String processAndReturnResultsKP1(List<Monitoring_Summary__c> listms, Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String costCenter, String cond) {
        EventMonitoring_API_Wrapper.GetResponseKP1_Model jres = new EventMonitoring_API_Wrapper.GetResponseKP1_Model();
        List<EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model> dataActivities = new List<EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model>();
        

        Integer totalActivities = 0;
        String costCenterDesc = '';

        String query = 'SELECT Id FROM Monitoring_Summary__c WHERE '+cond;
        List<Monitoring_Summary__c> mSummary = Database.query(query);

        for (Monitoring_Summary__c msmry : mSummary){
            totalActivities++;
        }
    
        for (Monitoring_Summary__c ms : listms) {
            String anomalyTypeKey = ms.Anomali_Category__r.RecordType.Name;
            
            if (String.isBlank(costCenterDesc) && ms.Divisi__c != null) {
                costCenterDesc = ms.Divisi__c;
            }
            
            EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model activity = new EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model();
            activity.AnomalyCategory_RecordType = anomalyTypeKey;
            activity.Total = String.valueOf(ms.Total__c);
            activity.User_Name = ms.User__r.Name;
            activity.Tanggal = String.valueOf(ms.Date__c);
            activity.MonitoringSummary_Name = ms.Name;
            dataActivities.add(activity);
        }
        
        // Sort the activities
        dataActivities.sort(new ActivitiesComparatorKP1());
        
        jres.dataActivities = dataActivities;
        
        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
        jres.area = area;
        jres.costCenter = costCenter;
        jres.costCenterDesc = costCenterDesc;
        jres.totalActivities = String.valueOf(totalActivities);
    
        return EventMonitoring_API_Ctrl.returnAPIKP1(jres);
    }
    
    // Updated Comparator class for sorting activities
    private class ActivitiesComparatorKP1 implements Comparator<EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model a, EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model b) {
            // First, compare by date (descending)
            Date dateA = Date.valueOf(a.Tanggal);
            Date dateB = Date.valueOf(b.Tanggal);
            
            if (dateA > dateB){
                return -1;
            }
            if (dateA < dateB){
                return 1;
            }
            
            // If dates are equal, compare by total (descending)
            Integer aTotal = Integer.valueOf(a.Total);
            Integer bTotal = Integer.valueOf(b.Total);
            return bTotal - aTotal;
        }
    }

    private static String processAndReturnResultsRO(List<Monitoring_Summary__c> listms, Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area) {
        EventMonitoring_API_Wrapper.GetResponseRO_Model jres = new EventMonitoring_API_Wrapper.GetResponseRO_Model();
        Map<String, EventMonitoring_API_Wrapper.GetDetailRO_Model> regionalOfficeSummary = new Map<String, EventMonitoring_API_Wrapper.GetDetailRO_Model>();
        
        // First, get the valid Branch_Code__c values from Branch_Unit__c
        Set<String> validBranchCodes = new Set<String>();
        for(Branch_Unit__c bu : [SELECT BranchCode__c 
                                FROM Branch_Unit__c 
                                WHERE Uker_type__c != 'RO' 
                                AND BranchCode__c != null]) {
            validBranchCodes.add(bu.BranchCode__c);
        }

        // Fetch required anomaly types from Custom Metadata Type
        Set<String> requiredAnomalyTypes = new Set<String>();
        Required_Anomaly_Types__mdt requiredTypes = Required_Anomaly_Types__mdt.getInstance('Default');
        if (requiredTypes != null && String.isNotBlank(requiredTypes.Anomaly_Types__c)) {
            requiredAnomalyTypes.addAll(requiredTypes.Anomaly_Types__c.split(','));
        }

        // Count records instead of summing Total__c
        Map<String, Map<String, Integer>> recordCounts = new Map<String, Map<String, Integer>>();

        Set<String> masterRegions = new Set<String>();
        Map<String, String> masterRegionDescriptions = new Map<String, String>();

        List<AggregateResult> results = [SELECT Region__c, Region_Name__c
                                        FROM Branch_Unit__c
                                        WHERE Region__c != null AND Uker_Type__c != 'RO'
                                        GROUP BY Region__c, Region_Name__c];

        for (AggregateResult ar : results) {
            String region = (String)ar.get('Region__c');
            String description = (String)ar.get('Region_Name__c');
            masterRegions.add(region);
            masterRegionDescriptions.put(region, description);
        }
        // Process cases
        Set<String> processedRegions = new Set<String>();

        for (Monitoring_Summary__c ms : listms) {
            // Only process records with valid branch codes
            if (validBranchCodes.contains(ms.Branch_Code__c)) {
                String areaKey = ms.Area__c;
                String anomalyTypeKey = ms.Anomali_Category__r.RecordType.Name;
                String regionKey = ms.Region__c;

                processedRegions.add(regionKey);

                if (!recordCounts.containsKey(regionKey)) {
                    recordCounts.put(regionKey, new Map<String, Integer>());
                }

                Map<String, Integer> anomalyCounts = recordCounts.get(regionKey);
                anomalyCounts.put(anomalyTypeKey, anomalyCounts.containsKey(anomalyTypeKey) ? anomalyCounts.get(anomalyTypeKey) + 1 : 1);
                
                // Check if this region already exists in the map
                if (!regionalOfficeSummary.containsKey(regionKey)) {
                    EventMonitoring_API_Wrapper.GetDetailRO_Model evdkp = new EventMonitoring_API_Wrapper.GetDetailRO_Model();
                    evdkp.region = regionKey;
                    evdkp.regionDesc = ms.Region_Name__c;
                    evdkp.activities = new List<EventMonitoring_API_Wrapper.GetActivitiesRO_Model>(); // Initialize list of activities
                    evdkp.totalActivities = '0';  // Initialize total activities as a String '0'
                    regionalOfficeSummary.put(regionKey, evdkp);
                }
            }
        }

        // Create empty data for master Cost Centers not found in Cases
        for (String masterRegion : masterRegions) {
            if (!processedRegions.contains(masterRegion)) {
                EventMonitoring_API_Wrapper.GetDetailRO_Model evdkp = new EventMonitoring_API_Wrapper.GetDetailRO_Model();
                evdkp.region = masterRegion;
                evdkp.regionDesc = masterRegionDescriptions.get(masterRegion);
                evdkp.activities = new List<EventMonitoring_API_Wrapper.GetActivitiesRO_Model>(); // Initialize list of activities
                evdkp.totalActivities = '0';
                regionalOfficeSummary.put(masterRegion, evdkp);
            }
        }

        // Update divisionSummaryMap with record counts
        for (String regionKey : recordCounts.keySet()) {
            EventMonitoring_API_Wrapper.GetDetailRO_Model detailKP = regionalOfficeSummary.get(regionKey);
            Map<String, Integer> anomalyCounts = recordCounts.get(regionKey);
            
            Integer totalActivities = 0;
            for (String anomalyTypeKey : anomalyCounts.keySet()) {
                Integer count = anomalyCounts.get(anomalyTypeKey);
                totalActivities += count;
                
                EventMonitoring_API_Wrapper.GetActivitiesRO_Model evakp = new EventMonitoring_API_Wrapper.GetActivitiesRO_Model();
                evakp.anomalyType = anomalyTypeKey;
                evakp.total = String.valueOf(count);
                detailKP.activities.add(evakp);
            }
            
            detailKP.totalActivities = String.valueOf(totalActivities);
        }

        // Ensure all required anomaly types are present in each division
        for (EventMonitoring_API_Wrapper.GetDetailRO_Model detail : regionalOfficeSummary.values()) {
            Map<String, EventMonitoring_API_Wrapper.GetActivitiesRO_Model> activityMap = new Map<String, EventMonitoring_API_Wrapper.GetActivitiesRO_Model>();
            for (EventMonitoring_API_Wrapper.GetActivitiesRO_Model activity : detail.activities) {
                activityMap.put(activity.anomalyType, activity);
            }
    
            for (String requiredType : requiredAnomalyTypes) {
                if (!activityMap.containsKey(requiredType)) {
                    EventMonitoring_API_Wrapper.GetActivitiesRO_Model newActivity = new EventMonitoring_API_Wrapper.GetActivitiesRO_Model();
                    newActivity.anomalyType = requiredType;
                    newActivity.total = '0';
                    detail.activities.add(newActivity);
                }
            }
        }
        // Convert the map values to a list
        List<EventMonitoring_API_Wrapper.GetDetailRO_Model> regionalOfficeSummaryList = new List<EventMonitoring_API_Wrapper.GetDetailRO_Model>(regionalOfficeSummary.values());
    
        // Sort divisionSummary by totalActivities (descending order)
        regionalOfficeSummaryList.sort(new DivisionSummaryComparatorRO());
    
        // Sort activities for each division by total (descending order)
        for (EventMonitoring_API_Wrapper.GetDetailRO_Model detail : regionalOfficeSummaryList) {
            detail.activities.sort(new ActivitiesComparatorRO());
        }
    
        // Convert the map values to a list and assign it to the response
        jres.regionalOfficeSummary = regionalOfficeSummaryList;
        // Set the response code and message
        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
        jres.area = area;
    
        // Return the final API response
        return EventMonitoring_API_Ctrl.returnAPIRO(jres);
    }

    // Comparator classes remain the same
    private class DivisionSummaryComparatorRO implements Comparator<EventMonitoring_API_Wrapper.GetDetailRO_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetDetailRO_Model a, EventMonitoring_API_Wrapper.GetDetailRO_Model b) {
            Integer aTotal = Integer.valueOf(a.totalActivities);
            Integer bTotal = Integer.valueOf(b.totalActivities);
            return bTotal - aTotal; // Descending order
        }
    }
    
    private class ActivitiesComparatorRO implements Comparator<EventMonitoring_API_Wrapper.GetActivitiesRO_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetActivitiesRO_Model a, EventMonitoring_API_Wrapper.GetActivitiesRO_Model b) {
            Integer aTotal = Integer.valueOf(a.total);
            Integer bTotal = Integer.valueOf(b.total);
            return bTotal - aTotal; // Descending order
        }
    }

    private static String processAndReturnResultsRO1(List<Monitoring_Summary__c> listms, String query, Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String region, Integer offset, Integer recordLimit) {
        EventMonitoring_API_Wrapper.GetResponseRO1_Model jres = new EventMonitoring_API_Wrapper.GetResponseRO1_Model();
        Map<String, EventMonitoring_API_Wrapper.GetDetailRO1_Model> branchOfficeSummary = new Map<String, EventMonitoring_API_Wrapper.GetDetailRO1_Model>();
        List<EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model> dataActivities = new List<EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model>();
        

        // Get valid BranchCode__c values from Branch_Unit__c
        Set<String> validBranchCodes = new Set<String>();
        for(Branch_Unit__c bu : [SELECT BranchCode__c 
                                FROM Branch_Unit__c 
                                WHERE Uker_type__c != 'RO' 
                                AND BranchCode__c != null]) {
            validBranchCodes.add(bu.BranchCode__c);
        }

         // Filter listms to only include valid branch codes
         List<Monitoring_Summary__c> filteredListms = new List<Monitoring_Summary__c>();
         for(Monitoring_Summary__c ms : listms) {
             if(validBranchCodes.contains(ms.Branch_Code__c)) {
                 filteredListms.add(ms);
             }
         }

        // if(recordLimit==0){
        //     query = query;
        // }else{
        //     query += ' LIMIT :recordLimit OFFSET :offset';
        // }
        // List<Monitoring_Summary__c> MonSum = Database.query(query);

        // Move the pagination query to after filtering
        // Move the pagination query to after filtering
        List<Monitoring_Summary__c> monSum;
        if(recordLimit == 0) {
            monSum = Database.query(query);
        } else {
            // Filter the query results first
            List<Monitoring_Summary__c> allResults = Database.query(query);
            List<Monitoring_Summary__c> validResults = new List<Monitoring_Summary__c>();
            
            // Filter for valid branch codes
            for(Monitoring_Summary__c ms : allResults) {
                if(validBranchCodes.contains(ms.Branch_Code__c)) {
                    validResults.add(ms);
                }
            }
            
            // Apply pagination after filtering
            monSum = new List<Monitoring_Summary__c>();
            Integer startIndex = Math.min(offset, validResults.size());
            Integer endIndex = Math.min(startIndex + recordLimit, validResults.size());
            
            // Manually create sublist
            for(Integer i = startIndex; i < endIndex; i++) {
                monSum.add(validResults[i]);
            }
        }

        String regionDesc = '';
        Integer totalDA = 0;
    
        // Fetch required anomaly types from Custom Metadata Type
        Set<String> requiredAnomalyTypes = new Set<String>();
        Required_Anomaly_Types__mdt requiredTypes = Required_Anomaly_Types__mdt.getInstance('Default');
        if (requiredTypes != null && String.isNotBlank(requiredTypes.Anomaly_Types__c)) {
            requiredAnomalyTypes.addAll(requiredTypes.Anomaly_Types__c.split(','));
        }

        Map<String, Map<String, Integer>> recordCounts = new Map<String, Map<String, Integer>>();

        Set<String> masterMainBranchs = new Set<String>();
        Map<String, String> masterMainBranchsDescriptions = new Map<String, String>();

        List<AggregateResult> results = [SELECT Kode_Cabang__c, Nama_Cabang__c
                                        FROM Branch_Unit__c
                                        WHERE Kode_Cabang__c != null AND Region__c = : region AND Uker_type__c != 'RO'
                                        GROUP BY Kode_Cabang__c, Nama_Cabang__c];

        for (AggregateResult ar : results) {
            String mainBranch = (String)ar.get('Kode_Cabang__c');
            String description = (String)ar.get('Nama_Cabang__c');
            masterMainBranchs.add(mainBranch);
            masterMainBranchsDescriptions.put(mainBranch, description);
        }
        // Process cases
        Set<String> processedMainBranchs = new Set<String>();
        
        Integer countDetail = 0;
        for (Monitoring_Summary__c ms : filteredListms) {
            // Only process records with valid branch codes
            if (validBranchCodes.contains(ms.Branch_Code__c)) {
                String areaKey = ms.Area__c;
                String anomalyTypeKey = ms.Anomali_Category__r.RecordType.Name;
                String mainBranchKey = ms.Main_Branch__c;

                processedMainBranchs.add(mainBranchKey);
                
                // Set regionDesc if it hasn't been set yet
                if (String.isBlank(regionDesc) && ms.Region_Name__c != null) {
                    regionDesc = ms.Region_Name__c;
                }

                if (!recordCounts.containsKey(mainBranchKey)) {
                    recordCounts.put(mainBranchKey, new Map<String, Integer>());
                }
                
                Map<String, Integer> anomalyCounts = recordCounts.get(mainBranchKey);
                anomalyCounts.put(anomalyTypeKey, anomalyCounts.containsKey(anomalyTypeKey) ? anomalyCounts.get(anomalyTypeKey) + 1 : 1);
        
                // Initialize the branch summary for the mainBranchKey if it doesn't exist
                if (!branchOfficeSummary.containsKey(mainBranchKey)) {
                    EventMonitoring_API_Wrapper.GetDetailRO1_Model evdkp = new EventMonitoring_API_Wrapper.GetDetailRO1_Model();
                    evdkp.mainBranch = mainBranchKey;
                    evdkp.mainBranchDesc = ms.Main_Branch_Description__c;
                    evdkp.activities = new List<EventMonitoring_API_Wrapper.GetActivitiesRO1_Model>();
                    evdkp.totalActivities = '0';  // Initialize as String '0'
                    branchOfficeSummary.put(mainBranchKey, evdkp);
                }

                totalDA++;

                if(countDetail == 0){
                    // Process MonSum records (which now contains the correctly paginated data)
                    for (Monitoring_Summary__c msm : monSum) {
                        EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model dataActivity = new EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model();
                        dataActivity.anomalyCategory_RecordType = msm.Anomali_Category__r.RecordType.Name;
                        dataActivity.total = String.valueOf(msm.Total__c);
                        dataActivity.user_Name = msm.User__r.Name;
                        dataActivity.mainBranch = msm.Main_Branch__c;
                        dataActivity.mainBranchDesc = msm.Main_Branch_Description__c;
                        dataActivity.branchCode = msm.Branch_Code__c;
                        dataActivity.branchDesc = msm.Branch_Unit__c;
                        dataActivity.tanggal = String.valueOf(msm.Date__c);
                        dataActivity.monitoringSummary_Name = msm.Name;
                        dataActivities.add(dataActivity);

                        // Only increment totalDA for the paginated subset
                        // totalDA++;
                    }
                    countDetail++;
                }
            }
        }

        // Create empty data for master Cost Centers not found in Cases
        for (String masterMainBranch : masterMainBranchs) {
            if (!processedMainBranchs.contains(masterMainBranch)) {
                EventMonitoring_API_Wrapper.GetDetailRO1_Model evdkp = new EventMonitoring_API_Wrapper.GetDetailRO1_Model();
                evdkp.mainBranch = masterMainBranch;
                evdkp.mainBranchDesc = masterMainBranchsDescriptions.get(masterMainBranch);
                evdkp.activities = new List<EventMonitoring_API_Wrapper.GetActivitiesRO1_Model>();
                evdkp.totalActivities = '0';  // Initialize as String '0'
                branchOfficeSummary.put(masterMainBranch, evdkp);
            }
        }

        // Update branchOfficeSummary with record counts
        for (String mainBranchKey : recordCounts.keySet()) {
            EventMonitoring_API_Wrapper.GetDetailRO1_Model detail = branchOfficeSummary.get(mainBranchKey);
            Map<String, Integer> anomalyCounts = recordCounts.get(mainBranchKey);
            
            Integer totalActivities = 0;
            for (String anomalyTypeKey : anomalyCounts.keySet()) {
                Integer count = anomalyCounts.get(anomalyTypeKey);
                totalActivities += count;
                
                EventMonitoring_API_Wrapper.GetActivitiesRO1_Model evakp = new EventMonitoring_API_Wrapper.GetActivitiesRO1_Model();
                evakp.anomalyType = anomalyTypeKey;
                evakp.total = String.valueOf(count);
                detail.activities.add(evakp);
            }
            
            detail.totalActivities = String.valueOf(totalActivities);
        }
        
        // Ensure all required anomaly types are present in each division
        for (EventMonitoring_API_Wrapper.GetDetailRO1_Model detail : branchOfficeSummary.values()) {
            Map<String, EventMonitoring_API_Wrapper.GetActivitiesRO1_Model> activityMap = new Map<String, EventMonitoring_API_Wrapper.GetActivitiesRO1_Model>();
            for (EventMonitoring_API_Wrapper.GetActivitiesRO1_Model activity : detail.activities) {
                activityMap.put(activity.anomalyType, activity);
            }
            for (String requiredType : requiredAnomalyTypes) {
                if (!activityMap.containsKey(requiredType)) {
                    EventMonitoring_API_Wrapper.GetActivitiesRO1_Model newActivity = new EventMonitoring_API_Wrapper.GetActivitiesRO1_Model();
                    newActivity.anomalyType = requiredType;
                    newActivity.total = '0';
                    detail.activities.add(newActivity);
                }
            }
        }
    
        // Convert the map values to a list and assign it to the response
        List<EventMonitoring_API_Wrapper.GetDetailRO1_Model> detailList = new List<EventMonitoring_API_Wrapper.GetDetailRO1_Model>(branchOfficeSummary.values());
        
        // Sort branchOfficeSummary by totalActivities (descending order)
        detailList.sort(new DivisionSummaryComparatorRO1());
    
        // Sort activities for each division by total (descending order)
        for (EventMonitoring_API_Wrapper.GetDetailRO1_Model detail : detailList) {
            detail.activities.sort(new ActivitiesComparatorRO1());
        }
    
        // Sort DataActivities by date (descending) and then by total (descending)
        dataActivities.sort(new DetailDataActivitiesComparatorRO1());
    
        // Assign to the response
        jres.branchOfficeSummary = detailList;
        jres.DataActivities = dataActivities;
    
        // Set the response code and message
        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
        jres.area = area;
        jres.region = region;
        jres.regionDesc = regionDesc;
        jres.totalActivities = String.valueOf(totalDA);

        // Return the final API response
        return EventMonitoring_API_Ctrl.returnAPIRO1(jres);
    }
    
    // Updated Comparator class for sorting activities
    private class DetailDataActivitiesComparatorRO1 implements Comparator<EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model a, EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model b) {
            // First, compare by date (descending)
            Date dateA = Date.valueOf(a.tanggal);
            Date dateB = Date.valueOf(b.tanggal);
            
            if (dateA > dateB){
                return -1;
            }
            if (dateA < dateB){
                return 1;
            }
            
            // If dates are equal, compare by total (descending)
            Integer aTotal = Integer.valueOf(a.total);
            Integer bTotal = Integer.valueOf(b.total);
            return bTotal - aTotal;
        }
    }

    // Existing comparator classes remain the same
    private class DivisionSummaryComparatorRO1 implements Comparator<EventMonitoring_API_Wrapper.GetDetailRO1_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetDetailRO1_Model a, EventMonitoring_API_Wrapper.GetDetailRO1_Model b) {
            Integer aTotal = Integer.valueOf(a.totalActivities);
            Integer bTotal = Integer.valueOf(b.totalActivities);
            return bTotal - aTotal; // Descending order
        }
    }
    
    private class ActivitiesComparatorRO1 implements Comparator<EventMonitoring_API_Wrapper.GetActivitiesRO1_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetActivitiesRO1_Model a, EventMonitoring_API_Wrapper.GetActivitiesRO1_Model b) {
            Integer aTotal = Integer.valueOf(a.total);
            Integer bTotal = Integer.valueOf(b.total);
            return bTotal - aTotal; // Descending order
        }
    }
    
    // New comparator for DetailActivitiesRO1_Model
    private class DetailActivitiesComparatorRO1 implements Comparator<EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model a, EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model b) {
            // First, compare by date (descending)
            Date dateA = Date.valueOf(a.tanggal);
            Date dateB = Date.valueOf(b.tanggal);
            
            if (dateA > dateB){
                return -1;
            }
            if (dateA < dateB){
                return 1;
            }
            
            // If dates are equal, compare by total (descending)
            Integer aTotal = Integer.valueOf(a.total);
            Integer bTotal = Integer.valueOf(b.total);
            return bTotal - aTotal;
        }
    }
    
    private static String processAndReturnResultsRO2(List<Monitoring_Summary__c> listms, String query, Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String region, String mainBranch, Integer recordLimit, Integer offset) {
        // EventMonitoring_API_Wrapper.GetResponseRO2_Model jres = new EventMonitoring_API_Wrapper.GetResponseRO2_Model();
        // Map<String, EventMonitoring_API_Wrapper.GetDetailRO2_Model> BranchSummary = new Map<String, EventMonitoring_API_Wrapper.GetDetailRO2_Model>();
        // List<EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model> DataActivities = new List<EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model>();
        

        // First, get all Branch Units that are not RO type
        Set<String> validBranchCodes = new Set<String>();
        for(Branch_Unit__c bu : [SELECT BranchCode__c 
                                FROM Branch_Unit__c 
                                WHERE Uker_Type__c != 'RO' 
                                AND Region__c = :region 
                                AND Kode_Cabang__c = :mainBranch]) {
            validBranchCodes.add(bu.BranchCode__c);
        }

        // Filter listms to only include valid branch codes
        List<Monitoring_Summary__c> filteredListms = new List<Monitoring_Summary__c>();
        for(Monitoring_Summary__c ms : listms) {
            if(validBranchCodes.contains(ms.Branch_Code__c)) {
                filteredListms.add(ms);
            }
        }

        EventMonitoring_API_Wrapper.GetResponseRO2_Model jres = new EventMonitoring_API_Wrapper.GetResponseRO2_Model();
        Map<String, EventMonitoring_API_Wrapper.GetDetailRO2_Model> branchSummary = new Map<String, EventMonitoring_API_Wrapper.GetDetailRO2_Model>();
        List<EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model> dataActivities = new List<EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model>();
        
        if(recordLimit==0){
            query = query;
        }else{
            query += ' LIMIT :recordLimit OFFSET :offset';
        }
        List<Monitoring_Summary__c> monSum = Database.query(query);

        String mainBranchDesc = '';
        String regionDesc = '';
        Integer totalDA = 0;
        
        // Fetch required anomaly types from Custom Metadata Type
        Set<String> requiredAnomalyTypes = new Set<String>();
        Required_Anomaly_Types__mdt requiredTypes = Required_Anomaly_Types__mdt.getInstance('Default');
        if (requiredTypes != null && String.isNotBlank(requiredTypes.Anomaly_Types__c)) {
            requiredAnomalyTypes.addAll(requiredTypes.Anomaly_Types__c.split(','));
        }
        
        Map<String, Map<String, Integer>> recordCounts = new Map<String, Map<String, Integer>>();

        Set<String> masterBranchs = new Set<String>();
        Map<String, String> masterBranchsDescriptions = new Map<String, String>();

        List<Branch_Unit__c> results = [SELECT BranchCode__c, Name
                                        FROM Branch_Unit__c
                                        WHERE Kode_Cabang__c != null AND Name != null AND Region__c = : region AND Kode_Cabang__c = : mainBranch AND Uker_Type__c != 'RO'];

        for (Branch_Unit__c ar : results) {
            String branch = (String)ar.get('BranchCode__c');
            String description = (String)ar.get('Name');
            masterBranchs.add(branch);
            masterBranchsDescriptions.put(branch, description);
        }
        // Process cases
        Set<String> processedBranchs = new Set<String>();

        Integer countDetail = 0;
        for (Monitoring_Summary__c ms : filteredListms) {
            String areaKey = ms.Area__c;
            String anomalyTypeKey = ms.Anomali_Category__r.RecordType.Name;
            String branchKey = ms.Branch_Code__c;

            processedBranchs.add(branchKey);
    
            // Set mainBranchDesc and regionDesc if they haven't been set yet
            if (String.isBlank(mainBranchDesc) && ms.Main_Branch_Description__c != null) {
                mainBranchDesc = ms.Main_Branch_Description__c;
            }
    
            if (String.isBlank(regionDesc) && ms.Region_Name__c != null) {
                regionDesc = ms.Region_Name__c;
            }

            if (!recordCounts.containsKey(branchKey)) {
                recordCounts.put(branchKey, new Map<String, Integer>());
            }
            
            Map<String, Integer> anomalyCounts = recordCounts.get(branchKey);
            anomalyCounts.put(anomalyTypeKey, anomalyCounts.containsKey(anomalyTypeKey) ? anomalyCounts.get(anomalyTypeKey) + 1 : 1);
            
            totalDA++;

            // Initialize branch summary for branchKey if it doesn't exist
            if (!branchSummary.containsKey(branchKey)) {
                EventMonitoring_API_Wrapper.GetDetailRO2_Model evdkp = new EventMonitoring_API_Wrapper.GetDetailRO2_Model();
                evdkp.branchCode = branchKey;
                evdkp.branchDesc = ms.Branch_Unit__c;
                evdkp.activities = new List<EventMonitoring_API_Wrapper.GetActivitiesRO2_Model>();
                evdkp.totalActivities = '0';  // Initialize as String '0'
                branchSummary.put(branchKey, evdkp);
            }

            if(countDetail == 0){
                for (Monitoring_Summary__c msm : monSum) {
                    // Only include if branch code is valid
                    if(validBranchCodes.contains(msm.Branch_Code__c)) {
                        String anomalyTypeKeyDetail = msm.Anomali_Category__r.RecordType.Name;
                        
                        EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model dataActivity = new EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model();
                        dataActivity.anomalyCategory_RecordType = anomalyTypeKeyDetail;
                        dataActivity.total = String.valueOf(msm.Total__c);
                        dataActivity.user_Name = msm.User__r.Name;
                        dataActivity.branchCode = msm.Branch_Code__c;
                        dataActivity.branchDesc = msm.Branch_Unit__c;
                        dataActivity.tanggal = String.valueOf(msm.Date__c);
                        dataActivity.monitoringSummary_Name = msm.Name;
                        dataActivities.add(dataActivity);
                    }

                    // totalDA++;
                }
                countDetail++;
            }
        }

        // Create empty data for master Cost Centers not found in Cases
        for (String masterBranch : masterBranchs) {
            if (!processedBranchs.contains(masterBranch)) {
                EventMonitoring_API_Wrapper.GetDetailRO2_Model evdkp = new EventMonitoring_API_Wrapper.GetDetailRO2_Model();
                evdkp.branchCode = masterBranch;
                evdkp.branchDesc = masterBranchsDescriptions.get(masterBranch);
                evdkp.activities = new List<EventMonitoring_API_Wrapper.GetActivitiesRO2_Model>();
                evdkp.totalActivities = '0';  // Initialize as String '0'
                branchSummary.put(masterBranch, evdkp);
            }
        }

        // Update BranchSummary with record counts
        for (String branchKey : recordCounts.keySet()) {
            EventMonitoring_API_Wrapper.GetDetailRO2_Model detail = branchSummary.get(branchKey);
            Map<String, Integer> anomalyCounts = recordCounts.get(branchKey);
            
            Integer totalActivities = 0;
            for (String anomalyTypeKey : anomalyCounts.keySet()) {
                Integer count = anomalyCounts.get(anomalyTypeKey);
                totalActivities += count;
                
                EventMonitoring_API_Wrapper.GetActivitiesRO2_Model evakp = new EventMonitoring_API_Wrapper.GetActivitiesRO2_Model();
                evakp.anomalyType = anomalyTypeKey;
                evakp.total = String.valueOf(count);
                detail.activities.add(evakp);
            }
            
            detail.totalActivities = String.valueOf(totalActivities);
        }
        
        // Ensure all required anomaly types are present in each division
        for (EventMonitoring_API_Wrapper.GetDetailRO2_Model detail : branchSummary.values()) {
            Map<String, EventMonitoring_API_Wrapper.GetActivitiesRO2_Model> activityMap = new Map<String, EventMonitoring_API_Wrapper.GetActivitiesRO2_Model>();
            for (EventMonitoring_API_Wrapper.GetActivitiesRO2_Model activity : detail.activities) {
                activityMap.put(activity.anomalyType, activity);
            }
    
            for (String requiredType : requiredAnomalyTypes) {
                if (!activityMap.containsKey(requiredType)) {
                    EventMonitoring_API_Wrapper.GetActivitiesRO2_Model newActivity = new EventMonitoring_API_Wrapper.GetActivitiesRO2_Model();
                    newActivity.anomalyType = requiredType;
                    newActivity.total = '0';
                    detail.activities.add(newActivity);
                }
            }
        }
        
        // Convert the map values to a list
        List<EventMonitoring_API_Wrapper.GetDetailRO2_Model> branchSummaryList = new List<EventMonitoring_API_Wrapper.GetDetailRO2_Model>(branchSummary.values());
    
        // Sort branchSummary by totalActivities (descending order)
        branchSummaryList.sort(new DivisionSummaryComparatorRO2());
    
        // Sort activities for each branch by total (descending order)
        for (EventMonitoring_API_Wrapper.GetDetailRO2_Model detail : branchSummaryList) {
            detail.activities.sort(new ActivitiesComparatorRO2());
        }
    
        // Sort DataActivities by date (descending) and then by total (descending)
        dataActivities.sort(new DetailDataActivitiesComparatorRO2());
    
        // Assign the sorted lists to the response
        jres.BranchSummary = branchSummaryList;
        jres.DataActivities = dataActivities;
    
        // Set the response code and message
        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
        jres.area = area;
        jres.region = region;
        jres.regionDesc = regionDesc;
        jres.mainBranch = mainBranch;
        jres.mainBranchDesc = mainBranchDesc;
        jres.totalActivities = String.valueOf(totalDA);
    
        // Return the final API response
        return EventMonitoring_API_Ctrl.returnAPIRO2(jres);
    }

    // Updated Comparator class for sorting activities
    private class DetailDataActivitiesComparatorRO2 implements Comparator<EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model a, EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model b) {
            // First, compare by date (descending)
            Date dateA = Date.valueOf(a.tanggal);
            Date dateB = Date.valueOf(b.tanggal);
            
            if (dateA > dateB){
                return -1;
            }
            if (dateA < dateB){
                return 1;
            }
            
            // If dates are equal, compare by total (descending)
            Integer aTotal = Integer.valueOf(a.total);
            Integer bTotal = Integer.valueOf(b.total);
            return bTotal - aTotal;
        }
    }
    
    // Existing comparator classes remain the same
    private class DivisionSummaryComparatorRO2 implements Comparator<EventMonitoring_API_Wrapper.GetDetailRO2_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetDetailRO2_Model a, EventMonitoring_API_Wrapper.GetDetailRO2_Model b) {
            Integer aTotal = Integer.valueOf(a.totalActivities);
            Integer bTotal = Integer.valueOf(b.totalActivities);
            return bTotal - aTotal; // Descending order
        }
    }
    
    private class ActivitiesComparatorRO2 implements Comparator<EventMonitoring_API_Wrapper.GetActivitiesRO2_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetActivitiesRO2_Model a, EventMonitoring_API_Wrapper.GetActivitiesRO2_Model b) {
            Integer aTotal = Integer.valueOf(a.total);
            Integer bTotal = Integer.valueOf(b.total);
            return bTotal - aTotal; // Descending order
        }
    }
    
    // New comparator for DetailActivitiesRO2_Model
    private class DetailActivitiesComparatorRO2 implements Comparator<EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model a, EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model b) {
            // First, compare by date (descending)
            Date dateA = Date.valueOf(a.tanggal);
            Date dateB = Date.valueOf(b.tanggal);
            
            if (dateA > dateB){
                return -1;
            }
            if (dateA < dateB){
                return 1;
            }
            
            // If dates are equal, compare by total (descending)
            Integer aTotal = Integer.valueOf(a.total);
            Integer bTotal = Integer.valueOf(b.total);
            return bTotal - aTotal; 
        }
    }

    private static String processAndReturnResultsRO3(List<Monitoring_Summary__c> listms, Map<String, SCC_Custom_API_Response_Code__mdt> maprc, String area, String region, String mainBranch, String branch, String cond) {
        // First, get all Branch Units that are not RO type
        Set<String> validBranchCodes = new Set<String>();
        for(Branch_Unit__c bu : [SELECT BranchCode__c 
                                FROM Branch_Unit__c 
                                WHERE Uker_Type__c != 'RO' 
                                AND Region__c = :region 
                                AND Kode_Cabang__c = :mainBranch]) {
            validBranchCodes.add(bu.BranchCode__c);
        }
        
        EventMonitoring_API_Wrapper.GetResponseRO3_Model jres = new EventMonitoring_API_Wrapper.GetResponseRO3_Model();
        List<EventMonitoring_API_Wrapper.GetDetailRO3_Model> dataActivities = new List<EventMonitoring_API_Wrapper.GetDetailRO3_Model>();
    
        Integer totalActivities = 0;
        String regionDesc = '';
        String mainBranchDesc = '';
        String branchDesc = '';

        String query = 'SELECT Id, Branch_Code__c FROM Monitoring_Summary__c WHERE '+cond;
        List<Monitoring_Summary__c> mSummary = Database.query(query);

        for (Monitoring_Summary__c msmry : mSummary){
            if(validBranchCodes.contains(msmry.Branch_Code__c)) {
                totalActivities++;
            }
        }
    
        for (Monitoring_Summary__c ms : listms) {
            if(validBranchCodes.contains(ms.Branch_Code__c)) {
                String anomalyTypeKey = ms.Anomali_Category__r.RecordType.Name;
                
                if (String.isBlank(branchDesc) && ms.Branch_Unit__c != null) {
                    branchDesc = ms.Branch_Unit__c;
                }

                if (String.isBlank(mainBranchDesc) && ms.Main_Branch_Description__c != null) {
                    mainBranchDesc = ms.Main_Branch_Description__c;
                }

                if (String.isBlank(regionDesc) && ms.Region_Name__c != null) {
                    regionDesc = ms.Region_Name__c;
                }
                
                EventMonitoring_API_Wrapper.GetDetailRO3_Model activity = new EventMonitoring_API_Wrapper.GetDetailRO3_Model();
                activity.anomalyCategory_RecordType = anomalyTypeKey;
                activity.total = String.valueOf(ms.Total__c);
                activity.user_Name = ms.User__r.Name;
                activity.tanggal = String.valueOf(ms.Date__c);
                activity.monitoringSummary_Name = ms.Name;
                dataActivities.add(activity);
                
            }
        }
        
        // Sort the activities
        dataActivities.sort(new ActivitiesComparatorRO3());
        
        jres.DataActivities = dataActivities;
        
        SCC_Custom_API_Response_Code__mdt rc = maprc?.get('Success');
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
        jres.area = area;
        jres.region = region;
        jres.regionDesc = regionDesc;
        jres.mainBranch = mainBranch;
        jres.mainBranchDesc = mainBranchDesc;
        jres.branchCode = branch;
        jres.branchDesc = branchDesc;
        jres.totalActivities = String.valueOf(totalActivities);
    
        return EventMonitoring_API_Ctrl.returnAPIRO3(jres);
    }

    // Updated Comparator class for sorting activities
    private class ActivitiesComparatorRO3 implements Comparator<EventMonitoring_API_Wrapper.GetDetailRO3_Model> {
        public Integer compare(EventMonitoring_API_Wrapper.GetDetailRO3_Model a, EventMonitoring_API_Wrapper.GetDetailRO3_Model b) {
            // First, compare by date (descending)
            Date dateA = Date.valueOf(a.tanggal);
            Date dateB = Date.valueOf(b.tanggal);
            
            if (dateA > dateB){
                return -1;
            }
            if (dateA < dateB){
                return 1;
            }
            
            // If dates are equal, compare by total (descending)
            Integer aTotal = Integer.valueOf(a.total);
            Integer bTotal = Integer.valueOf(b.total);
            return bTotal - aTotal;
        }
    }

    private static String createErrorResponse(SCC_Custom_API_Response_Code__mdt rc) {
        EventMonitoring_API_Wrapper.GetResponseModel jres = new EventMonitoring_API_Wrapper.GetResponseModel();
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
        return EventMonitoring_API_Ctrl.returnAPI(jres);
    }
    
    public static String returnAPI(EventMonitoring_API_Wrapper.GetResponseModel jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }

    public static String returnAPIKP(EventMonitoring_API_Wrapper.GetResponseKP_Model jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }

    public static String returnAPIKP1(EventMonitoring_API_Wrapper.GetResponseKP1_Model jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }

    public static String returnAPIRO(EventMonitoring_API_Wrapper.GetResponseRO_Model jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }

    public static String returnAPIRO1(EventMonitoring_API_Wrapper.GetResponseRO1_Model jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }

    public static String returnAPIRO2(EventMonitoring_API_Wrapper.GetResponseRO2_Model jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }

    public static String returnAPIRO3(EventMonitoring_API_Wrapper.GetResponseRO3_Model jres){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim(); 
        return returnJson;
    }
}