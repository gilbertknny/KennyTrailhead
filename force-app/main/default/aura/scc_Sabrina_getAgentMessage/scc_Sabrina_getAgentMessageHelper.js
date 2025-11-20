({
    fetchTargetTime: function (component) {
        const recordId = component.get("v.recordId");
        if (!recordId) {
            console.error("RecordID tidak ditemukan! Pastikan komponen ada di halaman record.");
            return;
        }

        const action = component.get("c.getTargetFirstResponseTime");
        action.setParams({ recordId: recordId });

        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const targetTime = response.getReturnValue();
                console.log("Fetched target time:", targetTime);
                component.set("v.targetFirstResponseTime", targetTime);
            } else {
                console.error("Error fetching target time: ", response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    fetchAgentMessagesHelper: function(component) {
        if (component.get("v.isProcessingMessages") === true) {
            console.log("Proses pengambilan pesan masih berjalan, menghindari multiple call");
            return;
        }
        
        // Periksa status terlebih dahulu
        const sessionStatus = component.get("v.sessionStatus");
        if (sessionStatus === 'Ended') {
            console.log("Session sudah berakhir, tidak perlu fetch messages");
            return;
        }
        
        component.set("v.isProcessingMessages", true);
        const recordId = component.get("v.recordId");
        
        this.getSessionDetails(component, recordId)
            .then(sessionDetails => {
                // Periksa status lagi setelah get session details terbaru
                if (sessionDetails.Status === 'Ended') {
                    console.log("Session baru saja dideteksi berakhir, tidak perlu melanjutkan");
                    return Promise.reject({message: "Session sudah berakhir"});
                }
                
                return this.validateUserOwnership(component, sessionDetails);
            })
            .then(sessionDetails => {
                return this.fetchAndProcessMessages(component, recordId, sessionDetails);
            })
            .catch(error => {
                // Jangan tampilkan error jika session memang sudah berakhir
                if (error && error.message !== "Session sudah berakhir") {
                    console.error("Error dalam proses message handling:", error.message);
                    component.set("v.errorMessage", "Terjadi kesalahan: " + (error.message || "Unknown error"));
                }
            })
            .finally(() => {
                component.set("v.isProcessingMessages", false);
            });
    },
    
    getSessionDetails: function(component, recordId) {
        return new Promise((resolve, reject) => {
            const sessionAction = component.get("c.getSessionDetails");
            sessionAction.setParams({ sessionId: recordId });
            
            sessionAction.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    const sessionDetails = response.getReturnValue();
                    
                    // Update status di komponen setiap kali mendapatkan session details
                    if (sessionDetails.Status) {
                        component.set("v.sessionStatus", sessionDetails.Status);
                    }
                    
                    resolve(sessionDetails);
                } else {
                    const error = response.getError();
                    console.error("Error fetching session details:", error);
                    reject(error || { message: "Error fetching session details" });
                }
            });
            
            $A.enqueueAction(sessionAction);
        });
    },
    
    validateUserOwnership: function(component, sessionDetails) {
        return new Promise((resolve, reject) => {
            const currentUserAction = component.get("c.getCurrentUserId");
            
            currentUserAction.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    const currentUserId = response.getReturnValue();
                    
                    console.log("sessionDetails: " + sessionDetails.OwnerId + " currentUserId: " + currentUserId );
                    if (sessionDetails.OwnerId !== currentUserId) {
                        const error = { message: "Anda tidak memiliki izin untuk mengakses sesi pesan ini" };
                        component.set("v.errorMessage", error.message);
                        reject(error);
                        return;
                    }
                    
                    resolve(sessionDetails);
                } else {
                    const error = response.getError();
                    console.error("Gagal mendapatkan ID user saat ini:", error);
                    reject(error || { message: "Gagal mendapatkan ID user saat ini" });
                }
            });
            
            $A.enqueueAction(currentUserAction);
        });
    },
    
    fetchAndProcessMessages: function(component, recordId, sessionDetails) {
        console.log('masuk fetch and processMessages')
        return new Promise((resolve, reject) => {
            const currentTimestamp = Date.now();
            console.log('TimeStamp sekarang: ' + String(currentTimestamp));
            const startTimestamp = String(currentTimestamp - 20500); // 20 detik 
            console.log('Timestamp 20 detik yang lalu: ' + startTimestamp);
            
            const fetchMessagesAction = component.get("c.fetchAgentMessages");
            fetchMessagesAction.setParams({ 
                recordId: recordId,
                startTimestamp: startTimestamp
            });
            
            fetchMessagesAction.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    const agentMessages = response.getReturnValue() || [];
                    console.log(`Berhasil mengambil ${agentMessages.length} pesan`);
                    
                    if (agentMessages && agentMessages.length > 0) {
                        // Komentar pengecekan previous messages agar pesan duplikat bisa terkirim
                        /* 
                        const previousMessagesMap = this.arrayToMap(component.get("v.previousMessages") || []);
                        const newMessages = agentMessages.filter(msg => !previousMessagesMap.has(msg));
                        
                        console.log(`Perbandingan: Total ${agentMessages.length}, Baru ${newMessages.length}`);
                        */
                        
                        // Anggap semua pesan sebagai pesan baru
                        const newMessages = agentMessages;
                        
                        if (newMessages.length > 0) {
                            const sendPromises = newMessages.map(message => 
                                this.sendMessageToAPIPromise(component, message, sessionDetails)
                            );
                            
                            Promise.all(sendPromises)
                                .then(() => {
                                    console.log("Semua pesan berhasil dikirim");
                                    component.set("v.previousMessages", agentMessages);
                                    component.set("v.agentMessages", agentMessages);
                                    resolve();
                                })
                                .catch(error => {
                                    console.error("Error saat mengirim pesan:", error);
                                    component.set("v.previousMessages", agentMessages);
                                    component.set("v.agentMessages", agentMessages);
                                    reject(error);
                                });
                        } else {
                            console.log("Tidak ada pesan baru yang perlu dikirim");
                            component.set("v.agentMessages", agentMessages);
                            resolve();
                        }
                    } else {
                        component.set("v.agentMessages", agentMessages);
                        resolve();
                    }
                } else {
                    const errors = response.getError();
                    let errorMsg = "Unknown error";
                    if (errors && errors.length > 0) {
                        errorMsg = `Error (${errors[0].statusCode}): ${errors[0].message}`;
                        console.error(errorMsg);
                    }
                    reject({ message: errorMsg });
                }
            });
            
            $A.enqueueAction(fetchMessagesAction);
        });
    },
    
    // Fungsi ini masih dipertahankan meskipun tidak digunakan lagi untuk pengecekan pesan duplikat
    arrayToMap: function(array) {
        const map = new Map();
        array.forEach(item => map.set(item, true));
        return map;
    },
    
    sendMessageToAPIPromise: function(component, messagePayload, sessionDetails) {
        return new Promise((resolve, reject) => {
            const milestoneTimer = component.find('sccSabrinaMilestoneTimer');
        
            console.log(`Mengirim pesan: "${messagePayload}" untuk session: ${sessionDetails.Id}`);
            
            if (!sessionDetails.is_Timer_Stop__c && milestoneTimer) {
                milestoneTimer.stopTimer();
            }
            
            const sendMessageAction = component.get("c.sendMessage");
            sendMessageAction.setParams({
                ticketNumber: sessionDetails.Conversation.ConversationIdentifier,
                message: messagePayload,
                customerName: sessionDetails.MessagingEndUser ? sessionDetails.MessagingEndUser.Name : 'Customer',
                mediaLink: ''
            });
        
            sendMessageAction.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    const result = response.getReturnValue();
                    console.log("Hasil pengiriman pesan:", result);
                    resolve(result);
                } else {
                    const error = response.getError();
                    console.error("Gagal mengirim pesan:", error);
                    component.set("v.errorMessage", "Gagal mengirim pesan");
                    reject(error || { message: "Gagal mengirim pesan" });
                }
            });
        
            $A.enqueueAction(sendMessageAction);
        });
    }
})