/**
 * @description       : Class untuk merubah nominal terbilang
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 11-22-2025
 * @last modified by  : Ahmad Yazid Munif
**/
public without sharing class Aswata_QuotationSlip_Terbilang {
    /**
     * @description function untuk Generate Nominal ke Terbilang Rupiah
     * contoh : 1000 -> Seribu
     * @param theAmount
     * @return String
     */
    public static String terbilangRupiah(Decimal theAmount) {
        if (theAmount == null) {
            return '';
        }
        // Gunakan Long untuk menangani nilai Milyaran (agar Math.mod tidak error)
        Long amount = Math.abs(theAmount.longValue());
        if (amount == 0) {
            return 'Nol Rupiah';
        }
        String result = '';
        Long milyar = 1000000000L;
        Long juta = 1000000L;
        Long ribu = 1000L;
        // 1. Milyaran
        if (amount >= milyar) {
            Long milyaran = amount / milyar;
            result += terbilangKurangDariSeribu(milyaran.intValue()) + ' Milyar ';
            amount = Math.mod(amount, milyar);
        }
        // 2. Jutaan
        if (amount >= juta) {
            Long jutaan = amount / juta;
            result += terbilangKurangDariSeribu(jutaan.intValue()) + ' Juta ';
            amount = Math.mod(amount, juta);
        }
        // 3. Ribuan
        if (amount >= ribu) {
            Long ribuan = amount / ribu;
            if (ribuan == 1) {
                result += 'Seribu ';
            } else {
                result += terbilangKurangDariSeribu(ribuan.intValue()) + ' Ribu ';
            }
            amount = Math.mod(amount, ribu);
        }
        // 4. Kurang dari Seribu
        if (amount > 0) {
            result += terbilangKurangDariSeribu(amount.intValue());
        }
        // 5. Hasil
        String finalResult = result.replaceAll('\\s+', ' ').trim();
        // if (!String.isBlank(finalResult)) {
        //     finalResult += ' Rupiah';
        // }
        return finalResult.trim();
    }
    private static String terbilangKurangDariSeribu(Integer amount) {
        if (amount == 0) {
            return '';
        }
        List<String> kata = new List<String> {'','Satu','Dua','Tiga','Empat','Lima','Enam','Tujuh','Delapan','Sembilan'};
        String result = '';
        // Ratusan
        if (amount < 20) {
            result = terbilangBelasan(amount);
        } else if (amount < 100) {
            result = kata[amount / 10] + ' Puluh ' + terbilangKurangDariSeribu(Math.mod(amount, 10));
        } else if (amount < 200) {
            result = 'Seratus ' + terbilangKurangDariSeribu(amount - 100);
        } else { // 200 - 999
            result = kata[amount / 100] + ' Ratus ' + terbilangKurangDariSeribu(Math.mod(amount, 100));
        }
        return result;
    }
    private static String terbilangBelasan(Integer amount) {
        List<String> kata = new List<String> {'','Satu','Dua','Tiga','Empat','Lima','Enam','Tujuh','Delapan','Sembilan'};
        String result = '';
        // Ratusan
        if (amount < 10) {
            result = kata[amount];
        } else if (amount < 20) {
            if (amount == 10) {
                result = 'Sepuluh';
            } else if (amount == 11) {
                result = 'Sebelas';
            } else {
                result = kata[Math.mod(amount, 10)] + ' Belas';
            }
        }
        return result;
    }
}

    // public static String terbilangRupiah(Decimal theAmount) {
    //     String resultTerbilang = '';
    //     List<String> kata = new List<String> {'','Satu','Dua','Tiga','Empat','Lima','Enam','Tujuh','Delapan','Sembilan'};
    //     Integer amount = (Integer)Math.FLOOR(Math.ABS(theAmount)); // sebelum koma
    //     // Integer tinyAmount = (Integer)Math.ROUND((math.ABS(theAmount) - amount ) * 100.00); // setelah koma (jika ada)
    //     if(amount < 10){
    //         resultTerbilang = kata[amount];
    //     }else if(amount<20){
    //         if(amount==10){
    //             return 'Sepuluh';
    //         }else if(amount == 11){
    //             return 'Sebelas';
    //         }else{
    //             return kata[amount-10] + ' Belas ';
    //         }
    //     }else if (amount < 100) {
    //         return kata[amount / 10] + ' Puluh ' + terbilangRupiah(Math.mod(amount, 10));
    //     } else if (amount < 200) {
    //         return 'Seratus ' + terbilangRupiah(amount - 100);
    //     } else if (amount < 1000) {
    //         return terbilangRupiah(amount/ 100) + ' Ratus ' + terbilangRupiah(Math.mod(amount, 100));
    //     } else if (amount < 2000) {
    //         return 'Seribu ' + terbilangRupiah(amount - 1000);
    //     } else if (amount < 1000000) {
    //         return terbilangRupiah(amount / 1000) + ' Ribu ' + terbilangRupiah(Math.mod(amount, 1000));
    //     } else if (amount < 1000000000) {
    //         return terbilangRupiah(amount / 1000000) + ' Juta ' + terbilangRupiah(Math.mod(amount, 1000000));
    //     } else if (amount < 1000000000000L) {
    //         return terbilangRupiah(amount / 1000000000) + ' Milyar ' + terbilangRupiah(Math.mod(amount, 1000000000));
    //     }
    //     String result = resultTerbilang.replaceAll('\\s+', ' ');
    //     return result.trim();
    // }