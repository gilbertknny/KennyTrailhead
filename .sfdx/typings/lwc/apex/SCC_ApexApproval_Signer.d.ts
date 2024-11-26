declare module "@salesforce/apex/SCC_ApexApproval_Signer.getInstance" {
  export default function getInstance(param: {pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_ApexApproval_Signer.getSearchCases" {
  export default function getSearchCases(param: {pageNumber: any, pageSize: any, calltype: any, noTicket: any, tanggalKomplain: any, cekNota: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_ApexApproval_Signer.approveTickets" {
  export default function approveTickets(param: {ticketIds: any, userId: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_ApexApproval_Signer.updateSigner" {
  export default function updateSigner(param: {newList: any, oldMap: any}): Promise<any>;
}
