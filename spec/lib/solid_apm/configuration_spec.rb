# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SolidApm configuration' do
  describe '.enabled' do
    it 'is disabled in test environment' do
      # SolidAPM is always disabled in test to prevent pollution
      expect(SolidApm.enabled).to be false
    end

    it 'can be set to false' do
      original = SolidApm.enabled
      SolidApm.enabled = false
      expect(SolidApm.enabled).to be false
      SolidApm.enabled = original
    end
  end
end
