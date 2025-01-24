class External::Airtable::SyncJob < ApplicationJob
  queue_as :default
  retry_on Airrecord::Error, wait: 5.seconds, attempts: 3

  def perform(user_id)
    ActiveSupport::TaggedLogging.new(Rails.logger).tagged("AirtableSync") do |tagged_logger|
      begin
        user = User.find(user_id)
        result = External::Airtable::UserRecord.create_from_user(user)
      rescue => e
        puts "Failed to sync user #{user_id}: #{e.message}"
        puts e.backtrace.join("\n")
        raise
      end
    end
  end
end
