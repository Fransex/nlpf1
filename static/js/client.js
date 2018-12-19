Vue.use(window.vuelidate.default)
const { required } = window.validators

new Vue({
    el: '#app',
    data () {
        return {
            tickets: [],
            buildings: [],

            ticket: {
                building: null,
                orientation: null,
                building_floor: 0,
                intervention_date: new Date().toISOString().slice(0,16),
                file_data: null,
                file_name: null
            },
            building: {
                nb_floor: 1,
                address: '',
                country: '',
                file_data: null,
                file_name: null
            }
        }
    },
    validations: {
        ticket: {
            building: { required },
            orientation: { required },
            building_floor: { required },
            intervention_date: { required }
        },
        building: {
            nb_floor: { required },
            address: { required },
            country: { required }
        }
    },
    methods: {
        handle_building_file_upload(){
            const input = event.target;
            let attachment = (input.files && input.files[0]) ? input.files[0] : '';
            if (attachment) {
                let reader = new FileReader();
                reader.onload = (e) => {
                    this.building.file_data = e.target.result;
                    let a = this.building.file_data.indexOf('base64')
                    let v = this.building.file_data.slice(a + 7)
                    this.building.file_data = v;
                }
                reader.readAsDataURL(attachment);
                this.building.file_name = attachment.name;
            } else {
                this.building.file_name = null;
                this.building.file_data = null;
            }
        },
        handle_ticket_file_upload(){
            const input = event.target;
            let attachment = (input.files && input.files[0]) ? input.files[0] : '';
            if (attachment) {
                let reader = new FileReader();
                reader.onload = (e) => {
                    this.ticket.file_data = e.target.result;
                    let a = this.ticket.file_data.indexOf('base64')
                    let v = this.ticket.file_data.slice(a + 7)
                    this.ticket.file_data = v;
                }
                reader.readAsDataURL(attachment);
                this.ticket.file_name = attachment.name;
            } else {
                this.ticket.file_name = null;
                this.ticket.file_data = null;
            }
        },
        send_building: function() {
            console.log(this.$v.building)
            if (this.$v.building.$invalid)
                return this.$v.$touch();

            axios.post("/building", this.building ).then(function(response) {
                // Close modal
                window.modal_building.close();

                // Reset building form
                this.building.nb_floor = 1;
                this.building.address = '';
                this.building.country = '';

                // Reload building list
                this.get_buildings();

            }.bind(this)).catch(function(error) {
                console.log(error)
            })
        },
        delete_bulding: function(building_id) {
            axios.delete("/building/" + building_id).then(function(response) {
                // Reload building list
                this.get_buildings();
            }.bind(this)).catch(function(error) {
                console.log(error)
            })
        },
        send_ticket: function() {
            if (this.$v.ticket.$invalid)
                return this.$v.$touch();

            let t = {
                building: parseInt(this.ticket.building),
                orientation: parseInt(this.ticket.orientation),
                building_floor: parseInt(this.ticket.building_floor),
                intervention_date: new Date(this.ticket.intervention_date).getTime()
            }
            if (this.ticket.file_name) {
                t.file_name = this.ticket.file_name;
                t.file_data = this.ticket.file_data;
            }

            axios.post("/ticket", t).then(function(response) {
                // Close modal
                window.modal_ticket.close();

                // Reset ticket form
                this.ticket.building = null;
                this.ticket.orientation = null;
                this.ticket.building_floor = 0;
                this.ticket.intervention_date = new Date().toISOString().slice(0,16);

                // Reload ticket list
                this.get_tickets();

            }.bind(this)).catch(function(error) {
                console.log(error)
            })
        },
        get_tickets: function() {
            axios.get("/tickets").then(function(response) {
                this.tickets = response.data;
            }.bind(this)).catch(function(error) {
                console.log(error)
            })
        },
        get_buildings: function() {
            axios.get("/buildings").then(function(response) {
                this.buildings = response.data;
            }.bind(this)).catch(function(error) {
                console.log(error)
            })
        },
    },
    mounted: function () {
        this.get_tickets();
        this.get_buildings();
    }
})
