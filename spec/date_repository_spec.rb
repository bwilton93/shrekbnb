require 'date_repository'

RSpec.describe DateRepository do
  before(:each) do
    reset_tables
  end

  context '#creates new date' do
    it 'adds new date to a listing' do
      repo = DateRepository.new
      date = Date.new
      date.date = '2023-10-10'
      date.listing_id = 1

      repo.create(date)
      new_date = repo.all.last

      expect(new_date.date).to eq '2023-10-10'
      expect(new_date.listing_id).to eq 1
    end
  end
end