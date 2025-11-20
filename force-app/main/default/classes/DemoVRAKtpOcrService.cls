public with sharing class DemoVRAKtpOcrService {
    public class DemoVRAKtpOcrRequest {
        @InvocableVariable(label='Content Version Id File Image')
        public Id contentVersionId;
    }

    public class DemoVRAKtpOcrResponse {
        @InvocableVariable public String nik_value;
        @InvocableVariable public Decimal nik_confidenceScore;

        @InvocableVariable public String nama_value;
        @InvocableVariable public Decimal nama_confidenceScore;

        @InvocableVariable public String alamat_value;
        @InvocableVariable public Decimal alamat_confidenceScore;

        @InvocableVariable public String agama_value;
        @InvocableVariable public Decimal agama_confidenceScore;

        @InvocableVariable public String rt_rw_value;
        @InvocableVariable public Decimal rt_rw_confidenceScore;

        @InvocableVariable public String status_perkawinan_value;
        @InvocableVariable public Decimal status_perkawinan_confidenceScore;

        @InvocableVariable public String jenis_kelamin_value;
        @InvocableVariable public Decimal jenis_kelamin_confidenceScore;

        @InvocableVariable public String tempat_tanggal_lahir_value;
        @InvocableVariable public Decimal tempat_tanggal_lahir_confidenceScore;

        @InvocableVariable public String gol_darah_value;
        @InvocableVariable public Decimal gol_darah_confidenceScore;

        @InvocableVariable public String kewarganegaraan_value;
        @InvocableVariable public Decimal kewarganegaraan_confidenceScore;

        @InvocableVariable public String pekerjaan_value;
        @InvocableVariable public Decimal pekerjaan_confidenceScore;

        @InvocableVariable public String tanda_tangan_value;
        @InvocableVariable public Decimal tanda_tangan_confidenceScore;

        @InvocableVariable public String berlaku_hingga_value;
        @InvocableVariable public Decimal berlaku_hingga_confidenceScore;

        @InvocableVariable public String kel_desa_value;
        @InvocableVariable public Decimal kel_desa_confidenceScore;

        @InvocableVariable public String kecamatan_value;
        @InvocableVariable public Decimal kecamatan_confidenceScore;

        @InvocableVariable public String header_ktp_value;
        @InvocableVariable public Decimal header_ktp_confidenceScore;

        @InvocableVariable public String kota_tanggal_terbit_ktp_value;
        @InvocableVariable public Decimal kota_tanggal_terbit_ktp_confidenceScore;
    }

    @InvocableMethod(label='Extract KTP Data')
    public static List<DemoVRAKtpOcrResponse> extractKtpData(List<DemoVRAKtpOcrRequest> requests) {
        List<DemoVRAKtpOcrResponse> results = new List<DemoVRAKtpOcrResponse>();

        for (DemoVRAKtpOcrRequest req : requests) {
            ContentVersion content = [
                SELECT Id, Title, VersionData, FileExtension 
                FROM ContentVersion 
                WHERE Id = :req.contentVersionId 
                LIMIT 1
            ];

            if (content != null && content.VersionData != null) {
                String responseBody = uploadFileToExternalService(
                    content.Title,
                    content.VersionData,
                    String.valueOf(content.VersionData.size()),
                    String.valueOf(content.VersionData.size()),
                    String.valueOf(content.VersionData.size()),
                    'sample_flow_identifier', '1', '1'
                );

                Map<String, Object> rawResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                DemoVRAKtpOcrResponse response = new DemoVRAKtpOcrResponse();

                for (String key : rawResponse.keySet()) {
                    Map<String, Object> fieldData = (Map<String, Object>) rawResponse.get(key);
                    String value = fieldData.containsKey('value') ? String.valueOf(fieldData.get('value')) : null;
                    Decimal confidence = fieldData.containsKey('confidenceScore') ? Decimal.valueOf(String.valueOf(fieldData.get('confidenceScore'))) : null;

                    if (key == 'nik') {
                        response.nik_value = value; response.nik_confidenceScore = confidence;
                    } else if (key == 'nama') {
                        response.nama_value = value; response.nama_confidenceScore = confidence;
                    } else if (key == 'alamat') {
                        response.alamat_value = value; response.alamat_confidenceScore = confidence;
                    } else if (key == 'agama') {
                        response.agama_value = value; response.agama_confidenceScore = confidence;
                    } else if (key == 'rt-rw') {
                        response.rt_rw_value = value; response.rt_rw_confidenceScore = confidence;
                    } else if (key == 'status-perkawinan') {
                        response.status_perkawinan_value = value; response.status_perkawinan_confidenceScore = confidence;
                    } else if (key == 'jenis-kelamin') {
                        response.jenis_kelamin_value = value; response.jenis_kelamin_confidenceScore = confidence;
                    } else if (key == 'tempat-tanggal-lahir') {
                        response.tempat_tanggal_lahir_value = value; response.tempat_tanggal_lahir_confidenceScore = confidence;
                    } else if (key == 'gol-darah') {
                        response.gol_darah_value = value; response.gol_darah_confidenceScore = confidence;
                    } else if (key == 'kewarganegaraan') {
                        response.kewarganegaraan_value = value; response.kewarganegaraan_confidenceScore = confidence;
                    } else if (key == 'pekerjaan') {
                        response.pekerjaan_value = value; response.pekerjaan_confidenceScore = confidence;
                    } else if (key == 'tanda-tangan') {
                        response.tanda_tangan_value = value; response.tanda_tangan_confidenceScore = confidence;
                    } else if (key == 'berlaku-hingga') {
                        response.berlaku_hingga_value = value; response.berlaku_hingga_confidenceScore = confidence;
                    } else if (key == 'kel-desa') {
                        response.kel_desa_value = value; response.kel_desa_confidenceScore = confidence;
                    } else if (key == 'kecamatan') {
                        response.kecamatan_value = value; response.kecamatan_confidenceScore = confidence;
                    } else if (key == 'header-ktp') {
                        response.header_ktp_value = value; response.header_ktp_confidenceScore = confidence;
                    } else if (key == 'kota-tanggal-terbit-ktp') {
                        response.kota_tanggal_terbit_ktp_value = value; response.kota_tanggal_terbit_ktp_confidenceScore = confidence;
                    }
                }

                results.add(response);
            }
        }

        return results;
    }

    public static String uploadFileToExternalService(
        String strFileName, Blob fileBlob, String strFlowTotalSize,
        String strFlowCurrentChunkSize, String strFlowChunkSize,
        String strFlowIdentifier, String strFlowChunkNumber, String strFlowTotalChunks
    ) {
        String clientId = '7bb8351f789c4e76bed97feb8104b9c8';
        String clientSecret = 'D2C81C37846540f88F34ddDBF9A6109B';
        String credentials = clientId + ':' + clientSecret;
        String encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(credentials));

        String contentType = DemoVRAMultipartRequestHelper.GetContentType();
        String form64 = '';

        form64 += DemoVRAMultipartRequestHelper.WriteBoundary();
        form64 += DemoVRAMultipartRequestHelper.WriteBodyParameter('flow_identifier', strFlowIdentifier);
        form64 += DemoVRAMultipartRequestHelper.WriteBoundary();
        form64 += DemoVRAMultipartRequestHelper.WriteBodyParameter('file_name', strFileName);
        form64 += DemoVRAMultipartRequestHelper.WriteBoundary();
        form64 += DemoVRAMultipartRequestHelper.WriteBodyParameter('total_size', strFlowTotalSize);
        form64 += DemoVRAMultipartRequestHelper.WriteBoundary();
        form64 += DemoVRAMultipartRequestHelper.WriteBodyParameter('current_chunk_size', strFlowCurrentChunkSize);
        form64 += DemoVRAMultipartRequestHelper.WriteBoundary();
        form64 += DemoVRAMultipartRequestHelper.WriteBodyParameter('chunk_size', strFlowChunkSize);
        form64 += DemoVRAMultipartRequestHelper.WriteBoundary();
        form64 += DemoVRAMultipartRequestHelper.WriteBodyParameter('chunk_number', strFlowChunkNumber);
        form64 += DemoVRAMultipartRequestHelper.WriteBoundary();
        form64 += DemoVRAMultipartRequestHelper.WriteBodyParameter('total_chunks', strFlowTotalChunks);
        form64 += DemoVRAMultipartRequestHelper.WriteBoundary();

        DemoVRAMultipartRequestHelper.WriteFileResult result = DemoVRAMultipartRequestHelper.WriteFile('file', strFileName, 'application/octet-stream', fileBlob);
        form64 += result.Content;
        form64 += DemoVRAMultipartRequestHelper.WriteBoundary(result.EndingType);

        Blob formBlob = EncodingUtil.base64Decode(form64);

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setBodyAsBlob(formBlob);
        httpRequest.setEndpoint('https://ktp-reader-45rx5m.jit1x7-1.sgp-s1.cloudhub.io/api/ktp');
        httpRequest.setHeader('client_id', clientId);
        httpRequest.setHeader('client_secret', clientSecret);
        httpRequest.setHeader('Content-Type', contentType);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);

        try {
            Http http = new Http();
            HttpResponse res = http.send(httpRequest);
            if (res.getStatusCode() == 200) {
                return res.getBody();
            } else {
                System.debug('Failed response: ' + res.getStatusCode() + ' - ' + res.getBody());
                return '{}';
            }
        } catch (Exception e) {
            System.debug('Exception during HTTP request: ' + e.getMessage());
            return '{}';
        }
    }
}