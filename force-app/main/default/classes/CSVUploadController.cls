/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-15-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CSVUploadController {
    
    @AuraEnabled(cacheable=true)
    public static List<TemplateOption> getAvailableTemplates() {
        try {
            List<TemplateOption> options = new List<TemplateOption>();
            
            // Query custom metadata for templates
            List<SCC_CSV_Header_Template__mdt> templates = [
                SELECT Id, MasterLabel, Field_Name__c, Case_Type__c
                FROM SCC_CSV_Header_Template__mdt
                ORDER BY MasterLabel
            ];
            
            for (SCC_CSV_Header_Template__mdt template : templates) {
                options.add(new TemplateOption(
                    template.Id,
                    template.MasterLabel,
                    template.Case_Type__c,
                    template.Field_Name__c
                ));
            }
            
            return options;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching templates: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static CSVPreviewResult previewCSVData(String csvData, String templateId) {
        try {
            if (String.isBlank(templateId)) {
                throw new AuraHandledException('Silahkan pilih template terlebih dahulu');
            }
            
            // Get template configuration
            SCC_CSV_Header_Template__mdt template = getTemplateById(templateId);
            if (template == null) {
                throw new AuraHandledException('Template not found');
            }
            
            // Parse CSV data
            List<String> lines = csvData.split('\n');
            if (lines.isEmpty()) {
                throw new AuraHandledException('CSV file is empty');
            }
            
            // Get expected headers from template
            List<String> expectedHeaders = getHeadersFromTemplate(template.Field_Name__c);
            
            // Parse CSV headers
            List<String> csvHeaders = parseCSVLine(lines[0]);
            
            // Validate headers
            validateHeaders(csvHeaders, expectedHeaders);
            
            // Parse data rows (limit to first 10 for preview)
            List<List<String>> previewData = new List<List<String>>();
            Integer maxRows = Math.min(lines.size(), 11); // Header + 10 data rows
            
            for (Integer i = 1; i < maxRows; i++) {
                if (String.isNotBlank(lines[i].trim())) {
                    List<String> rowData = parseCSVLine(lines[i]);
                    previewData.add(rowData);
                }
            }
            
            return new CSVPreviewResult(
                true,
                'Preview generated successfully',
                expectedHeaders,
                previewData,
                lines.size() - 1, // Total rows excluding header
                template.Case_Type__c
            );
            
        } catch (Exception e) {
            return new CSVPreviewResult(
                false,
                e.getMessage(),
                new List<String>(),
                new List<List<String>>(),
                0,
                ''
            );
        }
    }
    
    @AuraEnabled
    public static ProcessResult processCSVUpload(String csvData, String templateId) {
        try {
            if (String.isBlank(templateId)) {
                throw new AuraHandledException('Silahkan pilih template terlebih dahulu');
            }
            
            // Get template configuration
            SCC_CSV_Header_Template__mdt template = getTemplateById(templateId);
            if (template == null) {
                throw new AuraHandledException('Template not found');
            }
            
            // Get Case Type record
            Case_Type__c caseType = getCaseTypeByName(template.Case_Type__c);
            if (caseType == null) {
                throw new AuraHandledException('Case Type not found: ' + template.Case_Type__c);
            }
            
            // Parse and validate CSV
            List<String> lines = csvData.split('\n');
            List<String> expectedHeaders = getHeadersFromTemplate(template.Field_Name__c);
            List<String> csvHeaders = parseCSVLine(lines[0]);
            
            validateHeaders(csvHeaders, expectedHeaders);
            
            // Process data rows
            List<Case> casesToInsert = new List<Case>();
            List<String> errors = new List<String>();
            
            for (Integer i = 1; i < lines.size(); i++) {
                if (String.isNotBlank(lines[i].trim())) {
                    try {
                        Case newCase = createCaseFromCSVRow(lines[i], csvHeaders, caseType.Id);
                        casesToInsert.add(newCase);
                    } catch (Exception rowError) {
                        errors.add('Row ' + (i + 1) + ': ' + rowError.getMessage());
                    }
                }
            }
            
            // Insert cases if no errors
            if (errors.isEmpty() && !casesToInsert.isEmpty()) {
                insert casesToInsert;
                return new ProcessResult(
                    true,
                    'Successfully processed ' + casesToInsert.size() + ' cases',
                    casesToInsert.size(),
                    errors
                );
            } else if (!errors.isEmpty()) {
                return new ProcessResult(
                    false,
                    'Errors found during processing',
                    0,
                    errors
                );
            } else {
                return new ProcessResult(
                    false,
                    'No valid data rows found',
                    0,
                    new List<String>()
                );
            }
            
        } catch (Exception e) {
            return new ProcessResult(
                false,
                e.getMessage(),
                0,
                new List<String>{e.getMessage()}
            );
        }
    }
    
    // Helper method to get template by ID
    private static SCC_CSV_Header_Template__mdt getTemplateById(String templateId) {
        List<SCC_CSV_Header_Template__mdt> templates = [
            SELECT Id, MasterLabel, Field_Name__c, Case_Type__c
            FROM SCC_CSV_Header_Template__mdt
            WHERE Id = :templateId
            LIMIT 1
        ];
        return templates.isEmpty() ? null : templates[0];
    }
    
    // Helper method to parse headers from template field
    private static List<String> getHeadersFromTemplate(String fieldNames) {
        if (String.isBlank(fieldNames)) {
            return new List<String>();
        }
        return fieldNames.split(',');
    }
    
    // Helper method to parse CSV line
    private static List<String> parseCSVLine(String line) {
        List<String> result = new List<String>();
        String[] fields = line.split(',');
        
        for (String field : fields) {
            result.add(field.trim().replace('"', ''));
        }
        
        return result;
    }
    
    // Helper method to validate headers
    private static void validateHeaders(List<String> csvHeaders, List<String> expectedHeaders) {
        if (csvHeaders.size() != expectedHeaders.size()) {
            throw new AuraHandledException(
                'Header mismatch. Expected ' + expectedHeaders.size() + 
                ' columns but found ' + csvHeaders.size()
            );
        }
        
        for (Integer i = 0; i < expectedHeaders.size(); i++) {
            if (!csvHeaders[i].equalsIgnoreCase(expectedHeaders[i].trim())) {
                throw new AuraHandledException(
                    'Header mismatch at column ' + (i + 1) + 
                    '. Expected: ' + expectedHeaders[i].trim() + 
                    ', Found: ' + csvHeaders[i]
                );
            }
        }
    }
    
    // Helper method to get Case Type by name
    private static Case_Type__c getCaseTypeByName(String caseTypeName) {
        List<Case_Type__c> caseTypes = [
            SELECT Id, Name
            FROM Case_Type__c
            WHERE Name = :caseTypeName
            LIMIT 1
        ];
        return caseTypes.isEmpty() ? null : caseTypes[0];
    }
    
    // Helper method to create Case from CSV row
    private static Case createCaseFromCSVRow(String csvRow, List<String> headers, Id caseTypeId) {
        List<String> values = parseCSVLine(csvRow);
        
        if (values.size() != headers.size()) {
            throw new AuraHandledException('Column count mismatch in data row');
        }
        
        Case newCase = new Case();
        newCase.Call_Type__c = caseTypeId;
        
        // Map CSV values to Case fields based on headers
        for (Integer i = 0; i < headers.size(); i++) {
            String header = headers[i].trim();
            String value = values[i];
            
            // Map based on field names
            if (header.equalsIgnoreCase('Status')) {
                newCase.Status = String.isNotBlank(value) ? value : 'New';
            } else if (header.equalsIgnoreCase('SCC_Card_Number__c')) {
                newCase.SCC_Card_Number__c = value;
            }
            // Add more field mappings as needed
        }
        
        return newCase;
    }
    
    // Wrapper classes
    public class TemplateOption {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String caseType { get; set; }
        @AuraEnabled public String fieldNames { get; set; }
        
        public TemplateOption(String id, String label, String caseType, String fieldNames) {
            this.id = id;
            this.label = label;
            this.caseType = caseType;
            this.fieldNames = fieldNames;
        }
    }
    
    public class CSVPreviewResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public List<String> headers { get; set; }
        @AuraEnabled public List<List<String>> previewData { get; set; }
        @AuraEnabled public Integer totalRows { get; set; }
        @AuraEnabled public String caseType { get; set; }
        
        public CSVPreviewResult(Boolean success, String message, List<String> headers, 
                               List<List<String>> previewData, Integer totalRows, String caseType) {
            this.success = success;
            this.message = message;
            this.headers = headers;
            this.previewData = previewData;
            this.totalRows = totalRows;
            this.caseType = caseType;
        }
    }
    
    public class ProcessResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Integer recordsProcessed { get; set; }
        @AuraEnabled public List<String> errors { get; set; }
        
        public ProcessResult(Boolean success, String message, Integer recordsProcessed, List<String> errors) {
            this.success = success;
            this.message = message;
            this.recordsProcessed = recordsProcessed;
            this.errors = errors;
        }
    }
}