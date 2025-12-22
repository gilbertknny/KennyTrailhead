public class opptyFluc {
// @AuraEnabled(cacheable=true)
//     public static List<Map<String, String>> getOpportunities() {
//         List<Opportunity> opps = [
//             SELECT Id, Name, The_Insured_Name__r.name,
//             Confirmed_by_RI__c,Confirmed_by_RI_Amount__c,
//             Confirmed_to_RI__c,Confirmed_to_RI_Amount__c,
//             Request_Number__c,Sum_Insured__c,
//             Share_Offered__c,Share_Offered_Amount__c,
//             Offering_status__c
//             FROM Opportunity
//             WHERE Opportunity_Type__c = 'Facultative Outward'
//         ];

//         List<Map<String, String>> result = new List<Map<String, String>>();
//         for (Opportunity opp : opps) {
//             result.add(new Map<String, String>{
//                 'label' => opp.Name,
//                 'value' => opp.Id,
//               	'requestNumber' => opp.Request_Number__c,
//                 'insuredName' => opp.The_Insured_Name__r.name,
//                 'confirmedbyRI' => String.valueOf(opp.Confirmed_by_RI__c),
//                 'byRIAmount' => String.valueOf(opp.Confirmed_by_RI_Amount__c),
//                 'confirmedtoRI' => String.valueOf(opp.Confirmed_to_RI__c),
//                 'toRIAmount' => String.valueOf(opp.Confirmed_to_RI_Amount__c),
//                 'sumInsured' => String.valueOf(opp.Sum_Insured__c),
//                 'sharedOffered' => String.valueOf(opp.Share_Offered__c),
//                 'amountOffered' => String.valueOf(opp.Share_Offered_Amount__c),
//                 'offeredStatus' => opp.Offering_status__c
                   
               
//             });
//         }

//         return result;
//     }
//      @AuraEnabled
//       public static void saveFacultativeData(Map<String, Object> data) {
//         Id opptyId = (Id) data.get('opportunityId');

//         if (opptyId == null) {
//             throw new AuraHandledException('Please select Opportunity first');
//         }

//         Opportunity oppToUpdate = new Opportunity(
//             Id = opptyId,
//             Sum_Insured__c = Decimal.valueOf((String)data.get('tsiAccum')),
//             Share_Offered__c      = Decimal.valueOf((String)data.get('sharedOffered')),
//             //Share_Offered_Amount__c = (Decimal) data.get('offeredValue'),
//             Confirmed_by_RI__c    = Decimal.valueOf((String)data.get('confirmedByRIPercent')),
//             //Confirmed_by_RI_Amount__c = (Decimal) data.get('confirmedByRIValue'),
//             Confirmed_to_RI__c    = Decimal.valueOf((String)data.get('confirmedToRIPercent'))
//             //Confirmed_to_RI_Amount__c = (Decimal) data.get('confirmedToRIValue')
//             // add more mappings as needed
//         );

//         update oppToUpdate;
//     }

}