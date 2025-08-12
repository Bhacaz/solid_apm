RSpec.describe 'Time Range Selection', type: :request do
  before do
    # Create test data with correct Transaction attributes
    [
      { name: 'HomeController#index', timestamp: 5.minutes.ago, duration: 100 },
      { name: 'UsersController#show', timestamp: 10.minutes.ago, duration: 150 },
      { name: 'HomeController#index', timestamp: 2.hours.ago, duration: 120 },
      { name: 'HomeController#index', timestamp: 1.day.ago, duration: 80 }
    ].each do |attrs|
      SolidApm::Transaction.create!(
        uuid: SecureRandom.uuid,
        name: attrs[:name],
        timestamp: attrs[:timestamp],
        end_time: attrs[:timestamp] + (attrs[:duration] / 1000.0).seconds,
        duration: attrs[:duration],
        type: 'web',
        metadata: {}
      )
    end
  end

  context 'Quick time range selection' do
    it 'handles all quick range options' do
      %w[5m 15m 30m 1h 3h 6h 12h 24h 3d 7d].each do |range|
        get '/solid_apm/transactions', params: { quick_range: range }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('value="' + range + '"')
      end
    end

    it 'auto-applies quick range selection' do
      get '/solid_apm/transactions', params: { quick_range_apply: '1h' }
      expect(response).to have_http_status(:success)
    end
  end

  context 'Custom relative time range' do
    it 'handles custom from/to values' do
      get '/solid_apm/transactions', params: {
        quick_range: 'custom',
        from_value: 30,
        from_unit: 'minutes',
        to_value: 5,
        to_unit: 'minutes'
      }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('value="30"')
      expect(response.body).to include('value="custom"')
    end

    it 'defaults missing custom values' do
      get '/solid_apm/transactions', params: {
        from_value: 45,
        from_unit: 'minutes'
      }
      expect(response).to have_http_status(:success)
    end
  end

  context 'Absolute time range' do
    it 'handles timestamp parameters with browser timezone' do
      from_time = 2.hours.ago
      to_time = Time.current

      get '/solid_apm/transactions', params: {
        from_timestamp: from_time.to_i,
        to_timestamp: to_time.to_i,
        browser_timezone: 'America/New_York'
      }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('timezone-indicator')
    end

    it 'validates time range order' do
      from_time = Time.current
      to_time = 2.hours.ago

      get '/solid_apm/transactions', params: {
        from_timestamp: from_time.to_i,
        to_timestamp: to_time.to_i
      }
      expect(response).to redirect_to('/solid_apm/transactions')
      follow_redirect!
      expect(response.body).to include('Invalid time range')
    end
  end

  context 'Timezone functionality' do
    it 'accepts browser timezone parameter' do
      get '/solid_apm/transactions', params: {
        quick_range: '1h',
        browser_timezone: 'America/Los_Angeles'
      }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('timezone-indicator')
    end

    it 'includes timezone information in absolute mode' do
      get '/solid_apm/transactions', params: {
        from_timestamp: 2.hours.ago.to_i,
        to_timestamp: Time.current.to_i,
        browser_timezone: 'Europe/London'
      }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('from-timezone-label')
      expect(response.body).to include('to-timezone-label')
    end
  end

  context 'Time range calculation logic' do
    let(:controller) { SolidApm::TransactionsController.new }

    it 'calculates relative ranges correctly' do
      controller.params = ActionController::Parameters.new(quick_range: '1h')
      range = controller.send(:from_to_range)

      expect(range.begin).to be_within(1.minute).of(1.hour.ago)
      expect(range.end).to be_within(1.minute).of(Time.current)
    end

    it 'calculates custom relative ranges correctly' do
      controller.params = ActionController::Parameters.new(
        from_value: '30',
        from_unit: 'minutes',
        to_value: '5',
        to_unit: 'minutes'
      )
      range = controller.send(:from_to_range)

      expect(range.begin).to be_within(1.minute).of(30.minutes.ago)
      expect(range.end).to be_within(1.minute).of(5.minutes.ago)
    end

    it 'calculates absolute ranges with timezone correctly' do
      from_time = 2.hours.ago
      to_time = Time.current

      controller.params = ActionController::Parameters.new(
        from_timestamp: from_time.to_i.to_s,
        to_timestamp: to_time.to_i.to_s,
        browser_timezone: 'America/New_York'
      )
      range = controller.send(:from_to_range)

      expect(range.begin).to be_within(1.second).of(from_time)
      expect(range.end).to be_within(1.second).of(to_time)
    end

    it 'provides default range when no parameters' do
      controller.params = ActionController::Parameters.new
      range = controller.send(:from_to_range)

      expect(range.begin).to be_within(1.minute).of(1.hour.ago)
      expect(range.end).to be_within(1.minute).of(Time.current)
    end
  end

  context 'Form state rendering' do
    it 'shows relative mode by default' do
      get '/solid_apm/transactions'
      expect(response.body).to include('is-primary')
      expect(response.body).to include('relative-tab')
    end

    it 'shows absolute mode when timestamps present' do
      get '/solid_apm/transactions', params: {
        from_timestamp: 2.hours.ago.to_i,
        to_timestamp: Time.current.to_i
      }
      expect(response.body).to include('absolute-tab')
    end

    it 'includes timezone indicator in form' do
      get '/solid_apm/transactions'
      expect(response.body).to include('timezone-indicator')
      expect(response.body).to include('timezone-display')
    end
  end
end
