@isTest
public with sharing class SCC_Wise_Lookup_Test {
    
    @IsTest
    static void getWorkingInstructionLookup () {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseWiLookup());
        SCC_Wise_Lookup.getWorkingInstructionLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getProgramLookup () {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseProgramLookup());
        SCC_Wise_Lookup.getProgramLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getPromoLookup () {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponsePromoLookup());
        SCC_Wise_Lookup.getPromoLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getProdukLookup () {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseProdukLookup());
        SCC_Wise_Lookup.getProdukLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getWorkingInstructionLookupError() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseError());
        SCC_Wise_Lookup.getWorkingInstructionLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getPromoLookupError() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseError());
        SCC_Wise_Lookup.getPromoLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getProdukLookupError() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseError());
        SCC_Wise_Lookup.getProdukLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getProgramLookupError() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseError());
        SCC_Wise_Lookup.getProgramLookup('123');
        Test.stopTest();
    }

    @isTest
    static void testConvertImageSuccess() {
        // Prepare test data
        List<Object> mockImageObjects = new List<Object>();
        
        // Create first mock image object
        Map<String, Object> image1 = new Map<String, Object>();
        image1.put('name', 'test_image1.jpg');
        image1.put('size', '1024KB');
        image1.put('url', 'https://example.com/images/test1.jpg');
        mockImageObjects.add(image1);
        
        // Create second mock image object
        Map<String, Object> image2 = new Map<String, Object>();
        image2.put('name', 'test_image2.png');
        image2.put('size', '512KB');
        image2.put('url', 'https://example.com/images/test2.png');
        mockImageObjects.add(image2);
        
        // Call the method being tested
        Test.startTest();
        List<SCC_WiseWrapper.DataImage> result = SCC_Wise_Lookup.convertImage(mockImageObjects);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(2, result.size(), 'Should return 2 DataImage objects');
        
        // Verify first image data
        System.assertEquals('test_image1.jpg', result[0].name, 'First image name should match');
        System.assertEquals('1024KB', result[0].size, 'First image size should match');
        System.assertEquals('https://example.com/images/test1.jpg', result[0].url, 'First image URL should match');
        
        // Verify second image data
        System.assertEquals('test_image2.png', result[1].name, 'Second image name should match');
        System.assertEquals('512KB', result[1].size, 'Second image size should match');
        System.assertEquals('https://example.com/images/test2.png', result[1].url, 'Second image URL should match');
    }

    @isTest
    static void testConvertTableSuccess() {
        // This test assumes there's a parseKnowledgeData method that processes
        // a Map<String, Object> and returns a SCC_WiseWrapper.Table object
        
        // Create mock knowledge data
        List<Object> mockKnowledgeList = new List<Object>();
        
        // Create first knowledge object
        Map<String, Object> knowledge1 = new Map<String, Object>{
            'id' => '123',
            'title' => 'Knowledge Title 1',
            'content' => 'Knowledge Content 1'
            // Add other fields as needed based on your parseKnowledgeData implementation
        };
        mockKnowledgeList.add(knowledge1);
        
        // Create second knowledge object
        Map<String, Object> knowledge2 = new Map<String, Object>{
            'id' => '456',
            'title' => 'Knowledge Title 2',
            'content' => 'Knowledge Content 2'
            // Add other fields as needed
        };
        mockKnowledgeList.add(knowledge2);
        
        // Create a mock implementation of parseKnowledgeData
        // This requires knowing what parseKnowledgeData does
        // For test purposes, we'll assume it creates a Table with the id/title fields
        
        // Call the method with our test implementation
        Test.startTest();
        List<SCC_WiseWrapper.Table> result = SCC_Wise_Lookup.convertTable(mockKnowledgeList);
        Test.stopTest();
        
        // Since we don't know the exact implementation of parseKnowledgeData,
        // we can only test that the result has the right size
        System.assertEquals(2, result.size(), 'Should return 2 Table objects');
    }

    @isTest
    static void testParseKnowledgeDataComplete() {
        // Create a complete knowledge data structure
        Map<String, Object> knowledgeData = new Map<String, Object>();
        knowledgeData.put('name', 'Test Knowledge Table');
        
        // Create table data structure
        List<Object> tableDataRows = new List<Object>();
        
        // Row 1
        List<Object> row1 = new List<Object>();
        
        // Column 1 of Row 1
        Map<String, Object> col1_1 = new Map<String, Object>();
        col1_1.put('key', 'header1');
        col1_1.put('value', 'Header 1');
        col1_1.put('row_span', 1);
        col1_1.put('col_span', 1);
        row1.add(col1_1);
        
        // Column 2 of Row 1
        Map<String, Object> col1_2 = new Map<String, Object>();
        col1_2.put('key', 'header2');
        col1_2.put('value', 'Header 2');
        col1_2.put('row_span', 1);
        col1_2.put('col_span', 2);
        row1.add(col1_2);
        
        // Add Row 1 to tableDataRows
        tableDataRows.add(row1);
        
        // Row 2
        List<Object> row2 = new List<Object>();
        
        // Column 1 of Row 2
        Map<String, Object> col2_1 = new Map<String, Object>();
        col2_1.put('key', 'data1');
        col2_1.put('value', 'Data Value 1');
        col2_1.put('row_span', 2);
        col2_1.put('col_span', 1);
        row2.add(col2_1);
        
        // Column 2 of Row 2
        Map<String, Object> col2_2 = new Map<String, Object>();
        col2_2.put('key', 'data2');
        col2_2.put('value', 'Data Value 2');
        col2_2.put('row_span', 1);
        col2_2.put('col_span', 1);
        row2.add(col2_2);
        
        // Add Row 2 to tableDataRows
        tableDataRows.add(row2);
        
        // Add tableDataRows to knowledgeData
        knowledgeData.put('table_data', tableDataRows);
        
        // Call the method being tested
        Test.startTest();
        SCC_WiseWrapper.Table result = SCC_Wise_Lookup.parseKnowledgeData(knowledgeData);
        Test.stopTest();
        
        // Verify results
        System.assertEquals('Test Knowledge Table', result.name, 'Table name should match');
        System.assertEquals(2, result.table_data.size(), 'Should have 2 rows');
        
        // Verify Row 1
        List<SCC_WiseWrapper.TableData> row1Result = result.table_data[0];
        System.assertEquals(2, row1Result.size(), 'Row 1 should have 2 columns');
        System.assertEquals('header1', row1Result[0].key, 'Row 1 Column 1 key should match');
        System.assertEquals('Header 1', row1Result[0].value, 'Row 1 Column 1 value should match');
        System.assertEquals(1, row1Result[0].row_span, 'Row 1 Column 1 row_span should match');
        System.assertEquals(1, row1Result[0].col_span, 'Row 1 Column 1 col_span should match');
        
        System.assertEquals('header2', row1Result[1].key, 'Row 1 Column 2 key should match');
        System.assertEquals('Header 2', row1Result[1].value, 'Row 1 Column 2 value should match');
        System.assertEquals(1, row1Result[1].row_span, 'Row 1 Column 2 row_span should match');
        System.assertEquals(2, row1Result[1].col_span, 'Row 1 Column 2 col_span should match');
        
        // Verify Row 2
        List<SCC_WiseWrapper.TableData> row2Result = result.table_data[1];
        System.assertEquals(2, row2Result.size(), 'Row 2 should have 2 columns');
        System.assertEquals('data1', row2Result[0].key, 'Row 2 Column 1 key should match');
        System.assertEquals('Data Value 1', row2Result[0].value, 'Row 2 Column 1 value should match');
        System.assertEquals(2, row2Result[0].row_span, 'Row 2 Column 1 row_span should match');
        System.assertEquals(1, row2Result[0].col_span, 'Row 2 Column 1 col_span should match');
        
        System.assertEquals('data2', row2Result[1].key, 'Row 2 Column 2 key should match');
        System.assertEquals('Data Value 2', row2Result[1].value, 'Row 2 Column 2 value should match');
        System.assertEquals(1, row2Result[1].row_span, 'Row 2 Column 2 row_span should match');
        System.assertEquals(1, row2Result[1].col_span, 'Row 2 Column 2 col_span should match');
    }
}