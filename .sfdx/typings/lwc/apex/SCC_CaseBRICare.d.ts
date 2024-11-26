declare module "@salesforce/apex/SCC_CaseBRICare.getPortofolio" {
  export default function getPortofolio(param: {idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getMutation" {
  export default function getMutation(param: {norekVarchar: any, tanggalAwalDatetime: any, tanggalAkhirDatetime: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getCardDetailDebit" {
  export default function getCardDetailDebit(param: {cardNo: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getCustomer" {
  export default function getCustomer(param: {acctNo: any, cardNo: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getMachine" {
  export default function getMachine(param: {alamatMesin: any, tid: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getCardLink" {
  export default function getCardLink(param: {idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getCardLinkbyCardNumber" {
  export default function getCardLinkbyCardNumber(param: {CardNumber: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getTrxCredit" {
  export default function getTrxCredit(param: {cardNumber: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getPengajuanKartu" {
  export default function getPengajuanKartu(param: {idNumber: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getBRILink" {
  export default function getBRILink(param: {tid: any, mid: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getMerchant" {
  export default function getMerchant(param: {tid: any, mid: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getMerchantTrx" {
  export default function getMerchantTrx(param: {cdh: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getWholeSaleBRIMola" {
  export default function getWholeSaleBRIMola(param: {idPangkalan: any, startDate: any, endDate: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getDPLK" {
  export default function getDPLK(param: {acctNo: any, idNumber: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getHoldStatus" {
  export default function getHoldStatus(param: {norek: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getBranch" {
  export default function getBranch(param: {kode: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getCustomerVerification" {
  export default function getCustomerVerification(param: {norek: any, idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.UpdateVerification" {
  export default function UpdateVerification(param: {cv: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseBRICare.getTID" {
  export default function getTID(param: {data: any}): Promise<any>;
}
