namespace :solid_apm do
  desc 'Delete old transactions (default: older than 1 month). Usage: rake solid_apm:cleanup[1.week.ago]'
  task :cleanup, [:older_than] => :environment do |_task, args|
    older_than = args[:older_than] || '1.month.ago'

    begin
      result = SolidApm::CleanupService.new(older_than: older_than).call

      puts "Deleting transactions older than #{result[:cutoff_time]}..."
      puts "Deleted #{result[:deleted_count]} transactions"
    rescue StandardError => e
      puts "Error: #{e.message}"
      puts "Please provide a valid time expression like '1.week.ago', '2.months.ago', etc."
      puts 'Supported formats: [number].[unit].ago where unit is: second(s), minute(s), hour(s), day(s), week(s), month(s), year(s)'
      exit 1
    end
  end
end
