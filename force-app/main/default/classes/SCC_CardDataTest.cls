@isTest
private class SCC_CardDataTest {

    @isTest
    static void testConstructor1() {
        // Test data
        String cardNo = '1234567890123456';
        String type = 'Credit';
        String name = 'John Doe';
        String cardStatus = 'Active';
        String statusDesc = 'Card is currently active';
        String lastMaint = '2024-07-08';
        String userMaint = 'Admin';
        String activeDateCard = '2024-07-01';
        String issueDateCard = '2024-06-15';
        String expDateCard = '2025-06-30';
        String blockDate = null; // Assuming not blocked
        
        // Create an instance using constructor 1
        SCC_CardData cardData = new SCC_CardData(cardNo, type, name, cardStatus, statusDesc, lastMaint,
                                                 userMaint, activeDateCard, issueDateCard, expDateCard, blockDate);
        
        // Verify initialization
        System.assertEquals(cardNo, cardData.cardNo, 'Card number should be formatted correctly.');
        System.assertEquals(type, cardData.type, 'Card type');
        System.assertEquals(name, cardData.name, 'Name of the Account');
        System.assertEquals(cardStatus, cardData.cardStatus, 'Card status is displayed');
        System.assertEquals(statusDesc, cardData.statusDesc, 'Description of the card status');
        System.assertEquals(lastMaint, cardData.lastMaint, 'Last maintainence Date');
        System.assertEquals(userMaint, cardData.userMaint, 'Last Maintainence User');
        System.assertEquals(activeDateCard, cardData.activeDateCard,'Active Card Date');
        System.assertEquals(issueDateCard, cardData.issueDateCard,'Issue Card Date');
        System.assertEquals(expDateCard, cardData.expDateCard,'Expiry Card Date');
        System.assertEquals(blockDate, cardData.blockDate,'Blocked Card Date');
    }

    @isTest
    static void testConstructor2() {
        // Test data
        String cardStatusHis = 'Blocked';
        String cardNoHis = '9876543210987654';
        String lastMaintHis = '2024-07-05';
        String expDate = '2024-12-31';
        String activeDate = '2024-07-01';
        String branchCode = '1234';
        String issueDate = '2024-06-15';
        String typeCode = 'Debit';
        String renewalDate = '2025-06-15';
        String blockDate = '2024-07-05';
        String userBlock = 'Manager';
        String accNo = '1234567890';
        
        // Create an instance using constructor 2
        SCC_CardData cardData = new SCC_CardData(cardStatusHis, cardNoHis, lastMaintHis, expDate,
                                                 activeDate, branchCode, issueDate, typeCode,
                                                 renewalDate, blockDate, userBlock, accNo);
        
        // Verify initialization
        System.assertEquals(cardStatusHis, cardData.cardStatusHis,'Card Status History');
        System.assertEquals(cardNoHis, cardData.cardNoHis,'Card Number History');
        System.assertEquals(lastMaintHis, cardData.lastMaintHis,'Last Maintained History');
        System.assertEquals(cardNoHis, cardData.cardNoHis,'Card Number History');
        System.assertEquals(expDate, cardData.expDate,'Expiry Date');
        System.assertEquals(activeDate, cardData.activeDate,'Active Date');
        System.assertEquals(branchCode, cardData.branchCode,'Branch Code');
        System.assertEquals(typeCode, cardData.typeCode,'Card Type');
        System.assertEquals(renewalDate, cardData.renewalDate,'Renewal Date');
        System.assertEquals(issueDate, cardData.issueDate,'Issue Date');
        System.assertEquals(blockDate, cardData.blockDate,'Block Date');
        System.assertEquals(userBlock, cardData.userBlock,'User Block');
        System.assertEquals(accNo, cardData.accNo,'Account Number');
    }
}