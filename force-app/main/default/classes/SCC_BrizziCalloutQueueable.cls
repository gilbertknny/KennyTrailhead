public with sharing class SCC_BrizziCalloutQueueable implements Queueable, Database.AllowsCallouts {
    private String recordId;
    private String operationType;
    
    public SCC_BrizziCalloutQueueable(String recordId, String operationType) {
        this.recordId = recordId;
        this.operationType = operationType;
    }
    
    public void execute(QueueableContext context) {
        if (operationType == 'Adjust Deposit') {
            SCC_Brizzi_AdjustDeposit_UI.adjustDepositBrizzi(recordId);
        } 
        else if (operationType == 'Replace Card Invoc') {
            SCC_Brizzi_CardReplace_UI.replaceCard(recordId);
        }
        else if (operationType == 'Pembukuan Ulang Brizzi') {
            SCC_Brizzi_Pembukuan.pembukuanBrizzi(recordId,'',true);
        }
        else if (operationType == 'pembukuan') {
            SCC_Brizzi_Pembukuan.pembukuanBrizzi(recordId,'',false);
        }
        // else if (operationType == 'FindRTGS') {
        //     SCC_CaseResolution_RTGS_Ctrl.updateBillingNumber(recordId);
        // }
        else if (operationType == 'BillingMPN') {
            SCC_BillingMPN_Ctrl.updateBillingNumber(recordId);
        }
    }
}