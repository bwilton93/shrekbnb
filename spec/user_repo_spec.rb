require 'user_repo'

RSpec.describe UserRepo do
  before(:each) do
    reset_tables
  end

  context 'find' do
    it 'returns all users' do
      repo = UserRepo.new

      users = repo.all
      expect(users.length).to eq 3
      expect(users.first.name).to eq 'Shrek'
      expect(users.last.name).to eq 'Donkey'
    end

    it 'returns a single user from email' do
      repo = UserRepo.new
      user = repo.find_by_email('shrek@swamp.com')
      expect(user.name).to eq 'Shrek'
    end

    it 'returns nil if email doesnt exist' do
      repo = UserRepo.new
      user = repo.find_by_email('shreky@swamp.com')
      expect(user).to eq false
    end

    it 'returns a single user from an id' do
      repo = UserRepo.new
      user = repo.find_by_id('1')
      expect(user.name).to eq 'Shrek'
    end

    it 'returns nil if id doesnt exist' do
      repo = UserRepo.new
      user = repo.find_by_id('69')
      expect(user).to eq false
    end
  end

  context 'create' do
    it 'creates a new user' do
      repo = UserRepo.new

      new_user = User.new
      new_user.name = 'Muffin Man'
      new_user.email = 'muffinman@drury.lane'
      new_user.password = 'do_you_know_the_muffin_man'

      repo.create(new_user)
      expect(repo.all.length).to eq 4
      expect(repo.all.last.name).to eq 'Muffin Man'
    end

    it 'doesnt make user if email is taken' do
      repo = UserRepo.new

      new_user = User.new
      new_user.name = 'Muffin Man'
      new_user.email = 'shrek@swamp.com'
      new_user.password = 'do_you_know_the_muffin_man'

      repo.create(new_user)
      expect(repo.all.length).to eq 3
    end
  end

  context 'login' do
    it 'returns false if the user doesnt exist' do
      repo = UserRepo.new
      email = 'dragon@dragonskeep.com'
      password = 'lust_for_donkey'
      result = repo.log_in(email, password)
      expect(result).to eq nil
    end

    it 'returns false if the passwords dont match' do
      repo = UserRepo.new
      email = 'shrek@swamp.com'
      password = 'fiona_lover42'
      result = repo.log_in(email, password)
      expect(result).to eq nil
    end

    it 'returns the user.id when passwords match' do
      repo = UserRepo.new
      email = 'shrek@swamp.com'
      password = 'fiona_lover420'
      result = repo.log_in(email, password)
      expect(result).to eq 1
    end
  end

  context 'check password' do
    it 'returns true if the password is correct' do
      repo = UserRepo.new
      current_id = 1
      password = 'fiona_lover420'
      result = repo.check_password(current_id, password)
      expect(result).to eq true
    end

    it 'returns false if the password is incorrect' do
      repo = UserRepo.new
      current_id = 1
      password = 'incorrect_password'
      result = repo.check_password(current_id, password)
      expect(result).to eq false
    end
  end

  context 'update' do
    it 'updates the users email in the database' do
      repo = UserRepo.new
      email = 'shrek2@newswamp.com'
      name = nil
      result = repo.update(1, email, name)

      user = repo.find_by_id('1')
      expect(user.email).to eq 'shrek2@newswamp.com'
    end

    it 'fails to update a user email if user does not exist' do
      repo = UserRepo.new
      email = 'shrek2@newswamp.com'
      name = nil
      result = repo.update(69, email, name)
      expect(result).to eq nil
    end

    it 'fails to update a user email if new email is already taken' do
      repo = UserRepo.new
      email = 'donkey@donkey.com'
      name = nil
      result = repo.update(1, email, name)
      expect(result).to eq nil
    end

    it 'updates the users name in the database' do
      repo = UserRepo.new
      email = nil
      name = 'Shrek but better'
      result = repo.update(1, email, name)

      user = repo.find_by_id('1')
      expect(user.name).to eq 'Shrek but better'
    end

    it 'fails to update a user name if the user does not exist' do
      repo = UserRepo.new
      email = nil
      name = 'Shrekington'
      result = repo.update(69, email, name)
      expect(result).to eq nil
    end

    it 'updates the users password in the database' do
      repo = UserRepo.new
      current_id = 1
      old_password = 'fiona_lover420'
      new_password = 'lust_for_fiona'
      confirm_password = 'lust_for_fiona'

      repo.update_password(current_id, old_password, new_password, confirm_password)

      email = 'shrek@swamp.com'
      password = 'lust_for_fiona'
      result = repo.log_in(email, password)
      expect(result).to eq 1
    end

    it 'fails to update password if old_password is incorrect' do
      repo = UserRepo.new
      current_id = 1
      old_password = 'incorrect_password'
      new_password = 'lust_for_fiona'
      confirm_password = 'lust_for_fiona'

      result = repo.update_password(current_id, old_password, new_password, confirm_password)

      expect(result).to eq nil
    end

    it 'fails to update password if new passwords do not match' do
      repo = UserRepo.new
      current_id = 1
      old_password = 'fiona_lover420'
      new_password = 'lust_for_fiona'
      confirm_password = 'password_not_matching'

      result = repo.update_password(current_id, old_password, new_password, confirm_password)

      expect(result).to eq nil
    end
  end
end
