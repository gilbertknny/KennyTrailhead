declare module "@salesforce/apex/SCC_CustomerVerificationController.fetchBankingDataFromAPI" {
  export default function fetchBankingDataFromAPI(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CustomerVerificationController.fetchCreditDataFromAPI" {
  export default function fetchCreditDataFromAPI(param: {caseId: any, cardNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CustomerVerificationController.saveRecord" {
  export default function saveRecord(param: {caseStr: any}): Promise<any>;
}
