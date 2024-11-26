declare module "@salesforce/apex/CustomLookupController.fetchRecords" {
  export default function fetchRecords(param: {objectName: any, filterField: any, searchString: any, ft: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomLookupController.getListAPI" {
  export default function getListAPI(param: {searchString: any, tgl: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomLookupController.getDataDetail" {
  export default function getDataDetail(param: {tgl: any, termid: any}): Promise<any>;
}
