require 'booking_repo'

RSpec.describe BookingRepo do
  before(:each) do
    reset_tables
  end

  context 'using the listing id' do
    it 'finds multiple requests' do
      repo = BookingRepo.new
      results = repo.find_requests_by_listing_id(1)
      expect(results.length).to eq 3
      expect(results.first.booking_user_name).to eq 'Donkey'
      expect(results.first.date).to eq '2023-05-12'
      expect(results[1].booking_user_name).to eq 'Fiona'
      expect(results[1].date).to eq '2023-05-12'
      expect(results.last.booking_user_name).to eq 'Donkey'
      expect(results.last.date).to eq '2023-05-13'
    end

    it 'finds no requests when listing doesnt have any' do
      repo = BookingRepo.new
      expect(repo.find_requests_by_listing_id(2)).to eq false
    end

    it 'it fails when the listing doesnt exist' do
      repo = BookingRepo.new
      expect(repo.find_requests_by_listing_id(3)).to eq false
    end
  end

  context '#all method' do
    it 'returns all current booking requests' do
      repo = BookingRepo.new
      bookings = repo.all
      expect(bookings.length).to eq 3

      expect(bookings.first.booking_user_id).to eq(3)
      expect(bookings.first.date_id).to eq(1)
      expect(bookings.first.listing_id).to eq(1)
      expect(bookings.first.booking_user_name).to eq('Donkey')
      expect(bookings.first.date).to eq('2023-05-12')
      expect(bookings.last.booking_user_id).to eq(3)
      expect(bookings.last.date_id).to eq(2)
      expect(bookings.last.listing_id).to eq(1)
      expect(bookings.last.booking_user_name).to eq('Donkey')
      expect(bookings.last.date).to eq('2023-05-13')
    end
  end

  context '#create method' do
    it 'creates new booking request' do
      repo = BookingRepo.new
      booking = Booking.new
      booking.booking_user_id = 1
      booking.date_id = 1
      repo.create(booking)
      new_booking = repo.all.last

      expect(new_booking.booking_user_id).to eq 1
      expect(new_booking.date_id).to eq 1
    end

    it 'throws an error when booking request already exists' do
      repo = BookingRepo.new
      booking = Booking.new
      booking.booking_user_id = 3
      booking.date_id = 1
      expect { repo.create(booking) }.to raise_error 'Booking already exists, try again.'
    end
  end

  context '#is_booked?' do
    it 'returns false when date is not booked' do
      repo = BookingRepo.new
      response = repo.is_booked?(1)
      expect(response).to eq false
    end
  end

  context '#confirm method' do
    it 'updates dates table to have a booked_by_user value' do
      repo = BookingRepo.new
      booking_user_id = 3
      date_id = 1
      repo.confirm(booking_user_id, date_id)
      response = repo.is_booked?(date_id)
      expect(response).to eq true
    end

    it 'returns error if date is already booked' do
      repo = BookingRepo.new
      repo.confirm(3, 1)
      expect { repo.confirm(3, 1) }.to raise_error 'Booking is already confirmed.'
    end
  end

  context '#delete_requests method' do
    it 'deletes a single request for a date in join table' do
      repo = BookingRepo.new
      booking = Booking.new
      booking.booking_user_id = 1
      booking.date_id = 3
      repo.create(booking)
      repo.delete_requests(3)
      response = repo.find_requests_by_listing_id(2)

      expect(response).to eq false
    end

    it 'deletes all requests for a date in join table' do
      repo = BookingRepo.new
      repo.delete_requests(1)
      repo.delete_requests(2)
      response = repo.find_requests_by_listing_id(1)

      expect(response).to eq false
    end

    it 'returns error when no requests found' do
      repo = BookingRepo.new

      expect { repo.delete_requests(3) }.to raise_error 'No requests found.'
    end
  end

  context '#date_has_request? method' do
    it 'returns true if requests exist' do
      repo = BookingRepo.new

      expect(repo.date_has_request?(1)).to eq true
    end

    it 'returns false if no requests exist' do
      repo = BookingRepo.new

      expect(repo.date_has_request?(3)).to eq false
    end
  end

  context '#fetch_host_id' do
    it 'fetches host id when passed a valid date id' do
      repo = BookingRepo.new
      expect(repo.fetch_host_id(1)).to eq 1
    end

    it 'returns false when date_id is not valid' do
      repo = BookingRepo.new
      expect(repo.fetch_host_id(7)).to eq false
    end
  end

  context '#fetch_requester_ids' do
    it 'fetches all the requester ids for a given date' do
      repo = BookingRepo.new
      result_ids = repo.fetch_requester_ids(1, 3)
      expect(result_ids.length).to eq 1
      expect(result_ids.first).to eq 2
    end

    it 'retuns false when date_id is not valid' do
      repo = BookingRepo.new
      expect(repo.fetch_requester_ids(7, 3)).to eq false
    end
  end
end
