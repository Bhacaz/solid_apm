module SolidApm
  class Span < ApplicationRecord
    self.inheritance_column = :_type_disabled
    belongs_to :related_transaction, class_name: 'SolidApm::Transaction', foreign_key: 'transaction_id'
    # belongs_to :parent, class_name: 'Span', optional: true

    attribute :uuid, :string, default: -> { SecureRandom.uuid }
  end
end
