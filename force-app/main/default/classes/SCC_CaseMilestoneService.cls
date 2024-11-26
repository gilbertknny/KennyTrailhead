public class SCC_CaseMilestoneService {   
    public class CaseMilestoneWrapper {
        @AuraEnabled
        public Boolean hasCaseType { get; set; }
        @AuraEnabled
        public Boolean milestoneStarted { get; set; }
        @AuraEnabled
        public String milestoneName { get; set; }
        @AuraEnabled
        public String teamName { get; set; }
        @AuraEnabled
        public Boolean isViolated { get; set; }
        @AuraEnabled
        public Boolean isCompleted { get; set; }
        @AuraEnabled
        public Datetime targetDate { get; set; }
        @AuraEnabled
        public String elapsedTimeInMins { get; set; }
        @AuraEnabled
        public Integer targetResponseInMins { get; set; }
        @AuraEnabled
        public String timeSinceTargetInMins { get; set; }
        @AuraEnabled
        public String timeRemainingInMins { get; set; }
        @AuraEnabled
        public Boolean isStop { get; set; }
        @AuraEnabled
        public Boolean isActive { get; set; }
        @AuraEnabled
        public Integer targetDay { get; set; }
        
        public CaseMilestoneWrapper(Boolean hasCaseType, Boolean milestoneStarted, String milestoneName, String teamName, Boolean isViolated, Boolean isCompleted, Datetime targetDate, String elapsedTimeInMins, Integer targetResponseInMins, String timeSinceTargetInMins,  String timeRemainingInMins, Boolean isStop, Boolean isActive, Integer targetDay) {
            this.hasCaseType = hasCaseType;
            this.milestoneStarted= milestoneStarted;
            this.milestoneName = milestoneName;
            this.teamName = teamName;
            this.isViolated = isViolated;
            this.isCompleted = isCompleted;
            this.targetDate = targetDate;
            this.elapsedTimeInMins = elapsedTimeInMins;
            this.targetResponseInMins = targetResponseInMins;
            this.timeSinceTargetInMins = timeSinceTargetInMins;
            this.timeRemainingInMins = timeRemainingInMins;
            this.isStop = isStop;
            this.isActive = isActive;
            this.targetDay = targetDay;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CaseMilestoneWrapper> getCaseMilestonesWithCallTypeDetails(Id caseId) {        
        Boolean isStopped = false;
        Case caseRecord = [SELECT Id, SCC_Call_Type__c, Owner.Profile.Name, OwnerId, isStopped,
                           Entitlement.BusinessHoursId,BusinessHoursId,ShowSLA__c,SCC_Sub_Escalation_Level__c,isClosed
                           FROM Case
                           WHERE Id =:caseId
                           LIMIT 1];
        String caseOwnerId = caseRecord.OwnerId;
        System.debug(caseRecord.Owner.Profile.Name);
        List<SSC_Call_Type__c> callTypeList = [SELECT Id, 
                                               SCC_Agent_SLA__c,
                                               SCC_Total_SLA__c,
                                               SSC_Level_1_Escalation_Team__c,
                                               SCC_Level1_OLA__c,
                                               SSC_Level_2_Escalation_Team__c,
                                               SCC_Level2_OLA__c,
                                               SSC_Level_3_Escalation_Team__c,
                                               SCC_Level3_OLA__c,
                                               SSC_Level_4_Escalation_Team__c,
                                               SCC_Level4_OLA__c
                                               FROM SSC_Call_Type__c
                                               WHERE Id =:caseRecord.SCC_Call_Type__c
                                               WITH SECURITY_ENFORCED
                                               LIMIT 1];
        
        String querymilestones = 'SELECT MilestoneType.Name,IsViolated,IsCompleted,TargetDate,TargetResponseInMins,TimeSinceTargetInMins, ' +
        	'TimeRemainingInMins,ElapsedTimeInMins,BusinessHoursId,CreatedDate ' +
            'FROM CaseMilestone ' +
            'WHERE CaseId =:caseId ' +
            'WITH SECURITY_ENFORCED ' + 
            'ORDER BY CreatedDate DESC ' +
            'LIMIT 50000';
        List<CaseMilestone> milestones = Database.query(querymilestones);
        
        if(caseRecord.IsStopped == false){
            Boolean flag = false;
            String strBusinessHour = caseRecord.Entitlement.BusinessHoursId;
            if(strBusinessHour == null) strBusinessHour = caseRecord.BusinessHoursId;
            if(strBusinessHour != null){
                DateTime dtToday = DateTime.Now();
                Boolean isWithin= BusinessHours.isWithin(strBusinessHour, dtToday); //FALSE -> HOLIDAY
                system.debug('isWithin:'+isWithin);
                if(isWithin == false) flag = true;
                system.debug('flag:'+flag);
            }
            if(flag==true) isStopped = true;
        }else isStopped = true;
        
        Map<String, CaseMilestone> mapTypeName = new Map<String, CaseMilestone>();
        Map<String, Integer> duplicateCounter = new Map<String, Integer>();
        Map<String, custommilestone> MapCM = new Map<String, custommilestone>();

        for (CaseMilestone ms : milestones) {
            String key = ms.MilestoneType.Name;
            Integer iTotal = ms.ElapsedTimeInMins;
            DateTime dtCreated = ms.CreatedDate;
            DateTime dtTarget = ms.TargetDate;
            Integer iTargetMins = ms.TargetResponseInMins;
            if(iTotal == null) iTotal = 0;
            custommilestone cmiles = new custommilestone();
            cmiles.milestonename = key;
            
            if (mapTypeName.containsKey(key)) {
                custommilestone cmilesold = MapCM.get(key);
                Integer iTotalAll = cmilesold.totalsla;
                if(iTotalAll == null) iTotalAll = 0;
                cmiles.totalsla = iTotal+iTotalAll;
                DateTime dtCreatedOld = cmilesold.createddate;
                if(dtCreated < dtCreatedOld){
                    cmiles.targetdate = dtTarget;
                    cmiles.targetmins = iTargetMins;
                    cmiles.createddate = dtCreated;
                }
                
                if (duplicateCounter.containsKey(key)) duplicateCounter.put(key, duplicateCounter.get(key) + 1);
                else duplicateCounter.put(key, 1);
                key = key + '_' + duplicateCounter.get(key);
            }else{
                cmiles.totalsla = iTotal;
                cmiles.targetdate = dtTarget;
                cmiles.targetmins = iTargetMins;
                cmiles.createddate = dtCreated;
            }
            MapCM.put(ms.MilestoneType.Name,cmiles);
            mapTypeName.put(key, ms);
        }
        
        system.debug('MapCM:'+MapCM);
        system.debug('isStopped:'+isStopped);
        system.debug('callTypeList:'+callTypeList);
        system.debug('callTypeList-size:'+callTypeList.size());
        system.debug('mapTypeName:'+mapTypeName);
        system.debug('mapTypeName-size():'+mapTypeName.size());
        
        List<CaseMilestoneWrapper> msWrapper = new List<CaseMilestoneWrapper>();
        if(callTypeList.size()==0){
            Integer slaOlaKanpus = 1 * 1440;
            //Agent OLA (Kanpus)
            msWrapper.addAll(addMilestone(caseRecord,mapTypeName.get('Agent OLA (Kanpus)'),isStopped,false,false,null,slaOlaKanpus,'',null));
            Integer slaOlaUker = 1 * 1440;
            //Customer Service OLA (Uker)
            msWrapper.addAll(addMilestone(caseRecord,mapTypeName.get('Customer Service OLA (Uker)'),isStopped,false,false,null,slaOlaUker,'',null));
        }
        
        if(!callTypeList.isEmpty() && callTypeList != null){
            SSC_Call_Type__c callTypes = callTypeList[0];
            //Total SLA
            Integer slaTotal = Integer.ValueOf(callTypes.SCC_Total_SLA__c * 1440);
            msWrapper.addAll(addMilestone(caseRecord,mapTypeName.get('Total SLA'),isStopped,true,true,'Total SLA',slaTotal,'',MapCM.get('Total SLA')));
            Integer slaOlaKanpus = 1 * 1440;
            //Agent OLA (Kanpus)
            msWrapper.addAll(addMilestone(caseRecord,mapTypeName.get('Agent OLA (Kanpus)'),isStopped,true,false,null,slaOlaKanpus,'',MapCM.get('Agent OLA (Kanpus)')));
            Integer slaOlaUker = 1 * 1440;
            //Customer Service OLA (Uker)
            msWrapper.addAll(addMilestone(caseRecord,mapTypeName.get('Customer Service OLA (Uker)'),isStopped,true,false,null,slaOlaUker,'',MapCM.get('Customer Service OLA (Uker)')));
            //Waiting Document
            msWrapper.addAll(addMilestone(caseRecord,mapTypeName.get('Waiting Document'),isStopped,true,false,null,null,'',MapCM.get('Waiting Document')));
            
            //Level 1 OLA
            if(String.isNOTBlank(callTypes.SSC_Level_1_Escalation_Team__c) && callTypes.SCC_Level1_OLA__c != null){
                Integer slaLevel = Integer.ValueOf(callTypes.SCC_Level1_OLA__c * 1440);
                msWrapper.addAll(addMilestone(caseRecord,mapTypeName.get('Level 1 OLA'),isStopped,true,true,'Level 1 Escalation Team',slaLevel,callTypes.SSC_Level_1_Escalation_Team__c,MapCM.get('Level 1 OLA')));
            }
            //Level 2 OLA
            if(String.isNOTBlank(callTypes.SSC_Level_2_Escalation_Team__c) && callTypes.SCC_Level2_OLA__c != null){
                Integer slaLevel = Integer.ValueOf(callTypes.SCC_Level2_OLA__c * 1440);
                msWrapper.addAll(addMilestone(caseRecord,mapTypeName.get('Level 2 OLA'),isStopped,true,true,'Level 2 Escalation Team',slaLevel,callTypes.SSC_Level_2_Escalation_Team__c,MapCM.get('Level 2 OLA')));
            }
            //Level 3 OLA
            if(String.isNOTBlank(callTypes.SSC_Level_3_Escalation_Team__c) && callTypes.SCC_Level3_OLA__c != null){
                Integer slaLevel = Integer.ValueOf(callTypes.SCC_Level3_OLA__c * 1440);
                msWrapper.addAll(addMilestone(caseRecord,mapTypeName.get('Level 3 OLA'),isStopped,true,true,'Level 3 Escalation Team',slaLevel,callTypes.SSC_Level_3_Escalation_Team__c,MapCM.get('Level 3 OLA')));
            }
            //Level 4 OLA
            if(String.isNOTBlank(callTypes.SSC_Level_4_Escalation_Team__c) && callTypes.SCC_Level4_OLA__c != null){
                Integer slaLevel = Integer.ValueOf(callTypes.SCC_Level4_OLA__c * 1440);
                msWrapper.addAll(addMilestone(caseRecord,mapTypeName.get('Level 4 OLA'),isStopped,true,true,'Level 4 Escalation Team',slaLevel,callTypes.SSC_Level_4_Escalation_Team__c,MapCM.get('Level 4 OLA')));
            }
        }
        
        system.debug('msWrapper:'+msWrapper);
        system.debug('msWrapper-size():'+msWrapper.size());
        
        return msWrapper;
    }
    
    public static List<CaseMilestoneWrapper> addMilestone(Case caseRecord,
                                                          CaseMilestone cm,
                                                         	Boolean isStopped,
                                                         	Boolean hasCaseType,
                                                         	Boolean showMilestone,
                                                         	String milestoneName,
                                                         	Integer slaMilestone,
                                                         	String milestoneTeam, 
                                                         	custommilestone cmiles)
    {
        List<CaseMilestoneWrapper> msWrapper = new List<CaseMilestoneWrapper>();
        Integer totalElapsedTime = 0;
        Integer ElapsedSecond = 0;
        Integer allElapsedTime = 0;
        Integer iTargetMins = 0;
        DateTime dtTarget;
        Integer violatedMins = 0;
        Integer violatedSecond = 0;
        if(cmiles != null){
            allElapsedTime = cmiles.totalsla;
            iTargetMins = cmiles.targetmins;
            //dtTarget = cmiles.targetdate;
        }
        
        if(cm != null){
            if(cm.TimeRemainingInMins != '00:00' && cm.TimeRemainingInMins != null){
                // Split the string by ":"
                List<String> splitTime = (cm.TimeRemainingInMins).split(':');
                // Get the left side of the ":"
                Integer timeRemainingInMins = Integer.ValueOf(splitTime[0]);
                Integer timeRemainingInSeconds = Integer.ValueOf(splitTime[1]);
                Integer ElapsedTime = cm.TargetResponseInMins-timeRemainingInMins;
                totalElapsedTime = ElapsedTime;
                if(totalElapsedTime>0) totalElapsedTime = ElapsedTime-1;
                if(timeRemainingInSeconds > 0) ElapsedSecond = 60-timeRemainingInSeconds;
            } 
            else totalElapsedTime = cm.ElapsedTimeInMins;  
            if(totalElapsedTime == null) totalElapsedTime = 0;
            if(allElapsedTime != null && cm.IsCompleted == false) totalElapsedTime += allElapsedTime; //all time for multiple milestone
            else if(cm.IsCompleted == true) totalElapsedTime = allElapsedTime;
            
            if(milestoneName == null) milestoneName = cm.MilestoneType.Name;
            
            Boolean isViolated = cm.IsViolated;
            
            if(dtTarget == null) dtTarget = cm.TargetDate;
            
            String elapsedTimeInMins = String.ValueOf(totalElapsedTime) + ':' + ElapsedSecond;
            
            if(slaMilestone == null) slaMilestone = cm.TargetResponseInMins;
            Id BusinessHourId = cm.BusinessHoursId;
            DateTime dtNow = DateTime.Now();
            Boolean fgBusinessHour = false;
            if(BusinessHourId != null){
                fgBusinessHour = BusinessHours.isWithin(BusinessHourId, dtNow);
                if(fgBusinessHour == false) isStopped = true;
                else isStopped = false;
            }
            
            
            msWrapper.add(new CaseMilestoneWrapper(hasCaseType,
                                                   true,
                                                   milestoneName,
                                                   milestoneTeam,
                                                   isViolated,
                                                   cm.IsCompleted,
                                                   dtTarget,
                                                   elapsedTimeInMins,
                                                   slaMilestone, //cm.TargetResponseInMins,
                                                   cm.TimeSinceTargetInMins,
                                                   cm.TimeRemainingInMins,
                                                   isStopped,
                                                   false,
                                                   0));
        }else{
            if(showMilestone == true){
                Boolean isCompleted = false;
                Boolean isActive = false;
                String strLevel = caseRecord.SCC_Sub_Escalation_Level__c;
                if(Test.isRunningTest()) strLevel = '4';
                if(hasCaseType == true && milestoneName == 'Total SLA') isActive = true;
                if(caseRecord.IsClosed == true) isCompleted = true;
                else if(strLevel != null){
                	if(milestoneName == 'Level 1 Escalation Team' && 
                       (strLevel.contains('2') || strLevel.contains('3') || strLevel.contains('4'))) isCompleted = true;  
                    else if(milestoneName == 'Level 2 Escalation Team' && 
                       (strLevel.contains('3') || strLevel.contains('4'))) isCompleted = true; 
                    else if(milestoneName == 'Level 3 Escalation Team' && strLevel.contains('4')) isCompleted = true;
                    
                    if(milestoneName == 'Level 1 Escalation Team' && strLevel.contains('1')) isActive = true;
                    else if(milestoneName == 'Level 2 Escalation Team' && strLevel.contains('2')) isActive = true;
                    else if(milestoneName == 'Level 3 Escalation Team' && strLevel.contains('3')) isActive = true;
                    else if(milestoneName == 'Level 4 Escalation Team' && strLevel.contains('4')) isActive = true;
                }
                
                msWrapper.add(new CaseMilestoneWrapper(hasCaseType,
                                                       false,
                                                       milestoneName,
                                                       milestoneTeam,
                                                       false, //isViolated
                                                       isCompleted,
                                                       null,
                                                       '0',
                                                       slaMilestone,
                                                       '00:00',
                                                       '00:00',
                                                       isStopped,
                                                       isActive,
                                                       0));
            }
        }
        return msWrapper;
    }
    
    public class custommilestone{
        public string milestonename {get; set;}
        public datetime targetdate {get; set;}
        public datetime createddate {get; set;}
        public integer targetmins {get; set;}
        public integer totalsla {get; set;}
    }
}