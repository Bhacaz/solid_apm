class Transaction < ApplicationRecord
  self.inheritance_column = :_type_disabled
  has_many :spans, -> { order(:sequence) }, foreign_key: 'transaction_id', dependent: :delete_all
end
