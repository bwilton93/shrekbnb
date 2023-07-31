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

## Built with
#### Main languages used:
* Ruby
  * Object-Oriented lanugage used for to handle majority of our back-end logic
* HTML/CSS
  * Markup language used for documents designed to be displayed in the web browser
* Sinatra
  * Domain-specific language used to map incoming web requests to blocks of Ruby Code
#### Ruby gems:
* Webrick
  * HTTP server toolkit allowing logging of server operations and HTTP access.
* Bcrypt
  * Used for password encryption
* PG
  * Used to interface with PostgreSQL RDBMS
#### Testing environment:
* RSpec
  * Testing tool for Ruby, created for Test Driven Development
