@isTest
public class SCC_CardDataWrapperTest {
    static testMethod void testParse() {
		String json = '{'+
		'  \"chmGraphql\": {'+
		'    \"inquiryCardData\": {'+
		'      \"data\": {'+
		'        \"historyAccount\": {'+
		'          \"responseData\": {'+
		'            \"data \": ['+
		'              {'+
		'                \"userBlock\": \"\",'+
		'                \"typeCode\": \"01\",'+
		'                \"renewalDate\": null,'+
		'                \"mbStatus\": \"\",'+
		'                \"mbNo\": \"\",'+
		'                \"lastMaint\": null,'+
		'                \"issueDate\": \"2022-07-20\",'+
		'                \"expDate\": \"2707\",'+
		'                \"cardStatus\": \"NA\",'+
		'                \"cardNo\": \"6013014003495580\",'+
		'                \"branchCode\": \"0206\",'+
		'                \"blockDate\": null,'+
		'                \"activeDate\": \"2023-11-02\",'+
		'                \"accNo\": \"020601050752506\"'+
		'              }'+
		'            ]'+
		'          }'+
		'        },'+
		'        \"userBlock\": \"\",'+
		'        \"blockDate\": null,'+
		'        \"statusDesc\": \"Kartu Tidak Aktif\",'+
		'        \"userMaint\": \"\",'+
		'        \"lastMaint\": null,'+
		'        \"cardStatus\": \"NA\",'+
		'        \"issueDate\": \"2022-07-20\",'+
		'        \"expDate\": \"2707\",'+
		'        \"activeDate\": \"2023-11-02\",'+
		'        \"name\": \"GAVIN FAUZY IRWANTO\",'+
		'        \"type\": \"CHIP\",'+
		'        \"cardNo\": \"6013014003495580\",'+
		'        \"accNo\": \"020601050752506\"'+
		'      },'+
		'      \"status\": \"200\",'+
		'      \"responseDesc\": \"SUKSES\",'+
		'      \"responseCode\": \"00\"'+
		'    }'+
		'  }'+
		'}';
		SCC_CardDataWrapper obj = SCC_CardDataWrapper.parse(json);
		System.assert(obj != null);
	}
}