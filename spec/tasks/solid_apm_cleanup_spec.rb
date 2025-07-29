# frozen_string_literal: true

require 'rake'

RSpec.describe 'solid_apm:cleanup rake task' do
  before do
    # Load rake tasks
    Rails.application.load_tasks if Rake::Task.tasks.empty?

    # Clear any existing transactions
    SolidApm::Transaction.delete_all
  end

  let(:task) { Rake::Task['solid_apm:cleanup'] }

  before do
    task.reenable
  end

  describe 'with default parameter (1.month.ago)' do
    it 'uses the cleanup service and outputs results' do
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

      expect { task.invoke }.to output(/Deleted 1 transactions/).to_stdout

      expect(SolidApm::Transaction.exists?(old_transaction.id)).to be false
      expect(SolidApm::Transaction.exists?(recent_transaction.id)).to be true
    end
  end

  describe 'with custom time parameter' do
    it 'uses the cleanup service with custom parameter' do
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

      expect { task.invoke('1.week.ago') }.to output(/Deleted 1 transactions/).to_stdout

      expect(SolidApm::Transaction.exists?(old_transaction.id)).to be false
      expect(SolidApm::Transaction.exists?(recent_transaction.id)).to be true
    end
  end

  describe 'error handling' do
    it 'exits with error for invalid time format' do
      expect { task.invoke('invalid_format') }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'shows helpful error message for invalid format' do
      expect do
        task.invoke('invalid_format')
      rescue SystemExit
        # Ignore the exit, we just want to check the output
      end.to output(/Error: Invalid time expression format/).to_stdout
    end

    it 'shows supported formats in error message' do
      expect do
        task.invoke('invalid_format')
      rescue SystemExit
        # Ignore the exit, we just want to check the output
      end.to output(/Supported formats: \[number\]\.\[unit\]\.ago/).to_stdout
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

      expect { task.invoke('1.week.ago') }.to output(/Deleted 0 transactions/).to_stdout
    end
  end
end
