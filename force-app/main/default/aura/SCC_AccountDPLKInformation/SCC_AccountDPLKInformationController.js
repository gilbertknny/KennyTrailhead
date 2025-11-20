({
    handleInputChange : function(component, event, helper) {
        var inputValue = component.get("v.searchValue");
        if(inputValue.length > 0){
            component.set("v.hasText", true);  
            component.set("v.errorMessage", "");  
        }else{
            component.set("v.hasText", false); 
            component.set("v.errorMessage", "");
            component.set("v.dataSI", []);
            component.set("v.dataTransaction", []);   
        }
    },
    searchData : function(component, event, helper) {
        let searchMethod = component.get("v.methodValue");
        let searchValue = component.get("v.searchValue");
        // if searchMethod is empty, then alert the user
        if(searchMethod == ''){
            //alert('Pilih salah satu metode pencarian terlebih dahulu!');
            component.set('v.errorMessage', 'Pilih salah satu metode pencarian terlebih dahulu!');
            return;
        }
        // if searchValue is empty, then alert the user
        if(searchValue == ''){
            component.set('v.errorMessage', 'Masukkan ID Number atau Nomor Rekening terlebih dahulu!');
            return;
        }

        component.set('v.columns', [
            {label: 'Tgl Transaksi', fieldName: 'tanggal_transaksi', type: 'date', initialWidth: 120},
            {label: 'Nama Transaksi', fieldName: 'nama_transaksi', type: 'text'},
            {label: 'Kode Cabang', fieldName: 'branch_code', type: 'text', initialWidth: 120},
            {label: 'ID Transaksi', fieldName: 'id_transaksi', type: 'text', initialWidth: 120},
            {label: 'Keterangan', fieldName: 'keterangan', type: 'text', initialWidth: 330},
        ]);

        component.set("v.errorMessage", "");
        helper.searchData(component, searchMethod, searchValue);
    }
})