@IsTest
public with sharing class SFCallout_Test {
    @IsTest
    static void testsSfCallout() {
        // GIVEN
        HTTPMockFactory mock = new HTTPMockFactory(
            200,'OK',
            '{"isSuccess":true}',
            new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        // WHEN
        Test.startTest();
        String str = '{"data":"ini data"}';
        HTTPResponse res = sfCallout.fn_sendGoLiveData(str,'Agr12345');

        List<sfCallout.ParamIn> lstPrmIn = new List<sfCallout.ParamIn>();
        sfCallout.ParamIn prm = new sfCallout.ParamIn();
            prm.jsonBody = str;
            prm.AgreementId = 'Agr12345';
        lstPrmIn.add(prm);
        List<String> lres = sfCallout.sendGoLiveData(lstPrmIn);
        Test.stopTest();

        // THEN
        //Assert.areEqual('{"isSuccess":true}', res.getBody(), 'Gagal receive mock response');
        //System.assertNotEquals(null, lres, 'Generated payload should not be null');

    }
}