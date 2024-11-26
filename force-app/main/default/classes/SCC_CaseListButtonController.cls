public with sharing class SCC_CaseListButtonController {
    public Boolean redirectToForm { get; set; }

    public SCC_CaseListButtonController(ApexPages.StandardController controller) {
        redirectToForm = true;
    }
}