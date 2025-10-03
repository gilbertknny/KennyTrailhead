@isTest
private class LoanAmortizationControllerTest {
    
   @IsTest
    static void testControllerTotalsAndWrappers() {
        // Create test data
        
        Application__c app = BFI_TestDataFactory.createApplication('Test App', 'AGR-001', 'Jane Smith');
        BFI_TestDataFactory.createAmortizations(app, 3, 1000, 700, 300);

        // Set page parameter
        PageReference pageRef = new PageReference('/apex/dummyPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', app.Id);

        // Instantiate controller
        LoanAmortizationController controller = new LoanAmortizationController();

        // Assert totals
        System.assertEquals(3000, controller.totalInstallment);
        System.assertEquals(2100, controller.totalPrincipal);
        System.assertEquals(900, controller.totalInterest);

        // Assert wrapper list
        System.assertEquals(3, controller.amortizationWithOS.size());

        // Assert outstanding balances
        LoanAmortizationController.AmortizationWrapper firstWrapper = controller.amortizationWithOS[0];
        System.assertEquals(1400, firstWrapper.os_principal);
        System.assertEquals(600, firstWrapper.os_interest);

        LoanAmortizationController.AmortizationWrapper lastWrapper = controller.amortizationWithOS[2];
        System.assertEquals(0, lastWrapper.os_principal);
        System.assertEquals(0, lastWrapper.os_interest);

        // Assert customer info
        //System.assertEquals('John Doe', controller.customerName);
        //System.assertEquals('AGR-001', controller.agreementNo);
        System.assertEquals('Jane Smith', controller.branchManager);
    }

    @IsTest
    static void testControllerWithNoApplication() {
        // Set page parameter to a random Id that does not exist
        PageReference pageRef = new PageReference('/apex/dummyPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', '001000000000000AAA');

        // Instantiate controller
        LoanAmortizationController controller = new LoanAmortizationController();

        // Totals should be zero
        System.assertEquals(0, controller.totalInstallment);
        System.assertEquals(0, controller.totalPrincipal);
        System.assertEquals(0, controller.totalInterest);

        // No wrapper records
        System.assertEquals(0, controller.amortizationWithOS.size());

        // Customer info should default to '-'
        System.assertEquals('-', controller.customerName);
        System.assertEquals('-', controller.agreementNo);
        System.assertEquals('-', controller.branchManager);
    }
    
}