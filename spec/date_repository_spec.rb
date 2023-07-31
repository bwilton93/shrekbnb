require 'date_repository'
require 'booking_repo'

RSpec.describe DateRepository do
  before(:each) do
    reset_tables
  end

  context '#creates new date' do
    it 'adds new date to a listing' do
      repo = DateRepository.new
      date = DateModel.new
      date.date = '2023-10-10'
      date.listing_id = 1

      repo.create(date)
      new_date = repo.all.last

      expect(new_date.date).to eq '2023-10-10'
      expect(new_date.listing_id).to eq 1
    end

    it 'adds 2 new dates to listing' do
      repo = DateRepository.new
      date1 = DateModel.new
      date2 = DateModel.new
      date1.date = '2023-10-10'
      date1.listing_id = 1
      date2.date = '2023-10-12'
      date2.listing_id = 1
      repo.create(date1)
      repo.create(date2)

      expect(repo.all[-2].date).to eq '2023-10-10'
      expect(repo.all[-2].listing_id).to eq 1
      expect(repo.all[-1].date).to eq '2023-10-12'
      expect(repo.all[-1].listing_id).to eq 1
    end

    it 'throws error when date already exists' do
      repo = DateRepository.new
      date = DateModel.new
      date.date = '2023-05-12'
      date.listing_id = 1

      expect { repo.create(date) }.to raise_error 'Date already exists for this listing'
    end

    it 'throws error when adding a date which is already booked' do
      repo = DateRepository.new
      booking_repo = BookingRepo.new
      booking_repo.confirm(3, 1)

      date_to_add = DateModel.new
      date_to_add.date = '2023-05-12'
      date_to_add.listing_id = 1

      expect { repo.create(date_to_add) }.to raise_error 'One or more of these dates is already booked'
    end
  end

  context '#add_dates' do
    it 'adds date within a range' do
      repo = DateRepository.new
      repo.add_dates(1, '2023-10-10', '2023-10-11')
      dates = repo.all
      date1 = dates[-2]
      date2 = dates[-1]

      expect(date1.date).to eq '2023-10-10'
      expect(date2.date).to eq '2023-10-11'
      expect(date1.listing_id).to eq 1
      expect(date2.listing_id).to eq 1
    end

    it 'adds multiple dates within a range' do
      repo = DateRepository.new
      repo.add_dates(1, '2023-10-10', '2023-10-10')
      dates = repo.all
      date1 = dates[-1]

      expect(date1.date).to eq '2023-10-10'
      expect(date1.listing_id).to eq 1
    end

    it 'throws an error if dates already exist' do
      repo = DateRepository.new
      repo.add_dates(1, '2023-10-11', '2023-10-12')
      expect { repo.add_dates(1, '2023-10-10', '2023-10-11') }.to raise_error 'Date already exists for this listing'
    end

    it 'throws an error if end date before start date' do
      repo = DateRepository.new
      expect { repo.add_dates(1, '2024-01-01', '2023-10-10') }
        .to raise_error 'End date must be after start date'
    end

    it 'throws an error if start date in the past' do
      repo = DateRepository.new
      expect { repo.add_dates(1, '2023-01-10', '2023-10-09') }
        .to raise_error 'Start date must not be in the past'
    end
  end

  context '#find_by_listing' do
    it 'returns the dates available for listing 1' do
      repo = DateRepository.new

      dates = repo.find_by_listing(1)

      expect(dates.first.date).to eq '2023-05-12'
      expect(dates.first.listing_id).to eq 1
      expect(dates.last.date).to eq '2023-05-13'
      expect(dates.last.listing_id).to eq 1
    end

    it 'does not show a date if it has been booked' do
      repo = DateRepository.new
      booking_repo = BookingRepo.new
      booking_repo.confirm(3, 1)

      dates = repo.find_by_listing(1)
      expect(dates.length).to eq 1
      expect(dates.first.date).to eq '2023-05-13'
      expect(dates.first.listing_id).to eq 1
    end
  end
end
