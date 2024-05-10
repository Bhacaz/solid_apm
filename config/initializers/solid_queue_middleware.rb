# frozen_string_literal: true

# Not start with `!`
ActiveSupport::Notifications.subscribe(/^\w+\.action_view/) do |name, start, finish, id, payload|
  # pp name
  # pp payload.first(3)
  identifier = payload[:identifier]
  # relative to Rails.root
  identifier = identifier.sub(Rails.root.to_s + '/', '')

  transaction = ApplicationController.transaction

  # p transaction
  # pp caller
  next unless transaction

  parent_id = ApplicationController.spans.last&.dig(:id)
  subtype, type = name.split('.')
  # pp payload[:sql]
  span = {
    uuid: SecureRandom.uuid,
    # related_transaction: transaction,
    parent_id: parent_id,
    sequence: ApplicationController.spans.size + 1,
    timestamp: start,
    end_time: finish,
    duration: (finish.to_f - start.to_f).round(6),
    name: name,
    type: type,
    subtype: subtype,
    summary: identifier,
  }

  ApplicationController.spans << span
end

ActiveSupport::Notifications.subscribe("sql.active_record") do |name, start, finish, id, payload|
  # p name
  transaction = ApplicationController.transaction
  # p transaction
  # pp caller
  next unless transaction

  parent_id = ApplicationController.spans.last&.dig(:id)
  subtype, type = name.split('.')
  # pp payload[:sql]
  span = {
    uuid: SecureRandom.uuid,
    # related_transaction: transaction,
    parent_id: parent_id,
    sequence: ApplicationController.spans.size + 1,
    timestamp: start,
    end_time: finish,
    duration: (finish.to_f - start.to_f).round(6),
    name: name,
    type: type,
    subtype: subtype,
    summary: payload[:sql],
  }

  ApplicationController.spans << span
end
