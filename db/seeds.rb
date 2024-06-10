# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# transaction = Transaction.create!(
#   timestamp: Time.current,
#   type: 'request',
#   name: 'Home#index',
#   metadata: { status: 200 },
#   end_time: Time.current + 1.second,
#   duration: 1.second,
#   uuid: SecureRandom.uuid
# )
#
# span = Span.create!(
#   uuid: SecureRandom.uuid,
#   related_transaction: transaction,
#   parent_id: nil,
#   sequence: 1,
#   timestamp: Time.current,
#   name: 'sql.active_record',
#   type: 'active_record',
#   subtype: 'sql',
#   end_time: Time.current + 1.second,
#   duration: 1.second,
#   caller: ["app/models/user.rb:123:in `find_by_email'"]
# )
#
