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
        console.log("DEBUG - Starting fetchAgentMessagesHelper for recordId:", recordId);
        
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
        console.log('masuk fetch and processMessages');
        console.log('DEBUG - recordId for fetchAndProcessMessages:', recordId);
        return new Promise((resolve, reject) => {
            const currentTimestamp = Date.now();
            console.log('TimeStamp sekarang: ' + String(currentTimestamp));
            const timeInterval = parseInt($A.get("$Label.c.Sabrina_TimeInterval"), 10) || 30000;
            const startTimestamp = String(currentTimestamp - timeInterval); 
            console.log('Timestamp 20 detik yang lalu: ' + startTimestamp + ' timeInterval: ' + timeInterval);
            
            // Ambil existing processedMessageIds dari SessionStorage
            let processedMessageIds = {};
            try {
                const storedIds = sessionStorage.getItem('processedMessageIds_' + recordId);
                if (storedIds) {
                    processedMessageIds = JSON.parse(storedIds);
                    console.log('Mengambil processedMessageIds dari sessionStorage:', Object.keys(processedMessageIds));
                    // console.log('DEBUG - Jumlah ID dalam processedMessageIds:', Object.keys(processedMessageIds).length);
                    // console.log('DEBUG - Daftar lengkap ID:', Object.keys(processedMessageIds).join(', '));
                } else {
                    console.log('Tidak ada processedMessageIds di sessionStorage, membuat baru');
                }
            } catch (e) {
                console.error('Error saat mengambil processedMessageIds dari sessionStorage:', e);
            }
            
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
                        console.log('ID pesan yang sudah diproses sebelumnya:', Object.keys(processedMessageIds));
                        // console.log('DEBUG - Daftar semua ID pesan yang diambil:', agentMessages.map(msg => msg.id).join(', '));
                        
                        // Filter pesan yang belum pernah diproses berdasarkan ID
                        const newMessages = agentMessages.filter(msg => {
                            const msgId = msg.id;
                            if (!msgId) {
                                console.warn('Pesan tanpa ID ditemukan:', msg);
                                return false;
                            }
                            const alreadyProcessed = processedMessageIds[msgId] === true;
                            console.log(`Cek pesan ID ${msgId}: ${alreadyProcessed ? 'Sudah diproses' : 'Belum diproses'}`);
                            // console.log(`DEBUG - Pesan ID ${msgId} text: "${msg.text ? msg.text.substring(0, 20) + '...' : 'empty'}", status: ${alreadyProcessed ? 'processed' : 'new'}`);
                            return !alreadyProcessed;
                        });
                        
                        console.log(`Perbandingan: Total ${agentMessages.length}, Baru ${newMessages.length}`);
                        // console.log('DEBUG - IDs pesan baru yang akan diproses:', newMessages.map(msg => msg.id).join(', '));
                        
                        if (newMessages.length > 0) {
                            const sendSequentially = newMessages.reduce((chain, message) => {
                                return chain.then(() => {
                                    console.log(`Mencoba mengirim pesan ID ${message.id}`);
                                    return this.sendMessageToAPIPromise(component, message.text, sessionDetails)
                                        .then(result => {
                                            console.log(`Pesan ID ${message.id} berhasil dikirim`);
                                            // Menandai pesan sebagai sudah diproses
                                            processedMessageIds[message.id] = true;
                                            
                                            // Simpan ke sessionStorage setiap kali satu pesan berhasil dikirim
                                            try {
                                                sessionStorage.setItem('processedMessageIds_' + recordId, JSON.stringify(processedMessageIds));
                                                console.log('DEBUG - Updated processedMessageIds after processing message:', Object.keys(processedMessageIds).join(', '));
                                            } catch (e) {
                                                console.error('Error saat menyimpan ke sessionStorage:', e);
                                            }
                                            
                                            return result;
                                        })
                                        .catch(error => {
                                            console.error(`Error saat mengirim pesan ID ${message.id}:`, error);
                                            // Lanjutkan ke pesan berikutnya meskipun ada error
                                            return Promise.resolve();
                                        });
                                });
                            }, Promise.resolve());
                            
                            sendSequentially
                                .then(() => {
                                    console.log("Proses pengiriman pesan selesai");
                                    console.log("DEBUG - Final state of processedMessageIds:", Object.keys(processedMessageIds).join(', '));
                                    component.set("v.agentMessages", agentMessages);
                                    resolve();
                                })
                                .catch(error => {
                                    console.error("Error dalam proses pengiriman:", error);
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
    
    sendMessageToAPIPromise: function(component, messageText, sessionDetails) {
        return new Promise((resolve, reject) => {
            const milestoneTimer = component.find('sccSabrinaMilestoneTimer');
        
            if (!messageText) {
                console.warn("Mencoba mengirim pesan kosong, dilewati");
                return resolve(); // Skip pesan kosong
            }
            
            console.log(`Mengirim pesan: "${messageText.substring(0, 30)}..." untuk session: ${sessionDetails.Id}`);
            
            if (!sessionDetails.is_Timer_Stop__c && milestoneTimer) {
                try {
                    milestoneTimer.stopTimer();
                } catch(e) {
                    console.warn("Error saat menghentikan timer:", e);
                }
            }
            
            const sendMessageAction = component.get("c.sendMessage");
            sendMessageAction.setParams({
                ticketNumber: sessionDetails.Conversation.ConversationIdentifier,
                message: messageText,
                customerName: sessionDetails.MessagingEndUser ? sessionDetails.MessagingEndUser.Name : 'Customer',
                mediaLink: ''
            });
        
            sendMessageAction.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    const result = response.getReturnValue();
                    console.log("Hasil pengiriman pesan:", result);
                    console.log("DEBUG - Message sent successfully to API");
                    resolve(result);
                } else {
                    const error = response.getError();
                    let errorMsg = "Unknown error";
                    if (error && error.length > 0) {
                        errorMsg = error[0].message || JSON.stringify(error);
                    }
                    console.error("Gagal mengirim pesan:", errorMsg);
                    component.set("v.errorMessage", "Gagal mengirim pesan: " + errorMsg);
                    reject(new Error(errorMsg));
                }
            });
        
            $A.enqueueAction(sendMessageAction);
        });
    }
})