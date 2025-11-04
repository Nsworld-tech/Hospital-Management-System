@IsTest
public class DoctorAssignmentServiceTest {

    @IsTest
    static void testAssignDoctorSimplified() {
        // Create doctors for testing
        Doctor__c cardiologist = new Doctor__c(Name = 'Dr. Heart', Specialization__c = 'Cardiology');
        Doctor__c general = new Doctor__c(Name = 'Dr. General', Specialization__c = 'General Medicine');
        insert new List<Doctor__c>{ cardiologist, general };

        // Test assignment for heart problem
        Id cardiologyId = DoctorAssignmentService.assignDoctor('Patient has heart issues');
        System.assertEquals(cardiologist.Id, cardiologyId);

        // Test assignment for unknown or null problem → General Medicine
        Id generalId = DoctorAssignmentService.assignDoctor('Patient has fever');
        Id nullProblemId = DoctorAssignmentService.assignDoctor(null);
        System.assertEquals(general.Id, generalId);
        System.assertEquals(general.Id, nullProblemId);
    }
}
