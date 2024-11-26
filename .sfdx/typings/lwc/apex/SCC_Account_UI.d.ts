declare module "@salesforce/apex/SCC_Account_UI.getInformasiCustomer" {
  export default function getInformasiCustomer(param: {idacc: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_Account_UI.getInformasiFinansial" {
  export default function getInformasiFinansial(param: {idacc: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_Account_UI.getMutasiRekening" {
  export default function getMutasiRekening(param: {norek: any, tglawal: any, tglakhr: any, idacc: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_Account_UI.getMutasiKartu" {
  export default function getMutasiKartu(param: {nokar: any, idacc: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_Account_UI.getHoldStatus" {
  export default function getHoldStatus(param: {norek: any, idacc: any}): Promise<any>;
}
