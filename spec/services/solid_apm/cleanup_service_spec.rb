# frozen_string_literal: true

RSpec.describe SolidApm::CleanupService do
  before do
    # Clear any existing transactions
    SolidApm::Transaction.delete_all
  end

  describe '#call' do
    describe 'with default parameter (1.month.ago)' do
      it 'deletes transactions older than 1 month' do
        # Create transactions at different times
        old_transaction = SolidApm::Transaction.create!(
          uuid: SecureRandom.uuid,
          name: 'old_transaction',
          type: 'request',
          timestamp: 2.months.ago,
          end_time: 2.months.ago + 0.1.seconds,
          duration: 100.0
        )
        recent_transaction = SolidApm::Transaction.create!(
          uuid: SecureRandom.uuid,
          name: 'recent_transaction',
          type: 'request',
          timestamp: 1.week.ago,
          end_time: 1.week.ago + 0.05.seconds,
          duration: 50.0
        )

        service = described_class.new
        result = service.call

        expect(result[:deleted_count]).to eq(1)
        expect(result[:older_than]).to eq('1.month.ago')
        expect(result[:cutoff_time]).to be_within(1.minute).of(1.month.ago)

        expect(SolidApm::Transaction.exists?(old_transaction.id)).to be false
        expect(SolidApm::Transaction.exists?(recent_transaction.id)).to be true
      end
    end

    describe 'with custom time parameter' do
      it 'deletes transactions older than 1 week when passed 1.week.ago' do
        old_transaction = SolidApm::Transaction.create!(
          uuid: SecureRandom.uuid,
          name: 'old_transaction',
          type: 'request',
          timestamp: 2.weeks.ago,
          end_time: 2.weeks.ago + 0.1.seconds,
          duration: 100.0
        )
        recent_transaction = SolidApm::Transaction.create!(
          uuid: SecureRandom.uuid,
          name: 'recent_transaction',
          type: 'request',
          timestamp: 3.days.ago,
          end_time: 3.days.ago + 0.05.seconds,
          duration: 50.0
        )

        service = described_class.new(older_than: '1.week.ago')
        result = service.call

        expect(result[:deleted_count]).to eq(1)
        expect(result[:older_than]).to eq('1.week.ago')
        expect(result[:cutoff_time]).to be_within(1.minute).of(1.week.ago)

        expect(SolidApm::Transaction.exists?(old_transaction.id)).to be false
        expect(SolidApm::Transaction.exists?(recent_transaction.id)).to be true
      end

      it 'deletes transactions older than 2 days when passed 2.days.ago' do
        old_transaction = SolidApm::Transaction.create!(
          uuid: SecureRandom.uuid,
          name: 'old_transaction',
          type: 'request',
          timestamp: 1.week.ago,
          end_time: 1.week.ago + 0.1.seconds,
          duration: 100.0
        )
        recent_transaction = SolidApm::Transaction.create!(
          uuid: SecureRandom.uuid,
          name: 'recent_transaction',
          type: 'request',
          timestamp: 1.day.ago,
          end_time: 1.day.ago + 0.05.seconds,
          duration: 50.0
        )

        service = described_class.new(older_than: '2.days.ago')
        result = service.call

        expect(result[:deleted_count]).to eq(1)
        expect(result[:older_than]).to eq('2.days.ago')

        expect(SolidApm::Transaction.exists?(old_transaction.id)).to be false
        expect(SolidApm::Transaction.exists?(recent_transaction.id)).to be true
      end
    end

    describe 'with various time units' do
      before do
        # Create a transaction that's old enough for all our tests
        @old_transaction = SolidApm::Transaction.create!(
          uuid: SecureRandom.uuid,
          name: 'old_transaction',
          type: 'request',
          timestamp: 1.year.ago,
          end_time: 1.year.ago + 0.1.seconds,
          duration: 100.0
        )
      end

      it 'works with seconds' do
        service = described_class.new(older_than: '30.seconds.ago')
        result = service.call
        expect(result[:deleted_count]).to eq(1)
      end

      it 'works with minutes' do
        service = described_class.new(older_than: '30.minutes.ago')
        result = service.call
        expect(result[:deleted_count]).to eq(1)
      end

      it 'works with hours' do
        service = described_class.new(older_than: '2.hours.ago')
        result = service.call
        expect(result[:deleted_count]).to eq(1)
      end

      it 'works with singular units' do
        service = described_class.new(older_than: '1.day.ago')
        result = service.call
        expect(result[:deleted_count]).to eq(1)
      end

      it 'works with plural units' do
        service = described_class.new(older_than: '30.days.ago')
        result = service.call
        expect(result[:deleted_count]).to eq(1)
      end

      it 'works with months' do
        service = described_class.new(older_than: '2.months.ago')
        result = service.call
        expect(result[:deleted_count]).to eq(1)
      end

      it 'works with years' do
        service = described_class.new(older_than: '1.year.ago')
        result = service.call
        expect(result[:deleted_count]).to eq(1)
      end
    end

    describe 'error handling' do
      it 'raises error for invalid time format' do
        service = described_class.new(older_than: 'invalid_format')
        expect { service.call }.to raise_error(ArgumentError, 'Invalid time expression format')
      end

      it 'raises error for unsafe expressions' do
        service = described_class.new(older_than: 'system("rm -rf /")')
        expect { service.call }.to raise_error(ArgumentError, 'Invalid time expression format')
      end

      it 'raises error for eval-like expressions' do
        service = described_class.new(older_than: '1.week.ago; puts "hacked"')
        expect { service.call }.to raise_error(ArgumentError, 'Invalid time expression format')
      end

      it 'raises error for missing time unit' do
        service = described_class.new(older_than: '1.ago')
        expect { service.call }.to raise_error(ArgumentError, 'Invalid time expression format')
      end

      it 'raises error for invalid time unit' do
        service = described_class.new(older_than: '1.century.ago')
        expect { service.call }.to raise_error(ArgumentError, 'Invalid time expression format')
      end
    end

    describe 'when no transactions match' do
      it 'reports 0 deletions' do
        # Create only recent transactions
        SolidApm::Transaction.create!(
          uuid: SecureRandom.uuid,
          name: 'recent_transaction',
          type: 'request',
          timestamp: 1.hour.ago,
          end_time: 1.hour.ago + 0.05.seconds,
          duration: 50.0
        )

        service = described_class.new(older_than: '1.week.ago')
        result = service.call

        expect(result[:deleted_count]).to eq(0)
        expect(result[:older_than]).to eq('1.week.ago')
      end
    end

    describe 'cascading deletes' do
      it 'deletes associated spans when transaction is deleted' do
        transaction = SolidApm::Transaction.create!(
          uuid: SecureRandom.uuid,
          name: 'old_transaction',
          type: 'request',
          timestamp: 2.months.ago,
          end_time: 2.months.ago + 0.1.seconds,
          duration: 100.0
        )

        span = SolidApm::Span.create!(
          transaction_id: transaction.id,
          uuid: SecureRandom.uuid,
          name: 'test_span',
          sequence: 1,
          timestamp: 2.months.ago,
          duration: 100.0
        )

        service = described_class.new(older_than: '1.month.ago')
        result = service.call

        expect(result[:deleted_count]).to eq(1)
        expect(SolidApm::Transaction.exists?(transaction.id)).to be false
        expect(SolidApm::Span.exists?(span.id)).to be false
      end
    end
  end
end
