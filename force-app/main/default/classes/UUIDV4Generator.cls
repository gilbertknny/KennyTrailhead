public class UUIDV4Generator {
    @InvocableMethod
    public static List<String> generateUUID(List<String> requests) {
        System.debug('Input Requests: ' + requests);
        List<String> uuids = new List<String>();
        for (String req : requests) {
            String uuid = UUID.randomUUID().toString();
            System.debug('Generated UUID for ' + req + ': ' + uuid);
            uuids.add(uuid);
        }
        System.debug('All Generated UUIDs: ' + uuids);
        return uuids;
    }
}