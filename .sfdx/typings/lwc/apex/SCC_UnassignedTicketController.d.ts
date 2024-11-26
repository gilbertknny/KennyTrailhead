declare module "@salesforce/apex/SCC_UnassignedTicketController.getSearchCases" {
  export default function getSearchCases(param: {pageNumber: any, pageSize: any, calltype: any, noTicket: any, tanggalKomplain: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_UnassignedTicketController.getBackOfficeAgents" {
  export default function getBackOfficeAgents(): Promise<any>;
}
declare module "@salesforce/apex/SCC_UnassignedTicketController.assignCasesToAgent" {
  export default function assignCasesToAgent(param: {agentIds: any, caseIds: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_UnassignedTicketController.getBatchJobStatus" {
  export default function getBatchJobStatus(param: {jobID: any}): Promise<any>;
}
