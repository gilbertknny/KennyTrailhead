declare module "@salesforce/apex/SCC_HomePageSearch.getCustomerProfile" {
  export default function getCustomerProfile(param: {req: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_HomePageSearch.getCardLink" {
  export default function getCardLink(param: {cardNo: any, phoneNumber: any, customerNumber: any, nik: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_HomePageSearch.getDPLK" {
  export default function getDPLK(param: {idNumber: any, acctNo: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_HomePageSearch.getMerchant" {
  export default function getMerchant(param: {tid: any, mid: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_HomePageSearch.getBRILink" {
  export default function getBRILink(param: {tid: any, mid: any}): Promise<any>;
}
