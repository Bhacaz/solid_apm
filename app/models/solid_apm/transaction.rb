module SolidApm
  class Transaction < ApplicationRecord
    self.inheritance_column = :_type_disabled
    has_many :spans, -> { order(:timestamp, :sequence) }, foreign_key: 'transaction_id', dependent: :delete_all

    attribute :uuid, :string, default: -> { SecureRandom.uuid }

    def self.metadata_filter
      @metadata_filter ||= ActiveSupport::ParameterFilter
                             .new(Rails.application.config.filter_parameters)
    end

    def metadata=(value = {})
      super(self.class.metadata_filter.filter(value))
    end
  end
end
