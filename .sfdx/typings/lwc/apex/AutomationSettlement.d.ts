declare module "@salesforce/apex/AutomationSettlement.getInstance" {
  export default function getInstance(param: {pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/AutomationSettlement.getSearchCases" {
  export default function getSearchCases(param: {pageNumber: any, pageSize: any, calltype: any, noTicket: any, tanggalKomplain: any}): Promise<any>;
}
declare module "@salesforce/apex/AutomationSettlement.approveTickets" {
  export default function approveTickets(param: {ticketIds: any, userId: any}): Promise<any>;
}
declare module "@salesforce/apex/AutomationSettlement.approveAllTickets" {
  export default function approveAllTickets(): Promise<any>;
}
declare module "@salesforce/apex/AutomationSettlement.updateChecker" {
  export default function updateChecker(param: {newList: any, oldMap: any}): Promise<any>;
}
