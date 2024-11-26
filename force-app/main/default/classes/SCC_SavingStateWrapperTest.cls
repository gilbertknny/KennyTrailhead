@isTest
public class SCC_SavingStateWrapperTest {

    @isTest
    static void testConstructor() {
        // Test data
        Long noRek = 1234567890L;
        String tglTran = '2024-05-24';
        String jamTran = '120000';
        String remarkCustom = 'Test remark';
        String glsign = 'C';
        Integer mutasiDebet = 100;
        Integer mutasiKredit = 200;
        Double saldoAkhirMutasi = 1000;
        String truser = 'Test user';
        String ukerTransaksi = 'Test branch';
        String tid = '1234';
        String channel = 'CHMS';
        
        // Create instance of SCC_SavingStateWrapper
        SCC_SavingStateWrapper wrapper = new SCC_SavingStateWrapper(
            noRek, tglTran, jamTran, remarkCustom, glsign, 
            mutasiDebet, mutasiKredit, saldoAkhirMutasi, 
            truser, ukerTransaksi, tid, channel
        );
        
        // Verify properties
        System.assertEquals(noRek, wrapper.noRek, 'noRek should match');
        System.assertEquals(tglTran, wrapper.tglTran, 'tglTran should match');
        System.assertEquals(jamTran, wrapper.jamTran, 'jamTran should match');
        System.assertEquals(remarkCustom, wrapper.remarkCustom, 'remarkCustom should match');
        System.assertEquals(glsign, wrapper.glsign, 'glsign should match');
        System.assertEquals(mutasiDebet, wrapper.mutasiDebet, 'mutasiDebet should match');
        System.assertEquals(mutasiKredit, wrapper.mutasiKredit, 'mutasiKredit should match');
        System.assertEquals(saldoAkhirMutasi, wrapper.saldoAkhirMutasi, 'saldoAkhirMutasi should match');
        System.assertEquals(truser, wrapper.truser, 'truser should match');
        System.assertEquals(ukerTransaksi, wrapper.ukerTransaksi, 'ukerTransaksi should match');
        System.assertEquals(tid, wrapper.tid, 'tid should match');
        System.assertEquals(channel, wrapper.channel, 'channel should match');
    }
}