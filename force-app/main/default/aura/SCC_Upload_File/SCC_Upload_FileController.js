({
    handleUploadFinished : function(component,event,helper){
      var files = event.getParams("files");
      helper.handleUpload(component,event,files);
    }
})