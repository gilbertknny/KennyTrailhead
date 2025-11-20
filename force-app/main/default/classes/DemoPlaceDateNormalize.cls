public with sharing class DemoPlaceDateNormalize {
    public class Request {
        @InvocableVariable(required=true)
        public String placeDateForm;
        @InvocableVariable(required=true)
        public String placeDateOCR;
    }
    
    public class Output {
        @InvocableVariable
        public Boolean isMatch;
    }

    @InvocableMethod(label='Match TTL OCR And Form')
    public static List<Output> matchPlaceDateOfBirth(List<Request> requests) {
        List<Output> results = new List<Output>();

        for(Request req : requests){
            Output res = new Output();
            String norm1 = normalizePlaceDate(req.placeDateForm);
            String norm2 = normalizePlaceDate(req.placeDateOCR);
            res.isMatch = norm1 != null && norm1 == norm2;
            results.add(res);
        }

        return results;
    }

    private static String normalizePlaceDate(String input) {
        if(String.isBlank(input)) return null;

        List<String> parts = input.split(',');

        if(parts.size() < 2) {
            return cleanString(input);
        }

        String place = cleanString(parts[0]);
        String datePart = parts[1].trim();

        String normalizedDate = normalizeDate(datePart);

        if(normalizedDate == null) {
            return place;
        }

        return place + normalizedDate;
    }

    private static String cleanString(String input){
        if(String.isBlank(input)) return '';
        String cleaned = input.toLowerCase();
        cleaned = cleaned.replaceAll('[\\s,\\-\\./]', '');
        return cleaned;
    }

private static String normalizeDate(String dateStr) {
    if(String.isBlank(dateStr)) return null;

    // Coba format yyyy-MM-dd (ISO)
    try {
        Date dt = Date.valueOf(dateStr);
        return dt.format(); // default format yyyy-MM-dd
    } catch(Exception e) {
        // lanjut ke parsing manual
    }

    // Parsing manual untuk format dd-MM-yyyy, dd/MM/yyyy, ddMMyyyy
    // Ganti pemisah dengan dash dulu
    String temp = dateStr.replace('/', '-').replace('.', '-').trim();

    // Split berdasarkan dash
    List<String> parts = temp.split('-');
    if(parts.size() == 3) {
        Integer day;
        Integer month;
        Integer year;
        try {
            // Coba asumsikan format dd-MM-yyyy
            day = Integer.valueOf(parts[0]);
            month = Integer.valueOf(parts[1]);
            year = Integer.valueOf(parts[2]);

            // Validasi tahun (4 digit)
            if(year < 100) year += 2000;

            Date dt = Date.newInstance(year, month, day);
            return dt.format(); // yyyy-MM-dd
        } catch(Exception e) {
            // parsing gagal
        }
    }

    // Parsing untuk format tanpa pemisah: ddMMyyyy atau yyyyMMdd
    temp = temp.replaceAll('[^0-9]', ''); // hapus semua selain angka
    if(temp.length() == 8) {
        try {
            // Coba yyyyMMdd
            Integer year = Integer.valueOf(temp.substring(0,4));
            Integer month = Integer.valueOf(temp.substring(4,6));
            Integer day = Integer.valueOf(temp.substring(6,8));
            Date dt = Date.newInstance(year, month, day);
            return dt.format();
        } catch(Exception e) {
            // gagal
        }

        try {
            // Coba ddMMyyyy
            Integer day = Integer.valueOf(temp.substring(0,2));
            Integer month = Integer.valueOf(temp.substring(2,4));
            Integer year = Integer.valueOf(temp.substring(4,8));
            Date dt = Date.newInstance(year, month, day);
            return dt.format();
        } catch(Exception e) {
            // gagal
        }
    }

    return null; // gagal parse
}

}