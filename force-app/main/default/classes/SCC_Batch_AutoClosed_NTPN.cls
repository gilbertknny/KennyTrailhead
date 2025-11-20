/**
 * @description       : Batch class for auto-closing cases based on NTPN
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 23-05-2025
 * @last modified by  : Ardyta Yudianto
**/

global class SCC_Batch_AutoClosed_NTPN implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    private String query;
    private Integer successCount = 0;
    private Integer failCount = 0;
    
    /**
     * Constructor that accepts a query string for the batch
     * 
     * @param query The SOQL query to be used in the batch process
     */
    global SCC_Batch_AutoClosed_NTPN(String query) {
        this.query = query;
    }
    
    /**
     * Start method for the batch process
     * 
     * @param bc The batch context
     * @return Database.QueryLocator The query locator with the records to process
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    /**
     * Execute method for the batch process
     * 
     * @param bc The batch context
     * @param scope The list of records to process in this batch
     */
    global void execute(Database.BatchableContext bc, List<Case> scope) {
        List<Case> casesToUpdate = new List<Case>();
        
        // Debug the number of records in this batch execution
        System.debug('===== SCC_Batch_AutoClosed_NTPN: Processing ' + scope.size() + ' cases =====');
        
        try {
            for (Case cs : scope) {
                // Debug current case being processed
                System.debug('Processing Case: ' + cs.Id + ', Billing Number: ' + cs.scc_Billing_Number__c);
                
                // Only process cases with billing numbers
                if (cs.scc_Billing_Number__c != null) {
                    try {
                        System.debug('Calling searchBillingMPN for case ' + cs.Id + ' with billing number: ' + cs.scc_Billing_Number__c);
                        
                        // Search for billing MPN using the existing method
                        SCC_BillingMPN_Wrapper.BillingMPN_Response response = 
                            SCC_BillingMPN_Ctrl.searchBillingMPN(
                                cs.scc_Billing_Number__c, 
                                'IDR', 
                                cs.Id
                            );
                        
                        // Debug the response
                        System.debug('searchBillingMPN Response for case ' + cs.Id + ': ' + JSON.serialize(response));
                        System.debug('response transactionAmount : '+response.data.transactionAmount);
                        System.debug('Case Amount : '+cs.SCC_Amount__c);
                        
                        // Check if response contains NTPN information
                    if (response != null &&
                        response.data != null &&
                        response.data.kodeNTPN != null &&
                        response.data.kodeNTPN != '' &&
                        Decimal.valueOf(response.data.transactionAmount) == cs.SCC_Amount__c) 
                        {
                            System.debug('Valid NTPN found for case ' + cs.Id + ': ' + response.data.kodeNTPN);
                            System.debug('Transaction Amount ' + ': ' + response.data.transactionAmount);
                            // Update case with success status and NTPN information
                            cs.MPN_ID__c = response.data.kodeNTPN;  
                            cs.SCC_Status_Transaksi__c = 'Berhasil';
                            cs.SCC_Drone_Remark_Update__c = 'Transaksi sukses dengan nomor NTPN : ' + response.data.kodeNTPN;
                            cs.Status = 'Closed';
                            
                            casesToUpdate.add(cs);
                            successCount++;
                            System.debug('Case ' + cs.Id + ' marked for update. Success count: ' + successCount);
                        } else {
                            System.debug('No valid NTPN found for case ' + cs.Id + '. Response data: ' + 
                                        (response != null ? (response.data != null ? 'Data not null but no kodeNTPN' : 'No data in response') : 'Null response'));
                            System.debug('Transaction Amount ' + ': ' + response.data.transactionAmount);
                        }
                    } catch (Exception e) {
                        // Log exception but continue processing other cases
                        System.debug('ERROR: Exception processing case ' + cs.Id + ': ' + e.getMessage() + ' at line: ' + e.getLineNumber());
                        System.debug('Stack trace: ' + e.getStackTraceString());
                        failCount++;
                    }
                } else {
                    System.debug('Case ' + cs.Id + ' has no billing number. Skipping.');
                }
            }
            
            // Update cases in bulk if any
            if (!casesToUpdate.isEmpty()) {
                System.debug('Attempting to update ' + casesToUpdate.size() + ' cases');
                List<Database.SaveResult> updateResults = Database.update(casesToUpdate, false);
                
                // Process save results for error logging
                for (Integer i = 0; i < updateResults.size(); i++) {
                    if (!updateResults[i].isSuccess()) {
                        System.debug('ERROR: Failed to update case ' + casesToUpdate[i].Id);
                        for (Database.Error err : updateResults[i].getErrors()) {
                            System.debug('Error details: ' + err.getStatusCode() + ' - ' + err.getMessage());
                            System.debug('Error fields: ' + err.getFields());
                        }
                        failCount++;
                        successCount--;  // Adjust success count for the failed update
                    } else {
                        System.debug('Successfully updated case: ' + casesToUpdate[i].Id);
                    }
                }
            } else {
                System.debug('No cases to update in this batch');
            }
        } catch (Exception e) {
            // Handle any unexpected exceptions
            System.debug('CRITICAL ERROR: Batch execution error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
            System.debug('Stack trace: ' + e.getStackTraceString());
            failCount += scope.size();
        }
        
        System.debug('===== SCC_Batch_AutoClosed_NTPN: Completed batch with Success: ' + successCount + ', Failed: ' + failCount + ' =====');
    }
    
    /**
     * Finish method for the batch process
     * 
     * @param bc The batch context
     */
    global void finish(Database.BatchableContext bc) {
        System.debug('===== SCC_Batch_AutoClosed_NTPN: Batch job completed =====');
        System.debug('Total successful updates: ' + successCount);
        System.debug('Total failed updates: ' + failCount);
        
        System.debug('Starting SCC_Batch_AutoClosed_MPN as chained batch...');
        Database.executeBatch(new SCC_Batch_AutoClosed_MPN(query), 1);

    }
}