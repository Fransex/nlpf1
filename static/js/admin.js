Vue.use(window.vuelidate.default)
const { required } = window.validators

new Vue({
    el: '#app',
    data () {
        return {
            tickets: []
        }
    },
    validations: {

    },
    methods: {
        get_tickets: function() {
            axios.get("/admin/tickets").then(function(response) {
                this.tickets = response.data;
                console.log(this.tickets)
            }.bind(this)).catch(function(error) {
                console.log(error)
            })
        },

        set_state_ticket: function(id, state) {
            axios.patch("/admin/ticket/state/" + state + "/" + id).then(function(response) {
                this.get_tickets();
            }.bind(this)).catch(function(error) {
                console.log(error)
            })
        }
    },
    mounted: function () {
        this.get_tickets();
    }
})
