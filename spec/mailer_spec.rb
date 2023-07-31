require 'mailer'

RSpec.describe Mailer do
  context 'send' do
    it 'sends the signup email' do
      mailer = Mailer.new
      expect(mailer.send('signup', 'email@email.com')).to eq 'signup email sent'
    end

    it 'sends the createlisting email' do
      mailer = Mailer.new
      expect(mailer.send('createlisting', 'email@email.com')).to eq 'createlisting email sent'
    end

    it 'sends the updatelisting email' do
      mailer = Mailer.new
      expect(mailer.send('updatelisting', 'email@email.com')).to eq 'updatelisting email sent'
    end

    it 'sends the bookingrequested email' do
      mailer = Mailer.new
      expect(mailer.send('bookingrequested', 'email@email.com')).to eq 'bookingrequested email sent'
    end

    it 'sends the confirmrequest email' do
      mailer = Mailer.new
      expect(mailer.send('confirmrequest', 'email@email.com')).to eq 'confirmrequest email sent'
    end

    it 'sends the requestbooking email' do
      mailer = Mailer.new
      expect(mailer.send('requestbooking', 'email@email.com')).to eq 'requestbooking email sent'
    end

    it 'sends the requestconfirmed email' do
      mailer = Mailer.new
      expect(mailer.send('requestconfirmed', 'email@email.com')).to eq 'requestconfirmed email sent'
    end

    it 'sends the requestdenied email' do
      mailer = Mailer.new
      expect(mailer.send('requestdenied', 'email@email.com')).to eq 'requestdenied email sent'
    end

    it 'fails to send an email if email_type is invalid' do
      mailer = Mailer.new
      expect(mailer.send('invalid', 'email@email.com')).to eq 'Email failed to send.'
    end
  end

  context 'generate_subject method' do
    it 'generates the sign up subject subject' do
      mailer = Mailer.new
      subject = mailer.generate_subject('signup')
      expect(subject).to eq 'Welcome to MakersBnB!'
    end

    it 'generates the createlisting subject line' do
      mailer = Mailer.new
      subject = mailer.generate_subject('createlisting')
      expect(subject).to eq 'You created a new listing!'
    end

    it 'generates the updatelisting subject line' do
      mailer = Mailer.new
      subject = mailer.generate_subject('updatelisting')
      expect(subject).to eq 'You updated your listing!'
    end

    it 'generates the bookingrequested subject line' do
      mailer = Mailer.new
      subject = mailer.generate_subject('bookingrequested')
      expect(subject).to eq 'New booking request received!'
    end

    it 'generates the confirmrequest subject line' do
      mailer = Mailer.new
      subject = mailer.generate_subject('confirmrequest')
      expect(subject).to eq 'You approved a booking!'
    end

    it 'generates the requestbooking subject line' do
      mailer = Mailer.new
      subject = mailer.generate_subject('requestbooking')
      expect(subject).to eq 'You requested a new booking!'
    end

    it 'generates the requestconfirmed subject line' do
      mailer = Mailer.new
      subject = mailer.generate_subject('requestconfirmed')
      expect(subject).to eq 'Your booking request has been confirmed!'
    end

    it 'generates the requestdenied subject line' do
      mailer = Mailer.new
      subject = mailer.generate_subject('requestdenied')
      expect(subject).to eq 'Your booking request has been denied.'
    end

    it 'returns false if email_type does not exist' do
      mailer = Mailer.new
      expect(mailer.generate_subject('subject not present')).to eq false
    end
  end

  context 'generate_body method' do
    it 'generates the body of the email for sign up' do
      mailer = Mailer.new
      body = mailer.generate_body('signup')
      expect(body).to eq 'Welcome to MakersBnB!'
    end

    it 'generates the createlisting body' do
      mailer = Mailer.new
      body = mailer.generate_body('createlisting')
      expect(body).to eq 'You created a new listing!'
    end

    it 'generates the updatelisting body' do
      mailer = Mailer.new
      body = mailer.generate_body('updatelisting')
      expect(body).to eq 'You updated your listing!'
    end

    it 'generates the bookingrequested body' do
      mailer = Mailer.new
      body = mailer.generate_body('bookingrequested')
      expect(body).to eq 'New booking request received!'
    end

    it 'generates the confirmrequest body' do
      mailer = Mailer.new
      body = mailer.generate_body('confirmrequest')
      expect(body).to eq 'You approved a booking!'
    end

    it 'generates the requestbooking body' do
      mailer = Mailer.new
      body = mailer.generate_body('requestbooking')
      expect(body).to eq 'You requested a new booking!'
    end

    it 'generates the requestconfirmed body' do
      mailer = Mailer.new
      body = mailer.generate_body('requestconfirmed')
      expect(body).to eq 'Your booking request has been confirmed!'
    end

    it 'generates the requestdenied body' do
      mailer = Mailer.new
      body = mailer.generate_body('requestdenied')
      expect(body).to eq 'Your booking request has been denied.'
    end

    it 'returns false if the email_type does not exist' do
      mailer = Mailer.new
      expect(mailer.generate_body('subject not present')).to eq false
    end
  end
end
