@IsTest
public with sharing class SCC_SavingStatementWrapperTest {
    static testMethod void testParse() {
		String json = '{'+
		'  \"data\": ['+
		'    {'+
		'      \"remarkCustom\": \"Transfer Ke ASRENI via EDC\",'+
		'      \"tlbds2\": \" \",'+
		'      \"tlbds1\": \"FROM390301037982533 TO390301011429531EDC\",'+
		'      \"serial\": \"0\",'+
		'      \"auxtrc\": \"8506\",'+
		'      \"trremk\": \"EDC DIKI TO ASRENI\",'+
		'      \"terbilang\": \"\",'+
		'      \"glsign\": \"Db\",'+
		'      \"truser\": \"0852502   \",'+
		'      \"saldoAkhirMutasi\": 215000,'+
		'      \"mutasiKredit\": 0,'+
		'      \"mutasiDebet\": 200000,'+
		'      \"saldoAwalMutasi\": 415000,'+
		'      \"deskTran\": \"EDC DIKI TO ASRENI  FROM390301037982533 TO390301011429531EDC\",'+
		'      \"kodeTran\": \"2   \",'+
		'      \"jamTran\": 101357,'+
		'      \"tglEfektif\": \"2023-10-29T00:00:00Z\",'+
		'      \"tglTran\": \"2023-10-29T00:00:00Z\",'+
		'      \"noRek\": 390301037982533,'+
		'      \"idNum\": 2,'+
		'      \"seq\": 2411508,'+
		'      \"idNum2\": 0,'+
		'      \"idNum3\": 0'+
		'    },'+
		'    {'+
		'      \"remarkCustom\": \"Transfer Ke ASRENI via EDC\",'+
		'      \"tlbds2\": \"                                        \",'+
		'      \"tlbds1\": \"FROM390301037982533 TO390301011429531EDC\",'+
		'      \"serial\": \"0\",'+
		'      \"auxtrc\": \"8506\",'+
		'      \"trremk\": \"EDC DIKI TO ASRENI\",'+
		'      \"terbilang\": \"\",'+
		'      \"glsign\": \"Db\",'+
		'      \"truser\": \"0852502   \",'+
		'      \"saldoAkhirMutasi\": 415000,'+
		'      \"mutasiKredit\": 0,'+
		'      \"mutasiDebet\": 3000,'+
		'      \"saldoAwalMutasi\": 418000,'+
		'      \"deskTran\": \"EDC DIKI TO ASRENI FROM390301037982533 TO390301011429531EDC\",'+
		'      \"kodeTran\": \"2   \",'+
		'      \"jamTran\": 101357,'+
		'      \"tglEfektif\": \"2023-10-29T00:00:00Z\",'+
		'      \"tglTran\": \"2023-10-29T00:00:00Z\",'+
		'      \"noRek\": 390301037982533,'+
		'      \"idNum\": 1,'+
		'      \"seq\": 2411508,'+
		'      \"idNum2\": 0,'+
		'      \"idNum3\": 0'+
		'    }'+
		'  ],'+
		'  \"errors\": null,'+
		'  \"responseMessage\": \"Success\",'+
		'  \"responseCode\": \"00\",'+
		'  \"errorCode\": \"000\",'+
		'  \"statusCode\": 200'+
		'}';
		SCC_SavingStatementWrapper obj = SCC_SavingStatementWrapper.parse(json);
		System.assert(obj != null);
	}
}