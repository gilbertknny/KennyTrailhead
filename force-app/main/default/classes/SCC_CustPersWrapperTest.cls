@isTest
public class SCC_CustPersWrapperTest {

    @isTest
    static void testWrapperClass() {
        // Create test data
        String namaNasabahLengkap = 'John Doe';
        String nik = '1234567890123456';
        String tanggalLahir = '1990-01-01';
        String nomorAplikasiPengajuan = 'APP123456';
        String tanggalPengajuan = '2024-05-28';
        String channelPengajuan = 'Online';
        String nomorKartuKredit = '1234-5678-9012-3456';
        String progressPengajuan = 'Pending';

        // Instantiate the wrapper class
        SCC_CustPersWrapper wrapperInstance = new SCC_CustPersWrapper(
            namaNasabahLengkap, nik, tanggalLahir, nomorAplikasiPengajuan, tanggalPengajuan,
            channelPengajuan, nomorKartuKredit, progressPengajuan
        );

        // Verify that the properties are set correctly
        System.assertEquals(namaNasabahLengkap, wrapperInstance.namaNasabahLengkap);
        System.assertEquals(nik, wrapperInstance.nik);
        System.assertEquals(tanggalLahir, wrapperInstance.tanggalLahir);
        System.assertEquals(nomorAplikasiPengajuan, wrapperInstance.nomorAplikasiPengajuan);
        System.assertEquals(tanggalPengajuan, wrapperInstance.tanggalPengajuan);
        System.assertEquals(channelPengajuan, wrapperInstance.channelPengajuan);
        System.assertEquals(nomorKartuKredit, wrapperInstance.nomorKartuKredit);
        System.assertEquals(progressPengajuan, wrapperInstance.progressPengajuan);
    }
}