@isTest
public class SCC_InquiryHoldStatusWrapperTest {
    static testMethod void testParse() {
		String json = '{'+
		'  \"inquiryHoldStatus\": {'+
		'    \"holdDate\": \"0051120\",'+
		'    \"holdType\": \"HG\",'+
		'    \"holdRemark\": \"jaminan Pelaksanaan BG\",'+
		'    \"holdAmt\": \"823820\",'+
		'    \"responseMessage\": \"Transaction Successfully\",'+
		'    \"responseCode\": \"00\",'+
		'    \"errorCode\": \"AS-000\"'+
		'  }'+
		'}';
		SCC_InquiryHoldStatusWrapper obj = SCC_InquiryHoldStatusWrapper.parse(json);
		System.assert(obj != null);
	}
}