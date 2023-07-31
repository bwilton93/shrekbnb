require 'mail'

class Mailer
  def initialize
    options = {
      address: 'smtp.gmail.com',
      port: 587,
      domain: 'gmail.com',
      user_name: 'shrekfrommakersbnb@gmail.com',
      password: 'oxjwquviyyhjckqr',
      authentication: 'plain'
    }

    Mail.defaults do
      delivery_method :smtp, options
    end
  end

  def send(email_type, email_address)
    subject = generate_subject(email_type)
    body = generate_body(email_type)

    return 'Email failed to send.' unless subject || body

    Mail.deliver do
      to email_address
      from 'Shrek @ MakersBnB'
      subject subject
      body body
    end

    "#{email_type} email sent"
  end

  def generate_subject(email_type)
    case email_type
    when 'signup'
      'Welcome to MakersBnB!'
    when 'createlisting'
      'You created a new listing!'
    when 'updatelisting'
      'You updated your listing!'
    when 'bookingrequested'
      'New booking request received!'
    when 'confirmrequest'
      'You approved a booking!'
    when 'requestbooking'
      'You requested a new booking!'
    when 'requestconfirmed'
      'Your booking request has been confirmed!'
    when 'requestdenied'
      'Your booking request has been denied.'
    else
      false
    end
  end

  def generate_body(email_type)
    case email_type
    when 'signup'
      'Welcome to MakersBnB!'
    when 'createlisting'
      'You created a new listing!'
    when 'updatelisting'
      'You updated your listing!'
    when 'bookingrequested'
      'New booking request received!'
    when 'confirmrequest'
      'You approved a booking!'
    when 'requestbooking'
      'You requested a new booking!'
    when 'requestconfirmed'
      'Your booking request has been confirmed!'
    when 'requestdenied'
      'Your booking request has been denied.'
    else
      false
    end
  end
end
