global class SessionPlugin implements Process.Plugin
{    
   global Process.PluginDescribeResult describe()
   {
      Process.PluginDescribeResult result = new Process.PluginDescribeResult();
      result.description='This plug-in returns the no of concurrent sessions for the current user';
      result.tag='Identity';
       
      result.inputParameters = new List<Process.PluginDescribeResult.InputParameter> {
      };
       
      result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter> {
           new Process.PluginDescribeResult.OutputParameter('CONCURRENT_NO',
               Process.PluginDescribeResult.ParameterType.INTEGER),
           new Process.PluginDescribeResult.OutputParameter('SESSION_ID',
               Process.PluginDescribeResult.ParameterType.STRING)     
      };
       
       return result;
   }
   
   global Process.PluginResult invoke(Process.PluginRequest request)
   {   
       Map<String, Object> result = new Map<String, Object>();
       Integer no = 0;
       String session = '';
       String userid = UserInfo.getUserId();  
       List<AuthSession> sessions = [SELECT Id, ParentId, SessionType FROM AuthSession 
                   WHERE UsersId=:userid
                  AND ParentId = null
                  AND SessionType NOT IN ('TempUIFrontdoor','InternalServiceCall','UnspecifiedType')
                  ORDER BY CreatedDate ASC]; 
       for (AuthSession s : sessions)
       {
           // Count only parent and non-temp and non-internal sessions
           if(no==0) session = s.Id;
           no++;
       }
       system.debug('session:'+session);
       if(session != '') result.put('SESSION_ID', session);
       result.put('CONCURRENT_NO', no);
       return new Process.PluginResult(result);
   }
}