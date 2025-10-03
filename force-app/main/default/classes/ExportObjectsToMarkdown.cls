public class ExportObjectsToMarkdown {

    public static void toMarkdown() {
        // Daftar objek yang akan diproses
        Set<String> targetObjects = new Set<String>{
            'Application__c', 'Opportunity', 'Operation__c', 'Legal_Document__c', 'Contact', 'Account'
        };

        // Membuat konten markdown
        String markdownContent = '';

        // Loop melalui objek yang ditargetkan
        for (String objectName : targetObjects) {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            if (objType == null) continue; // Skip jika objek tidak ditemukan

            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

            // Menambahkan nama objek ke markdown
            markdownContent += '1. ' + objDescribe.getLabel() + ' (' + objDescribe.getName() + ')\n';
            markdownContent += '| API Name | Tipe Data |\n';
            markdownContent += '|----------|-----------|\n';

            // Mengambil semua field dari objek
            Map<String, Schema.SObjectField> fields = objDescribe.fields.getMap();
            for (String fieldName : fields.keySet()) {
                Schema.SObjectField field = fields.get(fieldName);
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

                // Menambahkan field ke tabel
                String fieldApiName = fieldDescribe.getName();
                String fieldType = String.valueOf(fieldDescribe.getType());

                if (fieldType == 'REFERENCE') {
                    // Jika field adalah reference, ambil objek referensi
                    List<Schema.sObjectType> referenceObjects = fieldDescribe.getReferenceTo();
                    if (!referenceObjects.isEmpty()) {
                        Schema.DescribeSObjectResult referenceObjDescribe = referenceObjects[0].getDescribe();
                        String referenceObjApiName = referenceObjDescribe.getName();

                        // Ambil semua field dari objek referensi
                        Map<String, Schema.SObjectField> referenceFields = referenceObjDescribe.fields.getMap();

                        // Jika jumlah field <= 10, tampilkan semua field
                        if (referenceFields.size() <= 10) {
                            for (String refFieldName : referenceFields.keySet()) {
                                Schema.SObjectField refField = referenceFields.get(refFieldName);
                                Schema.DescribeFieldResult refFieldDescribe = refField.getDescribe();
                                markdownContent += '| ' + fieldApiName + '.' + referenceObjApiName + '.' + refFieldDescribe.getName() + ' | ' + refFieldDescribe.getType() + ' |\n';
                            }
                        } else {
                            // Jika jumlah field > 10, tampilkan hanya Id dan Name
                            Schema.SObjectField idField = referenceFields.get('Id');
                            Schema.SObjectField nameField = referenceFields.get('Name');

                            if (idField != null) {
                                Schema.DescribeFieldResult idFieldDescribe = idField.getDescribe();
                                markdownContent += '| ' + fieldApiName + '.' + referenceObjApiName + '.Id | ' + idFieldDescribe.getType() + ' |\n';
                            }

                            if (nameField != null) {
                                Schema.DescribeFieldResult nameFieldDescribe = nameField.getDescribe();
                                markdownContent += '| ' + fieldApiName + '.' + referenceObjApiName + '.Name | ' + nameFieldDescribe.getType() + ' |\n';
                            }
                        }
                    }
                } else {
                    // Jika bukan reference, tambahkan field biasa
                    markdownContent += '| ' + fieldApiName + ' | ' + fieldType + ' |\n';
                }
            }

            markdownContent += '\n';
        }

        // Menyimpan konten ke file .md
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Salesforce_Objects_Fields.md';
        cv.PathOnClient = 'Salesforce_Objects_Fields.md';
        cv.VersionData = Blob.valueOf(markdownContent);
        cv.IsMajorVersion = true;
        insert cv;
    }
}