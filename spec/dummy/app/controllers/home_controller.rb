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
    ActiveSupport::Notifications.instrument("request.net_http", 'GET https://example.com') do
      sleep 0.1
    end
    redirect_to home_path
  end
end
