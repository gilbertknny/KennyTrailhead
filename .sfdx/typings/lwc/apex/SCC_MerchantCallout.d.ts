declare module "@salesforce/apex/SCC_MerchantCallout.makeCallout" {
  export default function makeCallout(param: {tid: any, mid: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_MerchantCallout.getTransactionHistory" {
  export default function getTransactionHistory(param: {midOrMpan: any, tidOrStoreId: any, trxDate: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_MerchantCallout.getDetailTransaction" {
  export default function getDetailTransaction(param: {midOrMpan: any, tidOrStoreId: any, trxDate: any, trxTime: any, appCodeOrReffNum: any}): Promise<any>;
}
