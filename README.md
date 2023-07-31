## Setup

```bash
# Create the test database
createdb makersbnb_test

# Install gems
bundle install
gem install bcrypt
gem install simplecov

# Run the tests
rspec

# Run the server (better to do this in a separate terminal).
rackup
```
