declare module "@salesforce/apex/SCC_ApprovalCheckerController.getInstance" {
  export default function getInstance(param: {pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_ApprovalCheckerController.getSearchCases" {
  export default function getSearchCases(param: {pageNumber: any, pageSize: any, calltype: any, noTicket: any, tanggalKomplain: any, cekNota: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_ApprovalCheckerController.approveTickets" {
  export default function approveTickets(param: {newList: any, oldMap: any}): Promise<any>;
}
