require "email"

def email_ticket_waiting_validation(email : String)
  EMail.send("smtp.gmail.com", 587, use_tls: true, auth: {"bob.nlpf@gmail.com", "bob-nlpf75"}) do
    subject "Ticket waiting for validation"
    from "bob.nlpf@gmail.com"
    to email

    message <<-EOM
    Hi ! Your ticket is waiting for validation.
    I will contact you soon.

    --
    Bob Boob
    EOM
  end
end

def email_ticket_validate_intervention(email : String)
  EMail.send("smtp.gmail.com", 587, use_tls: true, auth: {"bob.nlpf@gmail.com", "bob-nlpf75"}) do
    subject "Intervention scheduled"
    from "bob.nlpf@gmail.com"
    to email

    message <<-EOM
    Hi ! I schedule the intervention n°X

    --
    Bob Boob
    EOM
  end
end
