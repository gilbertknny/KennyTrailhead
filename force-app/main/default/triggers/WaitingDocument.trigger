trigger WaitingDocument on Case_Waiting_Document__c (before update) {
    BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name='Back Office'];
    for(Case_Waiting_Document__c CWS:system.trigger.new)
    {
      /* if(CWS.startdatetime__c != null && CWS.enddatetime__c!=null)
        {
              Long TotalTime=BusinessHours.diff(bh.id,CWS.startdatetime__c,CWS.enddatetime__c);
                
            CWS.total_Duration__c=Decimal.valueof(totaltime)/(1000*60*60*24);
           
        }*/
        if(CWS.startdate__c!=null && CWS.enddate__c!=null)
        {
            Datetime CheckDateTime=CWS.startdatetime__c.adddays(1);
            Date CheckDate=date.valueof(CheckDatetime);
            Integer totaldaysbetween=CWS.startdate__c.daysbetween(CWS.enddate__c);
            Integer weekenddays=0;
            while(CWS.enddate__c>=Checkdate)
            {
                String dayOfWeek = checkdatetime.format('EEEE');
                if(dayofweek=='Saturday'||dayofweek=='Sunday')
                {
                    weekenddays=weekenddays+1;
                }
                checkdatetime=checkdatetime.adddays(1);
                checkdate=checkdate.adddays(1);
            }
             CWS.total_Duration__c=totaldaysbetween-weekenddays;
        }
    }
    
}