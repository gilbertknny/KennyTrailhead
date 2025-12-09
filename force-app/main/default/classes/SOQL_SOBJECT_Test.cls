/**
 * @description SOQL_SOBJECT_Test
 */
@IsTest
private class SOQL_SOBJECT_Test {
    @IsTest
    private static void testgan(){
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            product2 prod = new product2();
            prod.Name = 'anjay';
            insert prod;
            String field = SOQL_SOBJECT.getallfield('product2');
            SOQL_SOBJECT.SOQL_Param sq = new SOQL_SOBJECT.SOQL_Param();
            sq.fields = field;
            sq.addField = '';
            sq.sobjectName = 'product2';
            sq.condition = 'id!=null';
            sq.order = 'id';
            sq.ascdesc = 'desc';
            sq.limits = '1';
            String soql = SOQL_SOBJECT.SOQL(sq);
            SOBJECT acc = SOQL_SOBJECT.SingleSobject(sq);
            List<SOBJECT> listacc = SOQL_SOBJECT.ListSobject(sq);
            system.assertEquals(1, listacc.size());
        }
    }
}