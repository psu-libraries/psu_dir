# PsuDir

Directory services integrations at Penn State University.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'psu_dir'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install psu_dir

## Usage

Instantiate the service with a string `PsuDir::Name.new("jbd123")` and then
call the disambiguate method which returns an array of people in the format `[{:id=>"jbd123", :given_name=>"Jane B", :surname=>"Doe", :email=>"jbd123@psu.edu", :affiliation=>["STAFF"]}]`

What you pass in as the name can vary from an id to a list of names and or emails.

### Basic usage with a id

You can call disambiguate with an id, which then calls ldap and returns a record.

```
service = PsuDir::Name.new("cam156") # #<PsuDir::Name:0x007fab36190710 @name="cam156", @email_for_name_cache={}, @results=[]>
service.disambiguate #[{:id=>"cam156", :given_name=>"CAROLYN A", :surname=>"COLE", :email=>"cam156@psu.edu", :affiliation=>["STAFF"]}]
```

### Basic usage with a name

```
service = PsuDir::Name.new("Carolyn Cole") # #<PsuDir::Name:0x007fab36190710 @name="Carolyn Cole", @email_for_name_cache={}, @results=[]>
service.disambiguate #[{:id=>"cam156", :given_name=>"CAROLYN A", :surname=>"COLE", :email=>"cam156@psu.edu", :affiliation=>["STAFF"]}]
```

### Usage with last name and first name part
```
service = PsuDir::Name.new("Carol Cole") # #<PsuDir::Name:0x007fab36190710 @name="Carol Cole", @email_for_name_cache={}, @results=[]>
service.disambiguate #[{:id=>"cam156", :given_name=>"CAROLYN A", :surname=>"COLE", :email=>"cam156@psu.edu", :affiliation=>["STAFF"]}]
```

### Usage with last name and first name part
```
service = PsuDir::Name.new("Carol Cole, cam156") # #<PsuDir::Name:0x007fab36190710 @name="Carol Cole", @email_for_name_cache={}, @results=[]>
service.disambiguate #[{:id=>"cam156", :given_name=>"CAROLYN A", :surname=>"COLE", :email=>"cam156@psu.edu", :affiliation=>["STAFF"]}]
```

### Usage with a list of names
```
service = PsuDir::Name.new("Carol Cole; Adam Wead") ##<PsuDir::Name:0x007fab32cf2418 @name="Carol Cole; Adam Wead", @email_for_name_cache={}, @results=[]>
service.disambiguate #[{:id=>"cam156", :given_name=>"CAROLYN A", :surname=>"COLE", :email=>"cam156@psu.edu", :affiliation=>["STAFF"]}, {:id=>"agw13", :given_name=>"ADAM GARNER", :surname=>"WEAD", :email=>"agw13@psu.edu", :affiliation=>["STAFF"]}]
```

## Contributing

Bug reports and pull requests are welcome!
