public class AccountHandler {
    public static void insertAccount(Integer value){
        Integer N = 1;
        List<Account> addAccounts = new List<Account>();
        While(N <= value){
            //display the current counter value
            System.debug('Counter Value before Incrementing ' + N);
            Account myAcc = new Account();
            myAcc.Name = 'Acme Inc ' + N;
            myAcc.AccountNumber = 'A000' + N;
            addAccounts.add(myAcc);
            System.debug(addAccounts);
            //increment the counter
            N = N + 1;
            System.debug('Counter Value after incrementing ' + N);
        }
        System.debug('Size of Account List: ' + addAccounts.size() );
        System.debug('Elements in Account List: ' + addAccounts);
        //insert all of the accounts in the list
        insert addAccounts;

        }
    }