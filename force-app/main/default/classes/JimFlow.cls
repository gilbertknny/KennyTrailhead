global with sharing class JimFlow {
    private Flow.Interview myfi;

    global void createInterview(String flowName,Map<String, Object> req) {
        this.myfi = Flow.Interview.createInterview(flowName, req);
    }

    global void start() {
        this.myfi.start();
    }

    global Object getVariableValue(String variableName) {
        return this.myfi.getVariableValue(variableName);
    }
}