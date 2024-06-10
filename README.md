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

## TODOs

### Features

- [ ] Ignore `/solid_apm` requests
- [ ] Better handle subscribing to ActiveSupport notifications
- [ ] Add methods to add context to the transaction (i.e. `SolidApm.add_context(user_id: 1)`)

### Interface

- [ ] Paginate transactions list
- [ ] Allow date range transactions index
- [ ] Display transaction as aggregated data with avg latency, tpm and impact (Relative Avg. duration * transactions per minute)

## Notes

https://apexcharts.com/javascript-chart-demos/timeline-charts/advanced

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
