@isTest
public class SessionPlugin_Test {
	static testmethod void testProcess () {
      
        SessionPlugin plugin = new SessionPlugin();
        Map<String,Object> inputParams = new Map<String,Object>();
        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        plugin.invoke(request);
        plugin.describe();
    } 
}