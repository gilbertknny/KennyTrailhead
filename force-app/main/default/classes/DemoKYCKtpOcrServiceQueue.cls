public with sharing class DemoKYCKtpOcrServiceQueue implements Queueable, Database.AllowsCallouts {
    private Id contentVersionId;
    private Id caseId;

    public DemoKYCKtpOcrServiceQueue(Id contentVersionId, Id caseId) {
        this.contentVersionId = contentVersionId;
        this.caseId = caseId;
    }

    private static String normalizeFormatTTL(String input){
        if (String.isBlank(input)) return '';

        List<String> parts = input.split(',');
        if (parts.size() != 2) {
            return input.trim();
        }

        String tempat = parts[0].trim();
        String tgl = parts[1].trim();

        if (Pattern.matches('\\d{4}-\\d{2}-\\d{2}', tgl)) {
            try {
                Date dateValue = Date.valueOf(tgl);
                String day = padLeftZero(String.valueOf(dateValue.day()), 2);
                String month = padLeftZero(String.valueOf(dateValue.month()), 2);
                String year = String.valueOf(dateValue.year());
                return tempat + ', ' + day + '-' + month + '-' + year;
            } catch (Exception e) {
                return input.trim();
            }
        }

        return input.trim();
    }

    private static String padLeftZero(String input, Integer length) {
        while (input.length() < length) {
            input = '0' + input;
        }
        return input;
    }

    public static String extractRtRw(String input) {
        if (String.isBlank(input)) return '';

        String lower = input.toLowerCase();
        Pattern p = Pattern.compile('rt\\s*(\\d{1,3})\\s*/\\s*rw\\s*(\\d{1,3})');
        Matcher m = p.matcher(lower);

        if (m.find()) {
            String rt = padLeftZero(m.group(1), 3);
            String rw = padLeftZero(m.group(2), 3);
            return rt + '/' + rw;
        }

        return '';
    }


private List<String> parseAddress(String fullAddress) {
    List<String> results = new List<String>{'', '', '', ''};

    if (String.isBlank(fullAddress)) {
        return results;
    }

    // Deteksi delimiter: pakai ';' kalau ada, kalau tidak pakai ','
    List<String> parts;
    if (fullAddress.contains(';')) {
        parts = fullAddress.split('\\s*;\\s*');
    } else {
        parts = fullAddress.split('\\s*,\\s*');
    }

    // Isi hasil parsing sesuai urutan
    results[0] = parts.size() > 0 ? parts[0].trim() : '';
    String rtRwRaw = parts.size() > 1 ? parts[1].trim() : '';
    results[1] = extractRtRw(rtRwRaw);
    results[2] = parts.size() > 2 ? parts[2].trim() : '';
    results[3] = parts.size() > 3 ? parts[3].trim() : '';

    return results;
}


    public void execute(QueueableContext context) {
        ContentVersion content = [
            SELECT Id, Title, VersionData
            FROM ContentVersion
            WHERE Id = :contentVersionId
            LIMIT 1
        ];

        String responseBody = DemoVRAKtpOcrService.uploadFileToExternalService(
            content.Title,
            content.VersionData,
            String.valueOf(content.VersionData.size()),
            String.valueOf(content.VersionData.size()),
            String.valueOf(content.VersionData.size()),
            'sample_flow_identifier', '1', '1'
        );

        Map<String, Object> rawResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Case caseToUpdate = new Case(Id = caseId);

        String nik = '';
        String cardNo = '';

        if (rawResponse.containsKey('nik')) {
            Object rawNik = ((Map<String, Object>) rawResponse.get('nik')).get('value');
            nik = rawNik != null ? String.valueOf(rawNik) : '';
        }

        if (rawResponse.containsKey('cardNo')) {
            Object rawCard = ((Map<String, Object>) rawResponse.get('cardNo')).get('value');
            cardNo = rawCard != null ? String.valueOf(rawCard) : '';
        }

        if (String.isBlank(nik) || 'not found'.equalsIgnoreCase(nik.trim())) {
            caseToUpdate.Demo_NIK_KTP__c = cardNo;
        } else {
            caseToUpdate.Demo_NIK_KTP__c = nik;
        }
        
        if (rawResponse.containsKey('name')) {
            Map<String, Object> namaData = (Map<String, Object>) rawResponse.get('name');
            String value = (String) namaData.get('value');
            caseToUpdate.Demo_Nama_KTP__c = 'not found'.equalsIgnoreCase(value) ? '' : value;
        }

        if (rawResponse.containsKey('datePlaceOfBirth')) {
            Map<String, Object> ttlData = (Map<String, Object>) rawResponse.get('datePlaceOfBirth');
            String value = (String) ttlData.get('value');
            caseToUpdate.Demo_Tempat_Tanggal_Lahir_KTP__c = 'not found'.equalsIgnoreCase(value) ? '' : normalizeFormatTTL(value);
        }

        if (rawResponse.containsKey('gender')) {
            Map<String, Object> jenisKelaminData = (Map<String, Object>) rawResponse.get('gender');
            String value = (String) jenisKelaminData.get('value');
            caseToUpdate.Jenis_Kelamin_KTP__c = 'not found'.equalsIgnoreCase(value) ? '' : value;
        }

        if (rawResponse.containsKey('bloodType')) {
            Map<String, Object> golDar = (Map<String, Object>) rawResponse.get('bloodType');
            String value = (String) golDar.get('value');
            caseToUpdate.Demo_Golangan_Darah_KTP__c = 'not found'.equalsIgnoreCase(value) ? '' : value;
        }

       if (rawResponse.containsKey('address')) {
        Map<String, Object> alamatData = (Map<String, Object>) rawResponse.get('address');
        String value = (String) alamatData.get('value');

        if (String.isBlank(value) || 'not found'.equalsIgnoreCase(value)) {
            caseToUpdate.Demo_Alamat_KTP__c = '';
            caseToUpdate.Demo_RT_RW__c = '';
            caseToUpdate.Demo_Kelurahan_Desa__c = '';
            caseToUpdate.Demo_Kecamatan_KTP__c = '';
        } else {
            List<String> parsed = parseAddress(value);
            caseToUpdate.Demo_Alamat_KTP__c = parsed[0];
            System.debug('ini adalah parsed nyah 0'+ parsed[0]);
            caseToUpdate.Demo_RT_RW__c = parsed[1];
            System.debug('ini adalah parsed nyah 1' + parsed[1]);
            caseToUpdate.Demo_Kelurahan_Desa__c = parsed[2];
            System.debug('ini adalah parsed nyah 2' + parsed[2]);
            caseToUpdate.Demo_Kecamatan_KTP__c = parsed[3];
            System.debug('ini adalah parsed nyah 3' + parsed[3]);
        }
    }


        if (rawResponse.containsKey('religion')) {
            Map<String, Object> agamaData = (Map<String, Object>) rawResponse.get('religion');
            String value = (String) agamaData.get('value');
            caseToUpdate.Demo_Agama__c = 'not found'.equalsIgnoreCase(value) ? '' : value;
        }

        if (rawResponse.containsKey('maritalStatus')) {
            Map<String, Object> statusPerkawinanData = (Map<String, Object>) rawResponse.get('maritalStatus');
            String value = (String) statusPerkawinanData.get('value');
            caseToUpdate.Demo_Status_Perkawinan__c = 'not found'.equalsIgnoreCase(value) ? '' : value;
        }

        if (rawResponse.containsKey('occupation')) {
            Map<String, Object> pekerjaanData = (Map<String, Object>) rawResponse.get('occupation');
            String value = (String) pekerjaanData.get('value');
            caseToUpdate.Demo_Pekerjaan__c = 'not found'.equalsIgnoreCase(value) ? '' : value;
        }

        if (rawResponse.containsKey('cardType')) {
            Map<String, Object> cardType = (Map<String, Object>) rawResponse.get('cardType');
            String value = (String) cardType.get('value');
            caseToUpdate.Demo_Card_Type_OCR__c = 'not found'.equalsIgnoreCase(value) ? '' : value;
        }
        
        if (rawResponse.containsKey('nationality')) {
            Map<String, Object> nationality = (Map<String, Object>) rawResponse.get('nationality');
            String value = (String) nationality.get('value');
            caseToUpdate.Demo_Kewarnagaraan__c = 'not found'.equalsIgnoreCase(value) ? '' : value;
        }

        // DML save
        try {
            update caseToUpdate;
            caseToUpdate.Demo_Status_Match__c = 'Success';
            update caseToUpdate;
            System.debug('Updated Case successfully.');
        } catch (Exception e) {
            caseToUpdate.Demo_Status_Match__c = 'Failed';
            update caseToUpdate;
            System.debug('Failed to update Case: ' + e.getMessage());
        }
    }
}