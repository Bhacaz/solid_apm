# frozen_string_literal: true

RSpec.describe SolidApm::Middleware do
  describe '.transaction_filtered?' do
    before do
      SolidApm.transaction_filters = []
    end

    after do
      SolidApm.transaction_filters = []
    end

    context 'with no filters configured' do
      it 'returns false' do
        expect(described_class.transaction_filtered?('HomeController#index')).to be false
      end
    end

    context 'with string filters' do
      before do
        SolidApm.transaction_filters = ['HomeController#index', 'HealthController#ping']
      end

      it 'filters exact string matches' do
        expect(described_class.transaction_filtered?('HomeController#index')).to be true
        expect(described_class.transaction_filtered?('HealthController#ping')).to be true
      end

      it 'does not filter non-matching strings' do
        expect(described_class.transaction_filtered?('UsersController#show')).to be false
        expect(described_class.transaction_filtered?('HomeController#show')).to be false
      end
    end

    context 'with regex filters' do
      before do
        SolidApm.transaction_filters = [/^Health/, /Controller#ping$/]
      end

      it 'filters regex matches' do
        expect(described_class.transaction_filtered?('HealthController#index')).to be true
        expect(described_class.transaction_filtered?('HealthController#ping')).to be true
        expect(described_class.transaction_filtered?('StatusController#ping')).to be true
      end

      it 'does not filter non-matching patterns' do
        expect(described_class.transaction_filtered?('HomeController#index')).to be false
        expect(described_class.transaction_filtered?('UserController#show')).to be false
      end
    end

    context 'with mixed string and regex filters' do
      before do
        SolidApm.transaction_filters = ['HomeController#index', /^Health/]
      end

      it 'filters both string and regex matches' do
        expect(described_class.transaction_filtered?('HomeController#index')).to be true
        expect(described_class.transaction_filtered?('HealthController#ping')).to be true
      end

      it 'does not filter non-matches' do
        expect(described_class.transaction_filtered?('UsersController#show')).to be false
      end
    end

    context 'with invalid filter types' do
      before do
        SolidApm.transaction_filters = [123, nil, true]
      end

      it 'does not filter for invalid types' do
        expect(described_class.transaction_filtered?('HomeController#index')).to be false
      end
    end
  end
end