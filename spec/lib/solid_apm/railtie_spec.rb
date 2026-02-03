# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolidApm::Railtie do
  describe 'test environment auto-disable' do
    it 'is disabled in test environment' do
      # Railtie always disables in test environment
      expect(Rails.env.test?).to be true
      expect(SolidApm.enabled).to be false
    end
  end
end
