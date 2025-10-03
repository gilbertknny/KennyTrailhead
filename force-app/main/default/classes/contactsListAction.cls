public class contactsListAction {
    /*
    //this invocable method takes a single contact id from Flow from a record variable
    //and returns a list of lists of opportunities associated with that contact.
    //the list of lists is stored as a collection variable in the Flow.
    @InvocableMethod (label = 'SendContactsGet Opps' description = 'returns opps for this contact.')
    
    //this method returns a List of Lists of Opps to the flow and receives a List of Ids
    public static List<List<Opportunity>> getContactIds (List<ID> ids) {
        
        //Store in a list the id, closedate and Amounts of opps whose Primary Contact came in the variable "ids"
        //and who have a stage of Clsoed Won and a Close Date of this year
        List<Opportunity> opps = [SELECT id,CloseDate,Amount
                                  FROM Opportunity                                   
                                  WHERE ownerId in :ids 
                                  ]; 
        //declare a new list of lists of opps
        List<List<Opportunity>> itemListList = new List<List<Opportunity>>();
        //add the list opps to the list of lists
        itemListList.add(opps);
        // send list of lists to the Flow	
        return itemListList;        
    }  
        */
}