public with sharing class AppointmentController {

    // Fetch all patients
    @AuraEnabled(cacheable=true)
    public static List<Patient__c> getPatients() {
        return [SELECT Id, Name, Condition__c, ProblemDescription__c FROM Patient__c ORDER BY Name];
    }

    // Fetch all appointments
    @AuraEnabled(cacheable=true)
    public static List<Appointment__c> getAppointments() {
        return [
            SELECT Id, Patient__r.Name, Doctor__r.Name, Date__c
            FROM Appointment__c
            ORDER BY Date__c
        ];
    }

    // Assign doctor based on patient condition
    public static Doctor__c assignDoctor(Patient__c patient) {
        List<Doctor__c> doctors = [
            SELECT Id, Name, Specialization__c
            FROM Doctor__c
            WHERE Specialization__c = :patient.Condition__c
            LIMIT 1
        ];

        if (!doctors.isEmpty()) {
            return doctors[0];
        }

        // fallback to any doctor if no match
        List<Doctor__c> allDoctors = [SELECT Id, Name FROM Doctor__c LIMIT 1];
        return allDoctors.isEmpty() ? null : allDoctors[0];
    }

    // Create appointment
    @AuraEnabled
    public static Appointment__c createAppointment(Id patientId, String apptDateTime) {
        try {
            if (patientId == null) {
                throw new AuraHandledException('Patient Id is missing');
            }

            Patient__c patient = [SELECT Id, Condition__c FROM Patient__c WHERE Id = :patientId LIMIT 1];

            Doctor__c doctor = assignDoctor(patient);
            if (doctor == null) {
                throw new AuraHandledException('No doctor available for this patient condition');
            }

            if (apptDateTime == null || apptDateTime.trim() == '') {
                throw new AuraHandledException('Appointment Date/Time is missing');
            }

            DateTime dt;
            try {
                dt = DateTime.valueOf(apptDateTime);
            } catch(Exception e) {
                throw new AuraHandledException('Invalid Date/Time format: ' + apptDateTime);
            }

            Appointment__c newAppt = new Appointment__c(
                Patient__c = patient.Id,
                Doctor__c = doctor.Id,
                Date__c = dt
            );
            insert newAppt;

            // Query inserted appointment including related fields
            newAppt = [
                SELECT Id, Date__c, Patient__r.Name, Doctor__r.Name
                FROM Appointment__c
                WHERE Id = :newAppt.Id
                LIMIT 1
            ];

            return newAppt;

        } catch(Exception e) {
            throw new AuraHandledException('Error creating appointment: ' + e.getMessage());
        }
    }
}
