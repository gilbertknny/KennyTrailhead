({
    initComponent: function(component, event, helper) {
        console.log('Initializing Aura component');
        const recordId = component.get("v.recordId");
        if (!recordId) {
            console.error('RecordId not available');
            return;
        }
        
        // Jalankan fetch pertama kali dan dapatkan status
        helper.getSessionDetails(component, recordId)
            .then(sessionDetails => {
                // Periksa status dan simpan
                component.set("v.sessionStatus", sessionDetails.Status);
                
                // Hanya jalankan fetch dan setup interval jika status bukan 'Ended'
                if (sessionDetails.Status !== 'Ended') {
                    helper.fetchAgentMessagesHelper(component);
                    
                    const intervalId = window.setInterval(
                        $A.getCallback(function() {
                            // Periksa status yang tersimpan sebelum fetch
                            if (component.get("v.sessionStatus") !== 'Ended') {
                                helper.fetchAgentMessagesHelper(component);
                            } else {
                                // Clear interval jika sesi sudah berakhir
                                window.clearInterval(intervalId);
                                console.log('Session telah berakhir, interval fetching dihentikan');
                            }
                        }), 10000
                    );
                    
                    // Simpan intervalId
                    component.set("v.intervalId", intervalId);
                } else {
                    console.log('Session sudah berakhir, tidak perlu melakukan polling');
                }
            })
            .catch(error => {
                console.error('Error saat memeriksa session details:', error);
            });
    },
    
    onDestroy: function(component, event, helper) {
        const intervalId = component.get("v.intervalId");
        if (intervalId) {
            window.clearInterval(intervalId);
            console.log('Interval polling dihentikan karena component di-destroy');
        }
    }
})