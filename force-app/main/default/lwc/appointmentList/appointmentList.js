import { LightningElement, track, wire } from 'lwc';
import getAppointments from '@salesforce/apex/AppointmentController.getAppointments';

export default class AppointmentList extends LightningElement {
    @track appointments = [];

    @wire(getAppointments)
    wiredAppointments({ error, data }) {
        if (data) {
            this.appointments = data;
        } else if (error) {
            console.error(error);
        }
    }
}
