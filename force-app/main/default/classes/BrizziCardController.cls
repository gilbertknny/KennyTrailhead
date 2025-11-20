public with sharing class BrizziCardController {
    @AuraEnabled
    public static Map<String, Object> getCardData(String cardNumber) {
        if (String.isEmpty(cardNumber)) {
            throw new AuraHandledException('Card number cannot be empty.');
        }

        Map<String, Object> cardData = new Map<String, Object>();
        if (cardNumber.startsWith('666')) {
            cardData.put('cardNumber', cardNumber);
            cardData.put('uid', '0497337A7D6D80'); 
            cardData.put('saldo', 'Rp 1.195.500,-'); 
            cardData.put('statusKartu', 'single'); 
            cardData.put('tanggalIssue', '31/01/23'); 
            cardData.put('saldoDeposit', '0012'); 
            cardData.put('issuer', '0012'); 
            cardData.put('tipeKartu', 'Gepeng'); 
            cardData.put('modelKartu', 'Majalah'); 
            cardData.put('trxTerakhir', '31/01/23'); 
        } else {
            throw new AuraHandledException('Card not found.');
        }
        return cardData;
    }

    @AuraEnabled
    public static Boolean replaceCard(String oldCardNumber, String newCardNumber) {
        if (String.isEmpty(oldCardNumber) || String.isEmpty(newCardNumber)) {
            throw new AuraHandledException('Both card numbers must be provided.');
        }

        if (oldCardNumber.equals(newCardNumber)) {
            throw new AuraHandledException('Old and new card numbers cannot be the same.');
        }

        return true;
    }
}