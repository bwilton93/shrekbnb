require_relative 'booking'

class BookingRepo
  def all
    sql = "SELECT users.id AS booking_user_id,
	        users.name AS booking_user_name,
	        listings.id AS listing_id,
	        dates.id AS date_id,
	        dates.date
    	    FROM users
    		JOIN dates_users_join ON dates_users_join.user_id = users.id
    		JOIN dates ON dates_users_join.dates_id = dates.id
    		JOIN listings ON dates.listing_id = listings.id;"
    result_set = DatabaseConnection.exec_params(sql, [])

    bookings = []
    result_set.each do |record|
      bookings << record_to_booking(record)
    end
    bookings
  end

  def find_requests_by_listing_id(listing_id)
    requests = []
    sql = 'SELECT users.id AS booking_user_id,
            users.name AS booking_user_name,
            listings.id AS listing_id,
            dates.id AS date_id,
            dates.date
                FROM users
                  JOIN dates_users_join ON dates_users_join.user_id = users.id
                  JOIN dates ON dates_users_join.dates_id = dates.id
                  JOIN listings ON dates.listing_id = listings.id
                WHERE listing_id=$1;'
    results = DatabaseConnection.exec_params(sql, [listing_id])
    return false if results.first.nil?

    results.each do |record|
      requests << record_to_booking(record)
    end
    requests
  end

  def create(booking)
    raise 'Booking already exists, try again.' if booking_exists?(booking)

    sql = "INSERT INTO dates_users_join (user_id, dates_id)
          VALUES ($1, $2);"
    params = [booking.booking_user_id, booking.date_id]
    DatabaseConnection.exec_params(sql, params)
    nil
  end

  def confirm(booking_user_id, date_id)
    raise 'Booking is already confirmed.' if is_booked?(date_id)

    params = [booking_user_id, date_id]

    sql = 'UPDATE dates SET booked_by_user=$1 WHERE id=$2;'
    DatabaseConnection.exec_params(sql, params)
  end

  def delete_requests(date_id)
    raise 'No requests found.' unless date_has_request?(date_id)

    sql = 'DELETE FROM dates_users_join WHERE dates_id = $1;'
    DatabaseConnection.exec_params(sql, [date_id])
  end

  def is_booked?(date_id)
    sql = 'SELECT booked_by_user FROM dates WHERE id=$1;'
    result = DatabaseConnection.exec_params(sql, [date_id]).first
    status = result['booked_by_user']
    !status.nil? # Returns false if booked_by_user returns nil
  end

  def date_has_request?(date_id)
    sql = 'SELECT * FROM dates_users_join WHERE dates_id = $1;'
    result = DatabaseConnection.exec_params(sql, [date_id]).first
    result.nil? ? false : true
  end

  def fetch_host_id(date_id)
    sql = 'SELECT users.id
            FROM users
              JOIN listings ON listings.user_id = users.id
              JOIN dates ON dates.listing_id = listings.id
              JOIN dates_users_join ON dates_users_join.dates_id = dates.id
            WHERE dates_users_join.dates_id=$1;'

    result = DatabaseConnection.exec_params(sql, [date_id])
    return false if result.first.nil?

    result.first['id'].to_i
  end

  def fetch_requester_ids(date_id, confirmed_id)
    user_ids = []

    sql = 'SELECT user_id
            FROM dates_users_join
            WHERE dates_id=$1 AND NOT user_id=$2;'

    params = [date_id, confirmed_id]
    results = DatabaseConnection.exec_params(sql, params)
    return false if results.first.nil?

    results.each do |result|
      user_ids << result['user_id'].to_i
    end

    user_ids
  end

  private

  def booking_exists?(booking)
    all.any? do |existing_booking|
      existing_booking.booking_user_id == booking.booking_user_id &&
        existing_booking.date_id == booking.date_id
    end
  end

  def record_to_booking(record)
    booking = Booking.new
    booking.booking_user_id = record['booking_user_id'].to_i
    booking.date_id = record['date_id'].to_i
    booking.listing_id = record['listing_id'].to_i
    booking.booking_user_name = record['booking_user_name']
    booking.date = record['date']

    booking
  end
end
