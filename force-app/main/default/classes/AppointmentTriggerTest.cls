@IsTest
public class AppointmentTriggerTest {

    @IsTest
    static void testAppointmentDoctorAssignment() {
        // Create test doctor
        Doctor__c cardiologist = new Doctor__c(Name = 'Dr. Heart', Specialization__c = 'Cardiology');
        insert cardiologist;

        // Create test patient
        Patient__c patient = new Patient__c(Name = 'John Doe', ProblemDescription__c = 'heart issue');
        insert patient;

        // Create appointment
        Appointment__c appt = new Appointment__c(Patient__c = patient.Id);
        insert appt;

        // Reload appointment from DB
        appt = [SELECT Id, Doctor__c FROM Appointment__c WHERE Id = :appt.Id];

        // Validate doctor is assigned
        System.assertEquals(cardiologist.Id, appt.Doctor__c);
    }
}
