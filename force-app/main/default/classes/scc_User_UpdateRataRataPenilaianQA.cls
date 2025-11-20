/**
 * @description       : Class to update a custom field on User using a parameter from Flow using Queueable Apex
 * @group             : 
 * @last modified on  : 20-12-2024
 * @last modified by  : Christian Vieri
**/
public without sharing class scc_User_UpdateRataRataPenilaianQA {

    @InvocableMethod(label='Queue Update User Average Rating' description='Queue User field update with a rating value from Flow')
    public static void queueUpdateUserRatings(List<Request> requests) {
        System.debug('Queuing updateUserRatings job');
        System.enqueueJob(new UpdateUserQueueable(requests));
    }

    public class UpdateUserQueueable implements Queueable {
        private List<Request> requests;

        public UpdateUserQueueable(List<Request> requests) {
            this.requests = requests;
        }

        public void execute(QueueableContext context) {
            System.debug('Executing UpdateUserQueueable job');

            Set<Id> userIds = new Set<Id>();
            for (Request req : requests) {
                if (req.userId != null) {
                    userIds.add(req.userId);
                }
            }

            System.debug('User IDs: ' + userIds);

            List<User> usersToUpdate = [
                SELECT Id, Rata_rata_penilaian_Bulan_Berjalan__c, Rata_rata_penilaian_Bulan_Ini__c FROM User WHERE Id IN :userIds
            ];

            System.debug('Users to Update: ' + usersToUpdate);

            try {
                for (User user : usersToUpdate) {
                    for (Request req : requests) {
                        if (user.Id == req.userId) {
                            user.Rata_rata_penilaian_Bulan_Berjalan__c = String.valueOf(req.ratingCurrentMonth);
                            user.Rata_rata_penilaian_Bulan_Ini__c = String.valueOf(req.ratingThisMonth);
                            System.debug('Updating User: ' + user.Id + ' with ratings - Current Month: ' + req.ratingCurrentMonth + ', This Month: ' + req.ratingThisMonth);
                        }
                    }
                }

                if (!usersToUpdate.isEmpty()) {
                    update usersToUpdate;
                    System.debug('Berhasil Update');
                }
            } catch (Exception e) {
                System.debug('Error during User Update: ' + e.getMessage());
            }
        }
    }


    public class Request {
        @InvocableVariable(label='User ID' description='ID of the User to update' required=true)
        public Id userId;

        @InvocableVariable(label='RatingThisMonth' description='Rating this month' required=true)
        public Decimal ratingThisMonth;

        @InvocableVariable(label='RatingCurrentMonth' description='Rating current month' required=true)
        public Decimal ratingCurrentMonth;
    }
}