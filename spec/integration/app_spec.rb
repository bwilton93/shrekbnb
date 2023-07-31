# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../../app'
require 'json'

describe Application do
  before(:each) do
    reset_tables
  end
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  # Write your integration tests below.
  # If you want to split your integration tests
  # accross multiple RSpec files (for example, have
  # one test suite for each set of related features),
  # you can duplicate this test file to create a new one.

  context 'GET /' do
    it 'should get the homepage' do
      response = get('/')

      expect(response.status).to eq(200)
    end

    it 'shows all listings' do
      response = get('/')

      expect(response.body).to include('Property name: Swamp')
      expect(response.body).to include('Price per night: £69')
      expect(response.body).to include('<a href="/listing/1">')

      expect(response.body).to include('Property name: Far Far Away Castle')
      expect(response.body).to include('Price per night: £420')
      expect(response.body).to include('<a href="/listing/2">')
    end
  end

  context 'GET /signup' do
    it 'should get the signup page' do
      response = get('/signup')

      expect(response.status).to eq 200
      expect(response.body).to include '<form'
      expect(response.body).to include '<input type="text" placeholder="Name" required="required" name="name">'
      expect(response.body).to include '<input type="email" placeholder="Email" required="required" name="email">'
      expect(response.body).to include '<input type="password" placeholder="Password" required="required" name="password">'
    end
  end

  context 'POST /signup' do
    it 'should create and log in to a new user account' do
      response = post(
        '/signup',
        name: 'Dragon',
        email: 'elizabeth@dragonskeep.com',
        password: 'lust_for_donkey'
      )

      expect(response.status).to eq 200
      expect(response.body).not_to include 'href="/signup" class="button-link">Sign up</a>'
      expect(response.body).not_to include 'href="/login" class="button-link">Log in</a>'
      expect(response.body).to include 'href="/logout" class="button-link">Log out</a>'
    end

    it 'should return to sign up form if email already taken' do
      response = post(
        '/signup',
        name: 'Dragon',
        email: 'donkey@donkey.com',
        password: 'lust_for_donkey'
      )

      expect(response.status).to eq 200
      expect(response.body).to include '<form'
      expect(response.body).to include '<input type="text" placeholder="Name" required="required" name="name">'
      expect(response.body).to include '<input type="email" placeholder="Email" required="required" name="email">'
      expect(response.body).to include '<input type="password" placeholder="Password" required="required" name="password">'
    end
  end

  context 'GET /login' do
    it 'should show the login form' do
      response = get('/login')

      expect(response.status).to eq 200
      expect(response.body).to include '<input type="text" placeholder="Email" required="required" name="email">'
      expect(response.body).to include '<input type="password" placeholder="Password" required="required" name="password">'
    end
  end

  context 'POST /login' do
    it 'should log in' do
      response = post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      expect(response.status).to eq 200
      expect(response.body).not_to include 'href="/signup" class="button-link">Sign up</a>'
      expect(response.body).not_to include 'href="/login" class="button-link">Log in</a>'
      expect(response.body).to include 'href="/account" class="button-link">Account page</a>'
      expect(response.body).to include 'href="/logout" class="button-link">Log out</a>'
    end

    it 'should fail to log in if password is wrong' do
      response = post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover42'
      )

      expect(response.status).to eq 200
      expect(response.body).to include '<input type="text" placeholder="Email" required="required" name="email">'
      expect(response.body).to include '<input type="password" placeholder="Password" required="required" name="password">'
    end
  end

  context 'GET /logout' do
    it 'logs out' do
      response = get('/logout')

      expect(response.status).to eq 200

      expect(response.body).to include '<a href="/signup" class="button-link">Sign up</a>'
      expect(response.body).to include '<a href="/login" class="button-link">Log in</a>'
      expect(response.body).not_to include '<a href="/logout" class="button-link">Log out</a>'
    end
  end

  context 'GET /listing/new' do
    it 'contains a form for a new listing' do
      response = get '/listing/new'

      expect(response.status).to eq 200
      expect(response.body).to include('<form action="/listing/new" method="POST">')
      expect(response.body).to include('<input id="listing-name" type="text" name="listing_name">')
    end
  end

  context 'POST /listing/new' do
    it 'adds a new listing when user logged in' do
      session = { user_id: 1 }
      params = {
        listing_name: 'New Listing',
        listing_description: 'Description',
        price: 0
      }

      response = post('/listing/new', params, 'rack.session' => session)

      expect(response.status).to eq 200
      expect(response.body).to include('<p>Your new listing has been added!</p>')
    end

    it 'runs error if no user logged in' do
      session = { user_id: nil }
      params = {
        listing_name: 'New Listing',
        listing_description: 'Description',
        price: 0
      }

      response = post('/listing/new', params, 'rack.session' => session)

      expect(response.status).to eq 400
      expect(response.body).to include('Sorry, try <a href="/login">logging in</a> to add a listing!')
    end

    it 'runs error if listing already exists' do
      session = { user_id: nil }
      params = {
        listing_name: 'Swamp',
        listing_description: 'Description',
        price: 0
      }

      response = post('/listing/new', params, 'rack.session' => session)

      expect(response.status).to eq 400
      expect(response.body).to include('This listing already exists, try again!')
    end

    it 'runs error if parameters not valid(empty string)' do
      session = { user_id: 1 }
      params = {
        listing_name: '',
        listing_description: '',
        price: 'hello?'
      }
      response = post('/listing/new', params, 'rack.session' => session)

      expect(response.status).to eq 400
      expect(response.body).to eq("We didn't like that... go back to try again!")
    end

    it 'runs error if parameters not valid(nil)' do
      session = { user_id: 1 }
      params = {
        listing_description: '',
        price: 'hello?'
      }
      response = post('/listing/new', params, 'rack.session' => session)

      expect(response.status).to eq 400
      expect(response.body).to eq("We didn't like that... go back to try again!")
    end
  end

  context 'GET /listing/:id' do
    it 'displays listing details of listing with id 1' do
      response = get('/listing/1')

      expect(response.status).to eq 200
      expect(response.body).to include 'Swamp'
      expect(response.body).to include 'Lovely swamp. Shrek lives here. Scenic outhouse. Donkey not included!'
      expect(response.body).to include 'Hosted by: Shrek'
      expect(response.body).to include 'Price per night: £69'
    end

    it 'contains a drop down with all available dates' do
      response = get('/listing/1')

      expect(response.status).to eq 200

      expect(response.body).to include('<form class="date-select" action="/book" method="post">')
      expect(response.body).to include('<label for="available-dates">Pick a night from available dates:</label>')
      expect(response.body).to include('<select name="date_id" id="available-dates">')
      expect(response.body).to include('<option value="1">2023-05-12</option>')
      expect(response.body).to include('<option value="2">2023-05-13</option>')
    end
  end

  context 'GET /account' do
    it 'returns the account page for the logged in user' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )
      response = get('/account')

      expect(response.status).to eq 200
      expect(response.body).to include '<h1>Welcome Shrek</h1>'
      expect(response.body).to include 'Listings: 1'
      expect(response.body).to include 'Property name: Swamp'
      expect(response.body).to include 'Price per night: £69'
      expect(response.body).to include 'Hosted by: Shrek'
      expect(response.body).to include 'href="available_dates/1">Add dates</a>'
      expect(response.body).to include 'href="view-requests/listing/1">View Requests (3)</a>'
    end

    it 'returns 0 total requests for account that has no requests' do
      post(
        '/login',
        email: 'donkey@donkey.com',
        password: 'lust_for_dragons'
      )
      response = get('/account')
      expect(response.body).to include 'Number of Listings: 0'
    end

    it 'returns the login page when not logged in' do
      response = get('/account')

      expect(response.status).to eq 200
      expect(response.body).to include '<input type="text" placeholder="Email" required="required" name="email">'
      expect(response.body).to include '<input type="password" placeholder="Password" required="required" name="password">'
    end
  end

  context 'GET /view-requests/listing/:id' do
    it 'shows the list of requests' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      response = get('/view-requests/listing/1')

      expect(response.status).to eq 200
      expect(response.body).to include '<h2>These are the requests for: Swamp</h2>'
      expect(response.body).to include 'Booking User: Donkey'
      expect(response.body).to include 'Date: 2023-05-12'
      expect(response.body).to include "<form method='POST' action='/confirm'>"
      expect(response.body).to include 'Booking User: Fiona'
      expect(response.body).to include 'Date: 2023-05-12'
      expect(response.body).to include "<form method='POST' action='/confirm'>"
    end

    it 'takes you to login page if not logged in' do
      response = get('/view-requests/listing/1')
      expect(response.status).to eq 200

      expect(response.body).to include '<input type="text" placeholder="Email" required="required" name="email">'
      expect(response.body).to include '<input type="password" placeholder="Password" required="required" name="password">'
    end

    it 'shows you have no requests if your listing has no requests' do
      post(
        '/login',
        email: 'fiona@farfaraway.com',
        password: 'save_me9001'
      )

      response = get('/view-requests/listing/2')
      expect(response.status).to eq 200
      expect(response.body).to include '<h2>These are the requests for: Far Far Away Castle</h2>'
      expect(response.body).to include '<h2> Your listing currently has no requests </h2>'
    end

    it 'returns 400 with error msg if accessing a non existent listing' do
      session = { user_id: 1 }
      response = get('/view-requests/listing/25')

      expect(response.status).to eq 400
      expect(response.body).to eq 'Listing does not exist'
    end
  end

  context 'GET /account-settings' do
    it 'shows password form on first entry' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      response = get('/account-settings')

      expect(response.status).to eq 200
      expect(response.body).to include "action='/account-settings' method='POST'>"
      expect(response.body).to include "<input type='password' required='required' name='password'>"
    end

    it 'shows login form if session id is nil' do
      response = get('/account-settings')
      expect(response.status).to eq 200

      expect(response.body).to include '<input type="text" placeholder="Email" required="required" name="email">'
      expect(response.body).to include '<input type="password" placeholder="Password" required="required" name="password">'
    end
  end

  context 'POST /account-settings' do
    it 'shows the account settings if the password is correct' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      response = post('/account-settings',
                      password: 'fiona_lover420')

      expect(response.status).to eq 200
      expect(response.body).to include '<h2>Account Settings</h2>'
      expect(response.body).to include "<form action='/update-username-email' method='POST'>"
      expect(response.body).to include 'Current username: Shrek'
      expect(response.body).to include "<input type='text' placeholder='New username' name='name'>"
      expect(response.body).to include 'Current email: shrek@swamp.com'
      expect(response.body).to include "<input type='text' placeholder='New email' name='email'>"

      expect(response.body).to include "<form action='/update-password' method='POST'>"
      expect(response.body).to include "<input type='password' placeholder='Password' required='required' name='old_password'>"
      expect(response.body).to include "<input type='password' placeholder='New password' required='required' name='new_password'>"
      expect(response.body).to include "<input type='password' placeholder='Confirm password' required='required' name='confirm_password'>"
    end

    it 'shows password form if password is incorrect' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      response = post('/account-settings',
                      password: 'incorrect_password')

      expect(response.status).to eq 200
      expect(response.body).to include "action='/account-settings' method='POST'>"
      expect(response.body).to include "<input type='password' required='required' name='password'>"
    end
  end

  context 'GET /update-username-email' do
    it 'goes to account settings page if logged in' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      response = get('/update-username-email')

      expect(response.status).to eq 200
      expect(response.body).to include "action='/account-settings' method='POST'>"
      expect(response.body).to include "<input type='password' required='required' name='password'>"
    end

    it 'goes to login page if not logged in' do
      response = get('/update-username-email')

      expect(response.status).to eq 200

      expect(response.body).to include '<input type="text" placeholder="Email" required="required" name="email">'
      expect(response.body).to include '<input type="password" placeholder="Password" required="required" name="password">'
    end
  end

  context 'POST /update-username-email' do
    it 'correctly updates name' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      response = post(
        '/update-username-email',
        name: 'King Shrek',
        email: nil
      )

      expect(response.status).to eq 200
      expect(response.body).to include 'Current username: King Shrek'
    end

    it 'correctly updates email' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      response = post(
        '/update-username-email',
        name: nil,
        email: 'shrek@newswamp.com'
      )

      expect(response.status).to eq 200
      expect(response.body).to include 'Current email: shrek@newswamp.com'
    end

    it 'fails to update if email taken' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      response = post(
        '/update-username-email',
        name: 'King Shrek',
        email: 'shrek@swamp.com'
      )

      expect(response.status).to eq 200
      expect(response.body).to include 'Current username: Shrek'
      expect(response.body).to include 'Current email: shrek@swamp.com'
    end
  end

  context 'GET /update-password' do
    it 'goes to account settings page if logged in' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      response = get('/update-password')

      expect(response.status).to eq 200
      expect(response.body).to include "action='/account-settings' method='POST'>"
      expect(response.body).to include "<input type='password' required='required' name='password'>"
    end

    it 'goes to login page if not logged in' do
      response = get('/update-password')

      expect(response.status).to eq 200

      expect(response.body).to include '<input type="text" placeholder="Email" required="required" name="email">'
      expect(response.body).to include '<input type="password" placeholder="Password" required="required" name="password">'
    end
  end

  context 'POST /update-password' do
    it 'updates the password' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      response = post(
        '/update-password',
        old_password: 'fiona_lover420',
        new_password: 'lust_for_fiona',
        confirm_password: 'lust_for_fiona'
      )

      expect(response.status).to eq 200

      response = post('/account-settings',
                      password: 'lust_for_fiona')

      expect(response.status).to eq 200
      expect(response.body).to include '<h2>Account Settings</h2>'
      expect(response.body).to include "<form action='/update-username-email' method='POST'>"
      expect(response.body).to include 'Current username: Shrek'
      expect(response.body).to include "<input type='text' placeholder='New username' name='name'>"
      expect(response.body).to include 'Current email: shrek@swamp.com'
      expect(response.body).to include "<input type='text' placeholder='New email' name='email'>"

      expect(response.body).to include "<form action='/update-password' method='POST'>"
      expect(response.body).to include "<input type='password' placeholder='Password' required='required' name='old_password'>"
      expect(response.body).to include "<input type='password' placeholder='New password' required='required' name='new_password'>"
      expect(response.body).to include "<input type='password' placeholder='Confirm password' required='required' name='confirm_password'>"
    end

    it 'doesnt update password if old_password is incorrect' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      response = post(
        '/update-password',
        old_password: 'incorrect_password',
        new_password: 'lust_for_fiona',
        confirm_password: 'lust_for_fiona'
      )

      expect(response.status).to eq 200

      response = post('/account-settings',
                      password: 'lust_for_fiona')

      expect(response.status).to eq 200
      expect(response.body).to include "action='/account-settings' method='POST'>"
      expect(response.body).to include "<input type='password' required='required' name='password'>"
    end

    it 'doesnt update password if new and confirm_password not matching' do
      post(
        '/login',
        email: 'shrek@swamp.com',
        password: 'fiona_lover420'
      )

      response = post(
        '/update-password',
        old_password: 'fiona_lover420',
        new_password: 'lust_for_fiona',
        confirm_password: 'passwords_dont_match'
      )

      expect(response.status).to eq 200

      response = post('/account-settings',
                      password: 'lust_for_fiona')

      expect(response.status).to eq 200
      expect(response.body).to include "action='/account-settings' method='POST'>"
      expect(response.body).to include "<input type='password' required='required' name='password'>"
    end
  end

  context 'GET /available_dates/:id' do
    it 'returns 200 OK with a date form' do
      response = get('/available_dates/1')

      expect(response.status).to eq 200
      expect(response.body).to include '<h2>Add dates for Swamp</h2>'
      expect(response.body).to include '<form action="/available_dates/1" method="POST">'
      expect(response.body).to include '<input type="date" name="start_date" />'
      expect(response.body).to include '<input type="date" name="end_date" />'
    end
  end

  context 'POST /available_dates/:id' do
    it 'returns 200 OK with confirmation message' do
      session = { user_id: 1 }
      params = { start_date: '2023-11-05', end_date: '2023-12-05' }
      response = post('/available_dates/1', params, 'rack.session' => session)

      expect(response.status).to eq 200
      expect(response.body).to include '<h2>Date successfully added</h2>'
    end

    it 'redirects to login page if wrong user logged in' do
      session = { user_id: 2 }
      params = { start_date: '2023-11-05', end_date: '2023-12-05' }
      response = post('/available_dates/1', params, 'rack.session' => session)

      expect(response.body).not_to include '<h2>Date successfully added</h2>'
      expect(response.status).to eq 302
    end

    it 'returns 400 error if end date before start date' do
      session = { user_id: 1 }
      params = { start_date: '2023-11-05', end_date: '2023-10-05' }
      response = post('/available_dates/1', params, 'rack.session' => session)

      expect(response.status).to eq 400
      expect(response.body).to eq 'End date must be after start date'
    end

    it 'returns 400 error if end date before start date' do
      session = { user_id: 1 }
      params = { start_date: '2023-01-05', end_date: '2023-10-05' }
      response = post('/available_dates/1', params, 'rack.session' => session)

      expect(response.status).to eq 400
      expect(response.body).to eq 'Start date must not be in the past'
    end

    it 'runs error if parameters not valid(empty string)' do
      session = { user_id: 1 }
      params = { start_date: '', end_date: '2023-10-05' }
      response = post('/available_dates/1', params, 'rack.session' => session)

      expect(response.status).to eq 400
      expect(response.body).to eq "We didn't like that... go back to try again!"
    end

    it 'runs error if parameters not valid(nil)' do
      session = { user_id: 1 }
      params = { end_date: '2023-10-05' }
      response = post('/available_dates/1', params, 'rack.session' => session)

      expect(response.status).to eq 400
      expect(response.body).to eq "We didn't like that... go back to try again!"
    end
  end

  context 'POST /book' do
    it 'requests to book when user is logged in' do
      session = { user_id: 1 }
      response = post('/book', { date_id: 1 }, 'rack.session' => session)

      expect(response.status).to eq 200
      expect(response.body).to include 'Booking request successfully added!'
    end

    it 'booking already exists' do
      session = { user_id: 3 }
      response = post('/book', { date_id: 1 }, 'rack.session' => session)

      expect(response.status).to eq 400
      expect(response.body).to eq 'Booking already exists, try again.'
    end

    it 'redirects to login page when not logged in' do
      session = { user_id: nil }
      response = post('/book', { date_id: 1 }, 'rack.session' => session)

      expect(response.status).to eq 302
    end
  end

  context 'POST /confirm' do
    it 'returns a booking confirmation message to the host' do
      session = { user_id: 1 }
      response = post('/confirm', { user_id: 3, date_id: 1 }, 'rack.session' => session)
      expect(response.status).to eq 200
      expect(response.body).to include 'Booking confirmed.'
    end
  end
end
