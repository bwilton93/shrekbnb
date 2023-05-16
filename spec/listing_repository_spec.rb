require 'listing_repository'

RSpec.describe ListingRepository do
  before(:each) do
    reset_tables
  end

  context 'the #create method' do
    it 'creates new listing to database' do
      repo = ListingRepository.new
      listing = Listing.new
      listing.listing_name = 'New listing'
      listing.listing_description = 'New description'
      listing.price = 50
      listing.user_id = 1

      repo.create(listing)
      new_listing = repo.all.last

      expect(new_listing.listing_name).to eq('New listing')
      expect(new_listing.listing_description).to eq('New description')
      expect(new_listing.price).to eq(50)
      expect(new_listing.user_id).to eq(1)
      expect(new_listing.host_name).to eq('Shrek')
    end

    it 'fails if listing name already exists' do
      repo = ListingRepository.new
      listing = Listing.new
      listing.listing_name = 'Swamp'
      listing.listing_description = 'New description'
      listing.price = 50
      listing.user_id = 1

      expect{ repo.create(listing) }.to raise_error "Listing already exists"
    end

    it 'fails if missing input value' do
      repo = ListingRepository.new
      listing = Listing.new
      listing.listing_name = 'New place!'
      listing.listing_description = 'New description'
      listing.price = 50

      expect{ repo.create(listing) }.to raise_error "Missing user id"
    end

    it 'fails if missing input value' do
      repo = ListingRepository.new
      listing = Listing.new
      listing.listing_name = 'New place!'
      listing.listing_description = 'New description'
      listing.price = 50
      listing.user_id = ''

      expect{ repo.create(listing) }.to raise_error "Missing user id"
    end
  end

  context '#all method' do
    it 'returns all current listings' do 
      repo = ListingRepository.new
      listings = repo.all
      expect(listings.length).to eq 2

      expect(listings.first.id).to eq 1
      expect(listings.first.listing_name).to eq("Swamp")
      expect(listings.first.listing_description).to eq("Lovely swamp. Shrek lives here. Scenic outhouse. Donkey not included!")
      expect(listings.first.price).to eq(69)
    end
  end

  context "#find method" do
    it "finds listing by id" do
      repo = ListingRepository.new
      listing = repo.find(1)

      expect(listing.id).to eq 1
      expect(listing.listing_name).to eq("Swamp")
      expect(listing.listing_description).to eq("Lovely swamp. Shrek lives here. Scenic outhouse. Donkey not included!")
      expect(listing.price).to eq(69)
      expect(listing.host_name).to eq("Shrek")
    end
  end
end
