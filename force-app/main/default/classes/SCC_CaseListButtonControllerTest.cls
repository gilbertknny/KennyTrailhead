@isTest
private class SCC_CaseListButtonControllerTest {

    @isTest
    static void testRedirectToForm() {
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Case());
        SCC_CaseListButtonController controller = new SCC_CaseListButtonController(stdController);

        System.assertEquals(true, controller.redirectToForm);
    }
}