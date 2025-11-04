trigger AppointmentTrigger on Appointment__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {

        Set<Id> patientIds = new Set<Id>();
        for (Appointment__c ap : Trigger.new) {
            if (ap.Patient__c != null) {
                patientIds.add(ap.Patient__c);
            }
        }

        Map<Id, Patient__c> patientMap =
            new Map<Id, Patient__c>([
                SELECT Id, ProblemDescription__c
                FROM Patient__c
                WHERE Id IN :patientIds
            ]);

        for (Appointment__c ap : Trigger.new) {
            if (ap.Patient__c != null && patientMap.containsKey(ap.Patient__c)) {
                String problem = patientMap.get(ap.Patient__c).ProblemDescription__c;
                ap.Doctor__c = DoctorAssignmentService.assignDoctor(problem);
            }
        }
    }
}
