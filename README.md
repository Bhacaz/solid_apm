[![Gem Version](https://badge.fury.io/rb/solid_apm.svg)](https://badge.fury.io/rb/solid_apm)

# SolidApm
Rails engine to manage APM data without using a third party service.

<img src="https://github.com/Bhacaz/solid_apm/assets/7858787/b83a4768-dbff-4c1c-8972-4b9db1092c99" width="400px">
<img src="https://github.com/Bhacaz/solid_apm/assets/7858787/87696866-1fb3-46d6-91ae-0137cc7da578" width="400px">


## Installation

Add to your Gemfile:

```shell
bin/bundle add solid_apm
```

Mount the engine in your routes file:
```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount SolidApm::Engine => "/solid_apm"
end
```

Configure the database connection:
```ruby
# config/initializers/solid_apm.rb
SolidApm.connects_to = { database: { writing: :solid_apm } }
```

Install and run the migrations:
```shell
DATABASE=solid_apm bin/rails solid_apm:install:migrations
```

## Usage

Go to `http://localhost:3000/solid_apm` and start monitoring your application.

Add context

```ruby
class ApplicationController
  before_action do
    SolidApm.set_context(user_id: current_user&.id)
  end
end
```

## TODOs

### Features

- [ ] Better handle subscribing to ActiveSupport notifications

### Interface

- [ ] Paginate transactions list
- [ ] Allow date range transactions index

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
