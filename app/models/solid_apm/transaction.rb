module SolidApm
  class Transaction < ApplicationRecord
    self.inheritance_column = :_type_disabled
    has_many :spans, -> { order(:timestamp, :sequence) }, foreign_key: 'transaction_id', dependent: :delete_all

    attribute :uuid, :string, default: -> { SecureRandom.uuid }
  end
end
