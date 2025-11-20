({
    searchData : function(component, searchMethod, searchValue) {
        // call apex class method
        component.set('v.isLoading', true);
        component.set('v.dataSI', []);
        component.set('v.dataTransaction', []);
        component.set('v.errorMessage', '');
        let param = {};
        let methodName = '';
        if (searchMethod === 'id_number') {
            methodName = 'c.inquiryByIdNumber';
            param = {
                'idNumber': searchValue
            };
        } else if (searchMethod === 'account_number') {
            methodName = 'c.inquiryByAccountNumber';
            param = {
                'accountNumber': searchValue
            };
        }
        let action = component.get(methodName);
        action.setParams(param);
        console.log('masuk');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                try {
                    var resultData = JSON.parse(result);
                  
                    // Check if resultData has SI_DPLK and TRX_DPLK
                    if((resultData.SI_DPLK === undefined ||resultData.SI_DPLK.length === 0) && (resultData.TRX_DPLK === undefined || resultData.TRX_DPLK.length === 0))
                        {
                           component.set('v.errorMessage', 'Data tidak ditemukan.');
                       }
                    else
                    {
                    if (resultData.SI_DPLK === undefined ||resultData.SI_DPLK.length === 0 )
                    {
                        component.set('v.dataSI', '');
                    }
                    else
                    {
                        resultData = this.formatSIData(resultData);
                        component.set('v.dataSI', resultData.SI_DPLK);
                    }
                    if (resultData.TRX_DPLK === undefined || resultData.TRX_DPLK.length === 0){
                        component.set('v.dataTransaction', '');
                       
                    } else {
                        
                        component.set('v.dataTransaction',  resultData.TRX_DPLK);
                    }
                    if((resultData.SI_DPLK === undefined ||resultData.SI_DPLK.length === 0) && (resultData.TRX_DPLK === undefined || resultData.TRX_DPLK.length === 0))
                     {
                        component.set('v.errorMessage', 'Data tidak ditemukan.');
                    }
                    }
                } catch (e) {
                    console.error('Error parsing response:', e);
                    
                    component.set('v.errorMessage', e);
                }
            } else if (state === 'ERROR') {
                component.set('v.errorMessage', 'Terjadi kesalahan saat mengambil data.');
            }else{
                component.set('v.errorMessage', 'Data tidak ditemukan.');
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
    formatSIData: function(data) {
       var formatIndonesiaCurrency = function(value) {
            var tmp = value;
           
            if (tmp === null) {
                return 'Rp 0';
            }
            let rupiahFormat = new Intl.NumberFormat('id-ID', {
                style: 'currency',
                currency: 'IDR',
              }).format(tmp);
         /*   tmp = tmp.replace('.0', '');
            return 'Rp ' + tmp.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');*/
        return rupiahFormat;

        };
        data.SI_DPLK.forEach(function(row) {
            // format and store to the same field
            // put T between date and time, and zone after the time
            row.tgl_registrasi = row.tgl_registrasi.replace(' ', 'T') + '.000+07:00';
           
            row.iuran = formatIndonesiaCurrency(row.iuran);
            row.pengembangan = formatIndonesiaCurrency(row.pengembangan);
            row.pengalihan = formatIndonesiaCurrency(row.pengalihan);
            row.total_saldo = formatIndonesiaCurrency(row.total_saldo);
           
          
        });
        
        return data;
    }
})