global class SurgeryReminderScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<Surgery__c> surgeries = [
            SELECT Id, Patient__c, SurgeryDate__c, ReminderSent__c, 
                   Patient__r.Name, Patient__r.Contact__c
            FROM Surgery__c
            WHERE SurgeryDate__c = :System.now().addDays(1)
            AND ReminderSent__c = false
        ];

        for(Surgery__c s : surgeries) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { s.Patient__r.Contact__c });
            mail.setSubject('Surgery Reminder');
            mail.setPlainTextBody('Hello ' + s.Patient__r.Name +
                ', this is a reminder for your scheduled surgery tomorrow.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            s.ReminderSent__c = true;
        }
        update surgeries;
    }
}
