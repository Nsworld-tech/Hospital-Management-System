public with sharing class AdmissionService {
    public static void calculateFinalBill(Id admissionId) {
        Admission__c admission = [
            SELECT Id, FinalBill__c, Patient__c 
            FROM Admission__c WHERE Id = :admissionId LIMIT 1
        ];

        Decimal total = 0;

        // Add pharmacy bills
        List<PharmacyBill__c> bills = [
            SELECT Amount__c FROM PharmacyBill__c WHERE Patient__c = :admission.Patient__c
        ];
        for(PharmacyBill__c b : bills) {
            total += b.Amount__c;
        }

        // Add consultation fees (appointments)
        List<Appointment__c> apps = [
            SELECT Id FROM Appointment__c 
            WHERE Patient__c = :admission.Patient__c AND PaymentStatus__c = 'Paid'
        ];
        total += apps.size() * 500; // assume 500 per consultation

        admission.FinalBill__c = total;
        update admission;
    }
}
