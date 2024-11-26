declare module "@salesforce/apex/FileUploadController.contentData" {
  export default function contentData(param: {conVerId: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploadController.fileSize" {
  export default function fileSize(param: {contentId: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploadController.uploadFile" {
  export default function uploadFile(param: {contentVersionId: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploadController.deleteFile" {
  export default function deleteFile(param: {contentDocumentId: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploadController.uploadFiles" {
  export default function uploadFiles(param: {contentVersionIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploadController.uploadFilesToITSM" {
  export default function uploadFilesToITSM(param: {lcvid: any, lcdid: any, recId: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploadController.deleteFiles" {
  export default function deleteFiles(param: {contentDocumentIds: any}): Promise<any>;
}
