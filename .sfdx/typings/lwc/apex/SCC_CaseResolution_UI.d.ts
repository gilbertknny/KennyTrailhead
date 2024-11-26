declare module "@salesforce/apex/SCC_CaseResolution_UI.getCaseDetail" {
  export default function getCaseDetail(param: {idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getListRekeningKoran" {
  export default function getListRekeningKoran(param: {idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getListRekon" {
  export default function getListRekon(param: {idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getListBAO" {
  export default function getListBAO(param: {idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getListAktivitasKartu" {
  export default function getListAktivitasKartu(param: {idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getListQueuetrans" {
  export default function getListQueuetrans(param: {idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getCallTypeDetail" {
  export default function getCallTypeDetail(param: {idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getFiturDetail" {
  export default function getFiturDetail(param: {idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getTerminalDetail" {
  export default function getTerminalDetail(param: {idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getNotifWA" {
  export default function getNotifWA(param: {cs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getRekeningKoran" {
  export default function getRekeningKoran(param: {accnum: any, strdt: any, enddt: any, cs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getRekon" {
  export default function getRekon(param: {cs: any, tgl: any, trmid: any, ctid: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getBAO" {
  export default function getBAO(param: {tgl: any, trmid: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getAktivitasKartu" {
  export default function getAktivitasKartu(param: {cs: any, posisiawal: any, posisiakhir: any, fitur: any, nomor: any, scope: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getEJLog" {
  export default function getEJLog(param: {tid: any, dateReq: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.getListEJ" {
  export default function getListEJ(param: {idcs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.updateCase" {
  export default function updateCase(param: {cs: any, rmk: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.insertRekeningKoran" {
  export default function insertRekeningKoran(param: {cs: any, listrekening: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.insertRekon" {
  export default function insertRekon(param: {cs: any, listrekon: any, tgl: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.insertBAO" {
  export default function insertBAO(param: {cs: any, listbao: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.insertFile" {
  export default function insertFile(param: {csid: any, condocid: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.deleteBAO" {
  export default function deleteBAO(param: {listbao: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.deleteRekon" {
  export default function deleteRekon(param: {listrek: any, cs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.deleteRekeningKoran" {
  export default function deleteRekeningKoran(param: {listrek: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.CustomerProfileDetail" {
  export default function CustomerProfileDetail(param: {cs: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.insertAktivitasKartu" {
  export default function insertAktivitasKartu(param: {cs: any, listrekening: any, msg: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.deleteAktivitasKartu" {
  export default function deleteAktivitasKartu(param: {listrek: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.insertEJ" {
  export default function insertEJ(param: {cs: any, listrekening: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.deleteEJ" {
  export default function deleteEJ(param: {listrek: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.updateEJ" {
  export default function updateEJ(param: {ejList: any}): Promise<any>;
}
declare module "@salesforce/apex/SCC_CaseResolution_UI.deleteAllEJRecords" {
  export default function deleteAllEJRecords(param: {caseId: any}): Promise<any>;
}
