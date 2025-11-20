public with sharing class SLSosmedController {
    @AuraEnabled
    public static Map<String, Object> updateCaseTimer(Id caseId) {
        Case c = [SELECT Id, SCC_SL_Sosmed_Timer_Dimulai__c, Date_Time_Answer__c, Status, SCC_SL_Sosmed_Waktu_Stop__c 
                  FROM Case WHERE Id = :caseId LIMIT 1];
        
        Map<String, Object> response = new Map<String, Object>();
        DateTime now = DateTime.now();
        DateTime timerStarted = c.SCC_SL_Sosmed_Timer_Dimulai__c;
        Boolean isCompleted = false;
        Boolean isViolated = false;
        String timerDisplay;

        if (c.Date_Time_Answer__c != null || 
            c.Status == 'Closed' || c.Status == 'Cancelled' || c.Status == 'Disconnected') {
            isCompleted = true;
            response.put('timerDisplay', c.SCC_SL_Sosmed_Waktu_Stop__c != null 
                          ? c.SCC_SL_Sosmed_Waktu_Stop__c : '00:00');
        } else {
            Long elapsedMillis = now.getTime() - timerStarted.getTime();
            Integer remainingSeconds = 900 - (elapsedMillis / 1000).intValue();
            
            if (remainingSeconds < 0) {
                isViolated = true;
                timerDisplay = formatTime(Math.abs(remainingSeconds)) + ' (Violated)';
            } else {
                timerDisplay = formatTime(remainingSeconds);
            }

            response.put('timerDisplay', timerDisplay);
        }

        update c;

        response.put('isCompleted', isCompleted);
        response.put('isViolated', isViolated);
        return response;
    }

    private static String formatTime(Integer totalSeconds) {
        Integer minutes = Math.floor(totalSeconds / 60).intValue();
        Integer seconds = Math.mod(totalSeconds, 60);
        return String.format('{0}:{1}', new List<Object>{ minutes, seconds });
    } 

    public class caseSosmedWrapper {
        @AuraEnabled
        public Boolean isCompleted {get; set;}
        @AuraEnabled
        public Boolean isViolated {get;set;}
        @AuraEnabled
        public String endCaptureTime {get; set;}

        public caseSosmedWrapper(Boolean isCompleted, Boolean isViolated, String endCaptureTime){
            this.isCompleted = isCompleted;
            this.isViolated = isViolated;
            this.endCaptureTime = endCaptureTime;
        }
    }
    
    @AuraEnabled
    public static caseSosmedWrapper updateStatusSL(String caseId, Boolean isCompleted, Boolean isViolated, String endTimeCapture){
        Boolean isComplete = false;
        Boolean isViolate = false;
        String endCaptureTime = '';

        try {
            List<Case> caseSosmed = [
                SELECT Id, SCC_SL_Sosmed_Timer_Dimulai__c, 
                       SCC_SL_Sosmed_Waktu_Stop__c, 
                       SCC_SL_Sosmed_Completed__c, 
                       SCC_SL_Sosmed_Violation__c,
                       Date_Time_Answer__c,
                       Date_Time_Post__c,
                       Response_Time_Minutes_v2__c,
                       Status
                FROM Case 
                WHERE Id = :caseId
                LIMIT 1
            ];  

            if(caseSosmed.size() > 0){
                Case cs = caseSosmed[0];

                if(isCompleted){
                    cs.SCC_SL_Sosmed_Completed__c = true;
                    isComplete = true;
                    
                    // add SCC_SL_Sosmed_Waktu_Stop__c
                    if(String.isNotBlank(endTimeCapture)) {
                        endCaptureTime = endTimeCapture;
                        cs.SCC_SL_Sosmed_Waktu_Stop__c = endTimeCapture;
                    } else if(cs.Response_Time_Minutes_v2__c != null) {
                        endCaptureTime = formatResponseTime(cs.Response_Time_Minutes_v2__c);
                        cs.SCC_SL_Sosmed_Waktu_Stop__c = endCaptureTime;
                    } else {
                        endCaptureTime = '0 Detik';
                        cs.SCC_SL_Sosmed_Waktu_Stop__c = endCaptureTime;
                    }
                }

                if(isViolated){
                   cs.SCC_SL_Sosmed_Violation__c = true;
                   isViolate = true;
                }

                update cs;
            } 

            caseSosmedWrapper csw = new caseSosmedWrapper(isComplete, isViolate, endCaptureTime);
            return csw;

        } catch (Exception e){
            throw new AuraHandledException('Failed to update case: ' + e.getMessage()); 
        }  
    }
    
    private static String formatResponseTime(Decimal minutes) {
        if(minutes == null || minutes == 0) return '0 Detik';
        
        Integer totalMinutes = minutes.intValue();
        Integer seconds = ((minutes - totalMinutes) * 60).intValue();
        
        Integer days = totalMinutes / (24 * 60);
        Integer hours = Math.mod(totalMinutes, (24 * 60)) / 60;
        Integer remainingMinutes = Math.mod(totalMinutes, 60);
        
        String formattedTime = '';
        
        if(days > 0) {
            formattedTime += days + ' Hari ';
        }
        if(hours > 0) {
            formattedTime += hours + ' Jam ';
        }
        if(remainingMinutes > 0) {
            formattedTime += remainingMinutes + ' Menit ';
        }
        if(seconds > 0 || formattedTime == '') {
            formattedTime += seconds + ' Detik';
        }
        
        return formattedTime.trim();
    }
}