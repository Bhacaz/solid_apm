# frozen_string_literal: true

class HomeController < ApplicationController
  def index

  end

  def span
    # now = Time.current
    # ActiveSupport::Notifications.publish("sql.active_record", now, (now + 1.seconds), 1, { sql: "SELECT * FROM users" })
    ActiveSupport::Notifications.instrument("sql.active_record", sql: "SELECT * FROM users") do
      sleep 0.1
    end
    require 'net/http'
    uri = URI('https://google.ca')
    Net::HTTP.get_response(uri)
    redirect_to home_path
  end

  def generate_n_plus_one
    @transactions = SolidApm::Transaction.last(100)
    @transactions.each do |transaction|
      transaction.spans.each do |span|
        span.name
      end
    end
    redirect_to home_path
  end
end
