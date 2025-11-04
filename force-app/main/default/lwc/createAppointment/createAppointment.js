import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPatients from '@salesforce/apex/AppointmentController.getPatients';
import createAppointment from '@salesforce/apex/AppointmentController.createAppointment';
import getAppointments from '@salesforce/apex/AppointmentController.getAppointments';

export default class CreateAppointment extends LightningElement {
    @track patients = [];
    @track appointments = [];
    @track selectedPatientId = '';
    @track selectedDate = '';
    @track selectedTime = '';

    // Load patients
    @wire(getPatients)
    wiredPatients({ error, data }) {
        if (data) {
            this.patients = data;
        } else if (error) {
            console.error(error);
            this.showToast('Error', 'Failed to load patients', 'error');
        }
    }

    // Load appointments on component load
    connectedCallback() {
        this.refreshAppointments();
    }

    // Refresh appointment list
    refreshAppointments() {
        getAppointments()
            .then(result => {
                this.appointments = result;
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', 'Failed to load appointments', 'error');
            });
    }

    get patientsOptions() {
        return this.patients.map(patient => ({
            label: `${patient.Name} (${patient.Condition__c})`,
            value: patient.Id
        }));
    }

    handlePatientChange(event) {
        this.selectedPatientId = event.target.value;
    }

    handleDateChange(event) {
        this.selectedDate = event.target.value;
    }

    handleTimeChange(event) {
        this.selectedTime = event.target.value;
    }

    handleCreateAppointment() {
        if (!this.selectedPatientId || !this.selectedDate || !this.selectedTime) {
            this.showToast('Error', 'Please select patient, date, and time.', 'error');
            return;
        }

        // Combine date and time into "yyyy-MM-dd HH:mm:ss"
        const [hours, minutes] = this.selectedTime.split(':');
        const dt = new Date(this.selectedDate);
        dt.setHours(parseInt(hours, 10));
        dt.setMinutes(parseInt(minutes, 10));
        dt.setSeconds(0);

        const yyyy = dt.getFullYear();
        const mm = String(dt.getMonth() + 1).padStart(2, '0');
        const dd = String(dt.getDate()).padStart(2, '0');
        const hh = String(dt.getHours()).padStart(2, '0');
        const min = String(dt.getMinutes()).padStart(2, '0');
        const ss = '00';
        const dateTimeString = `${yyyy}-${mm}-${dd} ${hh}:${min}:${ss}`;

        createAppointment({
            patientId: this.selectedPatientId,
            apptDateTime: dateTimeString
        })
        .then(result => {
            const patientName = result.Patient__r ? result.Patient__r.Name : 'Unknown Patient';
            const doctorName = result.Doctor__r ? result.Doctor__r.Name : 'Unassigned Doctor';

            this.showToast(
                'Success',
                `Appointment created for ${patientName} with doctor ${doctorName}`,
                'success'
            );

            this.selectedPatientId = '';
            this.selectedDate = '';
            this.selectedTime = '';

            this.refreshAppointments();
        })
        .catch(error => {
            let message = 'Unknown error';
            if (error && error.body && error.body.message) {
                message = error.body.message;
            } else if (error && error.message) {
                message = error.message;
            }
            console.error(error);
            this.showToast('Error', message, 'error');
        });
    }

    // Utility: show toast message
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
                mode: 'dismissable'
            })
        );
    }
}
