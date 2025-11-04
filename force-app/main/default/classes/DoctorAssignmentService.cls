public with sharing class DoctorAssignmentService {

    // Assign doctor based on patient problem
    public static Id assignDoctor(String problem) {
        String specialization = 'General Medicine';

        if (problem != null) {
            String lowerProblem = problem.toLowerCase();

            if (lowerProblem.contains('heart')) {
                specialization = 'Cardiology';
            } else if (lowerProblem.contains('bone')) {
                specialization = 'Orthopedic';
            } else if (lowerProblem.contains('eye')) {
                specialization = 'Ophthalmology';
            } else if (lowerProblem.contains('surgery')) {
                specialization = 'Surgery';
            }
        }

        Id doctorId;

        try {
            // Check if object and field exist before querying
            if (Schema.getGlobalDescribe().containsKey('Doctor__c') &&
                Schema.getGlobalDescribe().get('Doctor__c').getDescribe().fields.getMap().containsKey('Specialization__c')) {

                List<Doctor__c> doctors = [
                    SELECT Id 
                    FROM Doctor__c 
                    WHERE Specialization__c = :specialization 
                    LIMIT 1
                ];

                if (!doctors.isEmpty()) {
                    doctorId = doctors[0].Id;
                }
            }
        } catch (Exception e) {
            System.debug('Error in DoctorAssignmentService: ' + e.getMessage());
            doctorId = null;
        }

        return doctorId;
    }
}
