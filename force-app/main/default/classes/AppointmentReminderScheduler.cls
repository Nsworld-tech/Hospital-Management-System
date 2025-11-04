global class AppointmentReminderScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<Appointment__c> apps = [
            SELECT Id, Patient__c, Date__c, ReminderSent__c, Patient__r.Name, Patient__r.Contact__c
            FROM Appointment__c
            WHERE Date__c = :System.now().addDays(1)
            AND ReminderSent__c = false
        ];

        for(Appointment__c app : apps) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { app.Patient__r.Contact__c });
            mail.setSubject('Appointment Reminder');
            mail.setPlainTextBody('Hello ' + app.Patient__r.Name +
                ', this is a reminder for your appointment tomorrow.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            app.ReminderSent__c = true;
        }
        update apps;
    }
}
