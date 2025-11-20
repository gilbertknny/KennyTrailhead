public class SCC_UUID {
    public static void serializeAndDebug(String sccUuidString) {
        List<String> sccUuidArray = sccUuidString.split(',');
        String jsonString = JSON.serialize(sccUuidArray);
        System.debug(jsonString);
    }
}