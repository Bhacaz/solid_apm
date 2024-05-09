class Transaction < ApplicationRecord
  self.inheritance_column = :_type_disabled
  has_many :spans, foreign_key: 'transaction_id'
end
