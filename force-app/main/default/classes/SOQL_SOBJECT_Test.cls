@istest
private class SOQL_SOBJECT_Test {
    @istest
    private static void testgan(){
        product2 prod = new product2();
        prod.Name = 'anjay';
        insert prod;
        String field = SOQL_SOBJECT.getallfield('Account');
        String soql = SOQL_SOBJECT.SOQL(field, '', 'product2', '', '', '','');
		SOBJECT acc = SOQL_SOBJECT.SingleSobject('', 'product2', 'id!=null', 'id','desc', '1');
        List<SOBJECT> listacc = SOQL_SOBJECT.ListSobject('', 'product2', 'id!=null', 'id','desc', '1');
    }
}