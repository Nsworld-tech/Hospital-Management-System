public with sharing class AppointmentTriggerHandler {

    // Method to run before inserting appointments
    public static void beforeInsert(List<Appointment__c> newAppointments) {
        for (Appointment__c appt : newAppointments) {
            // Only assign doctor if not already set
            if (appt.Doctor__c == null) {
                String problemDescription = (appt.Patient__r != null) ? appt.Patient__r.ProblemDescription__c : null;
                appt.Doctor__c = DoctorAssignmentService.assignDoctor(problemDescription);
            }
        }
    }
}
