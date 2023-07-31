require 'bcrypt'
require_relative 'database_connection'
require_relative 'user'

class UserRepo
  def all
    users = []
    sql = 'SELECT * FROM users;'
    results = DatabaseConnection.exec_params(sql, [])

    results.each do |record|
      users << user(record)
    end

    users
  end

  def find_by_email(email)
    sql = 'SELECT * FROM users WHERE email=$1;'
    result = DatabaseConnection.exec_params(sql, [email])
    return if result.nil?

    result_of_find(result.first)
  end

  def find_by_id(id)
    sql = 'SELECT * FROM users WHERE id=$1;'
    result = DatabaseConnection.exec_params(sql, [id])
    return if result.nil?

    result_of_find(result.first)
  end

  def create(new_user)
    return false if find_by_email(new_user.email)

    encrypted_password = BCrypt::Password.create(new_user.password)

    sql = 'INSERT INTO users (name, email, password) VALUES ($1, $2, $3);'
    params = [new_user.name, new_user.email, encrypted_password]

    DatabaseConnection.exec_params(sql, params)
  end

  def log_in(email, password)
    user = find_by_email(email)
    return nil unless user

    check_password(user.id, password) ? user.id.to_i : nil
  end

  def check_password(current_id, password)
    user = find_by_id(current_id)
    BCrypt::Password.new(user.password) == password
  end

  def update(current_id, new_email, new_username)
    user_info = find_by_id(current_id)

    return unless user_info
    return if find_by_email(new_email)

    username = new_username.nil? ? user_info.name : new_username
    email = new_email.nil? ? user_info.email : new_email

    params = [current_id, username, email]

    sql = 'UPDATE users SET name=$2, email=$3 WHERE id=$1;'

    DatabaseConnection.exec_params(sql, params)
  end

  def update_password(current_id, old_password, new_password, confirm_password)
    user = find_by_id(current_id)
    return unless check_password(current_id, old_password)
    return if new_password != confirm_password

    new_password = BCrypt::Password.create(new_password)
    params = [current_id, new_password]

    sql = 'UPDATE users SET password=$2 WHERE id=$1;'
    DatabaseConnection.exec_params(sql, params)
  end

  private

  def user(record)
    user = User.new
    user.id = record['id']
    user.name = record['name']
    user.email = record['email']
    user.password = record['password']

    user
  end

  def result_of_find(result)
    return false if result.nil?

    user(result)
  end
end
