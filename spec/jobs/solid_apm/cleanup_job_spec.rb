# frozen_string_literal: true

RSpec.describe SolidApm::CleanupJob do
  before do
    # Clear any existing transactions
    SolidApm::Transaction.delete_all
  end

  describe '#perform' do
    it 'calls the cleanup service with default parameter' do
      # Create old transaction
      old_transaction = SolidApm::Transaction.create!(
        uuid: SecureRandom.uuid,
        name: 'old_transaction',
        type: 'request',
        timestamp: 2.months.ago,
        end_time: 2.months.ago + 0.1.seconds,
        duration: 100.0
      )

      result = described_class.new.perform

      expect(result[:deleted_count]).to eq(1)
      expect(result[:older_than]).to eq('1.month.ago')
      expect(SolidApm::Transaction.exists?(old_transaction.id)).to be false
    end

    it 'calls the cleanup service with custom parameter' do
      # Create old transaction
      old_transaction = SolidApm::Transaction.create!(
        uuid: SecureRandom.uuid,
        name: 'old_transaction',
        type: 'request',
        timestamp: 2.weeks.ago,
        end_time: 2.weeks.ago + 0.1.seconds,
        duration: 100.0
      )

      result = described_class.new.perform('1.week.ago')

      expect(result[:deleted_count]).to eq(1)
      expect(result[:older_than]).to eq('1.week.ago')
      expect(SolidApm::Transaction.exists?(old_transaction.id)).to be false
    end

    it 'logs the cleanup result' do
      # Create old transaction
      SolidApm::Transaction.create!(
        uuid: SecureRandom.uuid,
        name: 'old_transaction',
        type: 'request',
        timestamp: 2.months.ago,
        end_time: 2.months.ago + 0.1.seconds,
        duration: 100.0
      )

      expect(Rails.logger).to receive(:info).with(/SolidApm::CleanupJob completed: deleted 1 transactions/)

      described_class.new.perform
    end

    it 'propagates service errors' do
      expect do
        described_class.new.perform('invalid_format')
      end.to raise_error(ArgumentError, 'Invalid time expression format')
    end
  end
end
