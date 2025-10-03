public class LoanAmortizationController {
    
    public String pdf_content { get; set; }
    public List<API_Loan_Amortization__c> loanAmortization { get; set; }
    public List<AmortizationWrapper> amortizationWithOS { get; set; }
    public string customerName { get; set; }
    public string agreementNo { get; set; }
    public string branchManager { get; set; }
    public decimal totalInstallment { get; set; }
    public decimal totalPrincipal { get; set; }
    public decimal totalInterest { get; set; }
    
    public class AmortizationWrapper {
        public API_Loan_Amortization__c amortRecord { get; set; }
        public Decimal os_principal { get; set; }
        public Decimal os_interest { get; set; }
        
        public AmortizationWrapper(API_Loan_Amortization__c record) {
            this.amortRecord = record;
            this.os_principal = 0;
            this.os_interest = 0;
        }
    }
    
    public LoanAmortizationController() {
        totalInstallment = 0;
        totalPrincipal = 0;
        totalInterest = 0;
        amortizationWithOS = new List<AmortizationWrapper>();

        String relatedId = ApexPages.currentPage().getParameters().get('id');

        if (relatedId != null) {
            loanAmortization = [
                SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                       LastModifiedById, SystemModstamp, Loan_Information__c, admin_fee__c, 
                       installment__c, interest__c, loan_calculation_id__c, principal__c, 
                       provision_fee__c, sequence__c, related_id__c
                FROM API_Loan_Amortization__c
                WHERE related_id__c = :relatedId
                ORDER BY sequence__c
            ];
            
            // First pass: Calculate totals
            for (API_Loan_Amortization__c amort : loanAmortization) {
                totalInstallment += amort.installment__c != null ? amort.installment__c : 0;
                totalPrincipal += amort.principal__c != null ? amort.principal__c : 0;
                totalInterest += amort.interest__c != null ? amort.interest__c : 0;
            }
            
            // Second pass: Calculate outstanding balances
            Decimal remainingPrincipal = totalPrincipal;
            Decimal remainingInterest = totalInterest;
            boolean isFirst = true;
            
            for (API_Loan_Amortization__c amort : loanAmortization) {
                // Create wrapper
                AmortizationWrapper wrapper = new AmortizationWrapper(amort);
                
                // Set outstanding balances before deducting current payment
                wrapper.os_principal = remainingPrincipal - amort.principal__c;
                wrapper.os_interest = remainingInterest - amort.interest__c;
                
                // Deduct current payment from remaining balances
                remainingPrincipal -= amort.principal__c != null ? amort.principal__c : 0;
                remainingInterest -= amort.interest__c != null ? amort.interest__c : 0;
                
                // Ensure balances don't go negative
                if (remainingPrincipal < 0) remainingPrincipal = 0;
                if (remainingInterest < 0) remainingInterest = 0;
                
                amortizationWithOS.add(wrapper);
            }
            
            List<Application__c> applications = [
                SELECT Customer_Name__c, agreement_number__c, Branch_Manager__c
                FROM Application__c 
                WHERE Id = :relatedId 
                LIMIT 1
            ];
            
            if (!applications.isEmpty()) {
                customerName = applications[0].Customer_Name__c != null ? applications[0].Customer_Name__c : '-';
                agreementNo = applications[0].agreement_number__c != null ? applications[0].agreement_number__c : '-';
                branchManager = applications[0].Branch_Manager__c != null ? applications[0].Branch_Manager__c : '-';
            } else {
                customerName = '-';
                agreementNo = '-';
                branchManager = '-';
            }
        }
    }
}