public class SCC_CustomerProfileInfo {
    public SCC_CustomerProfileWrapper.Demografi demographicInfo;
    public String cifno;
    
    public SCC_CustomerProfileInfo(SCC_CustomerProfileWrapper.Demografi demographicInfo, String cifno) {
        this.demographicInfo = demographicInfo;
        this.cifno = cifno;
    }
}