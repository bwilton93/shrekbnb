## Setup

```bash
# Create the test database
createdb makersbnb_test

# Create the main database
createdb makersbnb

# Install gems
bundle install

# Run the server (might need to use different terminal).
rackup

# Take note of port provided in 'INFO  WEBrick::HTTPServer#start: pid=26468 port=9292' line

# Shrekbnb can be now accessed through your browser using 
http://localhost:port
# or
http://127.0.0.1:port

# To get details on test coverage:
rspec
```
